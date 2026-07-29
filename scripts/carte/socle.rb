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
  IGNORES = %w[_site .git .jekyll-cache node_modules vendor .carte .impeccable].freeze

  module_function

  def chemin(*bouts) = File.join(RACINE, *bouts)

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

  # Tous les fichiers du depot, hors repertoires ignores.
  def fichiers(motif)
    Dir.glob(File.join(RACINE, motif), File::FNM_DOTMATCH).reject do |f|
      rel = f.delete_prefix(RACINE + "/")
      IGNORES.any? { |d| rel == d || rel.start_with?("#{d}/") } || File.directory?(f)
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
      when Liquid::Assign
        vus << chaine_lookup(n.instance_variable_get(:@from))
        vus.concat(args_de_filtres(n.instance_variable_get(:@from)))
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
