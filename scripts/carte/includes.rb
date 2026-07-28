# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  PASSE 2 : LE GRAPHE DES INCLUDES, ET LE CONTRAT DE LEURS PARAMETRES
# ══════════════════════════════════════════════════════════════════════════
#
# Le graphe seul est peu utile : 30 includes sans orphelin, on le sait. Ce qui
# se perd vraiment, c'est le CONTRAT : ce qu'un appelant passe contre ce que
# l'include lit. Les deux derivent en silence, parce qu'un parametre passe et
# jamais lu ne casse rien et qu'un parametre lu et jamais passe rend nil.
#
# ⚠️ ET UN INCLUDE PEUT MARCHER SANS SES PARAMETRES, ce qui est le piege.
# `_includes/services/subservices-card.html` recoit `service_item=...` et
# `current_lang=...` mais lit `{{ service_item.nom[current_lang] }}`, c'est-a-dire
# des variables NUES et non `include.service_item`. Ca fonctionne uniquement
# parce que Jekyll ne cloisonne pas la portee : les variables de la boucle de
# l'appelant fuient dans l'include. Les deux parametres passes sont donc
# formellement morts, et l'include ne marche que par accident de portee.
# La carte doit voir ce cas, pas le rater.

module Carte
  class Includes
    # La meme regexp que `Jekyll::Tags::IncludeTag::VALID_SYNTAX`, pour decouper
    # les parametres exactement comme le build les decoupe.
    SYNTAXE = /([\w-]+)\s*=\s*(?:"[^"\\]*(?:\\.[^"\\]*)*"|'[^'\\]*(?:\\.[^'\\]*)*'|[\w.-]+)/

    attr_reader :appels, :lus, :graphe, :anomalies

    def initialize(couverture)
      @couverture = couverture
      @appels     = []  # { depuis:, vers:, params: [] }
      @lus        = {}  # include => [params lus]
      @anomalies  = []
      analyser
      confronter
    end

    def appelants(fichier) = @appels.select { |a| a[:vers] == fichier }.map { |a| a[:depuis] }.uniq
    def appeles(fichier)   = @appels.select { |a| a[:depuis] == fichier }.map { |a| a[:vers] }.uniq

    def orphelins
      tous = Carte.fichiers("_includes/**/*.html").map { |f| Carte.relatif(f).delete_prefix("_includes/") }
      tous.reject { |i| @appels.any? { |a| a[:vers] == i } }
    end

    def profondeur_max
      racines = ["_layouts/default.html"]
      max = 0
      marche = lambda do |nœud, d, vus|
        max = d if d > max
        return if vus.include?(nœud) || d > 12

        appeles(nœud).each { |e| marche.call(e, d + 1, vus + [nœud]) }
      end
      racines.each { |r| marche.call(r, 0, []) }
      max
    end

    private

    def sources
      Carte.fichiers("_includes/**/*.html") +
        Carte.fichiers("_layouts/*.html") +
        Carte.fichiers("**/*.html").reject { |f| Carte.relatif(f).start_with?("_includes/", "_layouts/") }
    end

    def analyser
      sources.uniq.each do |f|
        rel  = Carte.relatif(f)
        nom  = rel.start_with?("_includes/") ? rel.delete_prefix("_includes/") : rel
        brut = Carte.lire(f)
        # Le front matter n'est pas du Liquid : on le remplace par des lignes
        # vides pour garder les numeros de ligne justes.
        corps = brut.sub(/\A---.*?^---\s*$/m) { |m| Carte.blanchir(m) }
        propre = Carte.sans_commentaires_html(corps)

        arbre = begin
          Liquid::Template.parse(propre)
        rescue Liquid::Error => e
          @couverture.indetermine("liquid", rel, "parse impossible : #{e.message[0, 60]}")
          next
        end

        Carte.parcourir(arbre.root) do |n|
          next unless n.is_a?(Liquid::Tag)
          next unless n.class.name.to_s.include?("IncludeTag")

          cible = n.instance_variable_get(:@file).to_s
          params = n.instance_variable_get(:@params).to_s.scan(SYNTAXE).flatten

          # ⚠️ UN INCLUDE DYNAMIQUE N'EST PAS RESOLVABLE, et la carte doit le
          # DIRE plutot que de l'omettre. Il n'y en a aucun aujourd'hui ; le
          # controle existe pour le jour ou il y en aura un, sans quoi le graphe
          # deviendrait faux en silence.
          if cible.include?("{{") || cible.include?("{%")
            @couverture.indetermine("include dynamique", rel, "cible calculee : #{cible}")
            next
          end

          @appels << { depuis: nom, vers: cible, params: params }
        end

        # Les parametres REELLEMENT lus. Une regexp et non l'AST, a dessein :
        # `include.x` apparait aussi dans des arguments de filtre et dans des
        # conditions imbriquees, ou la marche d'AST devrait connaitre chaque
        # forme de nœud. Le nom d'un parametre est toujours un identifiant
        # litteral, donc la regexp ne peut pas se tromper sur ce point precis.
        next unless rel.start_with?("_includes/")

        @lus[nom] = propre.scan(/include\.([a-zA-Z_][\w-]*)/).flatten.uniq.sort
      end
    end

    def confronter
      passes_jamais_lus = []
      lus_jamais_passes = []

      @lus.each do |inc, lus|
        appels = @appels.select { |a| a[:vers] == inc }
        next if appels.empty?

        tous_passes = appels.flat_map { |a| a[:params] }.uniq

        (tous_passes - lus).sort.each do |p|
          ou = appels.select { |a| a[:params].include?(p) }.map { |a| a[:depuis] }.uniq
          passes_jamais_lus << { include: inc, param: p, depuis: ou }
        end

        # Un parametre lu par tous les appelants sauf certains : c'est le cas
        # normal (valeur par defaut). Celui qui compte est le parametre que
        # PERSONNE ne passe.
        (lus - tous_passes).sort.each do |p|
          lus_jamais_passes << { include: inc, param: p }
        end
      end

      unless passes_jamais_lus.empty?
        @anomalies << {
          titre: "Parametres passes a un include qui ne les lit jamais",
          detail: "L'include marche quand meme s'il lit la variable NUE : les portees fuient en Liquid.",
          cas: passes_jamais_lus.map { |c| "#{c[:include]} <- #{c[:param]} (depuis #{c[:depuis].join(', ')})" }
        }
      end

      return if lus_jamais_passes.empty?

      @anomalies << {
        titre: "Parametres lus par un include que personne ne passe",
        detail: "Chacun rend nil. Legitime s'il a une valeur par defaut, a verifier sinon.",
        cas: lus_jamais_passes.map { |c| "#{c[:include]} lit include.#{c[:param]}" }
      }
    end
  end
end
