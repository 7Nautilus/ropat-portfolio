# Carte du depot

> Generee le 29/07/2026 a 01:37 sur 59f3125.
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
| Pages construites lues comme oracle | **66** |
| Date du build lu | 29/07/2026 01:37 |
| Fichiers de donnees | 37 |
| Includes | 30 |
| Partiels SCSS | 31 |
| Cas **INDETERMINES** | **7** |

Repartition des indetermines : selecteur JS calcule (6), classe JS calculee (1).

**Les trois seuls verdicts employes ici sont `CONFIRME`, `ABSENT` et `INDETERMINE`.**
Le mot « mort » n'apparait nulle part : il affirme qu'une chose ne servira jamais, ce
qu'aucune mesure ne peut etablir. « Absent des 66 pages construites le
29/07 » est un fait, datable et refutable.

## 1. Routes

67 sources a front matter, dont 33 en FR et 31 en EN.

**48 pages ne portent qu'un identifiant** et un include d'une ligne : elles sont integralement derivables de leurs donnees.

<details><summary>Table complete des routes</summary>

| URL | Source | Lang |
|---|---|---|
| `/` | `index.html` | fr |
| `/DESIGN.html` | `DESIGN.md` | - |
| `/design-system.html` | `design-system.html` | fr |
| `/en/` | `en/index.html` | en |
| `/en/about.html` | `en/about.html` | en |
| `/en/contact.html` | `en/contact.html` | en |
| `/en/legal-notice.html` | `en/legal-notice.html` | en |
| `/en/portfolio.html` | `en/portfolio.html` | en |
| `/en/privacy.html` | `en/privacy.html` | en |
| `/en/projects/a-lone.html` | `en/projects/a-lone.html` | en |
| `/en/projects/aelio.html` | `en/projects/aelio.html` | en |
| `/en/projects/btr.html` | `en/projects/btr.html` | en |
| `/en/projects/chat-noir.html` | `en/projects/chat-noir.html` | en |
| `/en/projects/cheetah.html` | `en/projects/cheetah.html` | en |
| `/en/projects/crow.html` | `en/projects/crow.html` | en |
| `/en/projects/exit.html` | `en/projects/exit.html` | en |
| `/en/projects/hdd-defrag.html` | `en/projects/hdd-defrag.html` | en |
| `/en/projects/hors-champ.html` | `en/projects/hors-champ.html` | en |
| `/en/projects/jhag-banana-rush.html` | `en/projects/jhag-banana-rush.html` | en |
| `/en/projects/jhag-discovery-set.html` | `en/projects/jhag-discovery-set.html` | en |
| `/en/projects/jhag-pinterest.html` | `en/projects/jhag-pinterest.html` | en |
| `/en/projects/jpeja.html` | `en/projects/jpeja.html` | en |
| `/en/projects/logo-process.html` | `en/projects/logo-process.html` | en |
| `/en/projects/moon-vtc.html` | `en/projects/moon-vtc.html` | en |
| `/en/projects/ottony-paris.html` | `en/projects/ottony-paris.html` | en |
| `/en/projects/outlast-trials.html` | `en/projects/outlast-trials.html` | en |
| `/en/projects/sipsmith.html` | `en/projects/sipsmith.html` | en |
| `/en/projects/stelya.html` | `en/projects/stelya.html` | en |
| `/en/projects/zylkene.html` | `en/projects/zylkene.html` | en |
| `/en/services.html` | `en/services.html` | en |
| `/en/services/branding-strategy.html` | `en/services/branding-strategy.html` | en |
| `/en/services/graphic-design.html` | `en/services/graphic-design.html` | en |
| `/en/services/music-design.html` | `en/services/music-design.html` | en |
| `/en/services/web-design.html` | `en/services/web-design.html` | en |
| `/fr/about.html` | `fr/about.html` | fr |
| `/fr/confidentialite.html` | `fr/confidentialite.html` | fr |
| `/fr/contact.html` | `fr/contact.html` | fr |
| `/fr/experiences.html` | `fr/experiences.html` | fr |
| `/fr/mentions-legales.html` | `fr/mentions-legales.html` | fr |
| `/fr/portfolio.html` | `fr/portfolio.html` | fr |
| `/fr/projects/a-lone.html` | `fr/projects/a-lone.html` | fr |
| `/fr/projects/aelio.html` | `fr/projects/aelio.html` | fr |
| `/fr/projects/btr.html` | `fr/projects/btr.html` | fr |
| `/fr/projects/chat-noir.html` | `fr/projects/chat-noir.html` | fr |
| `/fr/projects/cheetah.html` | `fr/projects/cheetah.html` | fr |
| `/fr/projects/crow.html` | `fr/projects/crow.html` | fr |
| `/fr/projects/exit.html` | `fr/projects/exit.html` | fr |
| `/fr/projects/hdd-defrag.html` | `fr/projects/hdd-defrag.html` | fr |
| `/fr/projects/hors-champ.html` | `fr/projects/hors-champ.html` | fr |
| `/fr/projects/jhag-banana-rush.html` | `fr/projects/jhag-banana-rush.html` | fr |
| `/fr/projects/jhag-discovery-set.html` | `fr/projects/jhag-discovery-set.html` | fr |
| `/fr/projects/jhag-pinterest.html` | `fr/projects/jhag-pinterest.html` | fr |
| `/fr/projects/jpeja.html` | `fr/projects/jpeja.html` | fr |
| `/fr/projects/logo-process.html` | `fr/projects/logo-process.html` | fr |
| `/fr/projects/moon-vtc.html` | `fr/projects/moon-vtc.html` | fr |
| `/fr/projects/ottony-paris.html` | `fr/projects/ottony-paris.html` | fr |
| `/fr/projects/outlast-trials.html` | `fr/projects/outlast-trials.html` | fr |
| `/fr/projects/sipsmith.html` | `fr/projects/sipsmith.html` | fr |
| `/fr/projects/stelya.html` | `fr/projects/stelya.html` | fr |
| `/fr/projects/zylkene.html` | `fr/projects/zylkene.html` | fr |
| `/fr/services.html` | `fr/services.html` | fr |
| `/fr/services/branding-strategie.html` | `fr/services/branding-strategie.html` | fr |
| `/fr/services/conception-graphique.html` | `fr/services/conception-graphique.html` | fr |
| `/fr/services/design-musique.html` | `fr/services/design-musique.html` | fr |
| `/fr/services/web-design.html` | `fr/services/web-design.html` | fr |
| `/labo/design-system.html` | `labo/design-system.html` | - |
| `/sitemap.xml` | `sitemap.xml` | - |

</details>

### Sources dont la sortie calculee est introuvable dans _site  (1)

Soit la page est exclue par `_config.yml`, soit la regle d'URL de la carte est fausse.

- DESIGN.md -> DESIGN.html

### Pages dont le jumeau de langue calcule n'existe pas  (6)

Chacune produit un lien de bascule et un `<link rel="alternate">` vers une URL absente.

- en/index.html (en) vise /fr/
- en/legal-notice.html (en) vise /fr/legal-notice.html
- en/privacy.html (en) vise /fr/privacy.html
- fr/confidentialite.html (fr) vise /en/confidentialite.html
- fr/experiences.html (fr) vise /en/experiences.html
- fr/mentions-legales.html (fr) vise /en/mentions-legales.html

### Liens de langue EMIS qui ne resolvent vers aucun fichier  (13)

Mesure sur `_site`, pas sur les sources. Attendu apres correction : 0.

- design-system.html : lien de bascule -> /en/design-system.html
- design-system.html : hreflang -> https://ropat.art/fr/design-system.html
- design-system.html : hreflang -> https://ropat.art/en/design-system.html
- en/legal-notice.html : lien de bascule -> /fr/legal-notice.html
- en/legal-notice.html : hreflang -> https://ropat.art/fr/legal-notice.html
- en/privacy.html : lien de bascule -> /fr/privacy.html
- en/privacy.html : hreflang -> https://ropat.art/fr/privacy.html
- fr/confidentialite.html : lien de bascule -> /en/confidentialite.html
- fr/confidentialite.html : hreflang -> https://ropat.art/en/confidentialite.html
- fr/experiences.html : lien de bascule -> /en/experiences.html
- fr/experiences.html : hreflang -> https://ropat.art/en/experiences.html
- fr/mentions-legales.html : lien de bascule -> /en/mentions-legales.html
- fr/mentions-legales.html : hreflang -> https://ropat.art/en/mentions-legales.html

## 2. Graphe des includes

30 includes, 120 appels, profondeur maximale 4 depuis `_layouts/default.html`.

Aucun include orphelin.

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
- `projects/project-main.html` <- en/projects/a-lone.html, en/projects/aelio.html, en/projects/btr.html, en/projects/chat-noir.html, en/projects/cheetah.html, en/projects/crow.html, en/projects/exit.html, en/projects/hdd-defrag.html, en/projects/hors-champ.html, en/projects/jhag-banana-rush.html, en/projects/jhag-discovery-set.html, en/projects/jhag-pinterest.html, en/projects/jpeja.html, en/projects/logo-process.html, en/projects/moon-vtc.html, en/projects/ottony-paris.html, en/projects/outlast-trials.html, en/projects/sipsmith.html, en/projects/stelya.html, en/projects/zylkene.html, fr/projects/a-lone.html, fr/projects/aelio.html, fr/projects/btr.html, fr/projects/chat-noir.html, fr/projects/cheetah.html, fr/projects/crow.html, fr/projects/exit.html, fr/projects/hdd-defrag.html, fr/projects/hors-champ.html, fr/projects/jhag-banana-rush.html, fr/projects/jhag-discovery-set.html, fr/projects/jhag-pinterest.html, fr/projects/jpeja.html, fr/projects/logo-process.html, fr/projects/moon-vtc.html, fr/projects/ottony-paris.html, fr/projects/outlast-trials.html, fr/projects/sipsmith.html, fr/projects/stelya.html, fr/projects/zylkene.html
- `projects/project-note.html` <- projects/project-main.html
- `scroll-down-link.html` <- pages/experiences.html, pages/portfolio.html, pages/services.html, projects/project-main.html
- `services/service-card.html` <- pages/index.html, pages/services.html
- `services/service-main.html` <- en/services/branding-strategy.html, en/services/graphic-design.html, en/services/music-design.html, en/services/web-design.html, fr/services/branding-strategie.html, fr/services/conception-graphique.html, fr/services/design-musique.html, fr/services/web-design.html
- `services/subservices-card.html` <- services/service-main.html
- `social-media-icons.html` <- design-system.html, pages/contact.html
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

### Cles de donnees definies, aucun gabarit ne les lit  (16)

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

107 jetons definis, 98 consommes, 280 noms de selecteur, 11 `!important`.

`!important` : `assets/css/_sass/base/_bases.scss:63`, `assets/css/_sass/base/_bases.scss:64`, `assets/css/_sass/base/_bases.scss:65`, `assets/css/_sass/base/_bases.scss:66`, `assets/css/_sass/base/_bases.scss:77`, `assets/css/_sass/base/_bases.scss:82`, `assets/css/_sass/base/_bases.scss:83`, `assets/css/_sass/base/_bases.scss:84`, `assets/css/_sass/base/_generic.scss:21`, `assets/css/_sass/base/_generic.scss:60`, `assets/css/_sass/components/_cursor.scss:16`

Points de rupture ecrits en dur : 360px (3x), 520px (1x), 639px (2x), 767px (2x), 768px (2x), 900px (2x), 992px (1x), 1200px (1x)

### Jetons definis, aucun `var()` ne les lit  (11)

Verdict de fait, pas de valeur : certains sont reserves pour une phase a venir.

- --dur-reveal = 0.6s   (assets/css/_sass/base/_variables.scss:410)
- --p-vert-haute = #051510   (assets/css/_sass/base/_variables.scss:63)
- --p-vert-mediane = #030F0C   (assets/css/_sass/base/_variables.scss:62)
- --rhythm-lg = 10rem   (assets/css/_sass/base/_variables.scss:382)
- --rhythm-md = 6rem   (assets/css/_sass/base/_variables.scss:381)
- --rhythm-sm = 4rem   (assets/css/_sass/base/_variables.scss:380)
- --scrim-canal = 0, 0, 0   (assets/css/_sass/base/_variables.scss:165)
- --shadow-ambient-strong = 0 4px 6px rgba(0, 0, 0, 0.3)   (assets/css/_sass/base/_variables.scss:270)
- --squircle-small = 15%   (assets/css/_sass/base/_variables.scss:396)
- --text-muted = var(--ink-subtle)   (assets/css/_sass/base/_variables.scss:453)
- --track-display = -0.015em   (assets/css/_sass/base/_variables.scss:337)

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

### Selecteurs emis UNIQUEMENT par les pages internes  (1)

Ni vivants sur le site public, ni absents. Leur sort depend de celui des pages de labo.

- .contact-erreur  (assets/css/_sass/pages/_contact.scss:135) -> labo/design-system.html

### Selecteurs absents des 66 pages construites  (29)

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
- .subservice-section  assets/css/_sass/layout/_sections.scss:201
- #contact-social-links  assets/css/_sass/layout/_sections.scss:272 assets/css/_sass/layout/_sections.scss:322
- .social-links  assets/css/_sass/layout/_sections.scss:280 assets/css/_sass/layout/_sections.scss:288 assets/css/_sass/layout/_sections.scss:294 assets/css/_sass/layout/_sections.scss:299
- .social-icon  assets/css/_sass/layout/_sections.scss:315 assets/css/_sass/layout/_sections.scss:322
- .was-validated  assets/css/_sass/pages/_contact.scss:126 assets/css/_sass/pages/_contact.scss:316
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

2 fichiers, 45 selecteurs litteraux, 39 ecouteurs.

**Boucles rAF permanentes** (elles tournent tant que l'onglet est visible) : `animer` (assets/js/dither.js:635), `animateBlob` (assets/js/script.js:65), `updateParallax` (assets/js/script.js:1372)

### Selecteurs JS qui ne trouvent rien dans les 66 pages construites  (6)

Un selecteur qui ne matche rien n'echoue pas : il rend null et le code s'arrete en silence.

- .stt-progress  (assets/js/script.js:1318)
- .hero-project  (assets/js/script.js:1357)   proche : hero
- .hero-project-title-container  (assets/js/script.js:1362)   proche : hero
- .hero-image-container  (assets/js/script.js:1364)   proche : hero
- .thumbnail-image  (assets/js/script.js:98)
- .zoomable  (assets/js/script.js:98)

### Ecouteurs `scroll` recenses  (4)

A confronter au throttle : un handler sans rAF qui lit une metrique de layout force un reflow a chaque evenement.

- assets/js/script.js:444
- assets/js/script.js:887  (passive)
- assets/js/script.js:1341  (passive)
- assets/js/script.js:1394

## 6. Contrat des trois couches

Pour chaque `data-*` et `aria-*` emis : **H** le HTML le pose, **J** le JS l'ecrit ou le lit, **C** le CSS s'y accroche. Une ligne sans **C** ni **J** est un attribut que personne ne consomme.

| Attribut | HTML | CSS | JS |
|---|---|---|---|
| `aria-atomic` | 64 page(s) | - | - **personne ne le lit** |
| `aria-controls` | 65 page(s) | - | assets/js/script.js:135 |
| `aria-current` | 10 page(s) | - | - **personne ne le lit** |
| `aria-describedby` | 1 page(s) | - | assets/js/script.js:1187 |
| `aria-expanded` | 65 page(s) | oui | assets/js/script.js:142 |
| `aria-haspopup` | 5 page(s) | - | - **personne ne le lit** |
| `aria-hidden` | 65 page(s) | - | - **personne ne le lit** |
| `aria-invalid` | 1 page(s) | - | assets/js/script.js:1186 |
| `aria-label` | 66 page(s) | - | assets/js/script.js:1271 |
| `aria-labelledby` | 51 page(s) | - | - **personne ne le lit** |
| `aria-live` | 64 page(s) | - | - **personne ne le lit** |
| `aria-modal` | 40 page(s) | - | - **personne ne le lit** |
| `aria-selected` | 5 page(s) | oui | assets/js/script.js:152 |
| `data-category` | 10 page(s) | - | assets/js/script.js:268 |
| `data-chargee` | - | - | assets/js/script.js:1045 |
| `data-chrome` | - | oui | assets/js/script.js:431 |
| `data-chrome-fige` | 4 page(s) | - | - **personne ne le lit** |
| `data-courbe` | 1 page(s) | - | - **personne ne le lit** |
| `data-dbg` | - | - | assets/js/script.js:837 |
| `data-dropdown-caret` | 5 page(s) | - | - **personne ne le lit** |
| `data-dropdown-menu` | 5 page(s) | - | - **personne ne le lit** |
| `data-dropdown-option` | 5 page(s) | - | - **personne ne le lit** |
| `data-dropdown-selected` | 5 page(s) | - | - **personne ne le lit** |
| `data-dropdown-trigger` | 5 page(s) | - | - **personne ne le lit** |
| `data-dropdown-variant` | 5 page(s) | - | - **personne ne le lit** |
| `data-ds` | 1 page(s) | - | - **personne ne le lit** |
| `data-empty` | 3 page(s) | oui | assets/js/script.js:170 |
| `data-encre` | - | oui | assets/js/script.js:851 |
| `data-jeton` | 1 page(s) | - | - **personne ne le lit** |
| `data-mesure` | 1 page(s) | - | - **personne ne le lit** |
| `data-name` | 2 page(s) | - | - **personne ne le lit** |
| `data-placeholder` | 3 page(s) | - | - **personne ne le lit** |
| `data-set-lang` | 64 page(s) | - | assets/js/script.js:1095 |
| `data-seuil` | 24 page(s) | - | assets/js/script.js:964 |
| `data-seuil-mobile` | 24 page(s) | - | assets/js/script.js:963 |
| `data-src` | 4 page(s) | - | assets/js/script.js:1047 |
| `data-sur-media` | - | oui | assets/js/script.js:831 |
| `data-theme` | 1 page(s) | oui | - |
| `data-value` | 5 page(s) | oui | assets/js/script.js:174 |
| `data-zone` | - | oui | assets/js/script.js:875 |
| `loop` | - | - | assets/js/script.js:1061 |

## 7. Assets

80 fichiers, 156.0 Mo au total.

### Assets qu'aucune page construite ne reference (73.0 Mo)  (16)

Detection par nom de fichier : un chemin construit dynamiquement y echapperait. Verifier avant de supprimer.

-   18.5 Mo  /assets/videos/crow-noir-fluo.mp4
-   18.0 Mo  /assets/videos/jhag/jhag-br-p3-anim-pile.mp4
-   17.5 Mo  /assets/videos/crow-ascii.mp4
-   16.6 Mo  /assets/videos/cheetah-noir-fluo.mp4
-  487.4 Ko  /assets/images/projects/chatnoir.jpg
-  442.8 Ko  /assets/images/backgrounds/main-bg.webp
-  286.9 Ko  /assets/images/projects/jhag/jhag-br-p1-kv.webp
-  273.5 Ko  /assets/images/projects/JPeJA-thumbnail2.jpg
-  259.4 Ko  /assets/images/projects/aelio/aelio-app-mockup-alone.avif
-  218.9 Ko  /assets/images/projects/jhag/jhag-br-p3-flambe.webp
-  161.7 Ko  /assets/images/projects/Stelya/stelya-og.webp
-  141.8 Ko  /assets/images/projects/hors-champ/hors-champ-og.webp
-   78.6 Ko  /assets/images/projects/sipsmith/sipsmith-og.webp
-   40.0 Ko  /assets/images/projects/aelio/aelio-og.webp
-   34.1 Ko  /assets/images/projects/jhag/jhag-pinterest-og.webp
-    1.7 Ko  /assets/images/partners/ottony-paris.svg

### Pages les plus lourdes au chargement (medias non differes)  (10)

Ce que le visiteur telecharge sans l'avoir demande. Le CSS, le JS et les polices ne sont pas comptes.

-    9.5 Mo  fr/projects/jpeja.html   JPeJA.mp4
-    9.5 Mo  en/projects/jpeja.html   JPeJA.mp4
-    1.1 Mo  fr/projects/cheetah.html   CHEETAH.mp4
-    1.1 Mo  en/projects/cheetah.html   CHEETAH.mp4
-  751.3 Ko  fr/about.html   about-photo.jpg
-  751.3 Ko  en/about.html   about-photo.jpg
-  547.8 Ko  en/projects/exit.html   exit.webp
-  547.8 Ko  fr/projects/exit.html   exit.webp
-  501.4 Ko  fr/projects/zylkene.html   zylkene-mockup.webp
-  501.4 Ko  en/projects/zylkene.html   zylkene-mockup.webp

## 8. Build et CI

**CSS servi** : 175566 o brut, 51177 o gzip. Sans les commentaires : 76287 o, 12451 o gzip, soit **76 % de moins** sur le fil.

Les plugins Ruby de `_plugins/` **s'executent** avec cette chaine de build.

### Desaccords entre la configuration, le workflow et la tache locale  (11)

Chacun decrit le meme build. Quand ils divergent, c'est toujours le workflow qui gagne.

- Le CSS deploye n'est PAS compresse
      .github/workflows/deploy.yml, etape dart-sass
      La tache locale porte `--style=compressed`, la CI non. C'est donc la version commentee qui part en production.
- Le bloc `sass:` de `_config.yml` est inerte
      _config.yml
      `main.scss` n'a pas de front matter, donc Jekyll ne le compile jamais, il le COPIE. Le reglage n'a jamais rien fait, et il donne a lire que la compression est configuree.
- `sass_dir: _sass` pointe vers un repertoire inexistant
      _config.yml
      Les partiels vivent dans `assets/css/_sass/` et sont resolus par les `@use` relatifs.
- La reinclusion `!.vscode/...` de `.gitignore` est inoperante
      .gitignore
      Git ne peut pas reinclure un fichier dont le REPERTOIRE parent est exclu. Il faut `.vscode/*` puis `!.vscode/tasks.json`.
- `labo/` est publie en production
      _config.yml (exclude)
      Rien ne l'exclut du build. Seul un `noindex` le protege, ce qui n'est pas une exclusion.
- `TESTS/` est publie en production
      _config.yml (exclude)
      Rien ne l'exclut du build. Seul un `noindex` le protege, ce qui n'est pas une exclusion.
- dart-sass est installe en version flottante
      .github/workflows/deploy.yml
      `snap install dart-sass` prend la derniere version publiee au moment du build. Le CSS peut changer un jour ou personne n'a rien change.
- Aucun cache de gems en CI
      .github/workflows/deploy.yml
      `bundle install` complet a chaque push.
- `gem "jekyll"` sans contrainte de version
      Gemfile
      Une majeure suivante entrerait sans que rien ne l'annonce.
- `Gemfile.lock` ne declare pas la plateforme Linux
      Gemfile.lock (PLATFORMS)
      D'ou le contournement `bundle lock --add-platform x86_64-linux` a chaque build.
- `webrick` declare alors que jekyll le tire deja
      Gemfile
      Redondance sans effet, mais elle laisse croire a une dependance directe.

## 9. Ce que la carte ne sait pas

7 cas n'ont pas pu etre tranches. Ils sont listes ici plutot que passes sous silence : une carte qui cache ses angles morts parait meilleure qu'elle n'est.

**classe JS calculee** (1)

- `assets/js/script.js:86` : stateClass

**selecteur JS calcule** (6)

- `assets/js/dither.js:621` : INTERACTIF
- `assets/js/script.js:85` : selectors
- `assets/js/script.js:135` : trigger.getAttribute('aria-controls'
- `assets/js/script.js:247` : selector
- `assets/js/script.js:1173` : champ.id + '-erreur'
- `assets/js/script.js:1192` : champ.id + '-erreur'

**Noms de variable liees a plusieurs sources** (53). Liquid a des portees de bloc, la carte n'en a pas : quand un meme nom designe plusieurs choses dans un fichier, elle resout vers l'UNION des possibilites. Elle peut donc declarer vivante une cle qui ne l'est pas, jamais l'inverse.

- _includes/lang-selector.html : `service_item` a 2 liaisons
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
- ... et 41 autres

### Limites structurelles, valables meme quand la liste ci-dessus est vide

- **Les orphelins d'assets sont detectes par nom de fichier.** Un chemin construit
  dynamiquement echapperait au filet. Verifier avant de supprimer.
- **`_site` est l'oracle**, donc la carte ne connait que ce que le dernier build a
  produit. Une page exclue de la construction est invisible pour elle.
- **Le rendu n'est pas mesure.** Aucune section ne dit si une page est belle, lisible
  ou utilisable au clavier. La carte dit ce qui est branche, pas ce qui est bon.
