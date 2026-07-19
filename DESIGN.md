---
version: alpha
name: Ropat
description: Portfolio de Ropat, directeur artistique et graphiste. Socle sombre presque monochrome, ponctué d'orange.
colors:
  primary: "#FFFFFF"
  secondary: "#9CA3AF"
  accent: "#FF5C00"
  accent-soft: "rgba(255, 92, 0, 0.2)"
  neutral: "#0A0A0A"
  surface: "rgba(255, 255, 255, 0.1)"
  border: "rgba(255, 255, 255, 0.08)"
  muted: "rgba(255, 255, 255, 0.45)"
  success: "#34C759"
typography:
  display:
    fontFamily: Space Grotesk
    fontSize: 6rem
    fontWeight: 700
  heading-lg:
    fontFamily: Space Grotesk
    fontSize: 3rem
    fontWeight: 700
  heading-md:
    fontFamily: Space Grotesk
    fontSize: 2.25rem
    fontWeight: 700
  nav:
    fontFamily: Space Grotesk
    fontSize: 1rem
    fontWeight: 700
    letterSpacing: 3px
  body-lg:
    fontFamily: Manrope
    fontSize: 1.25rem
    fontWeight: 400
  body-md:
    fontFamily: Manrope
    fontSize: 1rem
    fontWeight: 400
  caption:
    fontFamily: Manrope
    fontSize: 0.875rem
    fontWeight: 400
  accent:
    fontFamily: Underdog
    fontWeight: 400
spacing:
  xs: 0.5rem
  sm: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
rounded:
  sm: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 6rem
  full: 9999px
components:
  button:
    rounded: full
    backgroundColor: accent-soft
    textColor: primary
    typography: nav
    padding: 0.5rem 1.5rem
---

## Overview

L'interface doit évoquer un style créatif, original et digital-native. Elle doit refléter l'identité de Ropat en tant que designer.

Portfolio de directeur artistique : le design EST le produit. L'exécution doit être soignée, contemporaine, pensée d'abord pour le sombre (dark-mode-first). Il n'existe pas de thème clair. Rien de générique ni de « template » : chaque écran doit donner l'impression d'avoir été composé, pas assemblé.

## Colors

Le socle est sombre : fond quasi noir (`neutral`, #0A0A0A), texte blanc (`primary`). L'orange (`accent`, #FF5C00) est une couleur d'accent, posée par petites touches (appels à l'action, survols, éléments actifs, détails de signature), jamais en aplats dominants.

L'orange ne sert pas de fond à du texte blanc : le contraste ne monte qu'à 3.1:1, sous le seuil WCAG AA. Sur fond orange, écrire en sombre (#0A0A0A, environ 6.4:1).

Le gris (`secondary`, #9CA3AF) porte les informations secondaires : métadonnées, client, légendes. `muted` sert au texte atténué, `border` aux séparations discrètes entre surfaces. Le vert (`success`) est réservé aux états de succès et à l'indicateur de disponibilité.

## Typography

Trois familles, trois rôles :

- **Space Grotesk** porte les titres, la navigation et les boutons. Souvent en capitales, interlettrage marqué (3px sur la navigation), graisse 700. C'est la signature visuelle.
- **Manrope** porte le corps de texte : paragraphes, descriptions, contenu long. Graisses 300 à 600.
- **Underdog** est une police d'accent occasionnelle, pour une touche décalée.

Les tailles ci-dessus sont les valeurs de grand écran. En réalité l'échelle est fluide (`clamp`) : un titre de héros va de 3rem sur mobile à 6rem sur desktop, un paragraphe de 1rem à 1.25rem. Les héros sont volontairement grands et affirmés.

## Layout

L'espacement suit un rythme régulier basé sur 1rem, décliné en 0.5 / 1 / 1.5 / 2 / 3rem (`xs` à `xl`). De l'air entre les blocs, une mise en page aérée et éditoriale.

Les grilles de projets et de services sont des cartes de hauteur homogène : les descriptions sont tronquées à 3 lignes pour que les rangées restent alignées.

## Elevation & Depth

Sur un socle sombre, la profondeur ne vient pas d'ombres noires (elles ne se voient pas). Elle vient de deux moyens :

1. **Des bordures blanches discrètes** (`border`, blanc à 8 %) et des surfaces légèrement éclaircies (`surface`, blanc à 10 %) pour détacher un bloc du fond.
2. **Une lueur orange** pour l'emphase : l'ombre d'accent est `0 6px 16px` en orange à 50 %, pas un gris. La profondeur est colorée, jamais terne.

Les ombres noires classiques (`0 4px 6px` en noir à 10 ou 30 %) restent réservées aux cas où un élément passe au-dessus d'un média clair.

## Shapes

Les angles sont généreux : 1rem à 2rem sur les cartes et conteneurs, jusqu'à 6rem sur les grands blocs. Rien d'anguleux ni de sec.

- **Boutons** : gélule (rayon plein).
- **Conteneurs et vignettes** : squircle (superellipse) via `corner-shape: squircle`, appliqué en amélioration progressive dans un `@supports`. Les navigateurs sans support gardent un `border-radius` classique.
- **Bulles de texte** : un coin volontairement carré et trois arrondis (`0 2rem 2rem 2rem`), qui donne au bloc son allure de bulle.

## Components

**Bouton** : gélule, bordure orange de 3px, fond orange à 20 %, qui devient orange plein au survol. Deux variantes, `solid` et `ghost`. Deux tailles, `md` par défaut et `xl` réservée aux appels à l'action principaux (héros de l'accueil, clôture de la page à propos). Un bouton texte existe aussi : ni fond, ni bordure, ni padding.

**Carte projet** : image en ratio 1:1 surmontant le contenu, séparée par un filet orange de 1px. Titre en Space Grotesk, client en gris, description en Manrope tronquée à 3 lignes.

**Menu déroulant** : l'état ouvert vit dans `aria-expanded`, jamais dans une classe.

## Do's and Don'ts

**À faire**

- Poser l'orange par touches : bordure, survol, état actif, détail.
- Mettre les titres et la navigation en capitales avec de l'interlettrage.
- Garder des angles généreux et des gélules sur les boutons.
- Respecter `prefers-reduced-motion` : le mouvement est discret et intentionnel.
- Viser WCAG 2.1 AA sur tous les contrastes.

**À éviter**

- Du texte blanc sur fond orange (3.1:1, sous le seuil AA).
- Des coins secs ou des rayons inférieurs à 1rem sur les cartes.
- L'orange en aplat dominant, ou comme couleur de texte courant.
- Un thème clair : le site n'en a pas.
- Des ombres noires pour créer de la profondeur sur le fond sombre.
