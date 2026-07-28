---
target: page projet (Phase 1)
total_score: 17
p0_count: 3
p1_count: 4
timestamp: 2026-07-26T19-44-08Z
slug: includes-projects-project-main-html
---
Method: dual-agent (A: revue de design isolée · B: détecteur + preuves navigateur isolées)

## Design Health Score

| # | Heuristique | Note | Problème clé |
|---|-----------|-------|-----------|
| 1 | Visibilité de l'état | 2 | Aucune indication de défilement sur 9 à 13 écrans, aucun compteur de pièces |
| 2 | Adéquation au monde réel | 2 | H1 anglais sur les 20 pages FR (« BTR Cover », « Chat Noir Poster ») |
| 3 | Contrôle et liberté | 1 | 8 pages sur 20 où l'œuvre ne peut jamais être vue entière, ouverture jamais cliquable |
| 4 | Cohérence et standards | 2 | Une recette de micro-libellé pour 6 emplois + 1 orpheline, images agrandissables mais pas les vidéos, sans différence visuelle |
| 5 | Prévention des erreurs | 2 | `.project-sequence` vide rendue sur chat-noir, `**` markdown qui fuit dans le JSON-LD |
| 6 | Reconnaissance plutôt que rappel | 1 | La bande de vignettes a disparu sans remplacement de fonction |
| 7 | Flexibilité et efficacité | 1 | Aucun chemin de survol, lightbox sans suivant/précédent, sortie = un lien de 14 px |
| 8 | Esthétique et minimalisme | 2 | 14 à 16 micro-libellés par page, deux CTA empilés, bande morte de 48 px |
| 9 | Diagnostic des erreurs | 2 | Page creuse rendue sans être reconnue |
| 10 | Aide et documentation | 2 | 9 projets sur 20 sont du récit sans image |
| **Total** | | **17/40** | **Sous la fourchette réelle habituelle (20-32)** |

## Anti-Patterns Verdict

**Évaluation LLM.** Pas de slop à l'échelle d'une page, mais oui à l'échelle du site. Trois bans tombent : glassmorphisme décoratif (header `backdrop-filter: blur(12px)` posé sur l'œuvre), micro-libellé répété 14 à 16 fois par page dont 4 d'affilée sur btr, et surtout la COPIE : aelio et stelya partagent le même squelette de phrase mot pour mot, cheetah et crow ont un pitch strictement identique. Un visiteur qui lit une page ne dira pas « IA ». Un visiteur qui en lit deux le dira en cinq secondes.

**Scan déterministe.** 13 à 15 trouvailles, code de sortie 2. **Zéro défaut réel imputable au code de la Phase 1.** Les 2 `broken-image` matchent le texte à l'intérieur de mon propre commentaire Liquid qui explique justement la correction. Les 25 `design-system-color` sont les nuanciers de marque des clients, rendus comme contenu éditorial. Un signal légitime hors périmètre : `marketing-buzzword` sur « cutting-edge technical expertise » dans le récit EN d'aelio.

**Contraste WCAG : tout passe**, mesuré avec témoins qui échouent bien (blanc/noir = 21,00 ; référence W3C #767676 = 4,54 ; deux témoins d'échec à 1,04 et 1,48). Correction de méthode apportée par l'évaluation B : pour les couleurs en rgba, le cas défavorable est le fond le plus SOMBRE, pas le plus clair. `.project-colophon dt` et `.project-next-label` valent 4,65 sur #030808, marge réelle de 0,15. Les chiffres inscrits dans `_variables.scss` sont honnêtes (concordance à l'arrondi près).

## Overall Impression

La grammaire est juste, l'exécution mutile l'œuvre. La thèse de la page était « l'œuvre ouvre à fond perdu, sans cadre » : elle ouvre RECADRÉE, de 12 à 58 % selon le format. Le score de 17/40 ne sanctionne pas le goût, il sanctionne une fonction supprimée sans remplacement : les heuristiques 3, 6 et 7 coulent toutes les trois parce que la bande de vignettes répondait à trois questions d'un coup d'œil et que rien ne les reprend.

## What's Working

1. **Le lede sur le sol nu.** Il inverse le cliché du portfolio et donne à l'œuvre le premier écran sans concurrence, puis aux mots leur propre terrain. Sur cet écran, l'orange apparaît exactement deux fois : la pastille du thème et le sous-titre. C'est « signal et pas motif », démontré et non revendiqué.
2. **Le colophon.** `dl/dt/dd`, lit comme l'achevé d'imprimer d'un livre, registre juste pour un graphiste, et indexable. 40 pages sur 40 structurellement conformes.
3. **La sémantique et l'anti-CLS.** 40/40 un seul h1, zéro saut de niveau, zéro image sans alt, CLS mesuré à 0. Les pièces sous la ligne de flottaison réservent leur hauteur avant chargement.

## Priority Issues

### [P0] `object-fit: cover` ampute l'œuvre, sans recours sur 8 pages sur 20
Part masquée mesurée : jhag-pinterest 58 % à 1440, chat-noir ~58 %, btr 37 %, aelio 37 %. Sur mobile la coupe devient latérale et tranche le bandeau du client en plein mot. L'ouverture n'est jamais un déclencheur de lightbox (0/20), et 8 projets n'ont aucun déclencheur du tout. Pour un pochettiste, le format complet EST le livrable.
**Fix** : `object-fit: contain` + `max-height: 100svh`, le ratio de l'œuvre décide de la hauteur. Rendre l'ouverture agrandissable sur les 20 pages.

### [P0] La règle dure est violée sur les 20 pages, par le header
`header` sticky, `z-index: 100`, `backdrop-filter: blur(12px)`, bordure orange de 2,86 px, posé sur l'œuvre dès 48 px de défilement. Le corps de page respecte la règle ; c'est le chrome qui la casse, ce qui du point de vue du client revient au même. Il réimporte les deux choses que la refonte disait avoir tuées : bordure orange uniforme et glassmorphisme.
**Fix** : IntersectionObserver sur `.project-open` et `.project-piece--pleine` qui neutralise le fond, le flou et la bordure du header. Supprimer la bande morte de 48 px.

### [P0] Le rythme est une alternance mécanique, pas une composition
Les 8 intervalles de la séquence aelio valent tous exactement 101 px à 1440 (60 px à 859), quel que soit le voisinage. Amplitude horizontale pleine/marge = +8,8 %, indiscernable. Le pas de note se verrouille en phase avec le cycle modulo 4 : aelio est un métronome image/note strict, stelya place systématiquement la note après le fond perdu, quatre projets finissent sur trois notes d'affilée. Aucune page ne reçoit un arrangement qu'un humain aurait choisi.
**Fix** : un intervalle vertical PAR rythme, élargir l'écart pleine/marge à environ 25 %, et remplacer le placement automatique des notes par un champ explicite dans le YAML. Un kit qui s'arrange tout seul n'est pas un kit.

### [P1] La lightbox ne piège pas le focus
Point de contradiction entre les deux évaluations : A la classe en force (le focus va sur la fermeture, Échap le rend au déclencheur, vérifié), B a poussé le test plus loin et trouvé le défaut. Une tabulation depuis la lightbox ouverte envoie le focus sur `a.email` à y = 9586 px, hors overlay, et `body.overflow: hidden` empêche la page de défiler jusqu'à lui. `role="dialog" aria-modal="true"` est déclaré mais `<main>` ne porte ni `inert` ni `aria-hidden`. B a raison : A avait testé un sous-ensemble.
**Fix** : confinement du Tab dans le dialogue, plus `inert` sur `<main>` à l'ouverture.

### [P1] Régression de poids : 51,87 Mo sur une page
jhag-banana-rush charge 3 vidéos de 17,87 / 17,82 / 15,54 Mo, toutes sous la ligne de flottaison, toutes téléchargées INTÉGRALEMENT (`readyState 4`, buffer complet) parce que `autoplay` force le fetch. L'ancien widget n'en affichait qu'une à la fois ; la séquence les rend toutes. jhag-pinterest : 10,15 Mo. C'est une régression introduite par la Phase 1.
**Fix** : IntersectionObserver qui ne pose `src` (ou ne déclenche `play`) qu'à l'approche, et `preload="none"`.

### [P1] Les médias portrait deviennent injouables
jhag-pinterest à 1440x900 : pièces de 1965, 2138 et 1965 px, soit 2,18 à 2,38 écrans. Aucune création visible en entier nulle part. `pleine`, le rythme censé être le climax, est le PIRE traitement pour tout ce qui est plus haut que du 16:9.
**Fix** : plafond de hauteur sur le média (`max-height: 88svh`), et faire déclarer au rythme une taille plutôt qu'un padding.

### [P1] Vidéos sans pause ni respect du mouvement réduit
`autoplay loop` sans `controls`, aucun traitement de `prefers-reduced-motion` sur les vidéos. Échec WCAG 2.2.2 niveau A (contenu animé de plus de 5 s sans mécanisme d'arrêt).

### [P2] Cible tactile « Tous les projets » à 146 x 14,4 px
Trouvé par les DEUX évaluations. Sous le seuil de 44 px et même sous les 24 px du critère AA 2.5.8. C'est la seule sortie de la page, en bas de 9 écrans.

### [P2] Quadratins dans le code, contre une règle explicite du projet
`project-main.html` lignes 170 et 198 : `aria-label="… — Cliquez pour agrandir"`, plus un troisième ligne 9. Trouvé par les deux évaluations. Le libellé embarque en outre une instruction réservée à la souris sur une commande atteignable au clavier.

### [P2] `.project-sequence` vide rendue sur chat-noir
Le garde-fou sur les notes vides fonctionne, mais le conteneur s'affiche quand même : 60 px de rien.

## Persona Red Flags

**Jordan (novice, arrive par Google sur chat-noir).** Premier écran : barre noire, rule orange, une affiche dont 38 à 58 % est coupé, aucun texte, aucun signe de suite. S'il défile : titre dont la deuxième ligne est en anglais, un paragraphe, 60 px de vide, un tableau, une relance commerciale. Il ne voit jamais l'affiche entière. Il ignore qu'il y a 19 autres projets.

**Riley (états limites).** Chaque asset de jhag-pinterest fait 2,18 à 2,38 écrans. Il clique l'ouverture : rien. Il clique la vidéo : rien, et il ne peut pas la mettre en pause. Il tabule : 2 arrêts pour 3 pièces. Il active le mouvement réduit : les révélations s'arrêtent, les vidéos continuent. Il passe en 375 : la même création est coupée à gauche et à droite au lieu du haut et du bas.

**Casey (mobile, un pouce).** jhag-pinterest fait 9,34 écrans pour 3 images, 10,15 Mo. La barre orange reste sur l'œuvre tout du long. Pour revenir à la liste, la cible fait 146 x 14 px. Elle rate et tombe sur « Prendre contact ».

## Minor Observations

- `--fs-xsmall` n'est pas fluide : il faudrait un viewport de 2000 px pour quitter son plancher. Tous les micro-libellés du site sont un 12 px fixe déguisé.
- Le stagger ne staggue rien : deux pièces consécutives sont séparées de 1400 à 2200 px, elles ne peuvent jamais être co-visibles. Motif appliqué là où il ne peut produire aucun effet.
- Colophon : `auto-fit minmax(160px)` donne 6 colonnes de 170 px à 1440, soit une justification de 21 signes. Plafonner à 3 ou 4.
- Justure plafonnée à 44,8 ch dès 845 px, juste sous la bande de confort 45-75.
- Anneau de focus rogné sur les pièces pleine largeur (côtés à x = -7 et x = 1432).
- Image d'ouverture d'aelio : 3840x3840 natifs pour un emplacement de 845 px, aucun `srcset` sur tout le corpus.
- cheetah, crow, jpeja : vidéo d'ouverture sans `poster` ni `fetchpriority`.
- Schema.org n'émet aucun champ du colophon, et la description transporte les `**` bruts du markdown.
- `.project-next` ne propose que le suivant, jamais le précédent.
- Le dither est rendu à 0,5x (canvas 430x374 pour un viewport de 859x745) et upscalé.

## Questions à considérer

1. À quoi sert `subtitle` ? Le même mot apparaît trois fois (thème, sous-titre, services) et c'est lui qui impose l'anglais dans chaque H1 français. Et si la deuxième ligne du H1 était le client ?
2. Si 9 projets sur 20 n'ont qu'une image, la page de case study est-elle le bon objet pour eux ? À quoi ressemblerait une page conçue pour une image et quarante mots ?
3. Le rythme est un token de padding. Et si c'était un token de HAUTEUR, c'est-à-dire de temps passé à l'écran ? Sur une page où tout défile, le temps est l'axe qu'on contrôle ; la largeur, le fichier du client l'a déjà décidée.
4. Le dither est l'actif le plus distinctif du site et il n'est qu'une texture sous le texte. Et si le rythme se jouait en MATIÈRE (le dither passe derrière l'œuvre, ou l'œuvre est posée sur une plaque pleine) au lieu de 115 pixels de padding ?
5. La bordure orange a été retirée parce qu'un signal partout ne signale plus. Le micro-libellé 12 px capitales espacées apparaît 14 à 16 fois par page. Qu'est-ce qui a rendu le deuxième différent du premier ?
