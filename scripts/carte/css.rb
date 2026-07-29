# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  PASSE 4 : LE CSS, SES JETONS ET SES SELECTEURS
# ══════════════════════════════════════════════════════════════════════════
#
# Trois pieges deja payes vivent ici, et chacun a produit une affirmation fausse
# pendant le sondage :
#
#  1. Sans depouiller les commentaires, la carte invente des jetons morts. Le
#     SCSS de ce projet est commente a 56 % ; `--blanc`, `--contexte`, `--solid`
#     ont ete annonces morts alors qu'ils n'existaient que dans de la prose.
#  2. Sans lire les `style=` en ligne, `--animate-delay` et `--swatch-color`
#     passent pour des jetons consommes et jamais definis. Ils sont poses par
#     `_includes/projects/project-main.html`.
#  3. Sans resoudre le `&` de l'imbrication SCSS, `&--pleine` sous
#     `.project-piece` ne produit jamais le nom `project-piece--pleine`, donc
#     toutes les variantes BEM du site sont declarees absentes du HTML.

module Carte
  class Css
    # Une page interne n'est pas le site. Une classe qui n'existe que la ne doit
    # etre ni declaree absente ni declaree vivante : elle a son propre verdict.
    INTERNES = %r{(\Alabo/|\ATESTS/|design-system)}

    attr_reader :jetons, :consommations, :selecteurs, :importants, :anomalies, :breakpoints

    def initialize(couverture, emis, js = nil)
      @couverture    = couverture
      @emis          = emis
      @js            = js
      @jetons        = {}   # nom => { valeur:, ou: [fichier:ligne] }
      @consommations = Hash.new { |h, k| h[k] = [] }
      @selecteurs    = {}   # nom (".x" ou "#x") => [fichier:ligne]
      @importants    = []
      @breakpoints   = []
      @anomalies     = []
      analyser
      confronter_jetons
      confronter_selecteurs
      confronter_litteraux
    end

    def fichiers_scss = Carte.fichiers("assets/css/**/*.scss")

    private

    def analyser
      fichiers_scss.each do |f|
        rel    = Carte.relatif(f)
        brut   = Carte.lire(f)
        propre = Carte.sans_commentaires_css(brut)

        propre.scan(/(--[a-zA-Z0-9_-]+)\s*:\s*([^;{}]*);/) do |nom, valeur|
          ligne = Carte.numero_ligne(propre, Regexp.last_match.begin(0))
          (@jetons[nom] ||= { valeur: valeur.strip, ou: [] })[:ou] << "#{rel}:#{ligne}"
        end

        propre.scan(/var\(\s*(--[a-zA-Z0-9_-]+)/) do |(nom)|
          @consommations[nom] << rel
        end

        propre.each_line.with_index(1) do |l, i|
          @importants << "#{rel}:#{i}" if l.include?("!important")
        end

        propre.scan(/@media[^{]*?\(\s*(?:min|max)-(?:width|height)\s*:\s*(\d+)px/) do |(px)|
          @breakpoints << { fichier: rel, valeur: px.to_i,
                            ligne: Carte.numero_ligne(propre, Regexp.last_match.begin(0)) }
        end

        extraire_selecteurs(rel, propre)
      end
    end

    # ── Le mini-resolveur d'imbrication ──────────────────────────────────────
    #
    # Il ne fait qu'une chose : produire les NOMS de classe et d'id reellement
    # engendres, `&` compris. Il n'a pas besoin d'etre un vrai compilateur Sass,
    # seulement de ne rien perdre.
    def extraire_selecteurs(rel, texte)
      pile = []
      tampon = +""
      i = 0
      while i < texte.length
        c = texte[i]
        case c
        when "{"
          brut = tampon.strip
          parent = pile.last
          resolu = if brut.start_with?("@")
                     parent # une at-rule ne cree pas de selecteur, elle traverse
                   else
                     resoudre(brut, parent)
                   end
          pile.push(resolu)
          enregistrer(rel, resolu, Carte.numero_ligne(texte, i)) unless brut.start_with?("@")
          tampon = +""
        when "}"
          pile.pop
          tampon = +""
        when ";"
          tampon = +""
        else
          tampon << c
        end
        i += 1
      end
    end

    def resoudre(sel, parent)
      parents = (parent || "").split(",").map(&:strip).reject(&:empty?)
      sel.split(",").map(&:strip).reject(&:empty?).flat_map do |part|
        if part.include?("&")
          parents.empty? ? [part.delete("&")] : parents.map { |p| part.gsub("&", p) }
        elsif parents.empty?
          [part]
        else
          parents.map { |p| "#{p} #{part}" }
        end
      end.join(", ")
    end

    def enregistrer(rel, selecteur, ligne)
      return unless selecteur

      # On retire les chaines et les url() : `content: ".x"` n'est pas un
      # selecteur, et une data-URI SVG contient des `#` a la pelle.
      propre = selecteur.gsub(/"[^"]*"|'[^']*'|url\([^)]*\)/, " ")
      propre.scan(/\.(-?[a-zA-Z_][\w-]*)/) { |(n)| (@selecteurs[".#{n}"] ||= []) << "#{rel}:#{ligne}" }
      propre.scan(/#(-?[a-zA-Z_][\w-]*)/)  { |(n)| (@selecteurs["##{n}"] ||= []) << "#{rel}:#{ligne}" }
    end

    # ── Confrontations ───────────────────────────────────────────────────────

    def confronter_jetons
      sans_consommateur = @jetons.keys.reject { |n| @consommations.key?(n) }.sort
      unless sans_consommateur.empty?
        @anomalies << {
          titre: "Jetons definis, aucun `var()` ne les lit",
          detail: "Verdict de fait, pas de valeur : certains sont reserves pour une phase a venir.",
          cas: sans_consommateur.map { |n| "#{n} = #{@jetons[n][:valeur]}   (#{@jetons[n][:ou].first})" }
        }
      end

      # ⚠️ Un jeton peut etre defini AILLEURS QUE DANS LE CSS : en ligne, dans un
      # attribut `style=`. C'est le cas de deux d'entre eux ici. Sans cette
      # confrontation contre `_site`, la carte les declare fantomes.
      poses_en_ligne = @emis.attributs.keys.grep(/\Astyle:/).map { |a| a.delete_prefix("style:") }.to_set
      fantomes = @consommations.keys.reject { |n| @jetons.key?(n) || poses_en_ligne.include?(n) }.sort
      unless fantomes.empty?
        @anomalies << {
          titre: "Jetons consommes, definis nulle part",
          detail: "Ni en CSS ni dans un `style=` de `_site`. Chacun rend `unset` sans previrenir.",
          cas: fantomes.map { |n| "#{n}   lu dans #{@consommations[n].uniq.join(', ')}" }
        }
      end

      # Un jeton pose en ligne mais consomme SANS repli : la declaration tombe
      # entierement des qu'une donnee manque.
      sans_repli = poses_en_ligne.select do |n|
        @consommations.key?(n) && !@jetons.key?(n)
      end
      return if sans_repli.empty?

      details = sans_repli.flat_map do |n|
        fichiers_scss.flat_map do |f|
          Carte.sans_commentaires_css(Carte.lire(f)).each_line.with_index(1).filter_map do |l, i|
            next unless l.include?("var(#{n}")
            next if l =~ /var\(\s*#{Regexp.escape(n)}\s*,/ # un repli est present

            "#{Carte.relatif(f)}:#{i}  #{l.strip[0, 90]}"
          end
        end
      end
      return if details.empty?

      @anomalies << {
        titre: "Jetons poses en ligne et consommes SANS valeur de repli",
        detail: "Si la donnee qui pose le `style=` manque, la declaration entiere tombe.",
        cas: details
      }
    end

    def confronter_selecteurs
      return unless @emis.existe?

      absents = []
      internes = []
      desaccords = []
      par_le_js = []

      @selecteurs.each do |nom, ou|
        genre = nom[0]
        cle   = nom[1..]
        pages = genre == "." ? @emis.classes[cle] : @emis.ids[cle]

        if pages.nil?
          # ⚠️ AVANT DE DIRE « ABSENT », TESTER L'AUTRE GENRE. Une classe `.x`
          # stylee alors que le HTML pose `id="x"` n'est PAS du code mort :
          # c'est un bug, du style qui devrait s'appliquer et ne s'applique pas.
          # Les ranger ensemble ferait supprimer une regle qu'il fallait reparer.
          autre = genre == "." ? @emis.ids[cle] : @emis.classes[cle]
          # ⚠️ TROISIEME VERDICT AVANT « ABSENT », AJOUTE LE 29/07/2026.
          # Un element cree a l'execution n'apparait dans AUCUNE page construite,
          # exactement comme du CSS mort. Les confondre ferait supprimer une
          # regle vivante, et c'est la barre de defilement sur mesure qui l'a
          # revele : `.scrollbar` et `.scrollbar-thumb` sont les premiers
          # selecteurs de ce depot ecrits en SCSS et poses par le JS.
          # ⚠️ `key?` ET PAS `[]`. `classes_posees` est un Hash a bloc par
          # defaut : y lire une cle absente la CREERAIT avec un tableau vide,
          # donc interroger la passe JS suffirait a modifier ses donnees.
          pose_js = @js && @js.classes_posees.key?(cle) ? @js.classes_posees[cle] : nil
          pose_js = nil if pose_js&.empty?

          if autre
            desaccords << { nom: nom, ou: ou.uniq, pages: autre.size,
                            genre_emis: genre == "." ? "id" : "class" }
          elsif genre == "." && pose_js
            par_le_js << { nom: nom, ou: ou.uniq, js: pose_js.uniq }
          else
            absents << { nom: nom, ou: ou.uniq }
          end
        elsif pages.all? { |p| p =~ INTERNES }
          internes << { nom: nom, ou: ou.uniq, pages: pages }
        end
      end

      unless desaccords.empty?
        @anomalies << {
          titre: "DESACCORD DE SELECTEUR : le CSS cible un genre, le HTML emet l'autre",
          detail: "Ce n'est pas du code non emis, c'est du style qui ne s'applique pas. A reparer, pas a supprimer.",
          cas: desaccords.map { |d| "#{d[:nom]} style en #{d[:ou].first}, mais le HTML emet #{d[:genre_emis]}=\"#{d[:nom][1..]}\" sur #{d[:pages]} page(s)" }
        }
      end

      unless par_le_js.empty?
        @anomalies << {
          titre: "Selecteurs absents du HTML mais POSES PAR LE JS",
          detail: "Vivants a l'execution, invisibles au build. A ne PAS ranger avec le CSS mort : " \
                  "les supprimer casserait un composant qui fonctionne.",
          cas: par_le_js.map { |c| "#{c[:nom]}  style en #{c[:ou].first}, pose par #{c[:js].join(', ')}" }
        }
      end

      unless internes.empty?
        @anomalies << {
          titre: "Selecteurs emis UNIQUEMENT par les pages internes",
          detail: "Ni vivants sur le site public, ni absents. Leur sort depend de celui des pages de labo.",
          cas: internes.map { |c| "#{c[:nom]}  (#{c[:ou].first}) -> #{c[:pages].join(', ')}" }
        }
      end

      return if absents.empty?

      @anomalies << {
        titre: "Selecteurs absents des #{@emis.nb_pages} pages construites",
        detail: "Fait date, pas jugement : aucune page du dernier build ne porte ce nom.",
        cas: absents.map { |c| "#{c[:nom]}  #{c[:ou].join(' ')}" }
      }
    end

    # Les valeurs ecrites en dur alors qu'un jeton porte exactement la meme.
    def confronter_litteraux
      echelle = @jetons.select { |n, _| n.start_with?("--spacing-", "--radius-", "--signal-width", "--hairline-") }
                       .to_h { |n, d| [d[:valeur], n] }
                       .reject { |v, _| v.include?("var(") || v.include?("clamp") }

      comptes = Hash.new(0)
      ou = Hash.new { |h, k| h[k] = [] }
      fichiers_scss.each do |f|
        rel = Carte.relatif(f)
        Carte.sans_commentaires_css(Carte.lire(f)).each_line.with_index(1) do |l, i|
          next if l =~ /^\s*--/ # la definition du jeton lui-meme

          echelle.each_key do |val|
            next unless l =~ /(?<![\w.-])#{Regexp.escape(val)}(?![\w.-])/

            comptes[val] += 1
            ou[val] << "#{rel}:#{i}"
          end
        end
      end

      cas = comptes.select { |_, n| n >= 3 }.sort_by { |_, n| -n }.map do |val, n|
        "#{val} ecrit #{n} fois, alors que #{echelle[val]} vaut exactement ca   (ex. #{ou[val].first(3).join(', ')})"
      end
      return if cas.empty?

      @anomalies << {
        titre: "Valeurs ecrites en dur alors qu'un jeton porte la meme",
        detail: "Chacune est un endroit que le jeton ne pourra pas deplacer le jour ou il bougera.",
        cas: cas
      }
    end
  end
end
