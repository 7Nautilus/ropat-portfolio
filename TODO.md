# TODO & Recommandations

---

## ✅ Corrections appliquées

- ✅ `onclick` inline supprimé du sélecteur de langue → délégation d'événements dans `script.js`
- ✅ Cookie de langue avec `SameSite=Lax` (sécurité CSRF)
- ✅ `aria-label` lightbox fusionné avec `alt` (description + action pour les lecteurs d'écran)
- ✅ `_data/pages/services.yml` complété en anglais (`pitch`, `generic`)
- ✅ `_data/services_old.yml` supprimé (fichier orphelin)
- ✅ Référence `matrix.js` commentée supprimée de `default.html`
- ✅ `en/projects/chatnoir2.html` créé (projet manquant côté EN)
- ✅ `rel="noopener noreferrer"` + `target="_blank"` ajoutés sur les liens sociaux (`_includes/social-media-icons.html`)
- ✅ Page About enrichie (stats, skills, parcours, CTA — `_data/pages/about.yml`)
- ✅ `en/services/web-design.html` : contenu complet FR+EN dans le YAML de service
- ✅ `prefers-reduced-motion` géré en CSS (`_bases.scss`, `_cursor.scss`) et JS

---

## 🔴 Critique — À corriger immédiatement

### Performance

- [ ] **Convertir les images PNG lourdes en WebP + AVIF**
  - `logo-design-process-3d-fx.png` (~4.5 MB) → WebP + AVIF
  - `exit.png` (~2.3 MB) → WebP + AVIF
  - `btr-cover.png` (~1.5 MB) → WebP + AVIF
  - Utiliser `<picture>` avec sources AVIF → WebP → PNG en fallback
  - Ajouter `width` + `height` explicites sur chaque `<img>` pour éviter le CLS
  - Impact : -60% de poids, gain majeur sur LCP

### Bilingue / SEO

- [ ] **Créer la page `/en/experiences.html`**
  - Page FR existe mais équivalent EN manquant → hreflang cassé pour cette page
  - Dupliquer `/fr/experiences.html` et traduire le contenu
  - Fichier data : `_data/pages/experiences.yml`

### Accessibilité

- ✅ **Contraste `--grey-light-400: #9CA3AF`** — faux positif : utilisé exclusivement sur fond sombre (`#0a0a0a`), ratio ~8:1, conforme WCAG AA

---

## 🟠 Haute priorité

### Contact & conversion

- ✅ **Formulaire de contact Web3Forms** — déjà implémenté avec honeypot `botcheck`, dropdown sujet et validation JS. Le `mailto:` visible est le fallback secondaire intentionnel.

### SEO technique

- ✅ **Sitemap.xml** — la logique Liquid couvre bien les pages légales et de services (vérification faite)

- ✅ **Corriger le hreflang des pages de services** — `hreflang_alternate` ajouté dans le front matter des 6 pages concernées, `default.html` mis à jour pour l'utiliser en priorité

- ✅ **`fr/projects/chatnoir2.html`** — page de test locale, non committée

- ✅ **Améliorer les titres de la page About** — `"À propos - Ropat, Graphiste & Directeur Artistique"` / `"About - Ropat, Graphic Designer & Art Director"`

- [ ] **Ajouter une OG image dédiée pour les pages principales**
  - L'image OG par défaut est `icon.png` (petit logo) pour home, portfolio, about, contact
  - Recommandé : créer un visuel 1200×630 pour le partage social
  - Fichier : `_includes/meta/open-graph.html` (fallback) + front matter des pages concernées

---

## 🟡 Priorité moyenne

### Performance

- [ ] **Ajouter `preload` explicite pour les fonts critiques**
  - `preconnect` Google Fonts en place mais pas de `<link rel="preload" as="font" crossorigin>` pour les fonts custom (ANICON SANS BLACK, CoFoRaffine)
  - Impact : -~300ms sur le FCP
  - Fichier : `_layouts/default.html`

- [ ] **Convertir les fonts custom en WOFF2**
  - `ANICON SANS BLACK.OTF`, `CoFoRaffine-VF-Trial.ttf`, `Fontspring-DEMO-resort-sansregular.otf` → WOFF2
  - Format plus léger et universel pour les navigateurs modernes
  - Fichier : `assets/fonts/`

### Contenu / conversion

- [ ] **Ajouter un CTA répété à chaque section scroll**
  - Actuellement visible uniquement dans le menu
  - Recommandation : bouton "Me contacter" ou "Voir les projets" en fin de chaque section (home)
  - Augmente significativement la conversion visiteur → client

- [ ] **Afficher la disponibilité sur la home**
  - Exemple : "Disponible pour nouveaux projets — Juin 2026"
  - Crée de l'urgence, rassure le client, visible sans scroll
  - Fichier : `_data/pages/index.yml` + `_includes/pages/index.html`

### Accessibilité

- [ ] **Compléter les aria sur les filtres du portfolio**
  - `aria-label` présent sur `.dropdown` mais manquant sur `.select` et `.menu`
  - Fichier : `_includes/portfolio-filters.html`

- [ ] **Ajouter un fallback sur les images cassées**
  - Gestionnaire `onerror` JS ou placeholder CSS
  - Fichier : `_includes/projects/project-card.html`

- [ ] **Revoir la config `.hintrc`**
  - Vérifications désactivées : `axe/structure`, `no-inline-styles`, `axe/language`
  - Les réactiver progressivement pour détecter d'autres problèmes

### Qualité du code

- [ ] **Supprimer `assets/js/matrix.js`**
  - Fichier orphelin (référence HTML déjà commentée, jamais chargé)
  - Fichier : `assets/js/matrix.js`

- [ ] **Supprimer `_includes/meta/schema.html`**
  - Ancienne version hardcodée, non utilisée (`default.html` charge `schema-org.html`)
  - Risque de confusion entre les deux fichiers
  - Fichier : `_includes/meta/schema.html`

- [ ] **Clarifier `fr/projects/chatnoir2.html` + `en/projects/chatnoir2.html`**
  - Double fichier avec `chat-noir.html` → risque de contenu dupliqué côté SEO
  - Supprimer si redondant, ou ajouter `<meta name="robots" content="noindex">` si intentionnel

- ✅ **Exclure les fichiers parasites du build Jekyll** — `backup.txt`, `extract_font_sizes.py`, `font_sizes_report.csv`, `VEILLE.md`, `TODO.md`, `CLAUDE.md`, `docs/`, `scripts/` ajoutés à `exclude:` dans `_config.yml`

---

## 🟢 Basse priorité — Différenciation

- [ ] **Ajouter des mockups vidéo / motion sur les projets phares**
  - 10-15s par projet = différenciateur majeur en 2025 vs portfolios statiques
  - Prioriser : BTR, Exit, A-Lone (projets musicaux phares)

- [ ] **Transformer 3-4 projets en case studies narratifs**
  - Structure : Problème → Contraintes → Démarche → Résultat
  - Les clients musicaux indés veulent comprendre la pensée derrière
  - Format : 6-8 écrans, ratio texte/image équilibré

- [ ] **Configurer les headers de sécurité**
  - `Content-Security-Policy`, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`
  - À configurer au niveau du serveur/hébergeur (GitHub Pages, Netlify, Vercel)
  - Critique si jamais le site migre vers self-hosted

- [ ] **Créer un blog / journal de bord**
  - SEO longue traîne : "graphiste pochette album Angers", "DA musique indépendante"
  - Contenus réguliers = autorité de domaine progressive

---

## 📦 Contenu à produire

- [ ] Poster "Carti" (FR + EN)
- [ ] Logo design process "K" (FR + EN)

---

## 📦 Historique récent

- ✅ EN & FR description de EXIT
- ✅ EN description de JPeJA
- ✅ EN description de Cheetah
- ✅ EN & FR description de Crow
- ✅ EN & FR description de Logo process
- ✅ EN & FR description de Outlast

---

## 🧩 Composants système (référence)

- Données modulaires dans `_data/projects/<slug>.yml`
- Ordre contrôlé par `_data/projects/index.yml`
- Script d'amorçage : `scripts/new-project.ps1`
- Templates : `_includes/projects/project-card.html`, `_includes/projects/project-main.html`
- Support images ET vidéos (fallbacks automatiques)
- Métadonnées SEO intégrées par langue
- Layout principal : `_layouts/default.html`
- SEO : `_includes/meta/schema-org.html`, `_includes/meta/open-graph.html`
