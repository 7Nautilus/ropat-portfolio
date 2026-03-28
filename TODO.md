# TODO & Recommandations

---

## ✅ Corrections appliquées (mars 2026)

- ✅ `onclick` inline supprimé du sélecteur de langue → délégation d'événements dans `script.js`
- ✅ Cookie de langue avec `SameSite=Lax` (sécurité CSRF)
- ✅ `aria-label` lightbox fusionné avec `alt` (description + action pour les lecteurs d'écran)
- ✅ `_data/pages/services.yml` complété en anglais (`pitch`, `generic`)
- ✅ `_data/services_old.yml` supprimé (fichier orphelin)
- ✅ Référence `matrix.js` commentée supprimée de `default.html`
- ✅ `en/projects/chatnoir2.html` créé (projet manquant côté EN)

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

### Sécurité

- [ ] **Ajouter `rel="noopener noreferrer"` sur tous les liens sociaux**
  - Fichier : `_includes/social-media-icons.html`
  - Tous les liens `target="_blank"` (Instagram, Pinterest, LinkedIn, Behance) exposés au vecteur `window.opener`
  - Fix : ajouter `rel="noopener noreferrer"` dans le template

### Accessibilité

- [ ] **Corriger le contraste de `--grey-light-400: #9CA3AF`**
  - Ratio actuel sur fond blanc : ~3.5:1 → **sous le seuil WCAG AA (4.5:1)**
  - Remplacer par `#6B7280` (ratio ~5.4:1) ou `#7A8895`
  - Fichier : `_sass/base/_variables.scss`
  - Vérifie tous les endroits où cette couleur est utilisée (textes secondaires, labels)

---

## 🟠 Haute priorité

### Contact & conversion

- [ ] **Remplacer le `mailto:` par un vrai formulaire de contact**
  - Expose l'email aux scrapers, dépend du client mail de l'utilisateur
  - Solution recommandée : **Web3Forms** (250 envois/mois gratuit, simple à intégrer)
  - Implémenter un honeypot anti-spam (champ caché)
  - Garder le `mailto:` en fallback secondaire
  - Fichier : `_includes/pages/contact.html`

### Contenu / SEO

- [ ] **Enrichir la page About (50 mots actuels → 300+ mots)**
  - Contenu trop court : faible SEO, engagement limité, aucune preuve sociale
  - Ajouter : photo professionnelle, skills, timeline d'expériences, noms de projets/clients reconnus
  - Ton humain et direct (les clients musicaux indés l'exigent)
  - Fichiers : `_includes/pages/about.html`, `_data/pages/about.yml`

- [ ] **Corriger et compléter `en/services/web-design.html`**
  - Contenu incomplet ou inexact côté EN

### SEO technique

- [ ] **Corriger le sitemap.xml : pages manquantes**
  - Pages légales absentes : `/fr/mentions-legales.html`, `/fr/confidentialite.html`, `/en/legal-notice.html`, `/en/privacy.html`
  - Pages services absentes : `/fr/services/*.html`, `/en/services/*.html`
  - Simplifier la logique Liquid (conditionnelles trop complexes)
  - Fichier : `sitemap.xml`

---

## 🟡 Priorité moyenne

### Performance

- [ ] **Ajouter `preload` explicite pour les fonts critiques**
  - `preconnect` déjà en place mais pas de `<link rel="preload" as="font" crossorigin>`
  - Impact : -~300ms sur le FCP
  - Fichier : `_layouts/default.html` (lignes 93-97)
  - Option avancée : self-héberger les fonts Google (RGPD + perf, zéro requête DNS externe)

- [ ] **Convertir la font `ANICON SANS BLACK.OTF` en WOFF2**
  - Format plus léger et universel pour les navigateurs modernes
  - Fichier : `assets/fonts/`

### Contenu / conversion

- [ ] **Ajouter un CTA répété à chaque section scroll**
  - Actuellement visible uniquement dans le menu
  - Recommandation : bouton "Me contacter" ou "Voir les projets" en fin de chaque section (home)
  - Augmente significativement la conversion visiteur → client

- [ ] **Afficher la disponibilité sur la home**
  - Exemple : "Disponible pour nouveaux projets — Avril 2026"
  - Crée de l'urgence, rassure le client, visible sans scroll
  - Fichier : `_data/pages/index.yml` + `_includes/pages/index.html`

### Accessibilité

- [ ] **Compléter les aria sur les filtres du portfolio**
  - `aria-label` présent sur `.dropdown` mais manquant sur `.select` et `.menu`
  - Fichier : `_includes/portfolio-filters.html`

- [ ] **Ajouter un fallback sur les images cassées**
  - Gestionnaire `onerror` JS ou placeholder CSS
  - Fichier : `_includes/projects/project-card.html`

- [ ] **Ajouter les légendes dynamiques aux termes techniques**
  - Tooltip ou définition inline dans les descriptions de projets

- [ ] **Revoir la config `.hintrc`**
  - Vérifications désactivées : `axe/structure`, `no-inline-styles`, `axe/language`
  - Les réactiver progressivement pour détecter d'autres problèmes

### Qualité du code

- [ ] **Supprimer `assets/js/matrix.js`**
  - Fichier orphelin (référence HTML déjà commentée)
  - Ne sert à rien, mauvaise hygiène de code

- [ ] **Vérifier et clarifier `_includes/meta/schema.html`**
  - Doublon potentiel avec `_includes/meta/schema-org.html`
  - Supprimer si redondant, documenter si spécialisé

- [ ] **Vérifier `fr/projects/chatnoir2.html` + `en/projects/chatnoir2.html`**
  - Double fichier → risque de contenu dupliqué
  - Confirmer si intentionnel

---

## 🟢 Basse priorité — Différenciation

- [ ] **Ajouter des mockups vidéo / motion sur les projets phares**
  - 10-15s par projet = différenciateur majeur en 2025 vs portfolios statiques
  - Prioriser : BTR, Exit, A-Lone (projets musicaux phares)

- [ ] **Transformer 3-4 projets en case studies narratifs**
  - Structure : Problème → Contraintes → Démarche → Résultat
  - Les clients musicaux indés veulent comprendre la pensée derrière
  - Format : 6-8 écrans, ratio texte/image équilibré

- [ ] **Ajouter `prefers-reduced-motion` côté CSS**
  - Déjà géré dans `script.js` ✅ mais animations CSS pures à vérifier
  - Fichiers : `_sass/` (animations, transitions)

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
