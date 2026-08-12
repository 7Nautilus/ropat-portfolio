# Carte du depot

> Generee le 12/08/2026 a 19:12, d'apres l'etat de cf81e90.
> (Elle decrit le commit CI-DESSUS et vit dans le SUIVANT : elle se genere forcement
> avant celui qui l'embarque. Un decalage d'un commit n'est pas une peremption.)
> **Ne pas editer a la main** : `bundle exec ruby scripts/carte.rb` la reecrit en entier.
> Pour ne voir que ce qui a bouge : `bundle exec ruby scripts/carte.rb --diff`.

Cette carte repond a une seule question, sous plusieurs angles : **qu'est-ce qui est branche
a quoi**. Elle est generee parce qu'un document redige se perime au premier commit
suivant. Demonstration mesuree pendant sa conception : entre deux relevés a quelques
jours d'ecart, les `corner-shape` ecrits a la main sont passes de 21 a 32 sans que rien
ne le signale.

## 0. Fiabilite de cette carte

| Mesure | Valeur |
|---|---|
| Pages construites lues comme oracle | **66** |
| Date du build lu | 12/08/2026 19:12 |
| Repertoire lu | `.carte/site` |
| Fichiers de donnees | 39 |
| Includes | 33 |
| Partiels SCSS | 33 |
| Cas **INDETERMINES** | **7** |

Repartition des indetermines : selecteur JS calcule (6), classe JS calculee (1).

**Les trois seuls verdicts employes ici sont `CONFIRME`, `ABSENT` et `INDETERMINE`.**
Le mot « mort » n'apparait nulle part : il affirme qu'une chose ne servira jamais, ce
qu'aucune mesure ne peut etablir. « Absent des 66 pages construites a la
date lue ci-dessus » est un fait, datable et refutable.

## 1. Routes

67 routes, dont **50 engendrees** par `_plugins/` et 17 portees par un fichier source. 34 en FR, 32 en EN.

<details><summary>Table complete des routes</summary>

| URL | Source | Lang |
|---|---|---|
| `/` | `index.html` | fr |
| `/404.html` | `404.html` | fr |
| `/en/` | `en/index.html` | en |
| `/en/about.html` | `en/about.html` | en |
| `/en/contact.html` | `en/contact.html` | en |
| `/en/legal-notice.html` | `en/legal-notice.html` | en |
| `/en/portfolio.html` | `en/portfolio.html` | en |
| `/en/privacy.html` | `en/privacy.html` | en |
| `/en/projects/a-lone.html` | `(engendree)` | en |
| `/en/projects/aelio.html` | `(engendree)` | en |
| `/en/projects/btr.html` | `(engendree)` | en |
| `/en/projects/chat-noir.html` | `(engendree)` | en |
| `/en/projects/cheetah.html` | `(engendree)` | en |
| `/en/projects/crow.html` | `(engendree)` | en |
| `/en/projects/exit.html` | `(engendree)` | en |
| `/en/projects/hdd-defrag.html` | `(engendree)` | en |
| `/en/projects/hors-champ.html` | `(engendree)` | en |
| `/en/projects/jhag-banana-rush.html` | `(engendree)` | en |
| `/en/projects/jhag-discovery-set.html` | `(engendree)` | en |
| `/en/projects/jhag-pinterest.html` | `(engendree)` | en |
| `/en/projects/jpeja.html` | `(engendree)` | en |
| `/en/projects/logo-process.html` | `(engendree)` | en |
| `/en/projects/moon-vtc.html` | `(engendree)` | en |
| `/en/projects/ottony-paris.html` | `(engendree)` | en |
| `/en/projects/outlast-trials.html` | `(engendree)` | en |
| `/en/projects/sipsmith.html` | `(engendree)` | en |
| `/en/projects/stelya.html` | `(engendree)` | en |
| `/en/projects/strakara.html` | `(engendree)` | en |
| `/en/projects/zylkene.html` | `(engendree)` | en |
| `/en/services.html` | `en/services.html` | en |
| `/en/services/branding-strategy.html` | `(engendree)` | en |
| `/en/services/graphic-design.html` | `(engendree)` | en |
| `/en/services/music-design.html` | `(engendree)` | en |
| `/en/services/web-design.html` | `(engendree)` | en |
| `/fr/about.html` | `fr/about.html` | fr |
| `/fr/confidentialite.html` | `fr/confidentialite.html` | fr |
| `/fr/contact.html` | `fr/contact.html` | fr |
| `/fr/experiences.html` | `fr/experiences.html` | fr |
| `/fr/mentions-legales.html` | `fr/mentions-legales.html` | fr |
| `/fr/portfolio.html` | `fr/portfolio.html` | fr |
| `/fr/projects/a-lone.html` | `(engendree)` | fr |
| `/fr/projects/aelio.html` | `(engendree)` | fr |
| `/fr/projects/btr.html` | `(engendree)` | fr |
| `/fr/projects/chat-noir.html` | `(engendree)` | fr |
| `/fr/projects/cheetah.html` | `(engendree)` | fr |
| `/fr/projects/crow.html` | `(engendree)` | fr |
| `/fr/projects/exit.html` | `(engendree)` | fr |
| `/fr/projects/hdd-defrag.html` | `(engendree)` | fr |
| `/fr/projects/hors-champ.html` | `(engendree)` | fr |
| `/fr/projects/jhag-banana-rush.html` | `(engendree)` | fr |
| `/fr/projects/jhag-discovery-set.html` | `(engendree)` | fr |
| `/fr/projects/jhag-pinterest.html` | `(engendree)` | fr |
| `/fr/projects/jpeja.html` | `(engendree)` | fr |
| `/fr/projects/logo-process.html` | `(engendree)` | fr |
| `/fr/projects/moon-vtc.html` | `(engendree)` | fr |
| `/fr/projects/ottony-paris.html` | `(engendree)` | fr |
| `/fr/projects/outlast-trials.html` | `(engendree)` | fr |
| `/fr/projects/sipsmith.html` | `(engendree)` | fr |
| `/fr/projects/stelya.html` | `(engendree)` | fr |
| `/fr/projects/strakara.html` | `(engendree)` | fr |
| `/fr/projects/zylkene.html` | `(engendree)` | fr |
| `/fr/services.html` | `fr/services.html` | fr |
| `/fr/services/branding-strategie.html` | `(engendree)` | fr |
| `/fr/services/conception-graphique.html` | `(engendree)` | fr |
| `/fr/services/design-musique.html` | `(engendree)` | fr |
| `/fr/services/web-design.html` | `(engendree)` | fr |
| `/sitemap.xml` | `sitemap.xml` | - |

</details>

Rien a signaler.

## 2. Graphe des includes

33 includes, 79 appels, profondeur maximale 4 depuis `_layouts/default.html`.

**Orphelins** : projects/project-main.html, services/service-main.html.

<details><summary>Qui inclut qui</summary>

- `burger-menu.html` <- layout/header.html
- `experiences/experience-card.html` <- pages/experiences.html
- `lang-detector.html` <- _layouts/default.html
- `lang-selector.html` <- layout/footer.html
- `layout/footer.html` <- _layouts/default.html
- `layout/header.html` <- _layouts/default.html
- `layout/nav.html` <- layout/header.html
- `meta/open-graph.html` <- _layouts/default.html
- `meta/schema-org.html` <- _layouts/default.html
- `pages/about.html` <- en/about.html, fr/about.html
- `pages/contact.html` <- en/contact.html, fr/contact.html
- `pages/experiences.html` <- fr/experiences.html
- `pages/index.html` <- en/index.html, index.html
- `pages/portfolio.html` <- en/portfolio.html, fr/portfolio.html
- `pages/services.html` <- en/services.html, fr/services.html
- `portfolio-filters.html` <- pages/portfolio.html
- `projects/project-avis.html` <- projects/project-main.html
- `projects/project-card.html` <- pages/index.html, pages/portfolio.html, services/service-main.html
- `projects/project-note.html` <- projects/project-main.html
- `scroll-down-link.html` <- pages/experiences.html, pages/portfolio.html, pages/services.html, projects/project-main.html
- `services/service-card.html` <- pages/index.html, pages/services.html
- `services/subservices-card.html` <- services/service-main.html
- `social-media-icons.html` <- pages/contact.html
- `ui/button.html` <- 404.html, labo/design-system.html, layout/nav.html, pages/about.html, pages/contact.html, pages/index.html, pages/services.html, projects/project-main.html, services/service-card.html, services/service-main.html
- `ui/dropdown.html` <- labo/design-system.html, pages/contact.html, portfolio-filters.html
- `ui/icon-arrow.html` <- ui/button.html
- `ui/icon-send.html` <- ui/button.html
- `ui/loader.html` <- pages/index.html
- `ui/logo.html` <- layout/header.html, ui/loader.html
- `ui/note-malt.html` <- pages/about.html, projects/project-avis.html
- `ui/status-dot.html` <- labo/design-system.html, pages/about.html, pages/index.html

</details>

### Parametres lus par un include que personne ne passe  (3)

Chacun rend nil. Legitime s'il a une valeur par defaut, a verifier sinon.

- ui/button.html lit include.type
- ui/loader.html lit include.indice
- ui/loader.html lit include.marque

## 3. Donnees

### Cles qu'aucun gabarit ne lit, mais qu'un plugin cite  (8)

Hors de portee de l'analyse Liquid : `_plugins/` lit les donnees en Ruby. Ni vivantes ni mortes du point de vue de cette passe. NE PAS SUPPRIMER sans avoir relu le plugin.

- site.data.services.branding-strategy.seo.en
- site.data.services.branding-strategy.seo.fr
- site.data.services.graphic-design.seo.en
- site.data.services.graphic-design.seo.fr
- site.data.services.music-design.seo.en
- site.data.services.music-design.seo.fr
- site.data.services.web-design.seo.en
- site.data.services.web-design.seo.fr

### Cles de donnees definies, aucun gabarit ne les lit  (4)

Aucun chemin resolu ne les atteint, propagation a travers les parametres d'include comprise.

- site.data.avis.*.source
- site.data.pages.contact.en.cta
- site.data.pages.contact.fr.cta
- site.data.socials.*.releve

### Couverture des cles de premier niveau dans `_data/projects/` (21 fichiers)  (11)

Une cle absente d'une partie du corpus fait s'appliquer une valeur par defaut sans que rien ne le dise.

- **livrables** : 1/21
- **chrome** : 2/21
- **formats** : 4/21
- **og_image** : 7/21
- **thumbnails** : 8/21
- **discipline** : 8/21
- **mockup_a_produire** : 12/21
- **secteur** : 13/21   absent de chat-noir, cheetah, crow, exit, hdd-defrag, jpeja, logo-process, outlast-trials
- **aspect** : 15/21   absent de btr, cheetah, crow, jhag-banana-rush, logo-process, moon-vtc
- **nature** : 20/21   absent de strakara
- **case_study** : 20/21   absent de hors-champ

### Couverture des cles de premier niveau dans `_data/services/` (4 fichiers)  (1)

Une cle absente d'une partie du corpus fait s'appliquer une valeur par defaut sans que rien ne le dise.

- **subtitles** : 3/4   absent de branding-strategy

## 4. CSS

129 jetons definis, 125 consommes, 294 noms de selecteur, 11 `!important`.

`!important` : `assets/css/_sass/base/_bases.scss:86`, `assets/css/_sass/base/_bases.scss:87`, `assets/css/_sass/base/_bases.scss:88`, `assets/css/_sass/base/_bases.scss:89`, `assets/css/_sass/base/_bases.scss:100`, `assets/css/_sass/base/_bases.scss:105`, `assets/css/_sass/base/_bases.scss:106`, `assets/css/_sass/base/_bases.scss:107`, `assets/css/_sass/components/_cursor.scss:16`, `assets/css/_sass/pages/_project.scss:1348`, `assets/css/_sass/pages/_project.scss:1356`

Points de rupture ecrits en dur : 520px (1x)

### Jetons definis, aucun `var()` ne les lit  (6)

Verdict de fait, pas de valeur : certains sont reserves pour une phase a venir.

- --dur-reveal = 0.8s   (assets/css/_sass/base/_variables.scss:572)
- --ease-expo-in-out = cubic-bezier(0.87, 0, 0.13, 1)   (assets/css/_sass/base/_variables.scss:696)
- --rhythm-lg = 10rem   (assets/css/_sass/base/_variables.scss:479)
- --rhythm-md = 6rem   (assets/css/_sass/base/_variables.scss:478)
- --rhythm-sm = 4rem   (assets/css/_sass/base/_variables.scss:477)
- --track-display = -0.015em   (assets/css/_sass/base/_variables.scss:415)

### Jetons lus UNIQUEMENT depuis le JavaScript  (2)

Aucun `var()` ne les lit, mais ils ont un consommateur. A ne PAS ranger avec les jetons sans emploi : les supprimer casserait un comportement.

- --dur-loader-hold = 800ms   lu par assets/js/script.js:150
- --p-vert-haute = #051510   lu par assets/js/dither.js:382

### Jetons poses en ligne et consommes SANS valeur de repli  (6)

Si la donnee qui pose le `style=` manque, la declaration entiere tombe.

- assets/css/_sass/components/_carousel.scss:183  -webkit-mask: var(--logo) center / contain no-repeat;
- assets/css/_sass/components/_carousel.scss:184  mask: var(--logo) center / contain no-repeat;
- assets/css/_sass/components/_carousel.scss:146  aspect-ratio: var(--ratio);
- assets/css/_sass/pages/_project.scss:970  color: oklch(from var(--swatch-color) clamp(0, (0.5 - l) * 9999, 1) 0 0);
- assets/css/_sass/pages/_project.scss:978  color: oklch(from var(--swatch-color) clamp(0, (0.5 - l) * 9999, 1) 0 0);
- assets/css/_sass/pages/_project.scss:994  color: oklch(from var(--swatch-color) clamp(0, (0.5 - l) * 9999, 1) 0 0);

### DESACCORD DE SELECTEUR : le CSS cible un genre, le HTML emet l'autre  (3)

Ce n'est pas du code non emis, c'est du style qui ne s'applique pas. A reparer, pas a supprimer.

- .projects-title style en assets/css/_sass/base/_media-queries.scss:236, mais le HTML emet id="projects-title" sur 4 page(s)
- .contact-email style en assets/css/_sass/base/_media-queries.scss:326, mais le HTML emet id="contact-email" sur 2 page(s)
- .projects-grid style en assets/css/_sass/layout/_grids.scss:12, mais le HTML emet id="projects-grid" sur 12 page(s)

### Selecteurs POSES PAR LE JS, absents du HTML construit  (16)

Vivants a l'execution, invisibles au build. A ne PAS ranger avec le CSS mort : les supprimer casserait un composant qui fonctionne.

- .reveal-arme  style en assets/css/_sass/base/_animations.scss:17, pose par _layouts/default.html (script en ligne 2):2, _layouts/default.html (script en ligne 2):4
- .is-visible  style en assets/css/_sass/base/_animations.scss:23, pose par assets/js/script.js:1331, assets/js/script.js:1336
- .custom-scrollbar  style en assets/css/_sass/base/_scrollbar.scss:58, pose par assets/js/script.js:1745
- .cursor-hover  style en assets/css/_sass/components/_cursor.scss:103, pose par assets/js/script.js:81
- .cursor-text  style en assets/css/_sass/components/_cursor.scss:111, pose par assets/js/script.js:81
- .cursor-zoom  style en assets/css/_sass/components/_cursor.scss:121, pose par assets/js/script.js:81
- .lightbox-image  style en assets/css/_sass/components/_lightbox.scss:35, pose par assets/js/script.js:574
- .loaded  style en assets/css/_sass/components/_loader.scss:43, pose par assets/js/script.js:147, assets/js/script.js:316
- .scrollbar  style en assets/css/_sass/components/_scrollbar.scss:14, pose par assets/js/script.js:1604
- .scrollbar-thumb  style en assets/css/_sass/components/_scrollbar.scss:59, pose par assets/js/script.js:1610
- .scrollbar-saisie  style en assets/css/_sass/components/_scrollbar.scss:91, pose par assets/js/script.js:1692, assets/js/script.js:1713
- .was-validated  style en assets/css/_sass/pages/_contact.scss:138, pose par assets/js/script.js:1449
- .contact-erreur  style en assets/css/_sass/pages/_contact.scss:147, pose par assets/js/script.js:1397
- .is-invalid  style en assets/css/_sass/pages/_contact.scss:328, pose par assets/js/script.js:391, assets/js/script.js:1438, assets/js/script.js:1442, assets/js/script.js:1466
- .galerie-plus  style en assets/css/_sass/pages/_project.scss:355, pose par assets/js/script.js:1189
- .voile-en-cours  style en assets/css/_sass/pages/_project.scss:1310, pose par _layouts/default.html (script en ligne 3):31, _layouts/default.html (script en ligne 3):33

### Selecteurs absents des 66 pages construites  (20)

Fait date, pas jugement : aucune page du dernier build ne porte ce nom.

- .card-grid  assets/css/_sass/base/_media-queries.scss:17 assets/css/_sass/base/_media-queries.scss:126 assets/css/_sass/base/_media-queries.scss:240 assets/css/_sass/layout/_grids.scss:1
- .service-main-container  assets/css/_sass/base/_media-queries.scss:40 assets/css/_sass/base/_media-queries.scss:219 assets/css/_sass/layout/_sections.scss:208
- .hero-project  assets/css/_sass/base/_media-queries.scss:103
- .hero-project-container  assets/css/_sass/base/_media-queries.scss:107 assets/css/_sass/components/_containers.scss:82
- .hero-image-container  assets/css/_sass/base/_media-queries.scss:111 assets/css/_sass/base/_media-queries.scss:195
- .hero-intro  assets/css/_sass/base/_media-queries.scss:134
- .hero-image  assets/css/_sass/base/_media-queries.scss:169
- .service-main-container-text  assets/css/_sass/base/_media-queries.scss:223 assets/css/_sass/layout/_sections.scss:215
- .services-page-subtitle  assets/css/_sass/base/_media-queries.scss:227 assets/css/_sass/layout/_sections.scss:247
- .services-page-description  assets/css/_sass/base/_media-queries.scss:231 assets/css/_sass/layout/_sections.scss:251
- .service-card-big  assets/css/_sass/components/cards/_service-cards.scss:71
- .hero-theme-container  assets/css/_sass/layout/_sections.scss:161
- .hero-theme  assets/css/_sass/layout/_sections.scss:176
- .hero-theme-dot  assets/css/_sass/layout/_sections.scss:186
- .subservice-section  assets/css/_sass/layout/_sections.scss:201
- #contact-social-links  assets/css/_sass/layout/_sections.scss:272 assets/css/_sass/layout/_sections.scss:322
- .social-links  assets/css/_sass/layout/_sections.scss:280 assets/css/_sass/layout/_sections.scss:288 assets/css/_sass/layout/_sections.scss:294 assets/css/_sass/layout/_sections.scss:299
- .social-icon  assets/css/_sass/layout/_sections.scss:315 assets/css/_sass/layout/_sections.scss:322
- .contact-select  assets/css/_sass/pages/_contact.scss:167 assets/css/_sass/pages/_contact.scss:183
- .project-back-link  assets/css/_sass/pages/_project.scss:1205 assets/css/_sass/pages/_project.scss:1218 assets/css/_sass/pages/_project.scss:1220 assets/css/_sass/pages/_project.scss:1223

### Valeurs ecrites en dur alors qu'un jeton DE LEUR FAMILLE porte la meme  (2)

Chacune est un endroit que le jeton ne pourra pas deplacer le jour ou il bougera.

- 1px ecrit 6 fois en trait, alors que --hairline-width vaut exactement ca   (ex. assets/css/_sass/base/_media-queries.scss:189, assets/css/_sass/components/cards/_project-cards.scss:24, assets/css/_sass/layout/_sections.scss:128)
- 3px ecrit 4 fois en trait, alors que --signal-width vaut exactement ca   (ex. assets/css/_sass/components/_cursor.scss:30, assets/css/_sass/components/_cursor.scss:107, assets/css/_sass/components/cards/_experience-cards.scss:22)

### Valeurs HORS ECHELLE : aucun jeton de leur famille ne les porte  (23)

Fait, pas jugement. Nommer n'est pas aligner : une valeur listee ici merite un nom pour devenir auditable, pas forcement d'etre deplacee. `scripts/jetons-hors-echelle.rb` verrouille cette liste contre une liste commitee.

- decalage 2px : 2 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/components/_lightbox.scss:72, assets/css/_sass/pages/_about.scss:227)
- decalage 4px : 2 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/base/_bases.scss:54, assets/css/_sass/layout/_header.scss:560)
- espacement 0.4rem : 9 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/base/_media-queries.scss:314, assets/css/_sass/base/_media-queries.scss:315, assets/css/_sass/base/_media-queries.scss:387)
- espacement 0.6rem : 7 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/components/cards/_service-cards.scss:85, assets/css/_sass/pages/_contact.scss:396, assets/css/_sass/pages/_contact.scss:397)
- espacement 0.75rem : 7 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/base/_bases.scss:15, assets/css/_sass/base/_media-queries.scss:151, assets/css/_sass/components/_buttons.scss:310)
- espacement 0.875rem : 7 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/base/_media-queries.scss:269, assets/css/_sass/components/_buttons.scss:34, assets/css/_sass/components/_buttons.scss:47)
- espacement 1.25rem : 4 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/base/_media-queries.scss:269, assets/css/_sass/components/_buttons.scss:311, assets/css/_sass/components/_containers.scss:15)
- espacement 0.25rem : 3 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/components/cards/_service-cards.scss:85, assets/css/_sass/pages/_project.scss:962, assets/css/_sass/pages/_project.scss:1057)
- espacement 0.9rem : 2 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/pages/_about.scss:208, assets/css/_sass/pages/_project.scss:428)
- espacement 2.5rem : 2 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/components/cards/_experience-cards.scss:16, assets/css/_sass/pages/_contact.scss:179)
- espacement 2px : 2 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/pages/_contact.scss:249, assets/css/_sass/pages/_contact.scss:375)
- espacement -1px : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/base/_bases.scss:38)
- espacement 0.15rem : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/pages/_contact.scss:270)
- espacement 0.35rem : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/pages/_contact.scss:372)
- espacement 0.5em : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/layout/_header.scss:488)
- espacement 1.1em : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/layout/_header.scss:488)
- espacement 1.1rem : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/pages/_project.scss:361)
- espacement 1.4rem : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/pages/_project.scss:212)
- espacement 1.75rem : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/components/_containers.scss:106)
- espacement 1em : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/pages/_project.scss:835)
- espacement 20px : 1 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/components/_carousel.scss:21)
- trait 2px : 15 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/components/_containers.scss:104, assets/css/_sass/components/_containers.scss:165, assets/css/_sass/components/_cursor.scss:125)
- trait 6px : 3 declaration(s), AUCUN jeton de cette famille ne porte cette valeur   (ex. assets/css/_sass/components/_dropdown.scss:46, assets/css/_sass/components/_dropdown.scss:47, assets/css/_sass/components/_dropdown.scss:48)

## 5. JS

2 fichiers, 43 selecteurs litteraux, 49 ecouteurs.

**Fonctions qui se relancent elles-memes en rAF** : `animer` (assets/js/dither.js:635), `animateBlob` (assets/js/script.js:65). Une fois demarrees elles ne s'arretent plus, mais leur MISE EN ROUTE depend d'une garde que la carte ne suit pas : elle rapporte la forme, pas le fait.

### Classes posees par le JS qu'aucune regle CSS ne lit  (2)

Legitime si le JS s'en sert comme verrou interne, a verifier sinon.

- stt-progress   (assets/js/script.js:1496)
- stt-track   (assets/js/script.js:1495)

### Ecouteurs `scroll` recenses  (4)

A confronter au throttle : un handler sans rAF qui lit une metrique de layout force un reflow a chaque evenement.

- assets/js/script.js:664
- assets/js/script.js:1107  (passive)
- assets/js/script.js:1561  (passive)
- assets/js/script.js:1719

## 6. Contrat des trois couches

Pour chaque `data-*` et `aria-*` emis : **H** le HTML le pose, **J** le JS l'ecrit ou le lit, **C** le CSS s'y accroche. Une ligne sans **C** ni **J** est un attribut que personne ne consomme.

| Attribut | HTML | CSS | JS |
|---|---|---|---|
| `aria-atomic` | 66 page(s) | - | - **personne ne le lit** |
| `aria-controls` | 66 page(s) | - | assets/js/script.js:355 |
| `aria-current` | 8 page(s) | - | - **personne ne le lit** |
| `aria-describedby` | - | - | assets/js/script.js:1407 |
| `aria-expanded` | 66 page(s) | oui | assets/js/script.js:362 |
| `aria-haspopup` | 4 page(s) | - | - **personne ne le lit** |
| `aria-hidden` | 66 page(s) | oui | assets/js/script.js:1608 |
| `aria-invalid` | - | - | assets/js/script.js:1406 |
| `aria-label` | 66 page(s) | - | assets/js/script.js:1491 |
| `aria-labelledby` | 54 page(s) | - | - **personne ne le lit** |
| `aria-live` | 66 page(s) | - | - **personne ne le lit** |
| `aria-modal` | 42 page(s) | - | - **personne ne le lit** |
| `aria-selected` | 4 page(s) | oui | assets/js/script.js:372 |
| `data-actif` | - | oui | assets/js/script.js:1626 |
| `data-category` | 10 page(s) | - | assets/js/script.js:488 |
| `data-chargee` | - | - | assets/js/script.js:1265 |
| `data-chrome` | - | oui | assets/js/script.js:651 |
| `data-chrome-fige` | 4 page(s) | - | - **personne ne le lit** |
| `data-dbg` | - | - | assets/js/script.js:1057 |
| `data-dropdown-caret` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-menu` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-option` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-selected` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-trigger` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-variant` | 4 page(s) | - | - **personne ne le lit** |
| `data-empty` | 2 page(s) | oui | assets/js/script.js:390 |
| `data-en` | 1 page(s) | oui | - |
| `data-encre` | - | oui | assets/js/script.js:1071 |
| `data-placeholder` | 2 page(s) | - | - **personne ne le lit** |
| `data-saisi` | - | oui | assets/js/script.js:1691 |
| `data-set-lang` | 64 page(s) | - | assets/js/script.js:1315 |
| `data-seuil` | 24 page(s) | - | assets/js/script.js:1184 |
| `data-seuil-mobile` | 24 page(s) | - | assets/js/script.js:1183 |
| `data-src` | 4 page(s) | - | assets/js/script.js:1267 |
| `data-sur-media` | - | oui | assets/js/script.js:1051 |
| `data-value` | 4 page(s) | oui | assets/js/script.js:394 |
| `data-zone` | - | oui | assets/js/script.js:1095 |
| `href` | - | - | assets/js/script.js:189 |
| `loop` | - | - | assets/js/script.js:1281 |

## 7. Assets

82 fichiers, 84.9 Mo au total.

### Assets qu'aucune page construite ne reference (1.2 Mo)  (4)

Detection par nom de fichier : un chemin construit dynamiquement y echapperait. Verifier avant de supprimer.

-  442.8 Ko  /assets/images/backgrounds/main-bg.webp
-  273.5 Ko  /assets/images/projects/JPeJA-thumbnail2.jpg
-  259.4 Ko  /assets/images/projects/aelio/aelio-app-mockup-alone.avif
-  218.9 Ko  /assets/images/projects/jhag/jhag-br-p3-flambe.webp

### Pages les plus lourdes au chargement (medias non differes)  (10)

Ce que le visiteur telecharge sans l'avoir demande. Le CSS, le JS et les polices ne sont pas comptes.

-    9.5 Mo  fr/projects/jpeja.html   JPeJA.mp4
-    9.5 Mo  en/projects/jpeja.html   JPeJA.mp4
-    1.1 Mo  fr/projects/cheetah.html   CHEETAH.mp4
-    1.1 Mo  en/projects/cheetah.html   CHEETAH.mp4
-  547.8 Ko  fr/projects/exit.html   exit.webp
-  547.8 Ko  en/projects/exit.html   exit.webp
-  501.4 Ko  fr/projects/zylkene.html   zylkene-mockup.webp
-  501.4 Ko  en/projects/zylkene.html   zylkene-mockup.webp
-  462.2 Ko  fr/projects/outlast-trials.html   outlast-trials.png
-  462.2 Ko  en/projects/outlast-trials.html   outlast-trials.png

## 8. Ratios declares contre dimensions reelles

60 medias mesures. Le ratio pilote la place reservee, le ratio par defaut des pieces de sequence, et le RYTHME de cadrage.

Rien a signaler.

## 9. Build et CI

**CSS servi** : 277056 o brut, 87939 o gzip. Sans les commentaires : 87020 o, 14163 o gzip, soit **84 % de moins** sur le fil.

Les plugins Ruby de `_plugins/` **s'executent** avec cette chaine de build.

Rien a signaler.

## 10. Ce que la carte ne sait pas

7 cas n'ont pas pu etre tranches. Ils sont listes ici plutot que passes sous silence : une carte qui cache ses angles morts parait meilleure qu'elle n'est.

**classe JS calculee** (1)

- `assets/js/script.js:86` : stateClass

**selecteur JS calcule** (6)

- `assets/js/dither.js:621` : INTERACTIF
- `assets/js/script.js:85` : selectors
- `assets/js/script.js:355` : trigger.getAttribute('aria-controls'
- `assets/js/script.js:467` : selector
- `assets/js/script.js:1393` : champ.id + '-erreur'
- `assets/js/script.js:1412` : champ.id + '-erreur'

**Noms de variable liees a plusieurs sources** (62). Liquid a des portees de bloc, la carte n'en a pas : quand un meme nom designe plusieurs choses dans un fichier, elle resout vers l'UNION des possibilites. Elle peut donc declarer vivante une cle qui ne l'est pas, jamais l'inverse.

- _includes/lang-selector.html : `hote` a 2 liaisons
- _includes/lang-selector.html : `switch_url` a 3 liaisons
- _includes/layout/footer.html : `item` a 2 liaisons
- _includes/layout/footer.html : `link_name` a 2 liaisons
- _includes/layout/footer.html : `final_url` a 2 liaisons
- _includes/layout/nav.html : `link_name` a 2 liaisons
- _includes/layout/nav.html : `final_url` a 2 liaisons
- _includes/meta/schema-org.html : `final_page_title` a 2 liaisons
- _includes/meta/schema-org.html : `final_page_description` a 3 liaisons
- _includes/meta/schema-org.html : `project_locale` a 2 liaisons
- _includes/meta/schema-org.html : `schema_image` a 2 liaisons
- _includes/pages/about.html : `_malt` a 2 liaisons
- ... et 50 autres

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
