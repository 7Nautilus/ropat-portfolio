# Architecture du projet - Principe DRY

## 📋 Vue d'ensemble

Ce projet suit le principe **DRY (Don't Repeat Yourself)** en utilisant Jekyll et un système centralisé de données.

## 🗂️ Structure des données

### Fichiers de données centralisés

- **`_data/projects.yml`** : Contient toutes les données des projets (contenu, métadonnées SEO, images)
- **`_data/services.yml`** : Contient tous les services
- **`_data/navigation.yml`** : Contient la navigation du site

## 🔧 Système de templates

### Layouts

- **`_layouts/default.html`** : Template de base pour toutes les pages
  - Gère automatiquement les métadonnées SEO (title, description, keywords)
  - Inclut `open-graph.html` pour Open Graph
  - Gère les liens alternatifs hreflang (FR/EN)

### Includes réutilisables

#### Navigation & Structure
- **`header.html`** : En-tête du site
- **`footer.html`** : Pied de page
- **`nav.html`** : Navigation principale
- **`burger-menu.html`** : Menu mobile

#### SEO
- **`project-seo.html`** : Injecte les métadonnées SEO des projets dans les variables `page.*` (récupère depuis `projects.yml`)
- **`open-graph.html`** : Balises Open Graph et Twitter (utilisé par le layout default)
- **`schema-org.html`** : Données structurées Schema.org

#### Projets
- **`project-main.html`** : Template principal pour afficher un projet
  - Support images ET vidéos
  - Galerie avec miniatures
  - Informations du projet (client, année, outils, etc.)
  - Contexte du projet
- **`project-card.html`** : Carte de projet pour la grille du portfolio

#### Services
- **`service-card.html`** : Carte de service

#### Autres
- **`portfolio-filters.html`** : Filtres du portfolio
- **`lang-detector.html`** : Détecteur de langue
- **`lang-selector.html`** : Sélecteur de langue

## 📄 Pages de projets

### Structure simplifiée

Toutes les pages de projets utilisent maintenant le même format minimal :

```html
---
layout: default
lang: "fr"  # ou "en"
---

{% include project-seo.html project_id="NOM_DU_PROJET" %}
{% include project-main.html project_id="NOM_DU_PROJET" %}
```

### Projets migrés

✅ **A-LONE** - Pochette d'album B-Lone
✅ **BTR** - Pochette EP Maltezz  
✅ **Cheetah Animation** - Animation stop-motion (avec vidéo)
✅ **EXIT** - Affiche design
✅ **HDD DEFRAG** - Affiche design
✅ **Logo Design Process** - Processus de création de logo (avec galerie)

## 🎨 Ajout d'un nouveau projet

### 1. Ajouter les données dans `_data/projects.yml`

```yaml
- category: music  # music, branding, animation, design
  url: /fr/projects/nom-projet.html
  aria_label: 
    fr: "Description FR"
    en: "Description EN"
  image_src: /assets/images/projects/image.png
  image_alt: 
    fr: "Alt FR"
    en: "Alt EN"
  title: 
    fr: "Titre FR"
    en: "Title EN"
  client: "Nom Client"  # optionnel
  description: 
    fr: "Description courte FR"
    en: "Short description EN"
  featured: true  # ou false
  project_title: "TITRE_UNIQUE"  # Utilisé comme ID
  subtitle:
    fr: "Sous-titre <strong>FR</strong>"
    en: "Subtitle <strong>EN</strong>"
  services:  # optionnel
    fr: "Services FR"
    en: "Services EN"
  year: "2024"  # optionnel
  tools: "Photoshop, Illustrator"  # optionnel
  context_title:
    fr: "Contexte du projet"
    en: "Project Context"
  context_content:
    fr: "<p>Contenu FR</p>"
    en: "<p>Content EN</p>"
  main_image: /assets/images/projects/main.png
  media_type: video  # optionnel, uniquement si c'est une vidéo
  thumbnails:  # optionnel
    - src: /assets/images/projects/thumb1.png
      alt:
        fr: "Alt 1 FR"
        en: "Alt 1 EN"
  seo:
    title:
      fr: "Titre SEO FR | Ropat"
      en: "SEO Title EN | Ropat"
    meta_description:
      fr: "Meta description FR"
      en: "Meta description EN"
    meta_keywords:
      fr: "mots, clés, fr"
      en: "keywords, en"
    canonical_url:
      fr: "https://ropat.art/fr/projects/nom-projet.html"
      en: "https://ropat.art/en/projects/nom-projet.html"
    og_title:
      fr: "OG Title FR"
      en: "OG Title EN"
    og_description:
      fr: "OG Description FR"
      en: "OG Description EN"
    og_url:
      fr: "https://ropat.art/fr/projects/nom-projet.html"
      en: "https://ropat.art/en/projects/nom-projet.html"
    og_image: "https://ropat.art/assets/images/projects/og-image.png"
```

### 2. Créer les fichiers de pages (FR et EN)

**`fr/projects/nom-projet.html`** :
```html
---
layout: default
lang: "fr"
---

{% include project-seo.html project_id="TITRE_UNIQUE" %}
{% include project-main.html project_id="TITRE_UNIQUE" %}
```

**`en/projects/nom-projet.html`** :
```html
---
layout: default
lang: "en"
---

{% include project-seo.html project_id="TITRE_UNIQUE" %}
{% include project-main.html project_id="TITRE_UNIQUE" %}
```

⚠️ **Important** : Le `project_id` doit correspondre exactement au `project_title` dans `projects.yml`

## 🌐 Multilinguisme

Le système supporte automatiquement FR et EN :
- Les données sont stockées avec les clés `fr:` et `en:`
- La langue est détectée via `page.lang`
- Les URLs sont automatiquement adaptées

## 🎯 Avantages du système

✅ **Une seule source de vérité** : Toutes les données au même endroit  
✅ **Pas de duplication** : Changement unique pour FR et EN  
✅ **SEO centralisé** : Métadonnées gérées depuis le YAML  
✅ **Réutilisation** : `open-graph.html` utilisé pour toutes les pages  
✅ **Maintenance facile** : Modifier un projet = modifier 1 fichier YAML  
✅ **Cohérence** : Tous les projets utilisent le même template  
✅ **Évolutif** : Facile d'ajouter de nouveaux champs

## 🔄 Flux des métadonnées SEO

### Pour les pages de projets :
1. **`project-seo.html`** récupère les données depuis `projects.yml`
2. Injecte les données dans les variables `page.*` (title, meta_description, og_title, etc.)
3. **`default.html`** utilise ces variables `page.*` pour les balises meta
4. **`open-graph.html`** est appelé par `default.html` et utilise aussi `page.*`

### Pour les pages normales (about, contact, etc.) :
1. Métadonnées définies directement dans le front matter
2. **`default.html`** utilise directement `page.*`
3. **`open-graph.html`** utilise aussi `page.*`

✨ **Résultat** : Un seul système cohérent pour toutes les pages !

## 📊 Score DRY : 9.5/10

Le projet respecte maintenant excellemment le principe DRY ! 🎉
