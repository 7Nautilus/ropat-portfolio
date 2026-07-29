# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  PASSE 5 : LE JS, ET CE QU'IL CROIT TROUVER DANS LE DOM
# ══════════════════════════════════════════════════════════════════════════
#
# ⚠️ TROIS REGLES, TROIS FAUX POSITIFS DEJA PAYES.
#
#  1. DECOUPER SUR LA VIRGULE. `.lang-selector` est noye au milieu d'une chaine
#     de treize selecteurs a `script.js:92`. Compare en bloc, ce selecteur ne
#     ressort jamais, et le bug qu'il cache (la classe emise est
#     `lang-selector-container`) reste invisible.
#  2. NORMALISER kebab-case ET camelCase DANS LES DEUX SENS. Le HTML emet
#     `data-seuil-mobile`, le JS lit `dataset.seuilMobile`. Sans normalisation,
#     la carte annonce trois attributs sans consommateur qui en ont tous un.
#  3. UN ARGUMENT NON LITTERAL VAUT `INDETERMINE`, jamais `ABSENT`.
#     `classList.add(stateClass)` recoit une variable ; les trois valeurs reelles
#     n'apparaissent que dans le `remove` d'une autre ligne. Conclure « ces
#     classes ne sont jamais posees » serait faux, et faux de facon plausible.

module Carte
  class Js
    # ⚠️ `querySelectorAll?` EST UN PIEGE, ET IL A MORDU ICI AVANT DE SERVIR DE
    # LECON. Le `?` porte sur le dernier CARACTERE : cette forme exige donc
    # `querySelectorAl` au minimum et ne matche JAMAIS `querySelector` seul.
    # Resultat, la sonde a annonce « aucun selecteur JS introuvable » en n'ayant
    # regarde qu'un tiers des appels, et son silence passait pour un bon
    # resultat. Une sonde qui ne peut pas echouer ne prouve rien.
    # Il faut `(?:All)?`.
    APPELS_DOM = /(?:querySelector(?:All)?|closest|matches|getElementById)\s*\(\s*(["'`])(.*?)\1/

    # ⚠️ ET LES APPELS NE SUFFISENT PAS, la sonde est aveugle par construction a
    # tout ce qui transite par une fonction maison. `script.js:98` ecrit
    # `bindCursorState('.lightbox-trigger, .thumbnail-image, .zoomable', ...)` :
    # ces selecteurs ne touchent jamais `querySelector`. Deux des trois
    # selecteurs sans cible connus de ce depot sont dans ce cas.
    # On balaye donc TOUS les litteraux de chaine ayant la FORME d'un selecteur,
    # quel que soit l'appel qui les recoit.
    FORME_SELECTEUR = /\A[.#\[][\w\-\[\]"'=:().,\s>+~*^$|]{1,120}\z/
    COULEUR_HEX     = /\A#[0-9a-fA-F]{3,8}\z/
    LITTERAL        = /(["'])((?:[^"'\\\n]|\\.)*)\1/

    attr_reader :selecteurs, :classes_posees, :attributs, :ecouteurs, :anomalies, :boucles

    def initialize(couverture, emis)
      @couverture     = couverture
      @emis           = emis
      @selecteurs     = Hash.new { |h, k| h[k] = [] }  # selecteur simple => [fichier:ligne]
      @classes_posees = Hash.new { |h, k| h[k] = [] }
      @attributs      = Hash.new { |h, k| h[k] = [] }
      @ecouteurs      = []
      @boucles        = []
      @anomalies      = []
      analyser
      confronter
    end

    def fichiers = Carte.fichiers("assets/js/*.js")

    private

    def analyser
      fichiers.each do |f|
        rel    = Carte.relatif(f)
        propre = Carte.sans_commentaires_js(Carte.lire(f))

        propre.scan(APPELS_DOM) do |_q, brut|
          ligne = Carte.numero_ligne(propre, Regexp.last_match.begin(0))
          decouper(brut).each { |x| @selecteurs[x] << "#{rel}:#{ligne}" }
        end

        # Le filet large : tout litteral qui a la forme d'un selecteur, ou qu'il
        # soit. C'est lui qui rattrape les selecteurs passes a un helper.
        propre.scan(LITTERAL) do |_q, brut|
          # ⚠️ LIRE LA POSITION AVANT TOUTE AUTRE COMPARAISON. `Regexp.last_match`
          # est global : le premier `=~` d'une garde l'ECRASE, et l'appeler apres
          # rend nil. Le symptome est un plantage, donc benin ; la variante
          # dangereuse est celle ou il rend la position d'une AUTRE mise en
          # correspondance et ou la carte rapporte des numeros de ligne faux
          # sans que rien ne le signale.
          debut = Regexp.last_match.begin(0)
          next unless brut =~ FORME_SELECTEUR
          next if brut =~ COULEUR_HEX

          ligne = Carte.numero_ligne(propre, debut)
          decouper(brut).each { |x| @selecteurs[x] << "#{rel}:#{ligne}" }
        end

        # Appels dont l'argument n'est PAS un litteral : on les compte comme
        # indetermines au lieu de les ignorer.
        propre.scan(/(?:querySelector(?:All)?|closest|getElementById)\s*\(\s*([^"'`)\s][^)]*)\)/) do |(arg)|
          ligne = Carte.numero_ligne(propre, Regexp.last_match.begin(0))
          @couverture.indetermine("selecteur JS calcule", "#{rel}:#{ligne}", arg.strip[0, 60])
        end

        propre.scan(/classList\.(?:add|remove|toggle|contains)\s*\(([^)]*)\)/) do |(args)|
          ligne = Carte.numero_ligne(propre, Regexp.last_match.begin(0))
          args.split(",").each do |a|
            a = a.strip
            if a =~ /\A(["'`])(.*)\1\z/
              @classes_posees[Regexp.last_match(2)] << "#{rel}:#{ligne}"
            elsif !a.empty?
              @couverture.indetermine("classe JS calculee", "#{rel}:#{ligne}", a[0, 40])
            end
          end
        end

        # ⚠️ `classList.add` N'EST PAS LE SEUL MOYEN DE POSER UNE CLASSE, et
        # l'oublier a un cout precis : une regle SCSS dont l'element est cree
        # par le JS se retrouve dans la liste des selecteurs absents, c'est-a-dire
        # dans celle qui sert a supprimer du CSS mort. Constate le 29/07/2026 sur
        # `.scrollbar` et `.scrollbar-thumb`, poses par `className =`.
        # Un attribut peut porter PLUSIEURS classes, d'ou le decoupage.
        propre.scan(/\.className\s*=\s*(["'`])([^"'`]*)\1/) do |_q, valeur|
          ligne = Carte.numero_ligne(propre, Regexp.last_match.begin(0))
          valeur.split(/\s+/).reject(&:empty?).each { |c| @classes_posees[c] << "#{rel}:#{ligne}" }
        end

        # Les gabarits de chaine qui construisent du HTML : `class="stt-track"`
        # dans un `innerHTML` pose une classe aussi surement qu'un appel.
        propre.scan(/class\s*=\s*\\?["']([^"'<>]*)\\?["']/) do |(valeur)|
          ligne = Carte.numero_ligne(propre, Regexp.last_match.begin(0))
          valeur.split(/\s+/).reject { |c| c.empty? || c.include?("{") }
                .each { |c| @classes_posees[c] << "#{rel}:#{ligne}" }
        end

        propre.scan(/(?:set|get|remove|has)Attribute\s*\(\s*(["'`])(.*?)\1/) do |_q, nom|
          @attributs[nom] << "#{rel}:#{Carte.numero_ligne(propre, Regexp.last_match.begin(0))}"
        end
        propre.scan(/dataset\.([a-zA-Z][\w]*)/) do |(camel)|
          @attributs["data-#{kebab(camel)}"] << "#{rel}:#{Carte.numero_ligne(propre, Regexp.last_match.begin(0))}"
        end

        propre.scan(/addEventListener\s*\(\s*(["'`])(\w+)\1([^)]*)/) do |_q, evt, reste|
          ligne = Carte.numero_ligne(propre, Regexp.last_match.begin(0))
          @ecouteurs << { fichier: rel, ligne: ligne, evenement: evt,
                          passif: reste.include?("passive") }
        end

        # ⚠️ « SE RELANCE » N'EST PAS « TOURNE ». Une fonction qui se rappelle en
        # rAF ne tourne que si quelqu'un l'a demarree, et le demarrage depend
        # souvent d'une garde (`prefers-reduced-motion`, presence d'une cible)
        # que la carte ne suit pas. Elle rapporte donc la FORME, pas le fait.
        propre.scan(/function\s+(\w+)\s*\([^)]*\)\s*\{/) do |(nom)|
          debut = Regexp.last_match.begin(0)
          corps = propre[debut, 2500].to_s
          next unless corps =~ /requestAnimationFrame\s*\(\s*#{Regexp.escape(nom)}\s*\)/

          @boucles << { fichier: rel, ligne: Carte.numero_ligne(propre, debut), fonction: nom }
        end
      end
    end

    # ⚠️ Un decoupage NAIF sur la virgule casserait `:not(.a, .b)` et
    # `[data-x="a,b"]`. On ne coupe qu'au niveau zero de parentheses et hors
    # crochets.
    def decouper(brut)
      parts = []
      buf = +""
      prof = 0
      brut.each_char do |c|
        case c
        when "(", "[" then prof += 1
        when ")", "]" then prof -= 1
        end
        if c == "," && prof.zero?
          parts << buf
          buf = +""
        else
          buf << c
        end
      end
      parts << buf
      parts.map(&:strip).reject(&:empty?)
    end

    def kebab(camel) = camel.gsub(/([a-z0-9])([A-Z])/) { "#{Regexp.last_match(1)}-#{Regexp.last_match(2)}" }.downcase

    # Le NOM cible d'un selecteur simple : la premiere classe ou le premier id
    # que le JS espere trouver.
    def cible(selecteur)
      return [:class, Regexp.last_match(1)] if selecteur =~ /\A\.(-?[\w-]+)/
      return [:id, Regexp.last_match(1)]    if selecteur =~ /\A#(-?[\w-]+)/

      if selecteur =~ /\[\s*(data-[\w-]+)/
        [:attr, Regexp.last_match(1)]
      end
    end

    def confronter
      return unless @emis.existe?

      absents = []
      @selecteurs.each do |sel, ou|
        c = cible(sel)
        next unless c

        genre, nom = c
        present = case genre
                  when :class then @emis.classes.key?(nom)
                  when :id    then @emis.ids.key?(nom)
                  when :attr  then @emis.attributs.key?(nom)
                  end
        next if present

        # Le JS peut CREER l'element qu'il cherche ensuite : si la meme classe
        # est posee par `classList.add` ou par une affectation de `className`
        # ailleurs dans le fichier, ce n'est pas une cible absente.
        next if genre == :class && @classes_posees.key?(nom)

        absents << { selecteur: sel, ou: ou.uniq, genre: genre, nom: nom }
      end

      unless absents.empty?
        @anomalies << {
          titre: "Selecteurs JS qui ne trouvent rien dans les #{@emis.nb_pages} pages construites",
          detail: "Un selecteur qui ne matche rien n'echoue pas : il rend null et le code s'arrete en silence.",
          cas: absents.map do |a|
            proche = suggestion(a[:nom], a[:genre])
            "#{a[:selecteur]}  (#{a[:ou].join(' ')})#{proche ? "   proche : #{proche}" : ''}"
          end
        }
      end

      # Ecrits par le JS, lus par personne.
      poses_sans_lecteur = @classes_posees.keys.reject do |c|
        @emis.classes.key?(c) || css_connait?(".#{c}")
      end
      unless poses_sans_lecteur.empty?
        @anomalies << {
          titre: "Classes posees par le JS qu'aucune regle CSS ne lit",
          detail: "Legitime si le JS s'en sert comme verrou interne, a verifier sinon.",
          cas: poses_sans_lecteur.sort.map { |c| "#{c}   (#{@classes_posees[c].uniq.join(' ')})" }
        }
      end

      sans_rythme = @ecouteurs.select { |e| e[:evenement] == "scroll" }
      return if sans_rythme.empty?

      @anomalies << {
        titre: "Ecouteurs `scroll` recenses",
        detail: "A confronter au throttle : un handler sans rAF qui lit une metrique de layout force un reflow a chaque evenement.",
        cas: sans_rythme.map { |e| "#{e[:fichier]}:#{e[:ligne]}#{e[:passif] ? '  (passive)' : ''}" }
      }
    end

    def css_connait?(sel)
      @css_noms ||= begin
        noms = Set.new
        Carte.fichiers("assets/css/**/*.scss").each do |f|
          Carte.sans_commentaires_css(Carte.lire(f)).scan(/\.(-?[a-zA-Z_][\w-]*)/) { |(n)| noms << ".#{n}" }
        end
        noms
      end
      @css_noms.include?(sel)
    end

    # Quand une cible est absente, proposer le nom emis le plus proche : c'est
    # ce qui transforme « code mort » en « faute de frappe » quand c'en est une.
    def suggestion(nom, genre)
      candidats = genre == :id ? @emis.ids.keys : @emis.classes.keys
      candidats.find { |c| c.start_with?(nom) || nom.start_with?(c) }
    end
  end
end
