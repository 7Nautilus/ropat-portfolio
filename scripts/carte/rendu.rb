# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  SORTIE : CARTE.md pour l'humain, .carte/carte.json pour le diff
# ══════════════════════════════════════════════════════════════════════════
#
# ⚠️ AUCUN NOMBRE N'EST TAPE A LA MAIN dans ce fichier. Chacun vient d'une
# mesure de la passe correspondante. La raison est dans les notes du projet :
# la page de labo a longtemps affiche « 113 alias » parce que quelqu'un l'avait
# ecrit, alors que la mesure en donnait 21. Un chiffre ecrit a la main est faux
# des le lendemain et personne ne le sait.

module Carte
  class Rendu
    def initialize(passes, couverture)
      @p = passes
      @c = couverture
    end

    def markdown
      s = +""
      s << entete
      s << fiabilite
      s << section_routes
      s << section_includes
      s << section_donnees
      s << section_css
      s << section_js
      s << section_contrat
      s << section_assets
      s << section_medias
      s << section_build
      s << section_inconnues
      s
    end

    def json
      {
        genere_le: Time.now.utc.iso8601,
        commit: commit,
        pages_construites: @p[:emis].nb_pages,
        perime: @p[:emis].perime,
        indetermines: @c.total,
        routes: @p[:routes].routes.map { |r| { source: r.source, url: r.url, lang: r.lang } },
        includes: @p[:includes].appels.map { |a| "#{a[:depuis]} -> #{a[:vers]}" }.sort.uniq,
        jetons: @p[:css].jetons.keys.sort,
        jetons_sans_consommateur: (@p[:css].jetons.keys - @p[:css].consommations.keys).sort,
        selecteurs_absents: selecteurs_absents,
        selecteurs_poses_par_js: selecteurs_poses_par_js,
        assets_orphelins: @p[:assets].orphelins,
        assets_manquants: @p[:assets].manquants,
        css_octets: @p[:build].faits[:css],
        ratios_faux: (@p[:medias].anomalies.find { |a| a[:titre].start_with?("Ratios DECLARES") } || { cas: [] })[:cas]
      }
    end

    # ── Le mode --diff ───────────────────────────────────────────────────────
    #
    # C'est l'outil de debug pour lequel la carte a ete demandee : apres un
    # changement, il ne dit QUE ce qui a bouge.
    def self.diff(avant, apres)
      lignes = []
      cmp = lambda do |cle, titre, fmt = ->(x) { x.to_s }|
        a = Array(avant[cle.to_s] || avant[cle])
        b = Array(apres[cle] || apres[cle.to_s])
        (b - a).each { |x| lignes << "  + #{titre} : #{fmt.call(x)}" }
        (a - b).each { |x| lignes << "  - #{titre} : #{fmt.call(x)}" }
      end

      ra = Array(avant["routes"]).map { |r| "#{r['url']}  <- #{r['source']}" }
      rb = Array(apres[:routes]).map { |r| "#{r[:url]}  <- #{r[:source]}" }
      (rb - ra).each { |x| lignes << "  + ROUTE : #{x}" }
      (ra - rb).each { |x| lignes << "  - ROUTE : #{x}" }

      cmp.call(:includes, "include")
      cmp.call(:jetons, "jeton")
      cmp.call(:jetons_sans_consommateur, "jeton sans consommateur")
      cmp.call(:selecteurs_absents, "selecteur absent")
      cmp.call(:selecteurs_poses_par_js, "selecteur pose par le JS")
      cmp.call(:assets_orphelins, "asset orphelin")
      cmp.call(:assets_manquants, "ASSET MANQUANT")

      av = avant["indetermines"] || avant[:indetermines]
      ap = apres[:indetermines]
      lignes << "  ! indetermines : #{av} -> #{ap}" if av && ap && av != ap

      lignes
    end

    private

    # ⚠️ PAS DE `2>/dev/null` ICI. Les backticks de Ruby passent par `cmd.exe`
    # sous Windows, qui ne connait pas `/dev/null` : la redirection elle-meme
    # imprimait « Le chemin d'acces specifie est introuvable » a chaque
    # lancement. `IO.popen` avec `err: :close` marche sur les deux systemes.
    def commit
      IO.popen(["git", "-C", Carte::RACINE, "rev-parse", "--short", "HEAD"], err: File::NULL, &:read).to_s.strip
    rescue StandardError
      ""
    end

    # ⚠️ LE TITRE EST LA CLE, DONC IL DOIT DISCRIMINER. Ces deux methodes se
    # ressemblent et ne doivent surtout pas se confondre : la premiere liste ce
    # qu'on peut supprimer, la seconde ce qu'il ne faut pas toucher. Les
    # prefixes sont donc pris aussi longs qu'il le faut pour qu'aucun bloc ne
    # puisse repondre aux deux.
    def selecteurs_absents
      bloc = @p[:css].anomalies.find { |a| a[:titre].start_with?("Selecteurs absents des") }
      bloc ? bloc[:cas].map { |c| c.split(/\s{2,}/).first } : []
    end

    def selecteurs_poses_par_js
      bloc = @p[:css].anomalies.find { |a| a[:titre].start_with?("Selecteurs POSES PAR LE JS") }
      bloc ? bloc[:cas].map { |c| c.split(/\s{2,}/).first } : []
    end

    def entete
      e = @p[:emis]
      <<~MD
        # Carte du depot

        > Generee le #{Time.now.strftime('%d/%m/%Y a %H:%M')}#{commit.empty? ? '' : ", d'apres l'etat de #{commit}"}.
        > (Elle decrit le commit CI-DESSUS et vit dans le SUIVANT : elle se genere forcement
        > avant celui qui l'embarque. Un decalage d'un commit n'est pas une peremption.)
        > **Ne pas editer a la main** : `bundle exec ruby scripts/carte.rb` la reecrit en entier.
        > Pour ne voir que ce qui a bouge : `bundle exec ruby scripts/carte.rb --diff`.

        Cette carte repond a une seule question, sous plusieurs angles : **qu'est-ce qui est branche
        a quoi**. Elle est generee parce qu'un document redige se perime au premier commit
        suivant. Demonstration mesuree pendant sa conception : entre deux relevés a quelques
        jours d'ecart, les `corner-shape` ecrits a la main sont passes de 21 a 32 sans que rien
        ne le signale.

      MD
    end

    def fiabilite
      e = @p[:emis]
      s = +"## 0. Fiabilite de cette carte\n\n"

      s << "> ⚠️ #{e.avertissement}\n\n" if e.avertissement

      if e.perime
        s << <<~MD
          > ### MESURE PERIMEE
          >
          > #{e.perime}
          >
          > Toute section derivee de `_site` decrit donc un etat ANCIEN. Relancer avec
          > `--build`, ou construire d'abord. La carte prefere le dire plutot que de
          > repondre juste-en-apparence.

        MD
      end

      s << "| Mesure | Valeur |\n|---|---|\n"
      s << "| Pages construites lues comme oracle | **#{e.nb_pages}** |\n"
      s << "| Date du build lu | #{e.date_build&.strftime('%d/%m/%Y %H:%M') || 'aucun'} |\n"
      # Dire QUEL repertoire a servi d'oracle. `_site` appartient au serveur de
      # developpement, `.carte/site` a la carte : la nuance a deja fausse deux
      # verifications, elle doit etre visible en tete du fichier.
      s << "| Repertoire lu | `#{e.lu_dans}` |\n"
      s << "| Fichiers de donnees | #{Carte.fichiers('_data/**/*.yml').size} |\n"
      s << "| Includes | #{Carte.fichiers('_includes/**/*.html').size} |\n"
      s << "| Partiels SCSS | #{@p[:css].fichiers_scss.size} |\n"
      s << "| Cas **INDETERMINES** | **#{@c.total}** |\n\n"

      unless @c.total.zero?
        s << "Repartition des indetermines : "
        # Cle TOTALE : la categorie departage les ex aequo. Voir `assets.rb`.
        s << @c.par_categorie.sort_by { |k, n| [-n, k.to_s] }.map { |k, n| "#{k} (#{n})" }.join(", ")
        s << ".\n\n"
      end

      s << <<~MD
        **Les trois seuls verdicts employes ici sont `CONFIRME`, `ABSENT` et `INDETERMINE`.**
        Le mot « mort » n'apparait nulle part : il affirme qu'une chose ne servira jamais, ce
        qu'aucune mesure ne peut etablir. « Absent des #{e.nb_pages} pages construites a la
        date lue ci-dessus » est un fait, datable et refutable.

      MD
      s
    end

    def anomalies(titre, sections, intro = nil)
      s = +"## #{titre}\n\n"
      s << "#{intro}\n\n" if intro
      blocs = sections.flat_map { |x| x.respond_to?(:anomalies) ? x.anomalies : [] }
      if blocs.empty?
        s << "Rien a signaler.\n\n"
        return s
      end
      blocs.each do |a|
        s << "### #{a[:titre]}  (#{a[:cas].size})\n\n"
        s << "#{a[:detail]}\n\n" if a[:detail]
        a[:cas].each { |c| s << "- #{c}\n" }
        s << "\n"
      end
      s
    end

    def section_routes
      r = @p[:routes]
      s = +"## 1. Routes\n\n"
      engendrees = r.routes.count { |x| x.source == "(engendree)" }
      ecrites    = r.routes.size - engendrees
      s << "#{r.routes.size} routes, dont **#{engendrees} engendrees** par `_plugins/` et #{ecrites} portees " \
           "par un fichier source. #{r.routes.count { |x| x.lang == 'fr' }} en FR, " \
           "#{r.routes.count { |x| x.lang == 'en' }} en EN.\n\n"

      derivables = r.routes.select do |x|
        x.source != "(engendree)" &&
          (x.front.keys.sort == %w[layout lang project_id].sort || x.front["service_id"])
      end
      unless derivables.empty?
        s << "⚠️ **#{derivables.size} fichiers sources ne portent qu'un identifiant** et un include d'une ligne : " \
             "ils sont derivables de leurs donnees et devraient rejoindre le generateur.\n\n"
      end

      s << "<details><summary>Table complete des routes</summary>\n\n"
      s << "| URL | Source | Lang |\n|---|---|---|\n"
      r.routes.each { |x| s << "| `#{x.url}` | `#{x.source}` | #{x.lang || '-'} |\n" }
      s << "\n</details>\n\n"
      s << anomalies("", [r]).sub(/\A## \n\n/, "")
      s
    end

    def section_includes
      i = @p[:includes]
      s = +"## 2. Graphe des includes\n\n"
      s << "#{Carte.fichiers('_includes/**/*.html').size} includes, #{i.appels.size} appels, " \
           "profondeur maximale #{i.profondeur_max} depuis `_layouts/default.html`.\n\n"
      orph = i.orphelins
      s << if orph.empty?
             "Aucun include orphelin.\n\n"
           else
             "**Orphelins** : #{orph.join(', ')}.\n\n"
           end

      s << "<details><summary>Qui inclut qui</summary>\n\n"
      i.appels.group_by { |a| a[:vers] }.sort.each do |vers, app|
        s << "- `#{vers}` <- #{app.map { |a| a[:depuis] }.uniq.sort.join(', ')}\n"
      end
      s << "\n</details>\n\n"
      s << anomalies("", [i]).sub(/\A## \n\n/, "")
      s
    end

    def section_donnees = anomalies("3. Donnees", [@p[:donnees]])

    def section_css
      c = @p[:css]
      s = +"## 4. CSS\n\n"
      s << "#{c.jetons.size} jetons definis, #{c.consommations.size} consommes, " \
           "#{c.selecteurs.size} noms de selecteur, #{c.importants.size} `!important`.\n\n"
      unless c.importants.empty?
        s << "`!important` : #{c.importants.map { |x| "`#{x}`" }.join(', ')}\n\n"
      end
      hors = c.breakpoints.map { |b| b[:valeur] }.tally.sort
      unless hors.empty?
        s << "Points de rupture ecrits en dur : " \
             "#{hors.map { |v, n| "#{v}px (#{n}x)" }.join(', ')}\n\n"
      end
      s << anomalies("", [c]).sub(/\A## \n\n/, "")
      s
    end

    def section_js
      j = @p[:js]
      s = +"## 5. JS\n\n"
      s << "#{j.fichiers.size} fichiers, #{j.selecteurs.size} selecteurs litteraux, " \
           "#{j.ecouteurs.size} ecouteurs.\n\n"
      unless j.boucles.empty?
        # ⚠️ « SE RELANCE » N'EST PAS « TOURNE », et l'ancienne formulation
        # affirmait le second. Une fonction qui se rappelle en rAF ne tourne que
        # si quelqu'un l'a demarree, et le demarrage depend souvent d'une garde
        # (`prefers-reduced-motion`, presence d'une cible) que la carte ne suit
        # pas. Elle a d'ailleurs longtemps liste `updateParallax` comme
        # permanente alors que son bloc sortait a sa premiere ligne utile.
        s << "**Fonctions qui se relancent elles-memes en rAF** : " \
             "#{j.boucles.map { |b| "`#{b[:fonction]}` (#{b[:fichier]}:#{b[:ligne]})" }.join(', ')}. " \
             "Une fois demarrees elles ne s'arretent plus, mais leur MISE EN ROUTE depend d'une " \
             "garde que la carte ne suit pas : elle rapporte la forme, pas le fait.\n\n"
      end
      s << anomalies("", [j]).sub(/\A## \n\n/, "")
      s
    end

    # Le contrat entre les trois couches, une ligne par attribut : qui l'ecrit,
    # qui le lit. C'est la section que le sondage a designee comme la plus utile
    # et la plus difficile a reconstituer a la main.
    def section_contrat
      s = +"## 6. Contrat des trois couches\n\n"
      s << "Pour chaque `data-*` et `aria-*` emis : **H** le HTML le pose, **J** le JS l'ecrit " \
           "ou le lit, **C** le CSS s'y accroche. Une ligne sans **C** ni **J** est un attribut " \
           "que personne ne consomme.\n\n"

      css_texte = @p[:css].fichiers_scss.map { |f| Carte.sans_commentaires_css(Carte.lire(f)) }.join("\n")
      js_attrs  = @p[:js].attributs

      noms = (@p[:emis].attributs.keys.grep(/\A(data|aria)-[a-z-]+\z/) + js_attrs.keys).uniq.sort
      s << "| Attribut | HTML | CSS | JS |\n|---|---|---|---|\n"
      noms.each do |n|
        html = @p[:emis].attributs.key?(n) ? "#{@p[:emis].attributs[n].size} page(s)" : "-"
        css  = css_texte.include?("[#{n}") ? "oui" : "-"
        js   = js_attrs.key?(n) ? js_attrs[n].uniq.first : "-"
        next if html == "-" && js == "-"

        alerte = (css == "-" && js == "-") ? " **personne ne le lit**" : ""
        s << "| `#{n}` | #{html} | #{css} | #{js}#{alerte} |\n"
      end
      s << "\n"
      s
    end

    def section_assets
      a = @p[:assets]
      s = +"## 7. Assets\n\n"
      s << "#{a.fichiers.size} fichiers, #{a.send(:ko, a.total)} au total.\n\n"
      s << anomalies("", [a]).sub(/\A## \n\n/, "")
      s
    end

    # ⚠️ SECTION A PART, ET NON FONDUE DANS « DONNEES ». Un ratio faux n'est pas
    # une cle morte : c'est une cle VIVANTE qui dit faux, ce qui demande un
    # geste oppose. Les melanger reviendrait a proposer de supprimer ce qu'il
    # faut corriger.
    def section_medias
      m = @p[:medias]
      s = +"## 8. Ratios declares contre dimensions reelles

"
      s << "#{m.mesures.size} medias mesures. Le ratio pilote la place reservee, le ratio par "            "defaut des pieces de sequence, et le RYTHME de cadrage.

"
      s << anomalies("", [m]).sub(/\A## 

/, "")
      s
    end

    def section_build
      b = @p[:build]
      s = +"## 9. Build et CI\n\n"
      if (css = b.faits[:css])
        s << "**CSS servi** : #{css[:brut]} o brut, #{css[:gzip]} o gzip. " \
             "Sans les commentaires : #{css[:sans_commentaires]} o, #{css[:gzip_sans]} o gzip, " \
             "soit **#{(100 - css[:gzip_sans] * 100.0 / css[:gzip]).round} % de moins** sur le fil.\n\n"
      end
      s << "Les plugins Ruby de `_plugins/` " \
           "#{b.faits[:plugins_possibles] ? "**s'executent**" : "ne s'executent pas"} " \
           "avec cette chaine de build.\n\n"
      s << anomalies("", [b]).sub(/\A## \n\n/, "")
      s
    end

    def section_inconnues
      s = +"## 10. Ce que la carte ne sait pas\n\n"
      if @c.total.zero?
        s << "Rien n'a resiste a l'analyse sur ce build.\n\n"
      else
        s << "#{@c.total} cas n'ont pas pu etre tranches. Ils sont listes ici plutot que passes " \
             "sous silence : une carte qui cache ses angles morts parait meilleure qu'elle n'est.\n\n"
        @c.cas.group_by { |x| x[:categorie] }.sort.each do |cat, liste|
          s << "**#{cat}** (#{liste.size})\n\n"
          liste.first(20).each { |x| s << "- `#{x[:ou]}` : #{x[:pourquoi]}\n" }
          s << "- ... et #{liste.size - 20} autres\n" if liste.size > 20
          s << "\n"
        end
      end

      amb = @p[:donnees].ambigus
      unless amb.empty?
        s << "**Noms de variable liees a plusieurs sources** (#{amb.size}). Liquid a des portees "              "de bloc, la carte n'en a pas : quand un meme nom designe plusieurs choses dans un "              "fichier, elle resout vers l'UNION des possibilites. Elle peut donc declarer vivante "              "une cle qui ne l'est pas, jamais l'inverse.

"
        amb.first(12).each { |x| s << "- #{x}
" }
        s << "- ... et #{amb.size - 12} autres
" if amb.size > 12
        s << "
"
      end

      s << <<~MD
        ### Limites structurelles, valables meme quand la liste ci-dessus est vide

        - **Les lectures des plugins ne sont pas suivies.** `_plugins/` lit les donnees en
          Ruby, hors de portee d'une analyse Liquid. La carte se rabat sur une heuristique :
          toute cle dont un segment figure parmi les litteraux de chaine d'un plugin quitte
          la liste des mortes pour la section « qu'un plugin cite ». C'est volontairement
          grossier, et le biais est du bon cote : la carte peut declarer vivante une cle qui
          ne l'est pas, jamais l'inverse. ⚠️ **Corollaire : cette section-la n'est PAS une
          liste de choses a supprimer.** Sans cette heuristique, le bloc `seo` des huit pages
          service etait annonce mort, avec une invitation a l'effacer.
        - **Les orphelins d'assets sont detectes par nom de fichier.** Un chemin construit
          dynamiquement echapperait au filet. Verifier avant de supprimer.
        - **`_site` est l'oracle**, donc la carte ne connait que ce que le dernier build a
          produit. Une page exclue de la construction est invisible pour elle.
        - **Une branche jamais rendue passe pour saine.** La carte voit ce que le build
          produit, donc un chemin de code qu'aucune donnee ne declenche ne peut pas etre
          juge. La branche `livrable` de `pages/_project.scss` en est l'exemple : ecrite,
          commentee, coherente, et en collision avec l'indice de defilement, ce qui n'a pu
          se voir qu'en la declenchant.
        - **Le rendu n'est pas mesure.** Aucune section ne dit si une page est belle, lisible
          ou utilisable au clavier. La carte dit ce qui est branche, pas ce qui est bon.
          Pour prouver qu'un changement n'a fait que ce qu'il annonce, l'outil est
          `scripts/comparer-builds.rb`.
      MD
      s
    end
  end
end
