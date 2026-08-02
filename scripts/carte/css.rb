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
      # ⚠️ UN LECTEUR EN JAVASCRIPT EST UN CONSOMMATEUR. Sans ce filtre,
      # `--dur-loader-hold`, que seul script.js lit pour savoir combien de temps
      # tenir le voile, atterrit dans la liste des jetons a supprimer. Meme
      # angle mort que les selecteurs poses par le JS, une couche plus bas.
      lus_par_js = @js ? @js.jetons_lus : {}

      sans_consommateur = @jetons.keys
                                 .reject { |n| @consommations.key?(n) || lus_par_js.key?(n) }
                                 .sort
      unless sans_consommateur.empty?
        @anomalies << {
          titre: "Jetons definis, aucun `var()` ne les lit",
          detail: "Verdict de fait, pas de valeur : certains sont reserves pour une phase a venir.",
          cas: sans_consommateur.map { |n| "#{n} = #{@jetons[n][:valeur]}   (#{@jetons[n][:ou].first})" }
        }
      end

      lus_seulement_en_js = @jetons.keys.select { |n| !@consommations.key?(n) && lus_par_js.key?(n) }.sort
      unless lus_seulement_en_js.empty?
        @anomalies << {
          titre: "Jetons lus UNIQUEMENT depuis le JavaScript",
          detail: "Aucun `var()` ne les lit, mais ils ont un consommateur. A ne PAS ranger avec " \
                  "les jetons sans emploi : les supprimer casserait un comportement.",
          cas: lus_seulement_en_js.map { |n| "#{n} = #{@jetons[n][:valeur]}   lu par #{lus_par_js[n].uniq.join(', ')}" }
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
          # ⚠️ CE TITRE NE DOIT PAS COMMENCER PAR « Selecteurs absents ».
          # `rendu.rb` retrouve les blocs par leur debut de titre, avec un
          # `find` qui rend le PREMIER correspondant. Le premier jet s'appelait
          # « Selecteurs absents du HTML mais POSES PAR LE JS » et passait avant
          # le bloc du CSS mort : le JSON de reference s'est mis a suivre les 14
          # selecteurs VIVANTS au lieu des 23 morts, et le `--diff` a surveille
          # la mauvaise liste sans que rien ne le dise.
          titre: "Selecteurs POSES PAR LE JS, absents du HTML construit",
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

    # ── Les litteraux confrontes a leur PROPRE famille ───────────────────────
    #
    # ⚠️ DEUX QUESTIONS, PAS UNE, et l'ancienne version n'en posait qu'une, mal.
    # Reecrit le 02/08/2026.
    #
    # CE QU'ELLE FAISAIT DE FAUX, et ce n'etait pas une approximation :
    #   1. Un `to_h { [valeur, nom] }` qui INVERSE valeur vers jeton. Or
    #      `--spacing-sm` et `--radius-sm` valent tous deux 1rem : le second
    #      ecrasait le premier, et la famille etait perdue avant meme le test.
    #   2. Elle cherchait la valeur N'IMPORTE OU sur la ligne, sans jamais
    #      regarder la propriete. Resultat publie dans CARTE.md, avec chemin et
    #      numero de ligne : un rayon propose pour un `bottom:`, un espacement
    #      propose pour un `border-radius`. C'est le corollaire pose par Ropat
    #      le 30/07 viole dans les deux sens : LE FILTRE PORTE SUR LA PROPRIETE
    #      AVANT DE PORTER SUR LA VALEUR.
    #   3. Son seuil `n >= 3` eliminait par construction toute EXCEPTION, qui
    #      par definition ne sert qu'une ou deux fois. C'est-a-dire exactement
    #      ce qu'on cherche depuis le 02/08.
    #
    # LES DEUX QUESTIONS SONT SYMETRIQUES :
    #   A. ce litteral egale un jeton DE SA FAMILLE   -> il devrait le prendre
    #   B. ce litteral n'a AUCUN jeton de sa famille  -> il est HORS ECHELLE
    # La seconde est l'inventaire que `scripts/jetons-hors-echelle.rb` verrouille
    # ensuite contre une liste commitee. Ici on le PRODUIT, la-bas on le GARDE.

    # La table qui manquait. Une propriete appartient a une famille, et une
    # famille a ses prefixes de jetons. Rien d'autre ne se confronte.
    FAMILLES = {
      "rayon" => {
        proprietes: /\A(border-radius|border-(top|bottom)-(left|right)-radius)\z/,
        prefixes:   ["--radius-", "--squircle-"]
      },
      "espacement" => {
        proprietes: /\A(padding|margin|gap|row-gap|column-gap)(-(top|right|bottom|left))?\z/,
        prefixes:   ["--spacing-"]
      },
      # ⚠️ `--signal-width` EST ECRIT EN ENTIER, ET C'EST UN CONSTAT, PAS UN CHOIX.
      # Les deux autres familles se declarent par un PREFIXE (`--radius-`,
      # `--spacing-`), donc elles sont enumerables : un jeton ajoute demain y
      # entre tout seul. Les epaisseurs, elles, n'ont aucun radical commun
      # (`--hairline-width` vaut 1px, `--signal-width` vaut 3px, et `-width` nomme
      # la propriete, pas la famille). Il faut donc les nommer une par une, et un
      # troisieme jeton d'epaisseur resterait invisible a cette table tant que
      # personne ne l'y aurait inscrit A LA MAIN. C'est le cout exact d'un radical
      # manquant, et c'est ici qu'il se paye.
      "trait" => {
        proprietes: /\A(border|outline)(-(top|right|bottom|left))?(-width)?\z/,
        prefixes:   ["--hairline-", "--signal-width"]
      },
      # Le decalage de l'anneau de focus. Famille A PART et non un trait : ce
      # n'est pas une epaisseur d'encre mais une DISTANCE entre l'objet et son
      # anneau. Ajoutee le 02/08/2026 apres un trou mesure : le motif de la
      # famille trait ci-dessus ne matche pas `outline-offset`, donc les quatre
      # decalages du site etaient invisibles a l'inventaire, dans les deux sens.
      # Aucun jeton ne les porte aujourd'hui : les quatre ressortent en orphelins,
      # ce qui est exactement le constat cherche.
      "decalage" => {
        proprietes: /\Aoutline-offset\z/,
        prefixes:   ["--offset-"]
      }
    }.freeze

    # ⚠️ LIMITE CONNUE, ECRITE ICI POUR QU'ON NE LA PRENNE PAS POUR UN BUG.
    # Ce scanner lit LIGNE A LIGNE, il ne voit pas le bloc. Il ne peut donc pas
    # savoir qu'un `border-top: 6px solid ...` pose sur une boite `width: 0;
    # height: 0` n'est pas un trait mais un TRIANGLE CSS (`.caret` de
    # components/_dropdown.scss). Ce 6px ressort donc en famille trait alors qu'il
    # est une dimension de forme.
    # C'est un faux positif ASSUME plutot qu'une heuristique fragile : il est
    # declare dans `.carte/hors-echelle.txt` comme les autres, donc visible et
    # compte. Le rendre muet demanderait de parser les blocs, c'est-a-dire un
    # vrai compilateur Sass, pour gagner une entree sur vingt-trois.

    # Ni des paliers ni des longueurs : des mots-cles, des formes, des idiomes.
    NEUTRES = %w[0 0px auto inherit initial none unset revert solid dashed dotted double
                 transparent currentcolor fit-content max-content min-content
                 -webkit-fill-available].freeze

    def confronter_litteraux
      egaux, orphelins = self.class.scanner(fichiers_scss, @jetons)
      publier_egaux(egaux)
      publier_orphelins(orphelins)
    end

    # ⚠️ PASSE DE CLASSE, ET C'EST DELIBERE : `scripts/jetons-hors-echelle.rb`
    # l'appelle telle quelle pour verrouiller la liste en CI. Deux lecteurs, une
    # seule logique. Si elle redevenait une methode d'instance, le garde-fou
    # devrait la recopier, et deux copies divergent toujours.
    #
    # Rend [egaux, orphelins], tous deux { cle => [fichier:ligne] } :
    #   egaux     [famille, valeur, jeton] -> le litteral double un jeton de sa famille
    #   orphelins [famille, valeur]        -> aucun jeton de sa famille ne le porte
    def self.scanner(fichiers, jetons)
      paliers   = paliers_par_famille(jetons)
      egaux     = Hash.new { |h, k| h[k] = [] }
      orphelins = Hash.new { |h, k| h[k] = [] }

      fichiers.each do |f|
        rel = Carte.relatif(f)
        Carte.sans_commentaires_css(Carte.lire(f)).each_line.with_index(1) do |l, i|
          next if l =~ /^\s*--/ # la definition du jeton lui-meme
          # ⚠️ Les bornes d'un `clamp()` ne sont pas des paliers, elles decrivent
          # une COURBE. Ropat, 30/07 : on ne les nomme pas. Idem calc/min/max.
          next if l =~ /\b(clamp|calc|min|max)\s*\(/

          famille, valeurs = famille_et_valeurs(l)
          next unless famille

          valeurs.each do |v|
            if (jeton = paliers[famille][v])
              egaux[[famille, v, jeton]] << "#{rel}:#{i}"
            else
              orphelins[[famille, v]] << "#{rel}:#{i}"
            end
          end
        end
      end

      [egaux, orphelins]
    end

    # famille => { valeur litterale => nom du jeton }. Les alias (`var(...)`) et
    # les courbes sont ecartes : ils n'ont pas de valeur propre a confronter.
    def self.paliers_par_famille(jetons)
      FAMILLES.to_h do |nom, d|
        table = jetons.select { |n, _| d[:prefixes].any? { |p| n.start_with?(p) } }
                      .reject { |_, j| j[:valeur].include?("var(") || j[:valeur].include?("clamp") }
                      .to_h { |n, j| [j[:valeur], n] }
        [nom, table]
      end
    end

    # Rend [famille, valeurs confrontables] pour une ligne, ou nil.
    # ⚠️ `@include squircle(5rem)` EST un rayon. Il ne s'ecrit pas
    # `propriete: valeur`, donc tout releve qui cherchait `border-radius:` le
    # manquait : c'est exactement ainsi que le `5rem` de toutes les cartes est
    # reste invisible jusqu'au 02/08.
    def self.famille_et_valeurs(ligne)
      if (m = ligne.match(/@include\s+squircle\s*\(\s*([^)]+)\)/))
        return ["rayon", longueurs(m[1])]
      end

      m = ligne.match(/^\s*([a-z-]+)\s*:\s*([^;{}]+);/)
      return nil unless m

      prop = m[1]
      famille = FAMILLES.find { |_, d| prop =~ d[:proprietes] }&.first
      return nil unless famille

      # Sur un raccourci `border` ou `outline`, seule la PREMIERE valeur est une
      # epaisseur ; les suivantes sont un style et une couleur.
      brut = famille == "trait" ? m[2].strip.split(/\s+/).first.to_s : m[2]
      [famille, longueurs(brut)]
    end

    def self.longueurs(texte)
      texte.split(/\s+/).reject { |v| v.include?("var(") || NEUTRES.include?(v.downcase) }
           .select { |v| v =~ /\A-?\d*\.?\d+(px|rem|em)\z/ }
    end

    def publier_egaux(egaux)
      cas = egaux.sort_by { |_, lieux| -lieux.size }.map do |(famille, val, jeton), lieux|
        "#{val} ecrit #{lieux.size} fois en #{famille}, alors que #{jeton} vaut exactement ca" \
          "   (ex. #{lieux.first(3).join(', ')})"
      end
      return if cas.empty?

      @anomalies << {
        titre: "Valeurs ecrites en dur alors qu'un jeton DE LEUR FAMILLE porte la meme",
        detail: "Chacune est un endroit que le jeton ne pourra pas deplacer le jour ou il bougera.",
        cas: cas
      }
    end

    def publier_orphelins(orphelins)
      cas = orphelins.sort_by { |(famille, val), lieux| [famille, -lieux.size, val] }.map do |(famille, val), lieux|
        "#{famille} #{val} : #{lieux.size} declaration(s), AUCUN jeton de cette famille ne porte cette valeur" \
          "   (ex. #{lieux.first(3).join(', ')})"
      end
      return if cas.empty?

      @anomalies << {
        titre: "Valeurs HORS ECHELLE : aucun jeton de leur famille ne les porte",
        detail: "Fait, pas jugement. Nommer n'est pas aligner : une valeur listee ici merite un " \
                "nom pour devenir auditable, pas forcement d'etre deplacee. " \
                "`scripts/jetons-hors-echelle.rb` verrouille cette liste contre une liste commitee.",
        cas: cas
      }
    end
  end
end
