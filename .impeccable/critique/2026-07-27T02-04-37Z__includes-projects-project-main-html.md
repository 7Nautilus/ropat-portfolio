---
target: page projet, passe 3 apres restructuration
total_score: 19
p0_count: 2
p1_count: 3
timestamp: 2026-07-27T02-04-37Z
slug: includes-projects-project-main-html
---
Method: dual-agent (A: revue de design isolée · B: détecteur + preuves navigateur isolées)

## Design Health Score

**TOTAL : 19/40** (passe 1 : 17 · passe 2 : 20 · passe 3 : **19**)

| # | Heuristique | Note | Évolution | Problème clé |
|---|-----------|-------|---|-----------|
| 1 | Visibilité de l'état | 2 | = | L'indice de défilement n'est JAMAIS émis : conditionné à `nature != contexte`, or les 20 fichiers déclarent `contexte`. Ouverture calée à 1px du viewport |
| 2 | Adéquation au monde réel | 2 | = | Une page titrée « OUTLAST TRIALS / POSTER » montre une affiche rognée à 57,7 % |
| 3 | Contrôle et liberté | 2 | = | L'ouverture n'est ouvrable nulle part sur 19 pages, le rognage est sans recours |
| 4 | Cohérence et standards | 3 | **+1** | Le progrès le plus net : une gouttière, un filet, un composant, une grille |
| 5 | Prévention des erreurs | 1 | **-2** | Le défaut `livrable`, écrit pour empêcher exactement cette faute, est surchargé par 20 fichiers sur 20. Taux de prévention réel : 0 % |
| 6 | Reconnaissance | 2 | **+1** | La planche répond enfin « combien y en a-t-il », mais 12 pages sur 19 n'ont rien à montrer |
| 7 | Flexibilité | 1 | = | Toujours aucun parcours entre pièces, `id="project-suite"` est une ancre morte |
| 8 | Esthétique | 2 | = | 15 micro-libellés identiques par page, 11,9 % du récit en gras sur 16 passages |
| 9 | Diagnostic | 2 | = | chat-noir rend 2,9 écrans sans rien signaler du vide |
| 10 | Aide et documentation | 2 | = | Colophon et design system utiles, retenus par les colonnes déséquilibrées |

Le score baisse parce que **l'heuristique 5 perd deux points** : le garde-fou construit pour protéger
l'œuvre du client n'est utilisé par aucune page.

## Anti-Patterns Verdict

**Évaluation LLM.** Deux bans touchés. Le micro-libellé 12px capitales espacées compte 15 occurrences
sur une seule page, dont 6 `<h2>` : l'échelle typographique est cassée (six h2 à 12px, deux à 41,8px,
rien entre les deux). Et la planche tombe dans « grilles de cartes identiques » : sur 19 pages, **18
ne produisent qu'une seule classe de rythme**.

**Scan déterministe.** 14 trouvailles, **14 faux positifs** vérifiés (nuanciers clients rendus comme
contenu, et texte matché dans un commentaire Liquid). Zéro défaut réel imputable au code.

**Ce que les mesures valident.** Les correctifs de la passe 2 ont TOUS tenu : pièce qui épouse son
média 18/18 avec 0,00 % d'écart de ratio, vidéos à 0 source posée au chargement, libellés ARIA
symétriques FR/EN (la régression « Agrandir » est corrigée), header conforme aux 4 positions,
anneaux de focus non rognés (26 mesures), sémantique 40/40, CLS à 0 avec témoin validé (0 → 0,21
quand le témoin est correctement injecté), 0 erreur console, 0 requête en échec.

## Overall Impression

La page n'a pas progressé, elle a **échangé un problème contre un autre de poids égal**. Le récit a
gagné (l'entrelacement mensonger est supprimé, la colonne est mesurée juste). L'ouverture a perdu
autant : en basculant 20 pages sur 20 en `contexte`, la refonte a mis le travail du client sous un
voile, sous un recadrage de 37 à 58 %, et sous la typographie de Ropat. C'est la faute que le
contre-projet B avait démontrée, généralisée à tout le site au lieu d'une page.

## What's Working

1. **Le chrome adaptatif, là où il s'applique.** Échantillonnage canvas du quart supérieur,
   luminance WCAG, seuil 0,45. Sur hors-champ en haut de page : contour du logo à **7,07:1** contre
   1,55:1 avec l'orange. Le problème est réel, la mesure est bonne, le correctif fonctionne.
2. **La suppression de l'entrelacement.** Correction de justesse, pas de goût : la mise en page
   affirmait une relation image/paragraphe que le contenu n'a jamais eue. La colonne qui la remplace
   mesure 864px pour 72,8 caractères réels en 20/32.
3. **Le chargement différé des vidéos.** 0 source posée au chargement sur les 3 vidéos de
   jhag-banana-rush, page à 1074 Ko, et repli `prefers-reduced-motion` qui affiche les contrôles.

## Priority Issues

### [P0] Le mode `livrable` est du code mort, et le placeholder est le mode le plus destructeur
`nature: contexte` est déclaré dans **20 fichiers sur 20**. Le mode `livrable` (œuvre entière,
`contain`, aucun voile, indice de défilement) n'est emprunté par aucune page. Rognage mesuré :
outlast-trials 57,7 % à 1440, btr 53,8 % à 375, jhag-pinterest ~58 %, hdd-defrag ~56 %. Sur
outlast-trials et btr, **la page n'a aucune autre pièce** : ce cadrage est la seule vue de l'œuvre.
**Fix** : repasser les 12 projets `mockup_a_produire: true` en `livrable`. Un placeholder doit être
le mode le plus CONSERVATEUR, pas le plus destructeur. Garder `contexte` pour les 8 projets qui ont
un vrai mockup.

### [P0] La planche est vide sur 63 % des pages
8 projets sur 19 ont zéro pièce, 4 de plus en ont une seule. La planche est bien conçue, elle n'a
rien à composer. C'est la vraie raison pour laquelle l'heuristique 6 plafonne à 2, et aucun travail
de grille ne la fera monter. **Ce n'est pas un correctif de code.**

### [P1] Le chrome adaptatif est neutralisé exactement quand le logo est visible
Bug introduit lors de la restauration du header d'origine. La garde
`:not([data-chrome="pose"])` est justifiée par un commentaire affirmant que « la barre revient avec
un fond opaque `--surface` ». **Cette règle n'existe nulle part dans le SCSS.** Or `pose` = header
VISIBLE. Mesure du contour du logo sur pièce claire à l'état posé : **1,01 à 2,46:1** sur 12
échantillons sur 12, contre 3:1 exigés par WCAG 1.4.11.

### [P1] `.galerie-plus` est un bouton fantôme sur 12 pages sur 12
`display: block` (0,1,0) écrase `[hidden] { display: none }` de la feuille navigateur (0,0,1). Le
bouton reste rendu (44px de haut, 1309,9px de large) et **focusable, sans aucun nom accessible** :
arrêt de tabulation n° 11 sur stelya, n° 10 sur aelio. **C'est exactement le bug déjà corrigé sur
`.project-piece`, documenté en commentaire, et non appliqué au bouton créé ensuite.**
Effet de bord : après un redimensionnement mobile vers desktop, le bouton conserve et affiche un
libellé périmé (« Voir les 2 autres pièces » alors que 5 pièces sur 5 sont visibles).

### [P1] Le rythme lit une donnée qui n'est jamais saisie
`_r100` est calculé sur `piece.aspect | default: project.aspect | default: "1/1"`. Sur 20 fichiers,
**une seule pièce du site déclare un `aspect`**. Résultat : span 3 sur 29 pièces, span 2 sur 3,
span 6 sur 1. Le mécanisme est correct dans son intention et inopérant dans les faits.
Effet secondaire : les attributs `width`/`height` valent `1x1` sur des images 1920x900, donc la
réservation anti-CLS documentée dans CLAUDE.md est fausse sur la quasi-totalité des pièces.

### [P2] Débordement horizontal du pied de page entre 350 et 370px de largeur utile
Balayage par pas de 5px : 0 à 315-345, **24px à 350**, 19 à 355, 14 à 360, 9 à 365, 4 à 370, puis 0
au-delà. Coupables : `.footer-nav-container`, `.nav-links-footer`, les liens sociaux. 360px utiles
est une largeur très répandue.

### [P2] Deux contrastes sous le seuil
Nuancier `Or Profond` #C4831A, libellé hex : **4,03:1**. `.project-theme` sur sipsmith à 1440 :
**4,36:1**. Sur 51 mesures de hero, c'est le seul échec.

### [P3] Un seul niveau typographique porte la page
15 micro-libellés à 12px/2,28px sur aelio, dont 6 `<h2>`. `--fs-xsmall` figé à 12px de 320 à 1599px.
11,9 % du récit en gras sur 16 passages dans 8 paragraphes : l'emphase ne signale plus rien.

### [P3] Restes de service à vide
`id="project-suite"` n'est visé par aucun lien. Un quadratin subsiste dans `moon-vtc.yml:43`. Trois
liens de pied de page sous 24px de haut (16,8 et 18,3px).

## Persona Red Flags

**L'artiste musical, sur téléphone.** Ouvre btr depuis Instagram. Il voit **46,2 %** de la pochette
qu'il a peut-être commandée, assombrie à 94 % dans le tiers bas, avec « BTR » écrit par-dessus dans
une autre police que la sienne. Aucune autre image sur la page. Sa question : « il a fait ça, lui,
ou c'est un filtre du site ? »

**La directrice marketing, 1440.** Après l'ouverture d'aelio, quatre carrés de 645x645 strictement
identiques, dont deux sont la même icône en deux coloris. Puis 375 mots sans titre de section. Sa
lecture : « c'est un moodboard, pas un dossier de marque. »

**Le DA senior qui balaie trois projets.** chat-noir : 0 pièce. outlast-trials : 0 pièce, affiche
rognée à 57,7 %. exit : 0 pièce. Il ne saura jamais que stelya et jhag existent. **L'ordre de
`index.yml` décide davantage que la mise en page.**

## Questions à considérer

1. Le mode `livrable` a été écrit, commenté sur 12 lignes, défendu contre la faute Sarah Lawrence,
   et il n'est utilisé par aucune page. À quoi sert un garde-fou dont le taux de déclenchement est de
   0 sur 20 ? Il n'a pas été violé par accident : il a été désactivé fichier par fichier, vingt fois.
2. Si 12 des 20 ouvertures sont des placeholders assumés, pourquoi le placeholder est-il le mode qui
   rogne et voile le PLUS ? L'attente d'un vrai mockup coûte 40 à 58 % de l'œuvre sur chaque page.
3. La planche a été construite pour répondre à « combien y en a-t-il ». Sur 12 pages sur 19, la
   réponse honnête est « zéro ». Trois passes ont produit trois refontes du contenant ; la cause est
   peut-être qu'il n'y a pas assez à contenir.
4. L'ancien rythme produisait la même suite M P M E partout ; le nouveau produit `marge` partout.
   Le remplacement d'un rythme faux par un rythme absent compte-t-il comme un progrès ?
5. Sur hors-champ, le titre du site écrit « HORS CHAMP » par-dessus le logotype « HORS CHAMP » du
   client, dans une autre police. Ropat livrerait-il ça à un client ? Si non, pourquoi le site le
   fait-il sur son propre travail ?
6. Le commentaire de `_header.scss` justifie une garde par une règle CSS qui n'existe pas. Combien
   d'autres décisions sont défendues par un état supposé plutôt que mesuré ?
