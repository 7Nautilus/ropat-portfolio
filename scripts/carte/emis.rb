# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  L'ORACLE : ce que le site EMET reellement
# ══════════════════════════════════════════════════════════════════════════
#
# ⚠️ C'EST LA DECISION CENTRALE DE TOUTE LA CARTE, et elle tient en une phrase :
#
#     `_site` dit le FAIT, les sources disent l'INTENTION.
#
# Aucune affirmation sur ce qui est emis n'est jamais inferee du Liquid. La
# raison est mesuree : ce depot construit des classes par concatenation
# (`class="project-piece--{{ rythme }}"`, `class="btn btn--{{ variant }}"`), et
# une carte qui lit les SOURCES declare ces classes-la absentes du HTML, ce qui
# est faux. Le sondage a produit exactement cette famille de faux positifs, sur
# `.btn--solid`, `.project-open--contexte`, `.galerie-plus` et huit autres.
# En lisant `_site`, la question ne se pose meme plus : la classe y est ou n'y
# est pas.
#
# Le prix de cette decision est qu'il faut un `_site` A JOUR, d'ou le verrou de
# peremption ci-dessous. La carte prefere refuser de repondre plutot que de
# repondre sur un build d'avant-hier.

module Carte
  class Emis
    ATTRS_INTERESSANTS = %w[id class role src href poster srcset style].freeze

    attr_reader :pages, :classes, :ids, :attributs, :references, :perime, :date_build,
                :lu_dans, :avertissement

    def initialize(couverture)
      @couverture = couverture
      @pages      = {}   # chemin relatif dans _site => { classes:, ids:, attrs:, refs: }
      @classes    = {}   # classe => [pages]
      @ids        = {}   # id => [pages]
      @attributs  = {}   # "data-xxx" => [pages]
      @references = {}   # chemin d'asset => [pages]
      @perime     = nil
      charger
    end

    def existe? = !@pages.empty?
    def nb_pages = @pages.size

    def classe?(c)   = @classes.key?(c)
    def id?(i)       = @ids.key?(i)
    def attribut?(a) = @attributs.key?(a)

    private

    def charger
      racine = Carte.dossier_build
      @lu_dans = Carte.relatif(racine)
      unless Dir.exist?(racine)
        @perime = "aucun build a lire. Lancer `bundle exec ruby scripts/carte.rb --build`."
        return
      end
      unless Carte.build_prive?
        @avertissement = "lecture de `_site`, qui appartient au serveur de developpement. "                          "Un `jekyll serve` en cours le reecrit avec SA configuration de demarrage. "                          "Preferer `--build`, qui construit dans `.carte/site`."
      end

      fichiers = Dir.glob(File.join(racine, "**", "*.html"))
      if fichiers.empty?
        @perime = "_site ne contient aucune page HTML."
        return
      end

      @date_build = fichiers.map { |f| File.mtime(f) }.max
      verifier_peremption

      fichiers.sort.each do |f|
        rel = f.delete_prefix(racine + "/")
        depouiller(rel, Carte.lire(f))
      end
    end

    # ⚠️ LE VERROU DE PEREMPTION. Sans lui, la carte reste plausible en etant
    # fausse : elle repondrait sur un build d'avant les derniers changements, ce
    # qui est exactement le mode de defaillance le plus difficile a voir, parce
    # que rien n'a l'air casse. Au moment ou ce fichier a ete ecrit, le depot
    # etait DEJA dans cet etat : `main.css` datait du 29/07 00:13 et `_site` du
    # 28/07 12:19. La carte aurait donc menti des son premier lancement.
    def verifier_peremption
      # ⚠️ NE COMPARER QUE CE QUE JEKYLL LIT VRAIMENT. Une premiere version
      # comparait TOUS les fichiers du depot, donc editer la carte elle-meme la
      # declarait perimee : un verrou qui se declenche sur son propre auteur
      # crie a chaque lancement et finit par etre ignore, ce qui revient a ne
      # pas l'avoir. On retire donc ce qui est exclu du build, plus les sorties
      # de la carte.
      exclus = %w[scripts/ CARTE.md .carte/ TODO.md VEILLE.md CLAUDE.md DESIGN.md README.md docs/]
      sources = Carte.fichiers("**/*").reject do |f|
        rel = Carte.relatif(f)
        f.include?("/_site/") || f.include?("/.carte/") || exclus.any? { |e| e.end_with?("/") ? rel.start_with?(e) : rel == e }
      end
      plus_recente = sources.max_by { |f| File.mtime(f) }
      return unless plus_recente && File.mtime(plus_recente) > @date_build

      @perime = "#{Carte.relatif(plus_recente)} (#{File.mtime(plus_recente).strftime('%d/%m %H:%M')}) " \
                "est plus recent que _site (#{@date_build.strftime('%d/%m %H:%M')})"
    end

    def depouiller(page, html)
      # ⚠️ DEPOUILLER LES COMMENTAIRES HTML, MEME ICI. Le layout porte un
      # commentaire expliquant que le fond dither a remplace `main-bg.webp` : ce
      # nom de fichier apparait donc dans les 63 pages construites sans etre
      # reference nulle part. Une verification faite au grep concluait que
      # l'image servait encore, alors qu'elle est bien orpheline.
      # C'est la meme regle que pour le SCSS et pour la passe build. Troisieme
      # fois qu'elle se paye.
      html = Carte.sans_commentaires_html(html)

      infos = { classes: Set.new, ids: Set.new, attrs: Set.new, refs: Set.new,
                titres: [], aria: Set.new }

      html.scan(/class\s*=\s*(["'])(.*?)\1/m) do |_q, v|
        v.split(/\s+/).reject(&:empty?).each { |c| infos[:classes] << c }
      end
      html.scan(/\bid\s*=\s*(["'])(.*?)\1/) { |_q, v| infos[:ids] << v.strip unless v.strip.empty? }

      # data-* et aria-*, avec leur valeur quand elle est courte : le contrat
      # entre les trois couches se joue autant sur la valeur (`data-encre="sombre"`)
      # que sur le nom.
      html.scan(/\b((?:data|aria)-[a-z0-9-]+)(?:\s*=\s*(["'])(.*?)\2)?/) do |nom, _q, val|
        infos[:attrs] << nom
        infos[:attrs] << "#{nom}=#{val}" if val && val.length <= 24 && !val.empty?
      end
      html.scan(/\brole\s*=\s*(["'])(.*?)\1/) { |_q, v| infos[:aria] << "role=#{v}" }

      # References d'assets. `data-src` compte comme une reference, mais la passe
      # assets distingue ensuite avide et differe.
      html.scan(/\b(?:src|data-src|href|poster)\s*=\s*(["'])(.*?)\1/) do |_q, v|
        infos[:refs] << v.strip
      end
      html.scan(/srcset\s*=\s*(["'])(.*?)\1/m) do |_q, v|
        v.split(",").each { |b| infos[:refs] << b.strip.split(/\s+/).first.to_s }
      end
      html.scan(/url\((["']?)([^)"']+)\1\)/) { |_q, v| infos[:refs] << v.strip }

      # ⚠️ LES `<meta content=>` SONT DE VRAIES REFERENCES, et les oublier a
      # failli faire supprimer SEPT images vivantes. Les images Open Graph et
      # Twitter ne sont citees nulle part ailleurs : elles n'apparaissent ni en
      # `src` ni en `href`, seulement en `content`. La carte les rangeait donc
      # parmi les orphelines, avec une taille et une invitation a les supprimer.
      # Ce sont pourtant les images que voit quiconque partage un lien du site.
      html.scan(/<meta\b[^>]*\bcontent\s*=\s*(["'])(.*?)\1/im) do |_q, v|
        infos[:refs] << v.strip if v =~ %r{/assets/|\.(?:avif|webp|jpe?g|png|svg|mp4)\z}i
      end

      # ⚠️ LES PROPRIETES PERSONNALISEES POSEES EN LIGNE. Sans cette lecture, la
      # carte annonce `--animate-delay` et `--swatch-color` comme consommes en
      # CSS et definis NULLE PART, donc comme des jetons fantomes. Ils sont bien
      # definis, mais dans un attribut `style=` emis par
      # `_includes/projects/project-main.html`. Deux fausses alertes sur onze,
      # c'est assez pour discrediter toute la section.
      html.scan(/style\s*=\s*(["'])(.*?)\1/m) do |_q, v|
        v.scan(/(--[a-zA-Z0-9_-]+)\s*:/) { |(jeton)| infos[:attrs] << "style:#{jeton}" }
      end

      html.scan(%r{<h([1-6])[^>]*>}i) { |(n)| infos[:titres] << n.to_i }

      @pages[page] = infos
      infos[:classes].each { |c| (@classes[c] ||= []) << page }
      infos[:ids].each     { |i| (@ids[i] ||= []) << page }
      infos[:attrs].each   { |a| (@attributs[a] ||= []) << page }
      infos[:refs].each    { |r| (@references[r] ||= []) << page }
    end
  end
end
