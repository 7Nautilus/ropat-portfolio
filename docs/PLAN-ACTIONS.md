# PLAN D'ACTIONS - AUDIT ROPAT.ART

**Date :** 12 mars 2026
**Basee sur :** [AUDIT-COMPLET.md](./AUDIT-COMPLET.md)

Chaque action est referencee par son code d'audit (ex: C1, P2) pour tracabilite.

---

## PHASE 1 - CORRECTIONS CRITIQUES (immediat)

> Impact direct sur le fonctionnement, la coherence ou la credibilite du site.

### 1.1 Unifier l'adresse email [C1] | FAIT
- [ ] Decider de l'email officiel : `contact@ropat.art` ou `contact@ropat.art`
- [ ] Mettre a jour `_config.yml` (champ `email`)
- [ ] Mettre a jour `_includes/layout/footer.html`
- [ ] Mettre a jour `_includes/pages/contact.html`
- [ ] Mettre a jour les pages legales FR et EN (confidentialite + mentions-legales)
- **Fichiers concernes :** `_config.yml`, `_includes/layout/footer.html`, `_includes/pages/contact.html`, `fr/confidentialite.html`, `en/privacy.html`, `fr/mentions-legales.html`, `en/legal-notice.html`

### 1.2 Rendre le service "Graphic Design" visible [C2]
- [ ] Ajouter `graphic-design` dans `_data/services/index.yml`
- [ ] Decider de sa position dans l'ordre d'affichage
- **Fichier concerne :** `_data/services/index.yml`

### 1.3 Internationaliser la section "generic" de la page services [C3]
- [ ] Ajouter les traductions EN dans `_data/pages/services.yml` pour les bulles (Flyers & Print, Visuels Social Media, Templates, Retouche Photo, etc.)
- [ ] Modifier `_includes/pages/services.html` pour lire les labels depuis les donnees YAML au lieu du HTML hardcode
- [ ] Traduire le CTA "Besoin d'un service ponctuel ?" en anglais
- [ ] Corriger le lien CTA hardcode `/fr/contact.html` -> utiliser `page.lang`
- **Fichiers concernes :** `_data/pages/services.yml`, `_includes/pages/services.html`

### 1.4 Creer la page Experiences en anglais [C4]
- [ ] Creer `en/experiences.html` avec le front matter bilingue
- [ ] Ajouter les traductions EN dans `_data/pages/experiences.yml`
- [ ] Ajouter le lien dans la navigation EN si necessaire
- **Fichiers a creer/modifier :** `en/experiences.html`, `_data/pages/experiences.yml`, `_data/navigation.yml`

---

## PHASE 2 - NETTOYAGE DU REPO (dans la semaine)

> Supprimer les fichiers orphelins et legacy pour un repo propre.

### 2.1 Supprimer les fichiers legacy
- [ ] Supprimer `assets/css/style.css` (1903 lignes CSS legacy, font Inter)
- [ ] Supprimer `assets/css/main.css` et `assets/css/main.css.map` (compiles locaux)
- [ ] Supprimer `_data/services_old.yml` (ancien format)
- [ ] Supprimer `_includes/meta/schema.html` (remplace par `schema-org.html`)
- [ ] Supprimer `backup.txt`
- [ ] Supprimer `extract_font_sizes.py`
- [ ] Supprimer `font_sizes_report.csv`

### 2.2 Supprimer les composants Matrix inutilises
- [ ] Supprimer `assets/js/matrix.js`
- [ ] Supprimer `assets/css/_sass/components/_matrix.scss`
- [ ] Retirer `@use "components/matrix"` de `assets/css/main.scss`

### 2.3 Supprimer le fichier SCSS vide
- [ ] Supprimer `assets/css/_sass/components/_utils.scss`
- [ ] Retirer `@use "components/utils"` de `assets/css/main.scss`

### 2.4 Nettoyer le cache committe
- [ ] Supprimer le dossier `.jekyll-cache/` du repo (`git rm -r --cached .jekyll-cache/`)
- [ ] Verifier que `.jekyll-cache/` est bien dans `.gitignore`

### 2.5 Mettre a jour le `.gitignore`
- [ ] Ajouter `assets/css/main.css` et `assets/css/main.css.map` au `.gitignore`

### 2.6 Decider du sort de `chatnoir2.html` [A3]
- [ ] Supprimer `fr/projects/chatnoir2.html` si c'est experimental
- [ ] OU normaliser en utilisant le systeme d'includes standard avec un `project_id` unique

---

## PHASE 3 - PERFORMANCE (1-2 semaines)

> Optimisations significatives pour le temps de chargement.

### 3.1 Retirer la font Google "Inter" [S5][P1]
- [ ] Retirer `Inter` de la balise Google Fonts dans `_layouts/default.html`
- [ ] Verifier qu'aucun composant ne reference `Inter` dans le SCSS actuel
- **Fichier concerne :** `_layouts/default.html`

### 3.2 Convertir les images en WebP [P2]
- [ ] `assets/images/projects/btr-cover.png` -> `.webp`
- [ ] `assets/images/projects/chatnoir.jpg` -> `.webp`
- [ ] `assets/images/projects/cheetah-stopmotion.png` -> `.webp`
- [ ] `assets/images/projects/crow-stopmotion.png` -> `.webp`
- [ ] `assets/images/projects/exit.png` -> `.webp`
- [ ] `assets/images/projects/hdd-defrag-poster.png` -> `.webp`
- [ ] `assets/images/projects/jpeja-thumbnail.jpg` -> `.webp`
- [ ] `assets/images/projects/JPeJA-thumbnail2.jpg` -> `.webp`
- [ ] `assets/images/projects/logo-design-process.png` (et variantes 3d, 3d-fx, vecto) -> `.webp`
- [ ] `assets/images/projects/outlast-trials.png` -> `.webp`
- [ ] Mettre a jour toutes les references dans les fichiers YAML `_data/projects/*.yml`
- **Outils :** Squoosh (https://squoosh.app/) ou `cwebp` en ligne de commande

### 3.3 Ajouter le lazy loading d'images [P3]
- [ ] Ajouter `loading="lazy"` sur toutes les `<img>` sauf celles above-the-fold (hero, logo)
- [ ] Modifier `_includes/projects/project-card.html`
- [ ] Modifier `_includes/projects/project-main.html` (thumbnails + galerie)
- [ ] Modifier `_includes/services/service-card.html` si applicable
- **Fichiers concernes :** tous les includes qui generent des `<img>`

### 3.4 Ajouter `srcset`/`sizes` pour les images responsives [P4]
- [ ] Generer des variantes d'images (400w, 800w, 1200w)
- [ ] Ajouter les attributs `srcset` et `sizes` dans les templates
- [ ] Priorite sur les images de la grille portfolio (les plus visibles)

### 3.5 Activer le cache bundler dans le CI [CI1]
- [ ] Modifier `.github/workflows/deploy.yml` : passer `cache: true` sur `ruby/setup-ruby`
- **Fichier concerne :** `.github/workflows/deploy.yml`

---

## PHASE 4 - CONTENU (2-4 semaines)

> Completer les contenus manquants ou partiels.

### 4.1 Completer le projet Chat Noir [C5]
- [ ] Rediger le `context_content` FR dans `_data/projects/chat-noir.yml`
- [ ] Rediger le `context_content` EN dans `_data/projects/chat-noir.yml`
- [ ] Ajouter les descriptions de case study (specs, mockup, colors, typography si pertinent)
- **Fichier concerne :** `_data/projects/chat-noir.yml`

### 4.2 Mettre a jour les dates des pages legales [S3]
- [ ] Mettre a jour "Last updated" dans `en/privacy.html` et `en/legal-notice.html`
- [ ] Mettre a jour "Derniere mise a jour" dans `fr/confidentialite.html` et `fr/mentions-legales.html`

### 4.3 Verifier et completer les contenus TODO.md
- [ ] Revoir les infos de `en/services/web-design.html`
- [ ] Rediger les descriptions EN & FR du projet EXIT
- [ ] Creer le projet "Poster Carti" si prevu
- [ ] Creer le projet "Logo design process K" si prevu
- **Reference :** `TODO.md` existant dans le repo

---

## PHASE 5 - QUALITE & CI (3-4 semaines)

> Ameliorations structurelles et bonnes pratiques.

### 5.1 Ajouter une validation HTML au CI [CI3]
- [ ] Ajouter `htmlproofer` au `Gemfile`
- [ ] Ajouter un step `bundle exec htmlproofer _site/` dans le workflow de deploy
- [ ] Corriger les eventuelles erreurs detectees
- **Fichiers concernes :** `Gemfile`, `.github/workflows/deploy.yml`

### 5.2 Ameliorer le dropdown de filtres [AC2]
- [ ] Remplacer le dropdown custom `<div>` par un composant accessible
- [ ] Ajouter les roles ARIA `listbox`/`option` ou utiliser un `<select>` natif style
- [ ] Tester la navigation clavier (fleches haut/bas, Entree, Escape)
- **Fichiers concernes :** `_includes/portfolio-filters.html`, `assets/js/script.js`, `_sass/components/_dropdown.scss`

### 5.3 Refactoriser les media queries [D2]
- [ ] Deplacer les regles de `_media-queries.scss` dans les fichiers de composants concernes
- [ ] Ou au minimum, supprimer les blocs vides et documenter les breakpoints
- [ ] Dedupliquer le bloc 640px+ pour le service container [D3]
- **Fichier concerne :** `assets/css/_sass/base/_media-queries.scss`

### 5.4 Supprimer les prefixes webkit manuels [D5]
- [ ] Retirer les `-webkit-` manuels sur les keyframes `pulse`, `fadeIn`, `loading`
- [ ] S'assurer que le pipeline de build gere l'autoprefixing (ou accepter que les navigateurs sans prefixe suffisent)
- **Fichiers concernes :** `_sass/base/_animations.scss`, `_sass/components/_loader.scss`

### 5.5 Nettoyer le workflow sitemap desactive [CI4]
- [ ] Supprimer `.github/workflows/sitemap.yml` (desactive et non utilise)

---

## PHASE 6 - AMELIORATIONS FUTURES (backlog)

> Nice-to-have, a prioriser selon les besoins.

### 6.1 Extraire les SVG de partners.yml [P6]
- [ ] Deplacer les logos SVG dans `assets/images/partners/`
- [ ] Modifier `partners.yml` pour referencer les chemins au lieu d'inclure le SVG inline
- [ ] Mettre a jour `_includes/pages/index.html` pour charger les fichiers SVG

### 6.2 Remplacer les valeurs magiques par des variables [D4]
- [ ] `10rem` gap sur `main` -> variable
- [ ] `76px` hauteur header dans le calc du hero -> variable
- [ ] `6rem` bottom sur scroll-down -> variable

### 6.3 Ajouter `prefers-reduced-motion` sur le carousel
- [ ] Verifier que l'animation infinie du carousel s'arrete avec `prefers-reduced-motion`
- [ ] Afficher les logos statiques dans ce cas

### 6.4 Ameliorer la lightbox [J4]
- [ ] Ajouter un spinner de chargement pendant le swap d'image
- [ ] Precharger l'image suivante quand la galerie est ouverte

### 6.5 Ajouter un formulaire de contact
- [ ] Evaluer Formspree, Netlify Forms, ou EmailJS
- [ ] Integrer sur la page contact en complement du mailto
- [ ] Ajouter validation cote client

### 6.6 Banniere cookies RGPD
- [ ] Ajouter un consentement avant chargement de GA/GTM
- [ ] Stocker le choix dans un cookie
- [ ] Charger les scripts analytics uniquement apres consentement

---

## MATRICE DE PRIORITE

| Action | Impact | Effort | Priorite |
|--------|--------|--------|----------|
| 1.1 Email coherent | Eleve | Faible | P0 |
| 1.2 Service visible | Eleve | Tres faible | P0 |
| 1.3 i18n services | Eleve | Moyen | P0 |
| 1.4 Page experiences EN | Moyen | Moyen | P0 |
| 2.1-2.6 Nettoyage repo | Moyen | Faible | P1 |
| 3.1 Retirer font Inter | Moyen | Tres faible | P1 |
| 3.2 Convertir images WebP | Eleve | Moyen | P1 |
| 3.3 Lazy loading | Eleve | Faible | P1 |
| 3.5 Cache CI | Faible | Tres faible | P1 |
| 4.1 Contenu Chat Noir | Moyen | Moyen | P2 |
| 4.2 Dates legales | Faible | Tres faible | P2 |
| 4.3 Contenus TODO | Moyen | Eleve | P2 |
| 5.1 Validation HTML CI | Moyen | Moyen | P2 |
| 5.2 Dropdown accessible | Moyen | Moyen | P2 |
| 5.3 Refactorer MQ | Faible | Moyen | P3 |
| 5.4 Retirer webkit | Faible | Faible | P3 |
| 5.5 Supprimer sitemap WF | Faible | Tres faible | P3 |
| 6.1-6.6 Backlog | Variable | Variable | P3 |

---

**Legende priorites :**
- **P0** = A faire immediatement (bloquant ou visible par les utilisateurs)
- **P1** = Dans la semaine (qualite technique et performance)
- **P2** = Dans le mois (contenu et qualite long terme)
- **P3** = Backlog (ameliorations futures)

---

**Document cree le 12 mars 2026**
**A mettre a jour au fur et a mesure de l'avancement**
