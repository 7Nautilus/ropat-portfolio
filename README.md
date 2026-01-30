# Portfolio Ropat

Bienvenue sur mon portfolio en ligne. Ce site présente mes projets, compétences et expériences professionnelles via un générateur statique Jekyll déployé sur GitHub Pages.

## Aperçu

- 🌍 Multilingue FR/EN avec SEO adapté
- 🎨 Portfolio filtrable et responsive
- ♿ Accessibilité renforcée (ARIA, alt explicites)
- ⚡ Performance optimisée (images dimensionnées, médias adaptés)
- 🤖 Déploiement automatisé via GitHub Actions (build + sitemap)

## Stack technique

- **HTML5 / CSS3 / JavaScript**
- **Jekyll** pour la génération statique
- **GitHub Pages** pour l'hébergement
- **GitHub Actions** pour l'automatisation CI/CD

## Architecture des contenus

### Données

```
_data/
├── navigation.yml             # Navigation principale
├── projects/                  # 1 fichier YAML par projet + ordre d'affichage
│   ├── index.yml              # Liste ordonnée des slugs
│   ├── a-lone.yml             # Contenu & SEO du projet "A-LONE"
│   ├── btr.yml
│   └── ...
└── services.yml               # Liste des services proposés
```

Chaque projet possède son propre fichier YAML. Les champs globaux (année, outils, client, média) sont partagés et les traductions sont rangées sous `locales`. Le principe DRY est ainsi respecté : une seule source de vérité pour les contenus et les métadonnées.

### Layouts et includes

- `_layouts/default.html` : détecte `project_id`, charge les données YAML, gère les balises hreflang
- `_includes/project-main.html`, `_includes/project-card.html`, `_includes/service-card.html` : blocs réutilisables pour projets/services
- `_includes/open-graph.html`, `_includes/schema-org.html` : balises SEO centralisées
- `header.html`, `footer.html`, `nav.html`, `portfolio-filters.html` : structure globale

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
image_src: /assets/images/projects/exemple.png
main_image: /assets/images/projects/exemple.png
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
      og_image: "https://ropat.art/assets/images/projects/exemple.png"
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
      og_image: "https://ropat.art/assets/images/projects/exemple.png"
```

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
  4. `_includes/open-graph.html` et `_includes/schema-org.html` injectent les balises
- **Pages classiques** : métadonnées définies directement dans le front matter puis relayées par le layout

## Projets disponibles

- ✅ A-LONE — Pochette d'album B-Lone
- ✅ BTR — Pochette EP Maltezz
- ✅ Cheetah Animation — Stop-motion (vidéo)
- ✅ Crow Animation — Stop-motion (vidéo)
- ✅ EXIT — Affiche design
- ✅ HDD DEFRAG — Affiche design
- ✅ JPeJA Animation — Visualizer
- ✅ Logo Design Process — Processus de création de logo

## Points forts

- Une seule source de vérité pour FR/EN
- Données, SEO et médias centralisés dans YAML
- Templates réutilisables pour limiter la duplication
- Système prêt pour de nouvelles catégories ou types de médias