# AUDIT COMPLET DU SITE ROPAT.ART

**Date de l'audit :** 12 mars 2026
**Site audite :** https://ropat.art
**Type :** Portfolio Jekyll statique bilingue (FR/EN) - Graphiste & Directeur Artistique
**Deploiement :** GitHub Pages via GitHub Actions

---

## RESUME EXECUTIF

**Score global : 7/10** - Architecture solide et bien pensee, mais plusieurs fichiers orphelins, des incoherences de contenu bilingue, et des optimisations de performance manquantes.

### Points forts
- Architecture data-driven tres propre (YAML + includes Jekyll)
- Systeme bilingue complet FR/EN avec detection de langue
- SEO avance (Open Graph, Schema.org JSON-LD, hreflang, sitemap)
- Accessibilite correcte (skip-link, ARIA, clavier, reduced-motion)
- JavaScript vanilla leger et sans dependances

### Points critiques
- Incoherence d'emails entre les pages
- Service "Graphic Design" invisible (absent de l'index)
- Contenu hardcode en francais sur la page services
- Fichiers legacy/orphelins encombrant le repo
- Pas de lazy loading d'images ni de format WebP generalise

---

## 1. ARCHITECTURE & STRUCTURE (8/10)

### Vue d'ensemble

```
ropat-portfolio/
  _config.yml              # Config Jekyll + donnees business
  _layouts/
    default.html           # Layout unique (SEO dynamique, analytics, fonts)
  _includes/
    layout/                # header, nav, footer
    meta/                  # open-graph, schema-org, schema (legacy)
    pages/                 # index, portfolio, services, contact, about, experiences
    projects/              # project-card, project-main
    services/              # service-card, subservices-card, service-main
    experiences/           # experience-card
    burger-menu.html, lang-detector.html, lang-selector.html, etc.
  _data/
    pages/                 # Contenu des pages (index, about, contact, services, experiences)
    projects/              # 12 fichiers YAML + index.yml (ordre d'affichage)
    services/              # 4 fichiers YAML + index.yml (ordre d'affichage)
    navigation.yml, design-system.yml, socials.yml, partners.yml
  en/                      # Pages anglaises
  fr/                      # Pages francaises
  assets/
    css/_sass/             # SCSS organise (base, components, layout, pages)
    css/main.scss          # Manifest SCSS
    js/script.js           # JS principal
    images/, videos/, fonts/
```

### Points forts
- Toute la donnee dans `_data/` : un seul point de verite par projet/service
- Pages = wrappers minimalistes (front matter + `{% include %}`)
- Layout unique avec logique SEO conditionnelle (page vs projet vs service)
- Script PowerShell (`scripts/new-project.ps1`) pour scaffolding de nouveaux projets
- Architecture SCSS bien decoupee : base/ -> layout/ -> components/ -> pages/

### Problemes identifies

| # | Probleme | Severite | Detail |
|---|----------|----------|--------|
| A1 | Asymetrie structure FR/EN | Moyenne | Pas de `fr/index.html` (homepage FR = `/index.html` racine) alors que EN a `en/index.html` |
| A2 | Fichiers legacy dans le repo | Faible | `style.css` (1903 lignes), `services_old.yml`, `schema.html`, `backup.txt`, `extract_font_sizes.py`, `font_sizes_report.csv`, `main.css.map` |
| A3 | `chatnoir2.html` hors standard | Faible | 190 lignes CSS inline + HTML custom, `project_id: "chatnoir"` vs `"chat-noir"` |
| A4 | `_utils.scss` vide | Negligeable | Fichier importe mais vide |
| A5 | `matrix.js` + `_matrix.scss` inutilises | Faible | Commentes dans le layout mais toujours dans le repo |

---

## 2. CONTENU & INTERNATIONALISATION (6/10)

### Systeme bilingue

- Detection automatique de la langue du navigateur (`lang-detector.html`)
- Cookie `lang_choice` (30 jours) pour memoriser le choix
- Switch manuel dans le footer avec gestion des slugs differents (FR: `branding-strategie.html` vs EN: `branding-strategy.html`)
- Cles `fr`/`en` dans chaque fichier YAML de donnees

### Problemes identifies

| # | Probleme | Severite | Detail |
|---|----------|----------|--------|
| C1 | Incoherence emails | **Critique** | `_config.yml` et contact page : `contact@ropat.art` / Footer : `contact@ropat.art` |
| C2 | Service "Graphic Design" invisible | **Critique** | `_data/services/graphic-design.yml` existe mais absent de `_data/services/index.yml` -> jamais affiche |
| C3 | Contenu hardcode FR dans services | **Importante** | Section "generic" avec bulles ("Flyers & Print", "Visuels Social Media") et CTA en francais uniquement |
| C4 | `fr/experiences.html` sans equivalent EN | Importante | Page experiences pro uniquement en francais |
| C5 | Projet Chat Noir incomplet | Moyenne | `context_content` vides (headers placeholder sans description) |
| C6 | `chatnoir2.html` en doublon | Faible | Page FR-only experimentale sans equivalent EN |

### Inventaire du contenu

**12 projets :**

| Projet | Categorie | Annee | Client | Featured |
|--------|-----------|-------|--------|----------|
| BTR | music | 2025 | Maltezz | oui |
| Logo Process | branding | 2025 | Personnel | oui |
| Cheetah | animation | 2025 | Personnel | oui |
| Zylkene | packaging | 2026 | Vetoquinol | non |
| Chat Noir | design | 2025 | Personnel | non |
| Ottony Paris | branding | 2026 | Ottony Paris | non |
| HDD Defrag | design | 2025 | Personnel | non |
| A-LONE | music | 2024 | B-Lone | non |
| EXIT | design | 2025 | Personnel | non |
| JPeJA | animation/music | 2025 | Personnel | non |
| Outlast Trials | design | 2025 | Personnel | non |
| Crow | animation | 2025 | Personnel | non |

**4 services :** Branding & Visual Strategy, Graphic Design (invisible), Music Design, Web Design & UX/UI

**5 partenaires carousel :** Ottony Paris, Vetoquinol, Juliette has a gun, PrintoClock, Moon VTC

**2 experiences pro :** Juliette has a gun (02/2026+), Vetoquinol (02/2026)

---

## 3. SEO & METADONNEES (7/10)

### Points forts
- Open Graph complet par page (titre, description, image, URL, locale)
- Twitter Cards (summary_large_image)
- Schema.org JSON-LD dynamique : ProfessionalService + WebSite + CreativeWork/WebPage selon contexte
- Hreflang FR/EN/x-default sur toutes les pages
- Sitemap XML avec priorites (1.0 homepage, 0.9 portfolio, 0.8 pages, 0.7 projets)
- `robots.txt` correct
- Google Analytics 4 + GTM configures

### Problemes identifies

| # | Probleme | Severite | Detail |
|---|----------|----------|--------|
| S1 | `schema.html` legacy present | Faible | Ancien schema.org avec commentaires JS dans JSON-LD (invalide). Remplace par `schema-org.html` |
| S2 | `canonical_url` hardcodes | Moyenne | Dans chaque front matter -> risque de desynchronisation si URLs changent |
| S3 | Dates pages legales obsoletes | Faible | "Last updated: November 1, 2025" dans les legal pages |
| S4 | `anonymize_ip` deprece | Faible | Option deprecee dans GA4 (anonymisation native) |
| S5 | Font "Inter" chargee inutilement | Moyenne | Google Fonts charge Inter qui n'est plus utilise (legacy de style.css) |

---

## 4. CSS & DESIGN SYSTEM (7/10)

### Architecture SCSS

```
assets/css/_sass/
  base/
    _variables.scss    # Custom properties (couleurs, typo fluide, espacements)
    _reset.scss        # Reset global + body styling
    _typography.scss   # Font-face Anicon, classes typo
    _generic.scss      # Utilitaires (separator, blur-bg, flex helpers)
    _bases.scss        # Skip-link, selection, focus-visible, reduced-motion
    _animations.scss   # Fade-up, fade-in, pulse
    _spacing.scss      # gap utilities
    _media-queries.scss # 340 lignes, tous breakpoints
  components/
    _buttons.scss, _carousel.scss, _containers.scss, _dropdown.scss,
    _gallery.scss, _loader.scss, _matrix.scss, _scroll-down.scss, _utils.scss
    cards/
      _cards.scss, _service-cards.scss, _project-cards.scss, _experience-cards.scss
  layout/
    _header.scss, _sections.scss, _grids.scss, _footer.scss
  pages/
    _legal.scss, _project.scss
```

### Points forts
- Variables CSS bien structurees avec typo fluide (`clamp()`)
- Support `corner-shape: squircle` avec fallbacks
- Support `prefers-reduced-motion`
- Carousel infini en CSS pur
- Sass compile et compresse (`compressed`)

### Problemes identifies

| # | Probleme | Severite | Detail |
|---|----------|----------|--------|
| D1 | `style.css` legacy | Moyenne | 1903 lignes legacy (font Inter, anciennes classes `.hero-test`, `.bulle`). Non utilise |
| D2 | Media queries monolithiques | Moyenne | Fichier unique de 340 lignes avec blocs vides (640-1023px, 1440px+) |
| D3 | Breakpoint 640px+ duplique | Faible | Service container padding repete en fin de `_media-queries.scss` |
| D4 | Valeurs magiques | Faible | `10rem` gap, `76px` hauteur header hardcodee dans calc, `6rem` scroll-down |
| D5 | Prefixes webkit manuels | Faible | Keyframes avec `-webkit-` au lieu d'autoprefixer |
| D6 | `_utils.scss` vide | Negligeable | Import inutile |

---

## 5. JAVASCRIPT (7/10)

### `script.js` (253 lignes) - Fonctionnalites :
1. Page Loader (delay 800ms + fadeout)
2. Burger Menu (toggle, aria-expanded, body lock, Escape)
3. Filtrage projets (dropdown + animations opacity/scale par categorie)
4. Dropdown custom (toggle open/close, selection active)
5. Galerie images (swap src, video support, keyboard)
6. Lightbox (open/close, Escape, backdrop click, focus management)
7. Scroll animations (IntersectionObserver + reduced-motion)

### `matrix.js` (46 lignes) - Effet Matrix rain (commente, non utilise)

### Problemes identifies

| # | Probleme | Severite | Detail |
|---|----------|----------|--------|
| J1 | `matrix.js` non utilise | Faible | Commente dans le layout, fichier + SCSS encore presents |
| J2 | `setInterval(draw, 33)` dans matrix.js | Faible | Devrait utiliser `requestAnimationFrame` si reactive |
| J3 | Filtrage avec `setTimeout` | Faible | Animations par timeout -> race conditions possibles sur connexions lentes |
| J4 | Lightbox sans preload | Faible | Image chargee dynamiquement via src swap -> potentiel flash |
| J5 | Debounce defini mais inutilise | Negligeable | Fonction disponible mais jamais appelee |

---

## 6. PERFORMANCE (6/10)

### Points forts
- Preload du background (`main-bg.webp`)
- JS charge en `defer`
- Sass compile en mode `compressed`
- Vanilla JS sans dependances externes
- Page loader masquant le chargement

### Problemes identifies

| # | Probleme | Severite | Detail |
|---|----------|----------|--------|
| P1 | 4 familles Google Fonts | **Importante** | Inter (inutile), Space Grotesk, Manrope, Underdog. 4 requetes HTTP + poids fonts |
| P2 | Images PNG/JPG non converties | Importante | btr-cover.png, chatnoir.jpg, stopmotions, exit, hdd-defrag, outlast, logo-process |
| P3 | Pas de `loading="lazy"` | Importante | Aucun lazy loading sur les images |
| P4 | Pas de `srcset`/`sizes` | Moyenne | Images non responsives (taille unique servie) |
| P5 | Videos autoplay sans lazy loading | Moyenne | Pages projets chargent les videos immediatement |
| P6 | SVG inline dans partners.yml | Faible | 5 logos en SVG complet dans le YAML -> fichier lourd |
| P7 | `main.css.map` dans le repo | Negligeable | Fichier de debug en production |

---

## 7. ACCESSIBILITE (7/10)

### Points forts
- Skip-to-content link bilingue (FR/EN)
- `aria-current="page"` sur la nav active
- `aria-expanded` sur le burger menu
- `focus-visible` global avec outline orange
- Keyboard support complet (menu, lightbox, gallery)
- `prefers-reduced-motion` respecte
- `::selection` stylise

### Problemes identifies

| # | Probleme | Severite | Detail |
|---|----------|----------|--------|
| AC1 | `.hintrc` desactive des regles | Moyenne | `duplicate-id`, `axe/structure`, `no-inline-styles`, `axe/language` desactives |
| AC2 | Dropdown custom non semantique | Moyenne | Construit avec `<div>` au lieu de `<select>` ou composant ARIA listbox |
| AC3 | Thumbnails sans role explicite | Faible | Container scrollable sans `role="list"` ou equivalent |
| AC4 | Attributs `alt` dependant du YAML | Faible | Si non rempli dans les donnees, images sans alt descriptif |

---

## 8. SECURITE (8/10)

### Points forts
- Site statique (pas de backend, pas d'injection)
- HTTPS via GitHub Pages
- Politique de confidentialite complete (RGPD)
- Pas de formulaire donc pas de faille input
- `rel="noopener noreferrer"` sur les liens externes

### Problemes identifies

| # | Probleme | Severite | Detail |
|---|----------|----------|--------|
| SE1 | Email personnel expose | Faible | `contact@ropat.art` visible dans le code source et _config.yml |
| SE2 | Pas de CSP | Faible | Content Security Policy non configuree (limites GitHub Pages) |
| SE3 | GTM vecteur potentiel | Faible | Si le compte GTM est compromis, des scripts tiers peuvent etre injectes |

---

## 9. DEPLOIEMENT / CI (7/10)

### Workflow `deploy.yml`
- Trigger : push sur `main`
- Build Jekyll (Ruby 3.2) + compile Dart Sass + deploy GitHub Pages
- Permissions minimales configures

### Problemes identifies

| # | Probleme | Severite | Detail |
|---|----------|----------|--------|
| CI1 | Pas de cache bundler | Moyenne | `cache: false` sur setup-ruby -> builds plus lents |
| CI2 | Dart Sass via snap | Faible | Installation fragile sur les runners GitHub |
| CI3 | Pas de validation | Moyenne | Pas de HTMLProofer, lint CSS/JS dans le pipeline |
| CI4 | Workflow sitemap desactive | Negligeable | Non nettoye du repo |

---

## 10. FICHIERS A NETTOYER

| Fichier | Raison | Action |
|---------|--------|--------|
| `assets/css/style.css` | CSS legacy non utilise (1903 lignes, font Inter) | Supprimer |
| `assets/css/main.css` + `main.css.map` | Fichiers compiles locaux | Ajouter au .gitignore + supprimer du repo |
| `_data/services_old.yml` | Ancien format remplace | Supprimer |
| `_includes/meta/schema.html` | Schema.org legacy remplace par `schema-org.html` | Supprimer |
| `backup.txt` | Snippets de backup obsoletes | Supprimer |
| `extract_font_sizes.py` | Script utilitaire one-shot | Supprimer |
| `font_sizes_report.csv` | Rapport genere | Supprimer |
| `assets/css/_sass/components/_utils.scss` | Fichier vide | Supprimer + retirer import |
| `assets/css/_sass/components/_matrix.scss` | Non utilise (commente) | Supprimer + retirer import |
| `assets/js/matrix.js` | Non utilise (commente) | Supprimer |
| `fr/projects/chatnoir2.html` | Page experimentale non standard | Supprimer ou normaliser |
| `.jekyll-cache/` | Fichiers de cache committes | Supprimer du repo (deja dans .gitignore) |

---

## SCORES PAR CATEGORIE

| Categorie | Score | Niveau |
|-----------|-------|--------|
| Architecture & Structure | 8/10 | Tres bon |
| Contenu & i18n | 6/10 | Correct - a ameliorer |
| SEO & Metadonnees | 7/10 | Bon |
| CSS & Design System | 7/10 | Bon |
| JavaScript | 7/10 | Bon |
| Performance | 6/10 | Correct - a ameliorer |
| Accessibilite | 7/10 | Bon |
| Securite | 8/10 | Tres bon |
| Deploiement / CI | 7/10 | Bon |
| **SCORE GLOBAL** | **7/10** | **Bon** |

---

**Audit realise le 12 mars 2026**
**Prochaine revision recommandee : Juin 2026**
