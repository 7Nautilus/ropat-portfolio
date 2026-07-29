# Carte du depot

> Generee le 29/07/2026 a 03:35 sur 623776f.
> **Ne pas editer a la main** : `bundle exec ruby scripts/carte.rb` la reecrit en entier.
> Pour ne voir que ce qui a bouge : `bundle exec ruby scripts/carte.rb --diff`.

Cette carte repond a une seule question, sous sept angles : **qu'est-ce qui est branche
a quoi**. Elle est generee parce qu'un document redige se perime au premier commit
suivant. Demonstration mesuree pendant sa conception : entre deux relevés a quelques
jours d'ecart, les `corner-shape` ecrits a la main sont passes de 21 a 32 sans que rien
ne le signale.

## 0. Fiabilite de cette carte

| Mesure | Valeur |
|---|---|
| Pages construites lues comme oracle | **63** |
| Date du build lu | 29/07/2026 03:35 |
| Repertoire lu | `.carte/site` |
| Fichiers de donnees | 37 |
| Includes | 30 |
| Partiels SCSS | 31 |
| Cas **INDETERMINES** | **7** |

Repartition des indetermines : selecteur JS calcule (6), classe JS calculee (1).

**Les trois seuls verdicts employes ici sont `CONFIRME`, `ABSENT` et `INDETERMINE`.**
Le mot « mort » n'apparait nulle part : il affirme qu'une chose ne servira jamais, ce
qu'aucune mesure ne peut etablir. « Absent des 63 pages construites le
29/07 » est un fait, datable et refutable.

## 1. Routes

64 routes, dont **48 engendrees** par `_plugins/` et 16 portees par un fichier source. 32 en FR, 31 en EN.

<details><summary>Table complete des routes</summary>

| URL | Source | Lang |
|---|---|---|
| `/` | `index.html` | fr |
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

30 includes, 71 appels, profondeur maximale 4 depuis `_layouts/default.html`.

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
- `projects/project-card.html` <- pages/index.html, pages/portfolio.html, services/service-main.html
- `projects/project-note.html` <- projects/project-main.html
- `scroll-down-link.html` <- pages/experiences.html, pages/portfolio.html, pages/services.html, projects/project-main.html
- `services/service-card.html` <- pages/index.html, pages/services.html
- `services/subservices-card.html` <- services/service-main.html
- `social-media-icons.html` <- pages/contact.html
- `ui/button.html` <- labo/design-system.html, layout/nav.html, pages/about.html, pages/contact.html, pages/index.html, pages/services.html, projects/project-main.html, services/service-card.html, services/service-main.html
- `ui/dropdown.html` <- labo/design-system.html, pages/contact.html, portfolio-filters.html
- `ui/icon-arrow.html` <- ui/button.html
- `ui/icon-send.html` <- ui/button.html
- `ui/logo.html` <- layout/header.html, pages/index.html
- `ui/status-dot.html` <- labo/design-system.html, pages/about.html, pages/index.html

</details>

### Parametres passes a un include qui ne les lit jamais  (2)

L'include marche quand meme s'il lit la variable NUE : les portees fuient en Liquid.

- services/subservices-card.html <- current_lang (depuis services/service-main.html)
- services/subservices-card.html <- service_item (depuis services/service-main.html)

### Parametres lus par un include que personne ne passe  (1)

Chacun rend nil. Legitime s'il a une valeur par defaut, a verifier sinon.

- ui/button.html lit include.type

## 3. Donnees

### Cles de donnees definies, aucun gabarit ne les lit  (18)

Aucun chemin resolu ne les atteint, propagation a travers les parametres d'include comprise.

- site.data.pages.contact.en.cta
- site.data.pages.contact.fr.cta
- site.data.projects.*.case_study.mockups.*.bg   (1 : stelya)
- site.data.projects.*.case_study.mockups.*.cols   (2 : aelio, stelya)
- site.data.projects.*.case_study.mockups.*.fit   (1 : stelya)
- site.data.projects.*.case_study.mockups.*.rows   (2 : aelio, stelya)
- site.data.projects.*.case_study.mockups_grid_cols   (2 : aelio, stelya)
- site.data.projects.*.discipline.en   (8 : chat-noir, cheetah, crow, exit, hdd-defrag, jpeja, logo-process, outlast-trials)
- site.data.projects.*.discipline.fr   (8 : chat-noir, cheetah, crow, exit, hdd-defrag, jpeja, logo-process, outlast-trials)
- site.data.projects.*.formats.en   (4 : jhag-banana-rush, jhag-discovery-set, jhag-pinterest, sipsmith)
- site.data.projects.*.formats.fr   (4 : jhag-banana-rush, jhag-discovery-set, jhag-pinterest, sipsmith)
- site.data.projects.*.livrables.en   (1 : moon-vtc)
- site.data.projects.*.livrables.fr   (1 : moon-vtc)
- site.data.services.*.seo.en   (4 : branding-strategy, graphic-design, music-design, web-design)
- site.data.services.*.seo.fr   (4 : branding-strategy, graphic-design, music-design, web-design)
- site.data.services.*.services.*   (4 : branding-strategy, graphic-design, music-design, web-design)
- site.data.services.*.slug.en   (4 : branding-strategy, graphic-design, music-design, web-design)
- site.data.services.*.slug.fr   (4 : branding-strategy, graphic-design, music-design, web-design)

### Couverture des cles de premier niveau dans `_data/projects/` (20 fichiers)  (10)

Une cle absente d'une partie du corpus fait s'appliquer une valeur par defaut sans que rien ne le dise.

- **livrables** : 1/20
- **chrome** : 2/20
- **formats** : 4/20
- **og_image** : 7/20
- **thumbnails** : 8/20
- **discipline** : 8/20
- **aspect** : 9/20
- **secteur** : 12/20   absent de chat-noir, cheetah, crow, exit, hdd-defrag, jpeja, logo-process, outlast-trials
- **mockup_a_produire** : 12/20   absent de a-lone, aelio, chat-noir, hors-champ, ottony, sipsmith, stelya, zylkene
- **case_study** : 19/20   absent de hors-champ

### Couverture des cles de premier niveau dans `_data/services/` (4 fichiers)  (1)

Une cle absente d'une partie du corpus fait s'appliquer une valeur par defaut sans que rien ne le dise.

- **subtitles** : 3/4   absent de branding-strategy

## 4. CSS

103 jetons definis, 98 consommes, 280 noms de selecteur, 11 `!important`.

`!important` : `assets/css/_sass/base/_bases.scss:63`, `assets/css/_sass/base/_bases.scss:64`, `assets/css/_sass/base/_bases.scss:65`, `assets/css/_sass/base/_bases.scss:66`, `assets/css/_sass/base/_bases.scss:77`, `assets/css/_sass/base/_bases.scss:82`, `assets/css/_sass/base/_bases.scss:83`, `assets/css/_sass/base/_bases.scss:84`, `assets/css/_sass/base/_generic.scss:21`, `assets/css/_sass/base/_generic.scss:60`, `assets/css/_sass/components/_cursor.scss:16`

Points de rupture ecrits en dur : 360px (3x), 520px (1x), 639px (2x), 767px (2x), 768px (2x), 900px (2x), 992px (1x), 1200px (1x)

### Jetons definis, aucun `var()` ne les lit  (7)

Verdict de fait, pas de valeur : certains sont reserves pour une phase a venir.

- --dur-reveal = 0.6s   (assets/css/_sass/base/_variables.scss:404)
- --p-vert-haute = #051510   (assets/css/_sass/base/_variables.scss:63)
- --p-vert-mediane = #030F0C   (assets/css/_sass/base/_variables.scss:62)
- --rhythm-lg = 10rem   (assets/css/_sass/base/_variables.scss:375)
- --rhythm-md = 6rem   (assets/css/_sass/base/_variables.scss:374)
- --rhythm-sm = 4rem   (assets/css/_sass/base/_variables.scss:373)
- --track-display = -0.015em   (assets/css/_sass/base/_variables.scss:330)

### Jetons poses en ligne et consommes SANS valeur de repli  (3)

Si la donnee qui pose le `style=` manque, la declaration entiere tombe.

- assets/css/_sass/pages/_project.scss:574  color: oklch(from var(--swatch-color) clamp(0, (0.5 - l) * 9999, 1) 0 0);
- assets/css/_sass/pages/_project.scss:582  color: oklch(from var(--swatch-color) clamp(0, (0.5 - l) * 9999, 1) 0 0);
- assets/css/_sass/pages/_project.scss:598  color: oklch(from var(--swatch-color) clamp(0, (0.5 - l) * 9999, 1) 0 0);

### DESACCORD DE SELECTEUR : le CSS cible un genre, le HTML emet l'autre  (3)

Ce n'est pas du code non emis, c'est du style qui ne s'applique pas. A reparer, pas a supprimer.

- .projects-title style en assets/css/_sass/base/_media-queries.scss:236, mais le HTML emet id="projects-title" sur 4 page(s)
- .contact-email style en assets/css/_sass/base/_media-queries.scss:326, mais le HTML emet id="contact-email" sur 2 page(s)
- .projects-grid style en assets/css/_sass/layout/_grids.scss:12, mais le HTML emet id="projects-grid" sur 12 page(s)

### Selecteurs absents des 63 pages construites  (33)

Fait date, pas jugement : aucune page du dernier build ne porte ce nom.

- .reveal-arme  assets/css/_sass/base/_animations.scss:17 assets/css/_sass/base/_animations.scss:23
- .is-visible  assets/css/_sass/base/_animations.scss:23 assets/css/_sass/base/_bases.scss:81
- .transparent-orange-bg  assets/css/_sass/base/_generic.scss:20
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
- .cursor-hover  assets/css/_sass/components/_cursor.scss:58
- .cursor-text  assets/css/_sass/components/_cursor.scss:66
- .cursor-zoom  assets/css/_sass/components/_cursor.scss:76 assets/css/_sass/components/_cursor.scss:84 assets/css/_sass/components/_cursor.scss:92 assets/css/_sass/components/_cursor.scss:98
- .lightbox-image  assets/css/_sass/components/_lightbox.scss:35 assets/css/_sass/components/_lightbox.scss:44
- .loaded  assets/css/_sass/components/_loader.scss:22
- .loader-logo-text  assets/css/_sass/components/_loader.scss:41
- .service-card-big  assets/css/_sass/components/cards/_service-cards.scss:71
- .hero-theme-container  assets/css/_sass/layout/_sections.scss:161
- .hero-theme  assets/css/_sass/layout/_sections.scss:176
- .hero-theme-dot  assets/css/_sass/layout/_sections.scss:186
- .subservice-section  assets/css/_sass/layout/_sections.scss:201
- #contact-social-links  assets/css/_sass/layout/_sections.scss:272 assets/css/_sass/layout/_sections.scss:322
- .social-links  assets/css/_sass/layout/_sections.scss:280 assets/css/_sass/layout/_sections.scss:288 assets/css/_sass/layout/_sections.scss:294 assets/css/_sass/layout/_sections.scss:299
- .social-icon  assets/css/_sass/layout/_sections.scss:315 assets/css/_sass/layout/_sections.scss:322
- .was-validated  assets/css/_sass/pages/_contact.scss:126 assets/css/_sass/pages/_contact.scss:316
- .contact-erreur  assets/css/_sass/pages/_contact.scss:135 assets/css/_sass/pages/_contact.scss:145 assets/css/_sass/pages/_contact.scss:148
- .contact-select  assets/css/_sass/pages/_contact.scss:155 assets/css/_sass/pages/_contact.scss:171
- .is-invalid  assets/css/_sass/pages/_contact.scss:316
- .galerie-plus  assets/css/_sass/pages/_project.scss:355 assets/css/_sass/pages/_project.scss:357 assets/css/_sass/pages/_project.scss:378
- .project-back-link  assets/css/_sass/pages/_project.scss:809 assets/css/_sass/pages/_project.scss:822 assets/css/_sass/pages/_project.scss:824 assets/css/_sass/pages/_project.scss:827

### Valeurs ecrites en dur alors qu'un jeton porte la meme  (8)

Chacune est un endroit que le jeton ne pourra pas deplacer le jour ou il bougera.

- 1rem ecrit 19 fois, alors que --radius-sm vaut exactement ca   (ex. assets/css/_sass/base/_generic.scss:27, assets/css/_sass/base/_media-queries.scss:79, assets/css/_sass/base/_media-queries.scss:268)
- 3rem ecrit 18 fois, alors que --spacing-xl vaut exactement ca   (ex. assets/css/_sass/base/_media-queries.scss:175, assets/css/_sass/base/_media-queries.scss:176, assets/css/_sass/base/_media-queries.scss:200)
- 2rem ecrit 16 fois, alors que --radius-lg vaut exactement ca   (ex. assets/css/_sass/base/_media-queries.scss:41, assets/css/_sass/components/_buttons.scss:31, assets/css/_sass/components/_buttons.scss:181)
- 1px ecrit 14 fois, alors que --hairline-width vaut exactement ca   (ex. assets/css/_sass/base/_bases.scss:35, assets/css/_sass/base/_bases.scss:36, assets/css/_sass/base/_generic.scss:8)
- 0.5rem ecrit 11 fois, alors que --spacing-xs vaut exactement ca   (ex. assets/css/_sass/base/_media-queries.scss:273, assets/css/_sass/base/_media-queries.scss:373, assets/css/_sass/components/cards/_experience-cards.scss:45)
- 3px ecrit 10 fois, alors que --signal-width vaut exactement ca   (ex. assets/css/_sass/base/_bases.scss:53, assets/css/_sass/components/_cursor.scss:30, assets/css/_sass/components/_cursor.scss:62)
- 1.5rem ecrit 8 fois, alors que --radius-md vaut exactement ca   (ex. assets/css/_sass/base/_bases.scss:15, assets/css/_sass/base/_media-queries.scss:36, assets/css/_sass/base/_media-queries.scss:372)
- 6rem ecrit 7 fois, alors que --radius-xl vaut exactement ca   (ex. assets/css/_sass/components/_scroll-down.scss:13, assets/css/_sass/pages/_about.scss:9, assets/css/_sass/pages/_about.scss:69)

## 5. JS

2 fichiers, 39 selecteurs litteraux, 38 ecouteurs.

**Fonctions qui se relancent elles-memes en rAF** : `animer` (assets/js/dither.js:635), `animateBlob` (assets/js/script.js:65). Une fois demarrees elles ne s'arretent plus, mais leur MISE EN ROUTE depend d'une garde que la carte ne suit pas : elle rapporte la forme, pas le fait.

### Selecteurs JS qui ne trouvent rien dans les 63 pages construites  (1)

Un selecteur qui ne matche rien n'echoue pas : il rend null et le code s'arrete en silence.

- .stt-progress  (assets/js/script.js:1329)

### Ecouteurs `scroll` recenses  (3)

A confronter au throttle : un handler sans rAF qui lit une metrique de layout force un reflow a chaque evenement.

- assets/js/script.js:455
- assets/js/script.js:898  (passive)
- assets/js/script.js:1352  (passive)

## 6. Contrat des trois couches

Pour chaque `data-*` et `aria-*` emis : **H** le HTML le pose, **J** le JS l'ecrit ou le lit, **C** le CSS s'y accroche. Une ligne sans **C** ni **J** est un attribut que personne ne consomme.

| Attribut | HTML | CSS | JS |
|---|---|---|---|
| `aria-atomic` | 63 page(s) | - | - **personne ne le lit** |
| `aria-controls` | 63 page(s) | - | assets/js/script.js:146 |
| `aria-current` | 8 page(s) | - | - **personne ne le lit** |
| `aria-describedby` | - | - | assets/js/script.js:1198 |
| `aria-expanded` | 63 page(s) | oui | assets/js/script.js:153 |
| `aria-haspopup` | 4 page(s) | - | - **personne ne le lit** |
| `aria-hidden` | 63 page(s) | - | - **personne ne le lit** |
| `aria-invalid` | - | - | assets/js/script.js:1197 |
| `aria-label` | 63 page(s) | - | assets/js/script.js:1282 |
| `aria-labelledby` | 51 page(s) | - | - **personne ne le lit** |
| `aria-live` | 63 page(s) | - | - **personne ne le lit** |
| `aria-modal` | 40 page(s) | - | - **personne ne le lit** |
| `aria-selected` | 4 page(s) | oui | assets/js/script.js:163 |
| `data-category` | 10 page(s) | - | assets/js/script.js:279 |
| `data-chargee` | - | - | assets/js/script.js:1056 |
| `data-chrome` | - | oui | assets/js/script.js:442 |
| `data-chrome-fige` | 4 page(s) | - | - **personne ne le lit** |
| `data-dbg` | - | - | assets/js/script.js:848 |
| `data-dropdown-caret` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-menu` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-option` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-selected` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-trigger` | 4 page(s) | - | - **personne ne le lit** |
| `data-dropdown-variant` | 4 page(s) | - | - **personne ne le lit** |
| `data-empty` | 2 page(s) | oui | assets/js/script.js:181 |
| `data-encre` | - | oui | assets/js/script.js:862 |
| `data-name` | 2 page(s) | - | - **personne ne le lit** |
| `data-placeholder` | 2 page(s) | - | - **personne ne le lit** |
| `data-set-lang` | 62 page(s) | - | assets/js/script.js:1106 |
| `data-seuil` | 24 page(s) | - | assets/js/script.js:975 |
| `data-seuil-mobile` | 24 page(s) | - | assets/js/script.js:974 |
| `data-src` | 4 page(s) | - | assets/js/script.js:1058 |
| `data-sur-media` | - | oui | assets/js/script.js:842 |
| `data-value` | 4 page(s) | oui | assets/js/script.js:185 |
| `data-zone` | - | oui | assets/js/script.js:886 |
| `loop` | - | - | assets/js/script.js:1072 |

## 7. Assets

76 fichiers, 84.7 Mo au total.

### Assets qu'aucune page construite ne reference (1.2 Mo)  (5)

Detection par nom de fichier : un chemin construit dynamiquement y echapperait. Verifier avant de supprimer.

-  442.8 Ko  /assets/images/backgrounds/main-bg.webp
-  273.5 Ko  /assets/images/projects/JPeJA-thumbnail2.jpg
-  259.4 Ko  /assets/images/projects/aelio/aelio-app-mockup-alone.avif
-  218.9 Ko  /assets/images/projects/jhag/jhag-br-p3-flambe.webp
-    1.7 Ko  /assets/images/partners/ottony-paris.svg

### Pages les plus lourdes au chargement (medias non differes)  (10)

Ce que le visiteur telecharge sans l'avoir demande. Le CSS, le JS et les polices ne sont pas comptes.

-    9.5 Mo  en/projects/jpeja.html   JPeJA.mp4
-    9.5 Mo  fr/projects/jpeja.html   JPeJA.mp4
-    1.1 Mo  fr/projects/cheetah.html   CHEETAH.mp4
-    1.1 Mo  en/projects/cheetah.html   CHEETAH.mp4
-  547.8 Ko  fr/projects/exit.html   exit.webp
-  547.8 Ko  en/projects/exit.html   exit.webp
-  501.4 Ko  en/projects/zylkene.html   zylkene-mockup.webp
-  501.4 Ko  fr/projects/zylkene.html   zylkene-mockup.webp
-  462.2 Ko  fr/projects/outlast-trials.html   outlast-trials.png
-  462.2 Ko  en/projects/outlast-trials.html   outlast-trials.png

## 8. Build et CI

**CSS servi** : 175369 o brut, 51094 o gzip. Sans les commentaires : 76084 o, 12406 o gzip, soit **76 % de moins** sur le fil.

Les plugins Ruby de `_plugins/` **s'executent** avec cette chaine de build.

Rien a signaler.

## 9. Ce que la carte ne sait pas

7 cas n'ont pas pu etre tranches. Ils sont listes ici plutot que passes sous silence : une carte qui cache ses angles morts parait meilleure qu'elle n'est.

**classe JS calculee** (1)

- `assets/js/script.js:86` : stateClass

**selecteur JS calcule** (6)

- `assets/js/dither.js:621` : INTERACTIF
- `assets/js/script.js:85` : selectors
- `assets/js/script.js:146` : trigger.getAttribute('aria-controls'
- `assets/js/script.js:258` : selector
- `assets/js/script.js:1184` : champ.id + '-erreur'
- `assets/js/script.js:1203` : champ.id + '-erreur'

**Noms de variable liees a plusieurs sources** (52). Liquid a des portees de bloc, la carte n'en a pas : quand un meme nom designe plusieurs choses dans un fichier, elle resout vers l'UNION des possibilites. Elle peut donc declarer vivante une cle qui ne l'est pas, jamais l'inverse.

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
- _includes/pages/about.html : `item` a 2 liaisons
- _includes/pages/index.html : `id` a 2 liaisons
- ... et 40 autres

### Limites structurelles, valables meme quand la liste ci-dessus est vide

- **Les orphelins d'assets sont detectes par nom de fichier.** Un chemin construit
  dynamiquement echapperait au filet. Verifier avant de supprimer.
- **`_site` est l'oracle**, donc la carte ne connait que ce que le dernier build a
  produit. Une page exclue de la construction est invisible pour elle.
- **Le rendu n'est pas mesure.** Aucune section ne dit si une page est belle, lisible
  ou utilisable au clavier. La carte dit ce qui est branche, pas ce qui est bon.
