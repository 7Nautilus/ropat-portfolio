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
- **JavaScript** : l'outil le plus pertinent par tâche, aucune dépendance front à ce jour
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
├── design-system.yml          # L'icône de flèche de scroll, source unique. Rien d'autre :
│                              # les couleurs et la typo vivent dans _sass/base/_variables.scss
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
│   └── projects/, services/    ← ENGENDRÉS AU BUILD, aucun fichier sur le disque
└── en/
    ├── index.html, about.html, contact.html, portfolio.html, services.html
    └── projects/, services/    ← idem
```

> ⚠️ Les 48 pages projet et service **n'existent pas dans le dépôt**. Elles sont produites au build
> par `_plugins/pages_generees.rb` à partir de `_data/projects/` et `_data/services/`. Seules les
> 14 pages fixes par langue sont écrites à la main. Chercher `fr/projects/aelio.html` sur le disque
> ne rend rien, et c'est normal.

- URLs distinctes : `/fr/...` et `/en/...`
- Textes et métadonnées centralisés dans `_data/projects/<slug>.yml`
- Hreflang géré automatiquement par `_layouts/default.html`
- Cartes projets (`project-card.html`) qui adaptent les URLs selon la langue active

## Ajouter un nouveau projet

**Il n'y a aucune page à écrire.** Depuis le 29/07/2026, `_plugins/pages_generees.rb` engendre au
build les pages projet et service dans les deux langues. `_data/projects/index.yml` n'est donc plus
une liste d'**ordre** mais une liste d'**existence** : un projet absent n'a pas de page, un projet
présent en a deux.

> ⚠️ Ce plugin ne s'exécute que parce que la CI lance `jekyll build` elle-même. Si le déploiement
> repassait par le constructeur intégré de GitHub Pages, les pages disparaîtraient **en silence**.

Deux gestes suffisent :

1. **Créer `_data/projects/<slug>.yml`** en partant de `_data/projects/aelio.yml`, qui est le
   modèle de référence et le seul à jour.
2. **Ajouter le slug à `_data/projects/index.yml`**, à la place voulue dans l'ordre d'affichage.

> ⚠️ `scripts/new-project.ps1` est **périmé** et ne doit pas être lancé : il engendre l'ancien
> format `context_content` et il écrit les fichiers de page qui n'existent plus.

### Modèle YAML minimal

```yaml
slug: exemple
project_title: EXEMPLE          # le nom du travail : un album, une campagne, ou la marque
subtitle: "Branding"            # le TYPE, affiché sous le titre du hero
theme: { fr: "…", en: "…" }
category: branding              # sert le filtre du portfolio (voir _data/projects/categories.yml)
year: "2025"
client: { fr: "…", en: "…" }
tools: "Photoshop, Illustrator"
image_src: /assets/images/projects/exemple.avif   # vignette, sert aussi d'image OG par défaut
main_image: /assets/images/projects/exemple.avif  # média du hero, image ou vidéo
media_type: image
aspect: "4/3"                   # ratio L/H du hero. À POSER si l'image n'est pas carrée : sans lui
                                # le défaut est 1/1 et la page prend du décalage de mise en page.
context: { fr: "…", en: "…" }   # l'OCCASION : sortie d'album, lancement de marque…
secteur: { fr: "…", en: "…" }   # l'ACTIVITÉ du client. À omettre pour un projet personnel.
context_sections:               # le récit du projet, format unique
  - title: { fr: "…", en: "…" }
    content:
      fr: |
        …
      en: |
        …
locales:
  fr:
    url: /fr/projects/exemple.html
    title: "Titre de carte FR"
    description: "Résumé court."
    services: "Compétences mises en œuvre"
    seo:
      title: "Titre SEO FR | Ropat"
      description: "Meta description FR"
      og_title: "Titre Open Graph FR"
      og_description: "Description Open Graph FR"
  en:
    # même structure
```

Quatre champs à **ne pas** remettre, tous dérivés automatiquement :

| Champ | Pourquoi |
|---|---|
| `canonical_url`, `og_url` | le layout les dérive de `site.url` + `page.url` |
| `og_image` en URL absolue | c'est un **chemin** top-level, dérivé de `image_src` par défaut |
| `context_title` | centralisé dans `_includes/projects/project-main.html` (« Coulisses du projet ») |
| `context_content` | remplacé par `context_sections` |

Le `subtitle` qui compte est celui du **haut du fichier** : un `subtitle` placé dans `locales` n'est
lu par personne. Et la catégorie ne va **jamais** dans `locales.*.title` : elle vit dans `category`.

Les projets aboutis enrichissent ce schéma avec un bloc `case_study` (`mockups`, `colors`,
`typography`, `specs`) et des `thumbnails`, dont seul `src` est obligatoire.

### Vérifier après coup

```bash
bundle exec ruby scripts/carte.rb --build --diff
```

La carte doit annoncer deux routes de plus et aucune perdue.

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
