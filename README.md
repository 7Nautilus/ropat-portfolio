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
├── projects.yml      # Tous les projets (contenu + SEO)
├── services.yml      # Tous les services
└── navigation.yml    # Navigation du site
```

### Layouts et Includes

**Layouts :**
- `_layouts/default.html` : Template de base
  - Détecte automatiquement les pages de projet via `project_id`
  - Charge les métadonnées SEO depuis `projects.yml`
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
2. **Traductions centralisées** : Tous les textes dans `_data/projects.yml`
3. **SEO optimisé** : Balises hreflang automatiques
4. **Navigation intelligente** : `project-card.html` adapte les URLs selon la langue

## 🎨 Ajouter un nouveau projet

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
  client: "Nom Client"
  description: 
    fr: "Description courte FR"
    en: "Short description EN"
  featured: true
  project_title: "TITRE_UNIQUE"  # ID du projet
  subtitle:
    fr: "Sous-titre <strong>FR</strong>"
    en: "Subtitle <strong>EN</strong>"
  year: "2024"
  tools: "Photoshop, Illustrator"
  context_title:
    fr: "Contexte du projet"
    en: "Project Context"
  context_content:
    fr: "<p>Contenu FR</p>"
    en: "<p>Content EN</p>"
  main_image: /assets/images/projects/main.png
  media_type: video  # optionnel (si vidéo au lieu d'image)
  thumbnails:  # optionnel (pour galerie)
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

### 2. Créer les pages (FR et EN)

**`fr/projects/nom-projet.html`** :
```html
---
layout: default
lang: "fr"
project_id: "TITRE_UNIQUE"
---

{% include project-main.html project_id=page.project_id %}
```

**`en/projects/nom-projet.html`** :
```html
---
layout: default
lang: "en"
project_id: "TITRE_UNIQUE"
---

{% include project-main.html project_id=page.project_id %}
```

⚠️ **Important** : Le `project_id` doit correspondre exactement au `project_title` dans `projects.yml`

## 🔄 Flux des métadonnées SEO

### Pages de projets :
1. Page définit `project_id` dans le front matter
2. `default.html` détecte `project_id` et charge les données depuis `projects.yml`
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