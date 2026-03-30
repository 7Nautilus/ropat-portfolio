# CLAUDE.md — ropat-portfolio

Portfolio professionnel de Ropat (Victor), designer graphique & motion designer.
Site bilingue FR/EN, déployé sur GitHub Pages à [ropat.art](https://ropat.art).

---

## Stack technique

- **Jekyll** (Ruby 3.2 + Bundler) — générateur de site statique
- **Dart Sass** — compilation SCSS avec modules `@use`
- **JavaScript vanilla** — aucun framework
- **GitHub Actions** — CI/CD automatique sur push vers `main`
- **GitHub Pages** — hébergement, domaine custom `ropat.art`

---

## Lancer le développement en local

Utiliser les tâches VSCode (`.vscode/tasks.json`) :

| Tâche | Action |
|---|---|
| `Dev: Sass Watch + Jekyll` | Lance les deux en parallèle (recommandé) |
| `Sass: Watch` | Compile SCSS à chaque modification |
| `Jekyll: Serve` | Serveur local avec livereload |

Ou via terminal :
```bash
bundle exec jekyll serve --livereload
sass --watch _sass/main.scss:assets/css/main.css
```

---

## Déploiement

Push sur `main` → GitHub Actions déclenche automatiquement :
1. Build Jekyll (`bundle exec jekyll build`)
2. Compilation Dart Sass → `_site/assets/css/main.css`
3. Déploiement sur GitHub Pages

**Pas de staging** — `main` = production directement.

---

## Structure du projet

```
_data/
├── projects/index.yml      # Ordre d'affichage des projets
├── projects/*.yml          # Données de chaque projet (source unique FR+EN)
├── pages/                  # Contenu des pages par langue
├── services/               # Offres de services
└── navigation.yml          # Structure du menu

_includes/                  # Partials réutilisables (DRY)
_layouts/default.html       # Layout maître (multilingue, SEO)
_sass/                      # SCSS organisé ITCSS (base → layout → components → pages)

fr/ & en/                   # Pages générées par langue
assets/
├── css/main.css            # CSS compilé (ne pas éditer manuellement)
├── js/script.js            # JS principal (17KB, vanilla)
├── images/                 # WebP recommandé
└── fonts/

.github/workflows/deploy.yml  # CI/CD principal
scripts/new-project.ps1       # Wizard PowerShell pour créer un projet
```

---

## Ajouter un projet

Utiliser le script PowerShell (recommandé) :
```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/new-project.ps1
```

Le script génère automatiquement :
- `_data/projects/<slug>.yml` (données bilingues)
- `fr/projects/<slug>.html`
- `en/projects/<slug>.html`
- Met à jour `_data/projects/index.yml`

Structure d'un fichier projet YAML :
```yaml
slug: mon-projet
project_title: MON PROJET
category: music  # ou: branding, motion, print, web...
year: "2025"
client: { fr: "...", en: "..." }
tools: "Photoshop, Illustrator"
image_src: /assets/images/projects/...
media_type: image  # ou: video
locales:
  fr:
    url: /fr/projects/mon-projet.html
    title: "..."
    subtitle: "..."
    description: "..."
    seo:
      title: "..."
      description: "..."
      og_image: "..."
  en:
    # même structure
```

---

## Conventions de code

**SCSS :**
- Modules `@use` uniquement (jamais `@import`)
- Variables CSS custom pour couleurs et typo (`--primary-color: #ff5c00`)
- Typographie fluide avec `clamp()`
- Ordre ITCSS : base → layout → components → pages → media queries

**HTML/Jekyll :**
- Tout contenu multilingue via `page.lang` + data YAML
- Templates DRY via `_includes/`
- ARIA labels sur tous les éléments interactifs
- Schema.org + Open Graph centralisés dans `_includes/meta/`

**Nommage :**
- Composants : `project-card`, `service-card`, `experience-card`
- Sections : `hero`, `portfolio`, `services`, `contact`
- BEM simplifié (pas de sur-imbrication)

**JavaScript :**
- Vanilla uniquement
- Event delegation + debounce
- Support `prefers-reduced-motion`
- Persistance langue via cookie (SameSite=Lax)

---

## SEO & accessibilité

- Hreflang auto-généré pour FR/EN
- Canonical URLs par langue
- sitemap.xml auto (Jekyll)
- Skip-to-content link présent
- Cible WCAG 2.1 AA (problème connu : contraste gris trop faible — voir TODO.md)

---

## Fichiers clés à connaître

| Fichier | Rôle |
|---|---|
| `_config.yml` | Config Jekyll + métadonnées business |
| `_data/projects/index.yml` | Ordre d'affichage des projets |
| `_sass/base/_variables.scss` | Variables CSS/SCSS globales |
| `assets/js/script.js` | Toute la logique JS (cursor, filters, loader) |
| `TODO.md` | Backlog actif priorisé |
| `docs/PLAN-ACTIONS.md` | Plan d'action détaillé |
| `.github/workflows/deploy.yml` | Pipeline CI/CD |

---

## À ne pas faire

- Ne jamais éditer `assets/css/main.css` directement (fichier compilé)
- Ne jamais utiliser `@import` dans les SCSS (utiliser `@use`)
- Ne pas pousser sur `main` sans vérifier le build Jekyll en local
- Ne pas dupliquer le contenu entre les YAMLs FR et EN (tout est dans le même fichier projet)
