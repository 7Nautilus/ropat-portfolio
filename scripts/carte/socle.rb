# frozen_string_literal: true

# ══════════════════════════════════════════════════════════════════════════
#  SOCLE : ce que toutes les passes partagent
# ══════════════════════════════════════════════════════════════════════════
#
# ⚠️ CE FICHIER EST L'ENDROIT OU VIVENT LES PIEGES DEJA PAYES. Chaque methode
# de depouillement ci-dessous existe parce qu'une mesure a ete FAUSSE sans elle,
# et le commentaire dit laquelle. Ne pas les simplifier sans relire ces cas.

require "yaml"
require "json"
require "digest"
require "set"
require "time"

module Carte
  RACINE = File.expand_path("../..", __dir__)

  # Les trois seuls verdicts que la carte a le droit d'ecrire.
  #
  # ⚠️ « MORT » N'EN FAIT PAS PARTIE, et ce n'est pas de la coquetterie.
  # « Mort » est un jugement : il affirme qu'une chose ne servira jamais.
  # « Absent des N pages construites le <date> » est un fait, verifiable et
  # datable. La difference se paye : pendant le sondage, trois selecteurs ont
  # ete declares morts alors qu'ils n'existaient que dans des commentaires, et
  # un quatrieme etait un BUG (une classe stylee la ou le HTML pose un id),
  # c'est-a-dire l'inverse d'un code mort : du code qui devrait servir.
  CONFIRME    = "CONFIRME"
  ABSENT      = "ABSENT"
  INDETERMINE = "INDETERMINE"

  # Les repertoires que la carte ne parcourt jamais.
  #
  # ⚠️ CETTE LISTE NE SUFFIT PAS, ET ELLE NE PEUT PAS SUFFIRE : c'est une liste de
  # REPERTOIRES, elle ne sait pas exprimer une regle de `.gitignore`. Voir
  # `suivis_par_git` juste en dessous, qui porte la vraie regle depuis le
  # 12/08/2026. Elle reste utile pour deux choses qu'un filtre git ne ferait pas :
  # `.carte/` contient `carte.json` et `hors-echelle.txt`, qui SONT suivis et que
  # la carte ne doit pas se lire a elle-meme ; et `_site` est l'oracle, pas une
  # source.
  IGNORES = %w[_site .git .jekyll-cache node_modules vendor .carte .impeccable .claude].freeze

  module_function

  def chemin(*bouts) = File.join(RACINE, *bouts)

  # ══════════════════════════════════════════════════════════════════════════
  #  ⚠️ LA CARTE LIT CE QUE GIT SUIT, PAS CE QUE LE DISQUE PORTE (12/08/2026)
  # ══════════════════════════════════════════════════════════════════════════
  #
  # Elle decrit le DEPOT. Un fichier qui n'est pas dans l'index n'est pas dans le
  # depot : il ne sera pas dans le checkout de la CI, donc tout ce que la carte en
  # dit est une affirmation que personne d'autre ne peut reproduire.
  #
  # Le defaut a ete paye trois fois le meme jour, et les trois etaient invisibles :
  #   1. `.claude/skills/mesurer-au-navigateur/SKILL.md`, gitignore, portait un
  #      front matter : la carte publiait la route
  #      `/.claude/skills/mesurer-au-navigateur/SKILL.html`, qu'AUCUN build ne
  #      produit (Jekyll ignore les repertoires en point). Sur un checkout de CI la
  #      regeneration comptait 65 routes contre 66 commitees, `carte-a-jour.rb`
  #      sortait en 1, et le job `carte` bloquait `deploy`.
  #   2. Le chantier « mise en situation » : `_situation.scss` plus cinq includes,
  #      gitignores VOLONTAIREMENT par `.gitignore:59-82` pour survivre a un
  #      `git clean -fd`. Mesure : « Includes 38 » et « Partiels SCSS 34 » en local
  #      contre 33 et 33 en CI, plus 35 mentions dans le corps de la carte.
  #      Ceux-la ne peuvent PAS etre deplaces, c'est le but de leur protection.
  #   3. `_data/projects/cinco.yml` et `luz-optique.yml`, non suivis : la passe
  #      donnees compte les FICHIERS du disque et non l'`order`, d'ou un « 20/23 »
  #      la ou la CI voit « 20/21 ».
  #
  # `git ls-files` rend l'INDEX, donc exactement ce qu'un commit contiendrait :
  # les ajouts stages y sont, les suppressions non encore commitees en sortent par
  # l'intersection avec le glob. C'est la bonne definition, pas `git ls-tree HEAD`.
  #
  # ⚠️ CETTE REGLE NE VAUT QUE POUR LES SOURCES. L'oracle est lu par un
  # `Dir.glob` direct dans `emis.rb`, sur `.carte/site` ou `_site`, qui ne sont
  # suivis ni l'un ni l'autre et doivent continuer d'etre lus.
  #
  # ⚠️ AUCUN REPLI SILENCIEUX. Si git ne repond pas, la carte s'arrete. Retomber
  # sur un scan du disque redonnerait une carte fausse sans que rien ne le dise,
  # c'est-a-dire exactement le defaut qu'on ferme ici.
  # Consequence a connaitre : `carte.rb` ne tourne plus dans un repertoire qui
  # n'est pas un depot git. Pour simuler un checkout de CI, utiliser
  # `git worktree add --detach`, pas une extraction `git archive`.
  def suivis_par_git
    @suivis_par_git ||= begin
      sortie = begin
        IO.popen(["git", "-C", RACINE, "ls-files", "-z"], &:read)
      rescue SystemCallError => e
        abort("carte : git est introuvable (#{e.message}). La carte lit l'index git, elle ne peut pas s'en passer.")
      end
      abort("carte : `git ls-files` a echoue dans #{RACINE}. Est-ce bien un depot git ?") unless $?.success?

      liste = sortie.to_s.force_encoding("UTF-8").split("\0").reject(&:empty?)
      abort("carte : `git ls-files` n'a rendu aucun fichier. La carte refuse de decrire un depot vide.") if liste.empty?

      liste.map { |r| r.tr("\\", "/") }.to_set
    end
  end

  def lire(f)
    File.read(f, encoding: "bom|utf-8")
  rescue ArgumentError
    # Un fichier mal encode ne doit pas tuer la carte : on le lit en binaire et
    # on remplace ce qui ne passe pas, en le signalant.
    File.binread(f).force_encoding("UTF-8").scrub("?")
  end

  def ecrire(f, contenu)
    require "fileutils"
    FileUtils.mkdir_p(File.dirname(f))
    File.binwrite(f, contenu.encode("UTF-8"))
  end

  # Tous les fichiers SUIVIS PAR GIT, hors repertoires ignores.
  # Le glob garde `File::FNM_DOTMATCH` : ce n'est plus lui qui protege des
  # repertoires en point, c'est l'index.
  def fichiers(motif)
    suivis = suivis_par_git
    Dir.glob(File.join(RACINE, motif), File::FNM_DOTMATCH).reject do |f|
      rel = relatif(f)
      IGNORES.any? { |d| rel == d || rel.start_with?("#{d}/") } ||
        File.directory?(f) ||
        !suivis.include?(rel)
    end.sort
  end

  def relatif(f) = f.delete_prefix(RACINE + "/").tr("\\", "/")

  # ⚠️ LA CARTE NE LIT PAS `_site`, ET C'EST UNE LECON PAYEE DEUX FOIS.
  # `_site` appartient au serveur de developpement : un `jekyll serve` qui tourne
  # le REECRIT a chaque fichier touche, avec la configuration qu'il a chargee a
  # son demarrage. Le 29/07, un serve lance avant l'exclusion de `labo/` a
  # continue de republier `labo/`, `TESTS/` et `CARTE.md` dans `_site` apres
  # chaque edition. Deux verifications ont conclu que l'exclusion ne marchait pas
  # alors qu'elle marchait : un build propre lance a la main donnait 63 pages
  # justes, et le serve les ecrasait dans la seconde qui suivait.
  # La carte construit donc dans SON PROPRE repertoire, que personne d'autre ne
  # touche. Elle retombe sur `_site` s'il n'existe pas, en le signalant.
  BUILD_PROPRE = ".carte/site"

  def dossier_build
    prive = chemin(BUILD_PROPRE)
    Dir.exist?(prive) ? prive : chemin("_site")
  end

  def build_prive? = Dir.exist?(chemin(BUILD_PROPRE))

  # ── Depouillement ────────────────────────────────────────────────────────

  # ⚠️ LE DEPOUILLEMENT PRESERVE LE NOMBRE DE LIGNES ET LES COLONNES.
  # Une premiere version faisait `sub(/\/\*.*?\*\//m, "")`, ce qui ECRASE les
  # commentaires multilignes : le texte depouille avait moins de lignes que
  # l'original, donc tout numero de ligne rapporte designait la mauvaise ligne.
  # On remplace le CONTENU par des espaces et on garde les sauts de ligne.
  def blanchir(m) = m.gsub(/[^\n]/, " ")

  # ⚠️ SANS CECI, LA CARTE INVENTE DES JETONS MORTS. Mesure faite pendant le
  # sondage : commentaires inclus, l'extraction annonce `--blanc`, `--contexte`
  # et `--solid` comme des jetons definis jamais consommes. Les trois n'existent
  # que dans de la PROSE, dans des commentaires qui racontent une decision.
  # Le SCSS de ce projet est commente a 56 % : ignorer cette regle ne produit
  # pas quelques faux positifs, ca produit une carte majoritairement fausse.
  def sans_commentaires_css(s)
    s = s.gsub(%r{/\*.*?\*/}m) { |m| blanchir(m) }
    # `//` de Sass, mais pas celui d'une `url(https://...)`.
    s.gsub(%r{(^|[^:])//[^\n]*}) { |m| m[0] + blanchir(m[1..]) }
  end

  # ⚠️ UN SCANNER, PAS UNE REGEXP, et la raison tient en un caractere : `/`.
  # En JavaScript il est soit une division, soit le debut d'un litteral
  # d'expression reguliere. `script.js` en contient (le garde-fou hexadecimal
  # de `dither.js`, les normalisations de `script.js`), et une regexp qui
  # contiendrait `//` ou `/*` ferait sauter tout le reste du fichier.
  # L'heuristique est celle des vrais analyseurs : apres `( , = : [ ! & | ? { } ;`
  # ou en debut de fichier, un `/` ouvre une regexp ; sinon c'est une division.
  def sans_commentaires_js(s)
    out = s.dup
    i = 0
    n = s.length
    dernier_signifiant = nil
    while i < n
      c = s[i]
      case c
      when '"', "'", "`"
        j = i + 1
        j += 1 while j < n && !(s[j] == c && s[j - 1] != "\\")
        i = j + 1
        dernier_signifiant = c
        next
      when "/"
        suivant = s[i + 1]
        if suivant == "/"
          j = s.index("\n", i) || n
          out[i...j] = " " * (j - i)
          i = j
          next
        elsif suivant == "*"
          j = (s.index("*/", i + 2) || (n - 2)) + 2
          out[i...j] = blanchir(s[i...j])
          i = j
          next
        elsif dernier_signifiant.nil? || "(,=:[!&|?{};\n".include?(dernier_signifiant)
          # Litteral d'expression reguliere : on le saute SANS le blanchir, il
          # peut contenir du contenu utile (un motif de classe, par exemple).
          j = i + 1
          j += 1 while j < n && !(s[j] == "/" && s[j - 1] != "\\") && s[j] != "\n"
          i = j + 1
          dernier_signifiant = "/"
          next
        end
      end
      dernier_signifiant = c unless c =~ /\s/
      i += 1
    end
    out
  end

  # ⚠️ MEME REGLE QUE POUR LE CSS, ET J'AI OUBLIE DE L'APPLIQUER ICI D'ABORD.
  # La passe build lit `_config.yml`, le `Gemfile` et le workflow comme du TEXTE
  # pour y chercher des motifs (`bundler-cache: false`, `gem "webrick"`). Le jour
  # ou ces reglages ont ete corriges, les commentaires qui EXPLIQUAIENT l'ancien
  # etat contenaient encore ces motifs : la carte a donc continue d'annoncer deux
  # defauts qu'on venait de fermer, en lisant sa propre explication de leur
  # fermeture.
  # Une sonde qui lit du texte doit toujours depouiller les commentaires. C'est
  # la meme lecon que pour le SCSS, payee deux fois.
  # Le `#` n'est traite comme un commentaire que s'il ouvre la ligne ou suit une
  # espace : `"#fff"` et `https://x#y` restent intacts.
  def sans_commentaires_diese(s)
    s.gsub(/(^|\s)#[^\n]*/) { "#{Regexp.last_match(1)}#{blanchir(Regexp.last_match(0)[1..])}" }
  end

  def sans_commentaires_html(s)
    s = s.gsub(/<!--.*?-->/m) { |m| blanchir(m) }
    s.gsub(/\{%-?\s*comment\s*-?%\}.*?\{%-?\s*endcomment\s*-?%\}/m) { |m| blanchir(m) }
  end

  def numero_ligne(texte, offset) = texte[0...offset].count("\n") + 1

  # ── Marche d'AST Liquid ──────────────────────────────────────────────────
  #
  # ⚠️ IL FAUT `require "jekyll"` AVANT DE PARSER, et ce n'est pas un detail de
  # confort. Mesure faite : avec Liquid seul, les nœuds `include` de
  # `_includes/projects/project-main.html` sortent avec `attrs={}`, donc LES
  # PARAMETRES SONT SILENCIEUSEMENT PERDUS. C'est Jekyll qui enregistre son
  # propre `IncludeTag` a la place de celui de Liquid. Une carte batie sur
  # Liquid seul afficherait « aucun include ne prend de parametre », ce qui est
  # faux et ne se signale nulle part.
  def parcourir(nœud, &bloc)
    return unless nœud.respond_to?(:nodelist)

    liste = begin
      nœud.nodelist
    rescue StandardError
      nil
    end
    return unless liste

    liste.compact.each do |enfant|
      bloc.call(enfant)
      parcourir(enfant, &bloc)
    end
  end

  # Toutes les recherches de variables d'un gabarit, sous forme de chaines
  # pointees (`site.data.projects.index.order`). Sert aux passes donnees et
  # includes.
  def lookups(racine)
    vus = []
    parcourir(racine) do |n|
      case n
      when Liquid::Variable
        vus << chaine_lookup(n.name)
        vus.concat(args_de_filtres(n))
        vus.concat(proprietes_de_filtres(n))
      when Liquid::Assign
        vus << chaine_lookup(n.instance_variable_get(:@from))
        vus.concat(args_de_filtres(n.instance_variable_get(:@from)))
        vus.concat(proprietes_de_filtres(n.instance_variable_get(:@from)))
      when Liquid::If, Liquid::Unless, Liquid::Case
        n.instance_variable_get(:@blocks)&.each do |b|
          cond = b.respond_to?(:left) ? b : nil
          next unless cond

          vus << chaine_lookup(cond.left)
          vus << chaine_lookup(cond.right)
        end
      when Liquid::For
        vus << chaine_lookup(n.instance_variable_get(:@collection_name))
      end
    end
    vus.compact.uniq
  end

  # ⚠️ LES ARGUMENTS DE FILTRE PORTENT DE VRAIES LECTURES, et les ignorer a
  # produit deux fausses accusations de cle morte, toutes deux sur des chemins
  # bien vivants :
  #   `seo.meta_description | default: seo.description`  ->  la description SEO
  #     des 20 projets etait declaree jamais lue, alors que c'est elle qui sert
  #     en pratique (la premiere branche, elle, n'existe dans aucun fichier).
  #   `pieces | concat: project.thumbnails`              ->  les vignettes de
  #     8 projets etaient declarees jamais lues.
  # Un filtre n'est pas une impasse : `default:` et `concat:` prennent en
  # argument le chemin qui compte.
  def args_de_filtres(variable)
    return [] unless variable.respond_to?(:filters)

    variable.filters.to_a.flat_map do |(_nom, args, *)|
      Array(args).map { |a| chaine_lookup(a) }
    end.compact
  rescue StandardError
    []
  end

  # ⚠️ CERTAINS FILTRES CHANGENT LA PROFONDEUR DU CHEMIN, ET LES IGNORER FAIT
  # DECLARER MORTE UNE DONNEE VIVANTE. `{% assign a = site.data.avis | where:
  # "projet", x | first %}` ne lie pas `a` a la COLLECTION mais a UN de ses
  # ELEMENTS : ce qu'on lit ensuite en `a.texte` vaut `site.data.avis.*.texte`,
  # cinq segments, et non `site.data.avis.texte`, quatre. La confrontation
  # exige `lue.size >= definie.size`, donc le chemin trop court ne matchait
  # aucune cle definie et TOUT `_data/avis.yml` sortait « qu'aucun gabarit ne
  # lit », alors que la fiche Banana Rush affichait l'avis a l'ecran.
  # C'est exactement le meme decalage que la boucle `for`, qui lui est deja
  # traite (`table[cible] << "#{src}.*"`), sauf qu'il passe par un filtre.
  # ⚠️ La liste est FERMEE et courte expres : seuls les filtres qui prennent UN
  # element dans une liste. `where`, `sort`, `reverse`, `uniq` et `concat`
  # rendent une liste, ils ne decalent rien. Elargir cette liste au hasard
  # rendrait la carte muette, ce qui est la meme chose qu'une carte fausse.
  REDUCTEURS = %w[first last sample].freeze

  # Vrai si la chaine de filtres finit par extraire un element de la collection.
  def reduit_a_un_element?(variable)
    return false unless variable.respond_to?(:filters)

    variable.filters.to_a.any? { |(nom, *)| REDUCTEURS.include?(nom.to_s) }
  rescue StandardError
    false
  end

  # ⚠️ UN NOM DE CHAMP PASSE EN CHAINE A UN FILTRE EST UNE LECTURE, et c'est la
  # seule forme de lecture qui n'apparait nulle part comme chemin.
  # `site.data.avis | where: "publiable", true` lit bel et bien `publiable` sur
  # chaque element, mais le nom du champ est un LITTERAL : aucun
  # `VariableLookup` ne le porte, donc `args_de_filtres` le laisse tomber et la
  # carte declarait mortes `projet` et `publiable` de `_data/avis.yml`. Ce sont
  # les deux cles dont tout le rendu depend, et `publiable: false` est la garde
  # qui tient les trois avis de BoostFollowers hors du site. Une carte qui
  # invite a les supprimer est pire qu'une carte muette.
  # ⚠️ Liste fermee, et `where_exp` en est ABSENT expres : son argument est une
  # expression a parser (`"item.a > 2"`), pas un nom de champ. Le prendre pour
  # un nom fabriquerait une cle qui n'existe pas.
  PROPRIETES = %w[where find group_by sort sort_natural map].freeze

  # Les chemins lus « par leur nom » a travers un filtre, sous la forme
  # `<source>.*.<champ>` : le `*` parce que le filtre s'applique a CHAQUE
  # element de la collection.
  def proprietes_de_filtres(variable)
    return [] unless variable.respond_to?(:filters)

    src = chaine_lookup(variable)
    return [] unless src

    variable.filters.to_a.filter_map do |(nom, args, *)|
      next unless PROPRIETES.include?(nom.to_s)

      champ = Array(args).first
      next unless champ.is_a?(String) && champ.match?(/\A[a-z_][\w-]*\z/i)

      "#{src}.*.#{champ}"
    end
  rescue StandardError
    []
  end

  # Un `Liquid::VariableLookup` porte son nom et ses cles ; tout le reste
  # (litteraux, expressions filtrees) rend nil, ce qui vaut INDETERMINE.
  def chaine_lookup(v)
    v = v.name if v.respond_to?(:name) && v.is_a?(Liquid::Variable)
    return nil unless v.is_a?(Liquid::VariableLookup)

    bouts = [v.name.to_s]
    v.lookups.each do |l|
      bouts << (l.is_a?(String) ? l : "*")
    end
    bouts.join(".")
  rescue StandardError
    nil
  end

  # ── Comptage de couverture ───────────────────────────────────────────────
  #
  # ⚠️ CE COMPTEUR EST LA CONTREPARTIE DE `INDETERMINE`. Sans lui, une carte
  # qui ne sait rien resoudre affiche « aucun probleme » et parait excellente.
  # Le nombre d'indetermines est donc publie EN TETE du fichier : s'il monte,
  # la carte est devenue moins fiable et elle le dit d'elle-meme.
  class Couverture
    attr_reader :cas

    def initialize = @cas = []

    def indetermine(categorie, ou, pourquoi)
      @cas << { categorie: categorie, ou: ou, pourquoi: pourquoi }
    end

    def total = @cas.size
    def par_categorie = @cas.group_by { |c| c[:categorie] }.transform_values(&:size)
  end
end
