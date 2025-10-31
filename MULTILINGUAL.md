# 🌍 Structure Multilingue du Portfolio

## 📁 Architecture des Fichiers

```
ropat-portfolio/
├── fr/
│   ├── about.html
│   ├── contact.html
│   ├── index.html
│   ├── portfolio.html
│   ├── services.html
│   └── projects/
│       ├── a-lone.html
│       ├── btr.html
│       ├── cheetah.html
│       ├── exit.html
│       ├── hdd-defrag.html
│       └── logo-process.html
├── en/
│   ├── about.html
│   ├── contact.html
│   ├── index.html
│   ├── portfolio.html
│   ├── services.html
│   └── projects/
│       ├── a-lone.html
│       ├── btr.html
│       ├── cheetah.html
│       ├── exit.html
│       ├── hdd-defrag.html
│       └── logo-process.html
└── projects/ (anciens fichiers - à supprimer après migration)
```

## 🎯 Fonctionnement

### 1. Layout Default
Toutes les pages utilisent `layout: default` avec le front matter :
```yaml
---
layout: default
lang: "fr"  # ou "en"
title: "..."
meta_description: "..."
canonical_url: "https://ropat.art/fr/projects/..."
og_url: "https://ropat.art/fr/projects/..."
---
```

### 2. Gestion des URLs
Le fichier `_includes/project-card.html` gère automatiquement les URLs selon la langue :
- Page FR → pointe vers `/fr/projects/...`
- Page EN → pointe vers `/en/projects/...`

### 3. Traductions dans _data/projects.yml
Chaque projet contient des traductions pour tous les textes :
```yaml
- category: music
  url: /fr/projects/btr.html
  title: 
    fr: 'Pochette d''album "BTR"'
    en: 'Album Cover "BTR"'
  description: 
    fr: "Direction artistique complète..."
    en: "Complete art direction..."
```

## ✅ Avantages

1. **SEO optimisé** : URLs distinctes par langue
2. **Balises hreflang** : Gérées automatiquement par `default.html`
3. **Maintenance facile** : Un seul fichier de données pour les traductions
4. **Performance** : Attributs width/height sur toutes les images
5. **Accessibilité** : aria-label multilingue

## 🔄 Prochaines Étapes

- [ ] Supprimer l'ancien dossier `/projects/` après vérification
- [ ] Vérifier que le sitemap GitHub Action inclut les nouvelles pages
- [ ] Tester la navigation entre FR et EN
