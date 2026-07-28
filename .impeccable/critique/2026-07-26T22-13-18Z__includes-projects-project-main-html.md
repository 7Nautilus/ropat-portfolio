---
target: page projet, corps de page (passe 2)
total_score: 20
p0_count: 2
p1_count: 4
timestamp: 2026-07-26T22-13-18Z
slug: includes-projects-project-main-html
---
Method: dual-agent (A: revue de design isolée · B: détecteur + preuves navigateur isolées)

## Design Health Score

| # | Heuristique | Note | Évolution | Problème clé |
|---|-----------|-------|---|-----------|
| 1 | Visibilité de l'état | 2 | = | Aucun compteur, aucune progression |
| 2 | Adéquation au monde réel | 2 | = | « Agrandir » réduit l'image de 10 % sur une pièce pleine ; l'icône de défilement est le pictogramme du téléchargement |
| 3 | Contrôle et liberté | 2 | **+1** | Lightbox accessible, header qui revient. Toujours aucun précédent |
| 4 | Cohérence et standards | 2 | = | `pleine` rend 35 % de l'écran et `marge` 41 % sur mobile |
| 5 | Prévention des erreurs | 3 | **+1** | Défaut `livrable`, note vide non rendue, garde-fous |
| 6 | Reconnaissance plutôt que rappel | 1 | **=** | Le widget supprimé, sa fonction jamais remplacée |
| 7 | Flexibilité et efficacité | 1 | **=** | 11,8 écrans mobiles pour 5 images, aucun raccourci |
| 8 | Esthétique et minimalisme | 2 | = | 2,1 à 3,0 écrans de vide dans les boîtes de pièces |
| 9 | Diagnostic des erreurs | 3 | **+1** | Garde sur les notes vides, repli des specimens |
| 10 | Aide et documentation | 2 | = | Le colophon fait le travail mais arrive après 7 écrans |
| **Total** | | **20/40** | **+3** | Toujours sous la fourchette réelle (20-32), à sa borne basse |

Les trois points gagnés viennent des heuristiques 3, 5 et 9. **Les heuristiques 6 et 7, celles que la
passe 1 désignait comme la cause du score, n'ont pas bougé d'un point.**

## Anti-Patterns Verdict

**Évaluation LLM.** Le site est passé de « générique » à « gabarit visible ». 15 micro-libellés
identiques sur aelio, tous à 12,0 px et 2,28 px de chasse. 9 projets sur 20 partagent exactement les
mêmes quatre titres de section. Le cycle de rythme par défaut est un `index modulo 4`, identique sur
les 11 projets à médias.

**Scan déterministe.** 11 trouvailles, **toutes des faux positifs** vérifiés ligne par ligne : 9
`design-system-color` qui sont les nuanciers de marque des clients rendus comme contenu, et 2
`broken-image` qui matchent du texte à l'intérieur d'un commentaire Liquid. Zéro défaut réel
imputable au code.

**Mesures qui valident le travail fait :** contraste du corps de page 14/14 conforme ; sémantique
40/40 (un seul h1, aucun saut de niveau, `dl` valide) ; piège de focus de la lightbox vérifié en
frappes Tab réelles, `inert` posé puis retiré ; vidéos à 0 source posée au chargement (995 Ko contre
34,66 Mo après défilement complet) avec lecture et pause effectives à l'approche ; CLS mesuré à
0,00000 à froid ; 0 erreur console, 0 requête en échec sur 6 pages ; aucun débordement horizontal.

## Overall Impression

Le socle technique est solide et vérifié. Le problème est de conception, et il est le même qu'à la
passe 1 sous une autre forme : **le rythme pilote une boîte, jamais l'œuvre**, et la fonction du
widget supprimé n'a toujours pas été remplacée.

## What's Working

1. **Le champ `nature` et son défaut `livrable`.** Position éditoriale, pas réglage. 0 % de coupe
   mesuré sur toutes les pièces livrable.
2. **L'accessibilité de la lightbox.** Piège de tabulation, `inert`, Échap, focus rendu au
   déclencheur. Au-dessus du niveau de la plupart des sites d'agence.
3. **Le rythme comme assurance anti-CLS.** `min-height` sur la pièce réserve la hauteur
   indépendamment du média : la hauteur du document est déterminée avant tout chargement d'image.
   Effet non prévu, mais réel et mesuré.

## Priority Issues

### [P0] Le rythme pilote une boîte, jamais l'œuvre
`max-height` est un plafond sans plancher. Mesure sur stelya à 1440 : la pièce `etroite` (468 px)
est rendue PLUS GRANDE que les deux `marge` qui l'encadrent (400 et 162 px). Sur mobile, `pleine`
(35 %) est plus petit que `marge` (41 %), sur aelio comme sur stelya. Coût mesuré : 2 406 px de vide
sur stelya, 1 672 px sur aelio, pour une part d'œuvre de 14 % de la hauteur de page.
**Fix** : `min-height: 0` sur la pièce, et `height` (et non `max-height`) sur le média.

### [P0] L'ouverture perd son titre entre 600 et 900 px
Mesure à 845x745 : `.project-open` fait 1096 px, le titre est à y = 803 soit 58 px sous la ligne de
flottaison, le pitch se termine 384 px hors écran. Le premier écran ne montre ni le nom du projet ni
une ligne de texte. La bascule deux colonnes est à 900 px et `min-height` est un minimum, pas un
plafond.
**Fix** : sous 900 px, plafonner le média pour laisser la place au texte.

### [P1] Le placement automatique des notes est un métronome
`note_step` en division entière donne 1 sur aelio (5 pièces, 4 notes) : une note après chaque pièce.
5 projets sur 20 en alternance stricte, 4 finissent sur trois notes d'affilée. Et l'intervalle après
une note vaut **exactement 101 px partout**, le même 101 px que mon propre commentaire SCSS reproche
à l'ancienne version.
**Fix** : plancher `note_step >= 2`, et à terme un placement explicite dans le YAML.

### [P1] Deux relances commerciales collées, finale mou
`.project-next` puis `.project-cta` puis le CTA du pied de page : quatre liens de contact dans les
830 derniers pixels, même demande, même voix, même orange.
**Fix** : supprimer `.project-cta` de la page projet et promouvoir `.project-next` en bande pleine
largeur portant l'image du projet suivant. La page finirait sur du travail, pas sur un pitch.

### [P1] Le bloc design system est un reste de l'ancienne page
744 px contre 88 px dans deux colonnes égales, soit 656 px de colonne vide. 8 des 10 projets
concernés n'ont qu'une seule fonte. Sur le fond, il montre le design system DU CLIENT : le lead qui
décide n'a pas besoin du hex du navy d'Aélio.

### [P1] Le header devient illisible sur une ouverture `contexte`
Défaut introduit aujourd'hui. Mesure sur hors-champ à 375, scrollY 0 : logo orange à **1,39:1**,
burger blanc à **2,22:1**, contre 3:1 exigés par WCAG 1.4.11 pour un contrôle. Le voile est calé sur
le bloc de texte du bas et volontairement léger en haut.

### [P2] « Agrandir » n'agrandit pas
Mesure sur aelio à 1440 : gain de 0,90x sur la pièce pleine, 0,99x sur le logo, +0,9 % sur mobile.
Et l'ouverture, l'œuvre principale, n'est pas cliquable du tout. Corollaire : l'absence de
suivant/précédent dans la lightbox n'est pas le problème, le problème est que la lightbox ne sert à
rien.

### [P2] L'indice de défilement se pose sur l'œuvre du client
Chevauchement mesuré de 101x58 px sur aelio, sur 17 des 20 projets d'après le champ `aspect`. Et le
glyphe est `arrow-big-down-dash`, le pictogramme standard du téléchargement. Sur une page dont la
règle fondatrice est de protéger le livrable, l'unique élément posé dessus dit « télécharger ».

### [P2] Nuanciers : 20 échecs de contraste sur 148 textes (13,5 %)
La bascule noir/blanc à `l = 0.5` est juste, mais les alphas 0,85 et 0,65 rongent le contraste dans
la bande de clarté où la bascule est déjà serrée. Pire cas `#6559a1` à 2,63:1. Le rôle hex (alpha
0,65) échoue 6 fois plus que le rôle name.

### [P2] Deux pages EN portent un libellé français
Bug introduit aujourd'hui. `ottony-paris` et `zylkene` affichent `aria-label="Agrandir : ..."` en
anglais. Cause : `zoom_label` est assigné À L'INTÉRIEUR de la boucle `for`, mais la branche
`lone_mockup` s'exécute quand la boucle ne tourne jamais. Le `default: 'Agrandir'` code alors le
français en dur. En prime, les 29 autres libellés EN s'écrivent `Enlarge : ` avec une espace avant
le deux-points, convention française contraire à l'anglais US du projet.

### [P3] `--fs-xsmall` est inerte
`clamp(0.75rem, 0.5vw + 0.25rem, 0.875rem)` n'atteint 12 px qu'à 1600 px de large. Sur toute la
plage réelle, la valeur est plate à 12,0 px.

### [P3] `.project-note-body { max-width: 56ch }` en résout 44,8
Le `ch` est calculé sur la fonte héritée du div (16 px) alors que le texte se compose à 20 px.
Écart de 20 % avec l'intention déclarée.

### [P3] 12 projets sur 20 montrent 0 ou 1 média sous l'ouverture
8 à zéro, 4 à un seul. Sur btr, quatre notes aux intervalles 101/101/101 px et aucun événement
visuel après le hero. Et ces 8 pages partagent 7 fois les mêmes quatre titres de section.

## Persona Red Flags

**Manager d'artiste, mobile, 90 secondes.** Ouvre btr depuis Instagram. Écran 1 : la pochette,
entière, belle. Écrans 2 à 4 : du texte. Il ne verra jamais une deuxième image et repart convaincu
que Ropat livre une image par projet. 8 pages sur 20 donnent cette impression.

**Directrice marketing PME, navigateur en demi-écran (845 px).** Atterrit sur aelio : un carré bleu
marine et un bouton qui ressemble à un téléchargement. Ni nom, ni pitch. Trouve enfin à l'écran 8 ce
qui a été livré, puis on lui demande deux fois en 400 px de prendre contact.

**Confrère DA ou recruteur, desktop.** Ouvre trois projets, voit la même boucle M-P-M-E, les mêmes
quatre titres orange dans le même ordre, le même colophon, le même « Travaillons ensemble ! ».
Conclusion : gabarit.

## Questions à considérer

1. `pleine` rend 35 % de l'écran et `marge` 41 %. Si le nom ne décrit pas ce qu'on voit, à quoi sert
   le nom ? Et pourquoi le rythme est-il décidé par `index modulo 4` plutôt que par l'œuvre, son
   ratio, son sujet, sa place dans le récit ?
2. Sur aelio à 375, 86 % de la hauteur de page n'est pas de l'œuvre. Quelle est la part défendable
   sur le portfolio d'un directeur artistique, et quel bloc part en premier ?
3. Si 8 projets sur 20 n'ont qu'une image, le problème est-il la page projet, ou ces 8 projets ne
   sont-ils pas des projets ? Une page ne peut pas sauver un dossier vide.
4. Le bloc couleurs et typographie montre le design system DU CLIENT. Qui, parmi les gens qui
   décident d'embaucher Ropat, a besoin du hex du navy d'Aélio ?
5. Le colophon arrive après 7 écrans. Le lead qui décide veut savoir quoi, pour qui, en combien de
   temps, AVANT de regarder. Pourquoi l'index est-il à la fin ?
6. Le widget de galerie a été retiré parce qu'il permutait des vignettes. Sa fonction, savoir
   combien il y a de pièces et pouvoir y revenir, n'a jamais été remplacée. C'est la seule chose
   qu'il faisait bien, et la seule qui n'a pas été reconstruite.
