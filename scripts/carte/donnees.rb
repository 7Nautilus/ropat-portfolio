# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  PASSE 3 : LES DONNEES, ET CE QUE LES GABARITS EN LISENT VRAIMENT
# ══════════════════════════════════════════════════════════════════════════
#
# Deux questions distinctes, et la seconde est la plus utile :
#
#  1. Quelles cles sont DEFINIES et jamais lues ?
#  2. Quelles cles sont LUES mais absentes d'une partie du corpus ? C'est la que
#     vivent les defauts silencieux : `aspect` n'existe que dans une partie des
#     projets, donc les autres tombent sur une valeur par defaut que personne ne
#     voit s'appliquer.
#
# ⚠️ TROIS PIEGES ONT ETE PAYES POUR ECRIRE CETTE PASSE, et chacun produisait une
# liste de « cles mortes » qui aurait fait supprimer du code vivant.
#
#  1. LE `*` DOIT MATCHER UNE CLE CONCRETE. Les cles definies sont concretes
#     (`projects.aelio.category`), les lectures sont dynamiques
#     (`projects[slug].category`, resolu en `projects.*.category`). Compares tels
#     quels, les deux ne se rencontrent jamais : premier jet, 127 cles « mortes »
#     dont la quasi-totalite du contenu de chaque projet.
#
#  2. UN MEME NOM DESIGNE PLUSIEURS CHOSES DANS UN MEME FICHIER. Dans
#     `_includes/pages/index.html`, `item` est tour a tour un service, un
#     partenaire et un projet. Garder la derniere affectation rendait fausses les
#     deux premieres. On garde donc TOUTES les liaisons et on resout vers leur
#     UNION : en cas d'ambiguite la carte penche du cote permissif, parce que le
#     cout d'un faux « mort » (supprimer du vivant) est sans commune mesure avec
#     celui d'un faux « vivant » (ne rien signaler).
#
#  3. LES DONNEES TRAVERSENT LES INCLUDES. `project-card.html` ne lit jamais
#     `site.data` : il lit `include.project.image_src`. Une analyse fichier par
#     fichier ne voit donc RIEN de ce que lisent les trois includes qui affichent
#     l'essentiel du site. Il faut propager : resoudre l'expression du parametre
#     chez l'appelant, la lier a `include.<nom>` chez l'appele, et recommencer
#     jusqu'a ce que plus rien ne bouge.

module Carte
  class Donnees
    PARAM = /([\w-]+)\s*=\s*(?:"[^"]*"|'[^']*'|([\w.\[\]-]+))/

    attr_reader :definies, :lues, :anomalies, :ambigus

    def initialize(couverture)
      @couverture = couverture
      @definies   = {}
      @lues       = {}
      @tables     = {}   # gabarit => { nom => Set de chemins }
      @brut       = {}   # gabarit => [lookups bruts]
      @appels     = []   # { depuis:, vers:, params: { nom => expression } }
      @ambigus    = []
      @anomalies  = []
      charger_yaml
      analyser_gabarits
      propager
      resoudre_lectures
      confronter
    end

    private

    # ── Les cles definies ────────────────────────────────────────────────────
    def charger_yaml
      Carte.fichiers("_data/**/*.yml").each do |f|
        rel = Carte.relatif(f)
        prefixe = "site.data." + rel.delete_prefix("_data/").sub(/\.yml\z/, "").tr("/", ".")
        doc = begin
          YAML.safe_load(Carte.lire(f), permitted_classes: [Date, Time], aliases: true)
        rescue Psych::Exception => e
          @couverture.indetermine("yaml", rel, e.message[0, 60])
          next
        end
        aplatir(doc, prefixe) { |chemin| (@definies[chemin] ||= []) << rel }
      end
    end

    def aplatir(obj, prefixe, &bloc)
      case obj
      when Hash
        bloc.call(prefixe)
        obj.each { |k, v| aplatir(v, "#{prefixe}.#{k}", &bloc) }
      when Array
        bloc.call(prefixe)
        obj.each { |e| aplatir(e, "#{prefixe}.*", &bloc) if e.is_a?(Hash) || e.is_a?(Array) }
      else
        bloc.call(prefixe)
      end
    end

    # ── Les gabarits ─────────────────────────────────────────────────────────
    def gabarits
      (Carte.fichiers("_includes/**/*.html") + Carte.fichiers("_layouts/*.html") +
       Carte.fichiers("**/*.{html,xml}")).uniq
    end

    # Un include se designe par son chemin sous `_includes/`, tout le reste par
    # son chemin relatif au depot. Les deux doivent se rencontrer dans le graphe.
    def cle(rel) = rel.start_with?("_includes/") ? rel.delete_prefix("_includes/") : rel

    def analyser_gabarits
      gabarits.each do |f|
        rel    = Carte.relatif(f)
        nom    = cle(rel)
        corps  = Carte.lire(f).sub(/\A---.*?^---\s*$/m) { |m| Carte.blanchir(m) }
        propre = Carte.sans_commentaires_html(corps)

        arbre = begin
          Liquid::Template.parse(propre)
        rescue Liquid::Error => e
          @couverture.indetermine("liquid", rel, e.message[0, 60])
          next
        end

        table = Hash.new { |h, k| h[k] = Set.new }
        Carte.parcourir(arbre.root) do |n|
          case n
          when Liquid::Assign
            cible = n.instance_variable_get(:@to).to_s
            depuis = n.instance_variable_get(:@from)
            src = Carte.chaine_lookup(depuis)
            table[cible] << src if src
            # `{% assign pieces = pieces | concat: project.thumbnails %}` lie
            # aussi `pieces` a `project.thumbnails`. Sans cette ligne, tout ce
            # qu'on lit ensuite sur les elements de `pieces` se perd, et les
            # vignettes de huit projets passent pour mortes.
            Carte.args_de_filtres(depuis).each { |a| table[cible] << a }
          when Liquid::For
            cible = n.instance_variable_get(:@variable_name).to_s
            src   = Carte.chaine_lookup(n.instance_variable_get(:@collection_name))
            table[cible] << "#{src}.*" if src
          end
          next unless n.is_a?(Liquid::Tag) && n.class.name.to_s.include?("IncludeTag")

          fichier = n.instance_variable_get(:@file).to_s
          next if fichier.include?("{{")

          # Seules les valeurs NUES transportent une donnee : une chaine entre
          # guillemets est une constante, elle ne relie rien.
          params = {}
          n.instance_variable_get(:@params).to_s.scan(PARAM) do |k, nue|
            params[k] = nue if nue
          end
          @appels << { depuis: nom, vers: fichier, params: params }
        end

        @tables[nom] = table
        @brut[nom]   = Carte.lookups(arbre.root)
        table.each { |k, v| @ambigus << "#{rel} : `#{k}` a #{v.size} liaisons" if v.size > 1 }
      end
    end

    # ── La propagation a travers les includes ────────────────────────────────
    #
    # La profondeur du graphe est de 4, donc six tours suffisent largement et
    # bornent le cas ou un cycle apparaitrait un jour.
    def propager
      6.times do
        change = false
        @appels.each do |a|
          appelant = @tables[a[:depuis]] || {}
          appele   = (@tables[a[:vers]] ||= Hash.new { |h, k| h[k] = Set.new })

          a[:params].each do |nom, expression|
            resolus = developper(expression, appelant)
            next if resolus.empty?

            avant = appele["include.#{nom}"].size
            resolus.each { |r| appele["include.#{nom}"] << r }
            change = true if appele["include.#{nom}"].size != avant
          end
        end
        break unless change
      end
    end

    # Developpe un chemin en suivant les liaisons connues, en rendant TOUTES les
    # possibilites. On cherche le plus LONG prefixe connu, pour que
    # `include.project` l'emporte sur `include`.
    def developper(chemin, table, profondeur = 0)
      return [] if chemin.nil? || profondeur > 6

      chemin = chemin.gsub(/\[[^\]]*\]/, ".*")
      bouts  = chemin.split(".")

      bouts.size.downto(1) do |n|
        prefixe = bouts[0, n].join(".")
        sources = table[prefixe] if table.key?(prefixe)
        next if sources.nil? || sources.empty?

        reste = bouts[n..].to_a
        return sources.flat_map { |s| developper(([s] + reste).join("."), table, profondeur + 1) }.uniq
      end

      chemin.start_with?("site.data.") ? [chemin] : []
    end

    def resoudre_lectures
      @brut.each do |nom, lookups|
        table = @tables[nom] || {}
        lookups.each { |l| developper(l, table).each { |r| (@lues[r] ||= []) << nom } }
      end
    end

    # ── Confrontations ───────────────────────────────────────────────────────

    # Le `*` d'une LECTURE matche n'importe quel segment d'une cle definie.
    def correspond?(lue, definie)
      return false if lue.size < definie.size

      definie.each_with_index { |seg, i| return false unless lue[i] == seg || lue[i] == "*" }
      true
    end

    def confronter
      lues = @lues.keys.map { |l| l.split(".") }

      mortes = @definies.keys.reject do |c|
        segs = c.split(".")
        lues.any? { |l| correspond?(l, segs) }
      end
      ensemble = mortes.to_set
      mortes = mortes.reject { |c| c.include?(".") && ensemble.include?(c[0...c.rindex('.')]) }

      unless mortes.empty?
        # On regroupe les cles qui ne different que par le fichier de donnees :
        # « `discipline` dans 8 projets » se lit, huit lignes separees non.
        groupes = Hash.new { |h, k| h[k] = [] }
        mortes.each do |c|
          segs = c.split(".")
          if %w[projects services].include?(segs[2]) && segs.size > 3
            suite = segs[4..]
            groupes[(%w[site data] + [segs[2], "*"] + Array(suite)).join(".")] << segs[3]
          else
            groupes[c] << nil
          end
        end
        @anomalies << {
          titre: "Cles de donnees definies, aucun gabarit ne les lit",
          detail: "Aucun chemin resolu ne les atteint, propagation a travers les parametres d'include comprise.",
          cas: groupes.sort.map do |chemin, fichiers|
            noms = fichiers.compact.sort
            noms.empty? ? chemin : "#{chemin}   (#{noms.size} : #{noms.join(', ')})"
          end
        }
      end

      couverture_corpus
    end

    def couverture_corpus
      { "_data/projects/" => %w[index categories], "_data/services/" => %w[index] }.each do |dossier, sauf|
        fichiers = Carte.fichiers("#{dossier}*.yml").reject { |f| sauf.include?(File.basename(f, ".yml")) }
        next if fichiers.size < 3

        cles = Hash.new { |h, k| h[k] = [] }
        fichiers.each do |f|
          doc = YAML.safe_load(Carte.lire(f), permitted_classes: [Date, Time], aliases: true) || {}
          next unless doc.is_a?(Hash)

          doc.each_key { |k| cles[k] << File.basename(f, ".yml") }
        end

        total = fichiers.size
        partielles = cles.select { |_, l| l.size < total }.sort_by { |_, l| l.size }
        next if partielles.empty?

        @anomalies << {
          titre: "Couverture des cles de premier niveau dans `#{dossier}` (#{total} fichiers)",
          detail: "Une cle absente d'une partie du corpus fait s'appliquer une valeur par defaut sans que rien ne le dise.",
          cas: partielles.map do |k, l|
            manquants = fichiers.map { |f| File.basename(f, ".yml") } - l
            "**#{k}** : #{l.size}/#{total}" + (manquants.size <= 8 ? "   absent de #{manquants.join(', ')}" : "")
          end
        }
      end
    end
  end
end
