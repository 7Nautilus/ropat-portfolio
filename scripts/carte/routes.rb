# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  PASSE 1 : LES ROUTES
# ══════════════════════════════════════════════════════════════════════════
#
# ⚠️ LE SITE N'A PAS DE SOURCE DE VERITE POUR SA PROPRE TABLE DE ROUTES, et
# c'est le defaut structurel le plus couteux du depot. L'URL d'une page vit
# simultanement a CINQ endroits :
#
#   1. le chemin du fichier source        fr/projects/ottony-paris.html
#   2. `locales.<lang>.url` du YAML       /fr/projects/ottony-paris.html
#   3. `canonical_url` du front matter    https://ropat.art/fr/projects/...
#   4. `hreflang_alternate`               l'URL jumelle
#   5. `detail_url.<lang>` (services)     /fr/services/...
#
# Rien ne verifie que les cinq s'accordent, et ils ne s'accordent PAS : cinq
# pages emettent aujourd'hui un lien de bascule et un `<link rel="alternate">`
# vers des URLs qui n'existent pas. Cette passe est donc le controle qui
# manquait, et elle doit rester vraie apres que les pages seront generees.
#
# ⚠️ ET LE SLUG N'EST PAS L'URL. `_data/projects/ottony.yml` porte `slug: ottony`
# pour des URLs `ottony-paris.html`. Toute mecanique qui deduirait l'URL du slug
# renommerait deux URLs vivantes sans que rien ne le signale.

module Carte
  class Routes
    Route = Struct.new(:source, :url, :sortie, :lang, :layout, :front, :produite, keyword_init: true)

    attr_reader :routes, :anomalies

    def initialize(couverture, emis)
      @couverture = couverture
      @emis       = emis
      @routes     = []
      @anomalies  = []
      collecter
      verifier_jumeaux
      verifier_liens_de_langue
    end

    private

    # ⚠️ HONORER `exclude`, SINON LA CARTE INVENTE DES ROUTES CASSEES. `DESIGN.md`
    # porte un front matter et calculerait donc l'URL `/DESIGN.html`, absente de
    # `_site` puisque `_config.yml` l'exclut. Sans ce filtre, le controle qui
    # valide la regle d'URL se remplit de faux positifs et cesse d'etre lisible,
    # donc cesse d'etre lu.
    def exclus
      @exclus ||= Carte.liste_exclue(
        File.exist?(Carte.chemin("_config.yml")) ? Carte.lire(Carte.chemin("_config.yml")) : nil
      )
    end

    def exclu?(rel)
      exclus.any? { |e| e.end_with?("/") ? rel.start_with?(e) : rel == e }
    end

    def collecter
      Carte.fichiers("**/*.{html,xml,md}").each do |f|
        front = front_matter(f)
        next unless front # sans front matter, Jekyll copie sans traiter

        rel = Carte.relatif(f)
        next if exclu?(rel)
        url, sortie = url_de(rel)
        @routes << Route.new(
          source: rel, url: url, sortie: sortie,
          lang: front["lang"], layout: front["layout"], front: front,
          produite: @emis.pages.key?(sortie)
        )
      end
      # ⚠️ LES PAGES ENGENDREES N'ONT PAS DE SOURCE, ET LES OUBLIER REND LA
      # SECTION AVEUGLE. Depuis que `_plugins/pages_generees.rb` produit les 48
      # pages projet et service, une table de routes batie sur les seuls fichiers
      # sources n'en connait plus que 15 sur 63. La carte affichait donc une
      # table qui avait l'air complete et qui ignorait les trois quarts du site.
      # On complete depuis l'oracle : toute page emise qu'aucune source ne
      # revendique est une page engendree.
      revendiquees = @routes.map(&:sortie).to_set
      @emis.pages.each_key do |sortie|
        next if revendiquees.include?(sortie)

        front = front_matter_emis(sortie)
        @routes << Route.new(
          source: "(engendree)", url: url_depuis_sortie(sortie), sortie: sortie,
          lang: front[:lang], layout: nil, front: front[:front], produite: true
        )
      end

      @routes.sort_by!(&:url)

      # ⚠️ LE CONTROLE QUI VALIDE LA REGLE PLUTOT QUE DE LA SUPPOSER. Au lieu de
      # reimplementer `Jekyll::Page#template` et d'esperer, on calcule l'URL puis
      # on verifie que le fichier correspondant existe VRAIMENT dans `_site`.
      # Si la regle etait fausse, cette liste se remplirait immediatement.
      # Une sortie non HTML n'est pas dans l'oracle (qui ne lit que le HTML) :
      # on verifie son existence sur le disque.
      @routes.each do |r|
        next if r.produite || !r.sortie.end_with?(".xml", ".txt")

        r.produite = File.exist?(File.join(Carte.dossier_build, r.sortie))
      end

      manquantes = @routes.reject(&:produite)
      return if manquantes.empty?

      @anomalies << {
        titre: "Sources dont la sortie calculee est introuvable dans _site",
        detail: "Soit la page est exclue par `_config.yml`, soit la regle d'URL de la carte est fausse.",
        cas: manquantes.map { |r| "#{r.source} -> #{r.sortie}" }
      }
    end

    # Une page engendree n'a pas de front matter a lire : on retrouve dans le
    # HTML produit les deux seules choses dont la passe a besoin, la langue et
    # l'URL jumelle declaree.
    def front_matter_emis(sortie)
      html = Carte.lire(File.join(Carte.dossier_build, sortie))
      lang = html[/<html[^>]*\blang\s*=\s*["']([a-z-]+)["']/i, 1]
      alt  = html.scan(/<link\b[^>]*rel\s*=\s*["']alternate["'][^>]*>/i)
                 .map { |b| [b[/hreflang\s*=\s*["']([\w-]+)["']/i, 1], b[/href\s*=\s*["']([^"']+)["']/i, 1]] }
                 .to_h
      autre = lang == "fr" ? "en" : "fr"
      { lang: lang, front: alt[autre] ? { "hreflang_alternate" => alt[autre] } : {} }
    end

    def url_depuis_sortie(sortie)
      return "/#{sortie.delete_suffix('index.html')}" if sortie.end_with?("index.html")

      "/#{sortie}"
    end

    def front_matter(f)
      tete = File.binread(f, 4096).force_encoding("UTF-8").scrub("?")
      return nil unless tete.start_with?("---")

      contenu = Carte.lire(f)
      fin = contenu.index(/^---\s*$/, 3)
      return {} unless fin

      YAML.safe_load(contenu[3...fin], permitted_classes: [Date, Time], aliases: true) || {}
    rescue Psych::Exception => e
      @couverture.indetermine("front matter", Carte.relatif(f), "YAML illisible : #{e.message[0, 60]}")
      {}
    end

    # La regle de `Jekyll::Page#template` : une page nommee `index` sort sur le
    # repertoire, tout le reste garde son nom de base plus l'extension.
    def url_de(rel)
      dir  = File.dirname(rel)
      dir  = "" if dir == "."
      base = File.basename(rel, ".*")
      ext  = File.extname(rel)
      ext  = ".html" if ext == ".md"

      if ext == ".html" && base == "index"
        url    = dir.empty? ? "/" : "/#{dir}/"
        sortie = dir.empty? ? "index.html" : "#{dir}/index.html"
      else
        url    = dir.empty? ? "/#{base}#{ext}" : "/#{dir}/#{base}#{ext}"
        sortie = dir.empty? ? "#{base}#{ext}" : "#{dir}/#{base}#{ext}"
      end
      [url, sortie]
    end

    # ── Jumeaux de langue ────────────────────────────────────────────────────
    def verifier_jumeaux
      sans_jumeau = []
      @routes.each do |r|
        next unless r.lang
        next if r.front["no_alternate"]

        autre = r.lang.to_s == "fr" ? "en" : "fr"
        attendue = jumelle_attendue(r, autre)
        next unless attendue

        existe = @routes.any? { |x| x.url == attendue }
        sans_jumeau << { source: r.source, lang: r.lang, visee: attendue } unless existe
      end
      return if sans_jumeau.empty?

      @anomalies << {
        titre: "Pages dont le jumeau de langue calcule n'existe pas",
        detail: "Chacune produit un lien de bascule et un `<link rel=\"alternate\">` vers une URL absente.",
        cas: sans_jumeau.map { |c| "#{c[:source]} (#{c[:lang]}) vise #{c[:visee]}" }
      }
    end

    # On reproduit ici la meme substitution naive que `_includes/lang-selector.html`
    # et `_layouts/default.html`, EXPRES : le but de la carte est de montrer ou
    # cette substitution se trompe, pas de la corriger.
    def jumelle_attendue(route, autre)
      if (h = route.front["hreflang_alternate"])
        return h.to_s.sub(%r{\Ahttps?://[^/]+}, "")
      end
      return nil unless route.url.start_with?("/fr/", "/en/")

      route.url.sub(%r{\A/(fr|en)/}, "/#{autre}/")
    end

    # ── Le controle qui compte : les liens reellement EMIS resolvent-ils ? ───
    #
    # Les deux precedents lisent les sources. Celui-ci lit `_site` : il prend
    # chaque `href` de bascule et chaque `<link rel="alternate">` REELLEMENT
    # produits, et verifie qu'ils tombent sur un fichier existant. C'est
    # l'invariant a zero que le lot D doit atteindre.
    def verifier_liens_de_langue
      return unless @emis.existe?

      casses = []
      racine = Carte.dossier_build

      @emis.pages.each_key do |page|
        html = Carte.lire(File.join(racine, page))

        html.scan(/<a\b[^>]*>/i) do |balise|
          next unless balise.include?("lang-switch-link")

          href = balise[/href\s*=\s*(["'])(.*?)\1/m, 2]
          casses << { page: page, genre: "lien de bascule", cible: href } if href && !cible_existe?(href)
        end

        html.scan(/<link\b[^>]*rel\s*=\s*(["'])alternate\1[^>]*>/i) do
          balise = Regexp.last_match(0)
          next if balise.include?("x-default") && false

          href = balise[/href\s*=\s*(["'])(.*?)\1/m, 2]
          casses << { page: page, genre: "hreflang", cible: href } if href && !cible_existe?(href)
        end
      end

      @liens_verifies = true
      return if casses.empty?

      @anomalies << {
        titre: "Liens de langue EMIS qui ne resolvent vers aucun fichier",
        detail: "Mesure sur `_site`, pas sur les sources. Attendu apres correction : 0.",
        cas: casses.map { |c| "#{c[:page]} : #{c[:genre]} -> #{c[:cible]}" }.uniq
      }
    end

    def cible_existe?(href)
      chemin = href.to_s.sub(%r{\Ahttps?://[^/]+}, "")
      return true unless chemin.start_with?("/") # ancre, mailto, externe

      chemin = chemin.split("#").first.to_s.split("?").first.to_s
      chemin = chemin.delete_prefix("/")
      chemin = chemin.empty? ? "index.html" : chemin
      chemin += "index.html" if chemin.end_with?("/")
      @emis.pages.key?(chemin) || File.exist?(File.join(Carte.dossier_build, chemin))
    end
  end
end
