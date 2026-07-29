# frozen_string_literal: true

# ══════════════════════════════════════════════════════════════════════════
#  LES PAGES PROJET ET SERVICE SONT ENGENDREES, PLUS ECRITES
# ══════════════════════════════════════════════════════════════════════════
#
# Avant le 29/07/2026, 48 fichiers existaient dans le depot pour ne rien faire
# d'autre que nommer un enregistrement de donnees : sept lignes de front matter
# pour une page projet, onze pour un service, puis un seul `include`. Les 40
# pages projet etaient IDENTIQUES au caractere pres, a l'identifiant pres.
#
# Ce que ca coutait : l'URL d'une page vivait a cinq endroits (le chemin du
# fichier, `locales.<lang>.url`, `canonical_url`, `hreflang_alternate`,
# `detail_url`) sans que rien ne verifie qu'ils s'accordent. Et ajouter un projet
# demandait de creer deux fichiers a la main, donc de pouvoir les oublier.
#
# Desormais la liste d'ORDRE est la liste d'EXISTENCE : un projet absent de
# `_data/projects/index.yml` n'a pas de page, un projet present en a deux.
#
# ══════════════════════════════════════════════════════════════════════════
#  POURQUOI CE PLUGIN PEUT EXISTER
# ══════════════════════════════════════════════════════════════════════════
#
# GitHub Pages interdit les plugins... quand c'est LUI qui construit. Ici ce
# n'est pas le cas : `.github/workflows/deploy.yml` lance `bundle exec jekyll
# build` sur `ubuntu-latest` puis televerse `_site/`. Le `Gemfile` ne contient
# pas la gem `github-pages`. `_plugins/` s'execute donc, et ce depot ne s'en
# etait jamais servi.
# ⚠️ Si le deploiement repassait un jour par le constructeur integre de Pages, ce
# fichier cesserait de s'executer EN SILENCE et 48 pages disparaitraient. Le
# repli est prevu et documente dans le plan : un script qui ecrit les memes 48
# fichiers, avec un mode `--check` pour detecter la derive.

module Jekyll
  class PagesGenerees < Generator
    safe true
    priority :high

    def generate(site)
      @site = site
      @vus = {}
      generer_projets
      generer_services
    end

    private

    # ── Les 40 pages projet ─────────────────────────────────────────────────
    def generer_projets
      ordre = @site.data.dig("projects", "index", "order")
      raise "pages_generees : _data/projects/index.yml n'a pas de cle `order`" unless ordre.is_a?(Array)

      ordre.each do |id|
        projet = @site.data.dig("projects", id)
        raise "pages_generees : `#{id}` est dans index.yml mais _data/projects/#{id}.yml n'existe pas" if projet.nil?

        %w[fr en].each do |lang|
          # ⚠️ LA CLE EST `locales.<lang>.url`, JAMAIS LE SLUG, et ce n'est pas
          # une precaution theorique : `_data/projects/ottony.yml` porte
          # `slug: ottony` pour les URLs `/fr/projects/ottony-paris.html` et
          # `/en/projects/ottony-paris.html`. Un generateur indexe sur le slug ou
          # sur le nom de fichier RENOMMERAIT deux URLs vivantes, et rien dans le
          # build ne le signalerait.
          url = projet.dig("locales", lang, "url")
          if url.nil? || url.empty?
            raise "pages_generees : _data/projects/#{id}.yml n'a pas de `locales.#{lang}.url`. " \
                  "Sans elle, l'URL de la page serait devinee, et c'est exactement ce qu'on refuse."
          end

          # ⚠️ LA LIGNE VIDE EN TETE N'EXISTE PAS, ET IL A FALLU LA MESURER.
          # Les fichiers projet supprimes portaient une ligne vide entre le front
          # matter et l'include, les fichiers service non. J'en ai deduit qu'il
          # fallait reproduire les deux formes : faux. La regexp de front matter
          # de Jekyll est `\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)`, et le `\s*`
          # avant le `$` AVALE la ligne vide. Mesure faite sur les deux fichiers
          # d'origine : `page.content` valait exactement la meme chaine.
          # Ce qui compte n'est pas ce que contient le fichier, c'est ce que son
          # lecteur en garde.
          #
          # ⚠️ LE SAUT DE LIGNE FINAL, LUI, EST UN ARBITRAGE, PAS UNE REPRODUCTION.
          # Les 40 fichiers n'etaient pas uniformes : 29 se terminaient par un
          # saut de ligne, 11 non, au hasard des editions a la main. Le diff
          # d'empreintes l'a revele en basculant d'un ensemble a son complementaire
          # selon la forme choisie ici.
          # Un generateur produit forcement quelque chose d'uniforme. On aligne
          # donc sur la majorite, et 11 pages gagnent une ligne vide dans leur
          # source HTML, ce qui ne change RIEN au rendu (la preuve est faite par
          # comparaison a espaces normalises).
          # C'est le generateur qui SUPPRIME une incoherence, pas qui en cree une.
          poser(url, "default", lang,
                { "project_id" => id },
                "{% include projects/project-main.html project_id=page.project_id %}\n")
        end
      end
    end

    # ── Les 8 pages service ─────────────────────────────────────────────────
    def generer_services
      services = @site.data["services"] || {}

      # ⚠️ ON N'ITERE PAS SUR `index.yml`, ET C'EST DELIBERE. Son `order` ne liste
      # que TROIS services alors que quatre existent : `graphic-design` en est
      # absent. Iterer dessus supprimerait donc deux pages vivantes
      # (`/fr/services/conception-graphique.html` et sa jumelle) sans rien dire.
      # Cet oubli est un vrai defaut, mais c'est un defaut de NAVIGATION (ces deux
      # pages n'ont aucun lien entrant), pas d'existence. Il se corrige dans les
      # donnees, pas ici.
      services.each do |id, service|
        next if id == "index"
        next unless service.is_a?(Hash) && service["detail_url"].is_a?(Hash)

        %w[fr en].each do |lang|
          url = service.dig("detail_url", lang)
          raise "pages_generees : _data/services/#{id}.yml n'a pas de `detail_url.#{lang}`" if url.nil?

          seo = service.dig("seo", lang) || {}
          autre = lang == "fr" ? "en" : "fr"
          jumelle = service.dig("detail_url", autre)

          # ⚠️ `canonical_url` ET `hreflang_alternate` SONT DERIVES, pas recopies.
          # Verifie sur les 8 pages avant la bascule : `canonical_url` valait
          # exactement `site.url + detail_url[lang]`. Les garder en donnees, ce
          # serait autoriser qu'ils divergent un jour de l'URL reelle, ce qui est
          # precisement le defaut que ce lot supprime.
          donnees = {
            "service_id" => id,
            "title" => seo["title"],
            "meta_description" => seo["meta_description"],
            "og_title" => seo["og_title"],
            "og_description" => seo["og_description"],
            "canonical_url" => "#{@site.config['url']}#{url}"
          }
          donnees["hreflang_alternate"] = "#{@site.config['url']}#{jumelle}" if jumelle

          # Les pages service n'avaient PAS de ligne vide, contrairement aux
          # pages projet. On reproduit chaque famille telle qu'elle etait.
          poser(url, "default", lang, donnees.compact,
                "{% include services/service-main.html service_id=page.service_id %}\n")
        end
      end
    end

    # ── La fabrique ─────────────────────────────────────────────────────────
    def poser(url, layout, lang, donnees, contenu)
      dir  = File.dirname(url)
      nom  = File.basename(url)

      # Filet contre la collision. Si un fichier source visait la meme sortie,
      # Jekyll ecrirait les deux et le gagnant dependrait de l'ordre : un des
      # deux contenus partirait en production sans qu'on sache lequel.
      # C'est le seul vrai risque de ce plugin, et il ne peut se produire que
      # pendant la bascule, si les 48 fichiers n'etaient pas supprimes dans le
      # MEME commit.
      if @vus[url]
        raise "pages_generees : deux pages visent #{url}"
      end
      source = File.join(@site.source, url.delete_prefix("/"))
      if File.exist?(source)
        raise "pages_generees : #{url} est engendree ET presente en source (#{source}). " \
              "Supprimer le fichier : sinon Jekyll ecrit les deux et le gagnant depend de l'ordre."
      end
      @vus[url] = true

      page = PageWithoutAFile.new(@site, @site.source, dir, nom)
      page.data["layout"] = layout
      page.data["lang"]   = lang
      donnees.each { |k, v| page.data[k] = v }
      page.content = contenu

      # ⚠️ NE JAMAIS POSER `page.data["path"]`. `Jekyll::Page#path` retombe sur
      # `relative_path` (jekyll/page.rb), qui vaut `dir/nom` : c'est ce que
      # `sitemap.xml` interroge avec `page.path contains 'fr/projects/'`. Le
      # forcer romprait le filtre du sitemap sans casser le build, donc en
      # silence.
      @site.pages << page
    end
  end
end
