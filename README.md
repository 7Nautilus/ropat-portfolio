# Portfolio Ropat

Bienvenue sur mon portfolio en ligne. Ce site présente mes projets, compétences et expériences professionnelles via un générateur statique Jekyll déployé sur GitHub Pages.

## Aperçu

- 🌍 Multilingue FR/EN avec SEO adapté
- 🎨 Portfolio filtrable et responsive
- ♿ Accessibilité renforcée (ARIA, alt explicites)
- ⚡ Performance optimisée (images dimensionnées, médias adaptés)
- 🤖 Déploiement automatisé via GitHub Actions (build + sitemap)

## Stack technique

- **Jekyll** (Ruby + Bundler) pour la génération statique
- **Dart Sass** (SCSS, modules `@use`, architecture ITCSS) pour les styles
- **JavaScript vanilla** (aucun framework)
- **GitHub Pages** pour l'hébergement
- **GitHub Actions** pour l'automatisation CI/CD (build + sitemap)

## Architecture des contenus

### Données

```
_data/
├── navigation.yml             # Navigation principale
├── projects/                  # 1 fichier YAML par projet + ordre d'affichage
│   ├── index.yml              # Liste ordonnée des slugs
│   ├── aelio.yml              # Contenu & SEO du projet "Aélio"
│   ├── btr.yml
│   └── ...
├── pages/                     # Contenu des pages (about, contact, services, experiences...)
├── services/                  # Offres de services (4 services + index.yml)
├── design-system.yml          # Référence design system (couleurs, typo)
├── partners.yml               # Partenaires / clients
└── socials.yml                # Liens réseaux sociaux
```

Chaque projet possède son propre fichier YAML. Les champs globaux (année, outils, client, média) sont partagés et les traductions sont rangées sous `locales`. Le principe DRY est ainsi respecté : une seule source de vérité pour les contenus et les métadonnées.

### Layouts et includes

- `_layouts/default.html` : détecte `project_id`, charge les données YAML, gère les balises hreflang
- `_includes/projects/project-main.html`, `_includes/projects/project-card.html`, `_includes/services/service-card.html` : blocs réutilisables pour projets/services
- `_includes/meta/open-graph.html`, `_includes/meta/schema-org.html` : balises SEO centralisées
- `_includes/layout/header.html`, `_includes/layout/footer.html`, `_includes/layout/nav.html`, `_includes/portfolio-filters.html` : structure globale

## Système multilingue

```
ropat-portfolio/
├── fr/
│   ├── index.html, about.html, contact.html, portfolio.html, services.html
│   └── projects/
│       ├── a-lone.html
│       ├── btr.html
│       ├── cheetah.html
│       └── ...
└── en/
    ├── index.html, about.html, contact.html, portfolio.html, services.html
    └── projects/
        ├── a-lone.html
        ├── btr.html
        ├── cheetah.html
        └── ...
```

- URLs distinctes : `/fr/...` et `/en/...`
- Textes et métadonnées centralisés dans `_data/projects/<slug>.yml`
- Hreflang géré automatiquement par `_layouts/default.html`
- Cartes projets (`project-card.html`) qui adaptent les URLs selon la langue active

## Ajouter un nouveau projet

1. **Lancer l'assistant** :
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\new-project.ps1
   # ou : pwsh -File ./scripts/new-project.ps1
   ```
   Le script crée automatiquement :
   - `_data/projects/<slug>.yml`
   - l'entrée correspondante dans `_data/projects/index.yml`
   - `fr/projects/<slug>.html` et `en/projects/<slug>.html`

2. **Compléter le YAML généré** : renseigner les textes FR/EN manquants, les champs SEO et les médias supplémentaires.

### Modèle YAML de référence

```yaml
slug: exemple
project_title: EXEMPLE
category: music
featured: false
client: "Nom du client (optionnel)"
year: "2025"
tools: "Photoshop, Illustrator"
image_src: /assets/images/projects/exemple.avif
main_image: /assets/images/projects/exemple.avif
media_type: image
locales:
  fr:
    url: /fr/projects/exemple.html
    aria_label: "Voir le projet Exemple"
    image_alt: "Visuel du projet Exemple"
    title: "Titre FR"
    subtitle: "Sous-titre avec **mise en avant**"
    description: "Résumé court du projet en français."
    services: "Compétences mises en œuvre"
    context_title: "Contexte du projet"
    context_content: |
      Paragraphe(s) détaillant le déroulé du projet.
    seo:
      title: "Titre SEO FR | Ropat"
      description: "Meta description FR"
      canonical_url: "https://ropat.art/fr/projects/exemple.html"
      og_title: "Titre Open Graph FR"
      og_description: "Description Open Graph FR"
      og_url: "https://ropat.art/fr/projects/exemple.html"
      og_image: "https://ropat.art/assets/images/projects/exemple.avif"
  en:
    url: /en/projects/exemple.html
    aria_label: "View the Exemple project"
    image_alt: "Exemple project visual"
    title: "English title"
    subtitle: "English subtitle with **emphasis**"
    description: "Short English summary."
    services: "Services provided"
    context_title: "Project Context"
    context_content: |
      Paragraph(s) describing the project in English.
    seo:
      title: "SEO Title EN | Ropat"
      description: "Meta description EN"
      canonical_url: "https://ropat.art/en/projects/exemple.html"
      og_title: "Open Graph Title EN"
      og_description: "Open Graph Description EN"
      og_url: "https://ropat.art/en/projects/exemple.html"
      og_image: "https://ropat.art/assets/images/projects/exemple.avif"
```

> Modèle minimal. Les projets aboutis enrichissent ce schéma avec une liste `context_sections` (sections titre + contenu bilingue) et un bloc `case_study` (`mockups`, `colors`, `typography`, `specs`). Voir `_data/projects/aelio.yml` comme exemple complet.

### Pages générées (FR/EN)

```yaml
---
layout: default
lang: "fr" # ou "en"
project_id: "exemple"
---

{% include projects/project-main.html project_id=page.project_id %}
```

`project_id` doit correspondre au slug. Cette clé pilote le chargement des données et des métadonnées SEO.

## Flux SEO

- **Pages projets**
  1. Le front matter définit `project_id`
  2. `_layouts/default.html` charge `_data/projects/<slug>.yml`
  3. Les variables sont exposées à la page et aux includes
  4. `_includes/meta/open-graph.html` et `_includes/meta/schema-org.html` injectent les balises
- **Pages classiques** : métadonnées définies directement dans le front matter puis relayées par le layout

## Projets disponibles

Liste ordonnée dans `_data/projects/index.yml` (16 projets) :

1. **Juliette has a Gun** : social ads
2. **BTR** : pochette musicale
3. **Aélio** : identité visuelle / branding
4. **Logo Design Process** : branding
5. **Cheetah** : animation stop-motion (vidéo)
6. **Stelya** : identité visuelle / branding
7. **Zylkene** : packaging
8. **Chat Noir** : design graphique
9. **Ottony Paris** : branding
10. **HDD DEFRAG** : design graphique (affiche)
11. **A-LONE** : pochette musicale
12. **EXIT** : design graphique (affiche)
13. **Moon VTC** : branding
14. **JPeJA** : animation / visualizer (vidéo)
15. **Outlast Trials** : design graphique
16. **Crow** : animation stop-motion (vidéo)

## Points forts

- Une seule source de vérité pour FR/EN
- Données, SEO et médias centralisés dans YAML
- Templates réutilisables pour limiter la duplication
- Système prêt pour de nouvelles catégories ou types de médias
