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

## 🔴 Haute priorité

- [ ] **Convertir les images PNG lourdes en WebP**
  - `btr-cover.png` (~1.5 MB) → WebP
  - `exit.png` (~2.3 MB) → WebP
  - `logo-design-process-3d-fx.png` (~4.5 MB) → WebP
  - Impact : -60% de poids, gain de performance significatif

- [ ] **Revoir les infos de `en/services/web-design.html`**
  - Contenu incomplet ou inexact

---

## 🟡 Priorité moyenne

- [ ] **Ajouter un formulaire de contact**
  - Actuellement : lien `mailto:` uniquement → dépend du client mail de l'utilisateur
  - Solution recommandée : Formspree ou Basin (gratuit, sans backend)
  - Fichier concerné : `_includes/pages/contact.html`

- [ ] **Enrichir la page About**
  - Contenu actuel très court → faible SEO et engagement limité
  - Idées : skills, timeline d'expériences, photo, citations

- [ ] **Vérifier le contraste de `--grey-light-400: #9CA3AF`**
  - Ratio potentiellement insuffisant sur fond blanc (WCAG AA = 4.5:1)
  - Outil : [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

- [ ] **Ajouter les légendes dynamiques aux termes techniques**
  - Dans les descriptions de projets (tooltip ou définition inline)

---

## 🟢 Basse priorité

- [ ] **Convertir la font `ANICON SANS BLACK.OTF` en WOFF2**
  - Format plus léger et universel pour les navigateurs modernes
  - Fichier : `assets/fonts/`

- [ ] **Ajouter `preload` pour les fonts Google**
  - Améliore le First Contentful Paint (FCP)
  - Fichier : `_layouts/default.html`

- [ ] **Revoir la config `.hintrc`**
  - Plusieurs vérifications désactivées (`axe/structure`, `no-inline-styles`, `axe/language`)
  - Les réactiver progressivement pour détecter d'autres problèmes d'accessibilité

- [ ] **Ajouter un fallback sur les images cassées**
  - Ajouter un gestionnaire `onerror` JS ou un placeholder CSS
  - Fichier : `_includes/projects/project-card.html`

---

## 📦 Contenu à produire

- [ ] Poster "Carti" (FR + EN)
- [ ] Logo design process "K" (FR + EN)

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
