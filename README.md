# Portfolio Ropat

Bienvenue sur mon portfolio en ligne ! Ce site présente mes projets, compétences et expériences professionnelles.

## 🚀 Technologies utilisées

- **HTML5 / CSS3 / JavaScript**
- **Jekyll** pour la génération statique du site
- **GitHub Pages** pour l'hébergement
- **GitHub Actions** pour l'automatisation du déploiement et de la génération du sitemap

## ✨ Fonctionnalités

- 🌍 **Multilingue** : Support complet FR/EN
- 🎨 **Portfolio dynamique** : Filtres par catégorie
- 📱 **Design responsive** : Optimisé pour tous les appareils
- 🔍 **SEO optimisé** : Métadonnées, sitemap, balises hreflang
- ♿ **Accessibilité** : Labels ARIA, attributs alt
- ⚡ **Performance** : Images optimisées avec width/height

## 📁 Architecture DRY (Don't Repeat Yourself)

Ce projet suit le principe **DRY** avec une architecture centralisée :

### Pages légales

Le site inclut des pages de mentions légales et de confidentialité conformes au RGPD :
- 🇫🇷 `/fr/mentions-legales.html` + `/fr/confidentialite.html`
- 🇬🇧 `/en/legal-notice.html` + `/en/privacy.html`

### Structure des données

```
_data/
├── navigation.yml             # Navigation du site
├── projects/                  # 1 fichier par projet + ordre d'affichage
│   ├── index.yml              # Liste ordonnée des slugs
│   ├── a-lone.yml             # Contenu & SEO du projet "A-LONE"
│   ├── btr.yml
│   └── ...
└── services.yml               # Tous les services
```

Chaque projet possède désormais son propre fichier YAML. Les champs globaux (année, outils, client, média) sont partagés, tandis que les textes traduits sont regroupés sous `locales`. Ce découpage facilite les ajouts, les revues et les contributions multiples.

### Layouts et Includes

**Layouts :**
- `_layouts/default.html` : Template de base
  - Détecte automatiquement les pages de projet via `project_id`
  - Charge les métadonnées SEO depuis `_data/projects/<slug>.yml`
  - Gère les liens hreflang FR/EN

**Includes réutilisables :**
- `header.html`, `footer.html`, `nav.html` : Structure
- `open-graph.html` : Balises Open Graph/Twitter
- `project-main.html` : Template principal pour les projets
- `project-card.html` : Carte de projet (grille portfolio)
- `service-card.html` : Carte de service
- `portfolio-filters.html` : Filtres du portfolio

## 🌍 Système Multilingue

### Structure des fichiers

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

### Fonctionnement

1. **URLs distinctes** : `/fr/projects/...` et `/en/projects/...`
2. **Traductions centralisées** : Tous les textes dans `_data/projects/<slug>.yml`
3. **SEO optimisé** : Balises hreflang automatiques
4. **Navigation intelligente** : `project-card.html` adapte les URLs selon la langue

## 🎨 Ajouter un nouveau projet

1. Lancer l'assistant :
    ```powershell
    powershell -ExecutionPolicy Bypass -File .\scripts\new-project.ps1
    # ou : pwsh -File ./scripts/new-project.ps1
    ```
    Le script demande le slug, la catégorie, les textes principaux FR/EN et crée automatiquement :
    - le fichier `_data/projects/<slug>.yml`
    - l'entrée correspondante dans `_data/projects/index.yml`
    - les pages `fr/projects/<slug>.html` et `en/projects/<slug>.html`

2. Ouvrir le fichier YAML généré et compléter les champs encore « TODO » si nécessaire (SEO, contexte détaillé, miniatures additionnelles, etc.).

### Structure du fichier projet

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

### Pages FR/EN générées

Les deux fichiers contiennent uniquement le front matter suivant (déjà rempli par le script) :

```yaml
---
layout: default
lang: "fr" # ou "en"
project_id: "exemple"
---

{% include project-main.html project_id=page.project_id %}
```

`project_id` doit correspondre au slug : c'est la clé utilisée pour récupérer les données dans `_data/projects/<slug>.yml`.

## 🔄 Flux des métadonnées SEO

### Pages de projets :
1. Page définit `project_id` dans le front matter
2. `default.html` détecte `project_id` et charge les données depuis `_data/projects/<slug>.yml`
3. Les métadonnées sont injectées dans `page.*`
4. `open-graph.html` utilise ces variables

### Pages normales :
1. Métadonnées définies dans le front matter
2. `default.html` et `open-graph.html` utilisent `page.*`

✨ Un seul système cohérent pour toutes les pages !

## 📊 Projets migrés

✅ **A-LONE** - Pochette d'album B-Lone  
✅ **BTR** - Pochette EP Maltezz  
✅ **Cheetah Animation** - Stop-motion (vidéo)  
✅ **EXIT** - Affiche design  
✅ **HDD DEFRAG** - Affiche design  
✅ **Logo Design Process** - Processus création logo (galerie)

## 🎯 Avantages du système

✅ **Une seule source de vérité** : Données centralisées  
✅ **Pas de duplication** : Modification unique pour FR et EN  
✅ **SEO centralisé** : Métadonnées gérées depuis YAML  
✅ **Maintenance facile** : 1 projet = 1 modification YAML  
✅ **Cohérence** : Template unique pour tous les projets  
✅ **Évolutif** : Facile d'ajouter de nouveaux champs

## 📈 Score DRY : 9.5/10 🎉