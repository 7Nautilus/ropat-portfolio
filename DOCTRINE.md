# DOCTRINE.md

La loi de design du site. **Huit règles, écrites pour être opposables.**

> Une règle qu'on ne peut pas invoquer contre une décision n'est pas une règle,
> c'est une intention.

Ce fichier est **écrit à la main**, contrairement à `CARTE.md` qui est générée. Il est la
**source unique** de l'énoncé des règles : quand un autre document les cite, il cite celui-ci.

| Où | Quoi |
|---|---|
| **`DOCTRINE.md`** (ici) | l'énoncé des règles, ce qu'elles interdisent, leur test |
| `labo/design-system.html` | la **preuve** : mesures, tableaux, sondes en direct sur la feuille servie |
| `docs/PLAN-MAINTENANCE.md` §2 | la doctrine de **méthode** (sept règles, R1 à R7). Autre sujet |
| `docs/PLAN-MAINTENANCE.md` §2.2 | le **registre** des décisions tranchées, à lire avant toute passe de jugement |

---

## Règle 0 · On essaie, puis on range

**Posée par Ropat le 31/07/2026, et elle prime sur tout ce qui suit** parce qu'elle dit *quand*
les autres règles s'appliquent. Sa formulation : *« fais-le exister d'abord, puis améliore-le
ensuite »*.

**La charte est une codification de ce qui a été tenté, pas un péage avant de tenter.** L'ordre
est : faire exister la chose, la regarder, puis décider. On a le droit d'essayer **hors charte**.

**Tout essai reçoit un verdict daté, et il n'y en a que trois :**

| Verdict | Ce qu'il veut dire |
|---|---|
| **promu** | la charte l'accueille tel quel |
| **amendant** | la charte **change** pour le recevoir, et l'amendement s'écrit ici |
| **retiré** | la chose s'en va |

⚠️ **C'est le verdict qui fait tenir la règle 0, pas la permission d'essayer.** Un essai sans
verdict n'est pas un essai, c'est un dépôt : « essayer d'abord » devient « accumuler », et la
charte finit par décrire un site qui n'existe plus.

**Pourquoi elle est vraie ici et pas seulement souhaitable.** Les règles 7 et 8, les deux plus
solides de cette doctrine, sont **descriptives** : elles ont été lues dans les arbitrages de
Ropat après coup. La seule règle de composition écrite *a priori*, la grammaire *pleine, marge,
étroite*, est exactement celle qui a été jetée. La règle 0 décrit donc ce qui a marché sur ce
dépôt, elle ne l'assouplit pas.

**Ce qu'elle coûte** (règle 3 des règles sur les règles) : du travail à refaire, et un endroit où
essayer ne casse rien. Cet endroit existe, c'est `labo/`, hors production et hors du hook de
design.

---

## Les trois règles sur les règles

1. **Une règle qu'on ne peut pas invoquer contre une décision est une intention.** D'où le fait
   que chaque règle ci-dessous porte un test, et non une valeur.
2. **Une règle qu'on écrit ne vaut que si on la retourne d'abord contre son propre travail.**
   Écrite le 28/07/2026, au prix d'un cas réel : la règle 8 excluait déjà le liseré posé une
   heure plus tôt, et il a fallu que Ropat le signale une cinquième fois.
3. **Une règle sans coût connu n'est pas une règle, c'est une préférence.** Posée le 31/07/2026.
   Toute règle ajoutée ici doit dire ce qu'elle coûte, à qui, et ce qu'elle aurait évité si elle
   avait existé plus tôt.

---

## Les huit règles

| | Énoncé | Origine |
|---|---|---|
| **1** | L'œuvre est le produit | fondatrice, précisée le 28/07/2026 |
| **2** | Deux couches, jamais une | référent Realtree |
| ~~**3**~~ | ~~Chaque orange doit pouvoir nommer ce qu'il signale~~ | 26/07/2026, **RETIRÉE le 04/08/2026** |
| **4** | Un jeton nomme un rôle, jamais une apparence | 28/07/2026 |
| **5** | L'intensité est composée, pas répartie | 26/07/2026, test refondu le 04/08/2026 |
| **6** | Rien ne se décide sans mesure | permanente |
| **7** | Le camouflage habille les surfaces, pas les encres | Ropat, 28/07/2026 |
| **8** | L'œuvre ne paye jamais la lisibilité du chrome | Ropat, 28/07/2026, six arbitrages |
| **9** | Le maximalisme ne coûte que de la sobriété | Ropat, 31/07/2026 |

Les règles **7 et 8 sont descriptives** : elles ont été lues dans les arbitrages de Ropat après
coup, pas décidées à l'avance. C'est leur force et leur limite.

---

### 1 · L'œuvre est le produit

Sur un **`livrable`** (pochette, affiche, logo), le format et la couleur *sont* le travail : on
ne rogne pas, on ne voile pas, on n'écrit pas dessus. Sur un **`contexte`** (mockup, mise en
situation), c'est une photo de l'œuvre, la mise en page a le droit d'en faire un décor.

Le champ `nature` du YAML tranche, et **son défaut est `livrable`**, donc protecteur.

**Précision du 28/07/2026.** La règle protège l'œuvre **présentée comme telle**. Une vignette de
grille est un **index**, un pointeur vers l'œuvre, et sort de son champ : elle est rognée au
carré, et c'est un choix assumé. La vignette dit « c'est par ici », la page projet dit « la
voici ».
⚠️ Ne pas ressortir « la carte rogne, donc elle viole la règle 1 » : rouvrir le sujet demanderait
un chantier de refonte des cartes, pas un réglage.

⚠️ **Formulation révisée le 27/07/2026.** L'ancienne, « ne jamais superposer sa typo à l'œuvre du
client », avait été généralisée à partir d'un seul échec. Elle était trop large. Ne pas la
ressortir.

---

### 2 · Deux couches, jamais une

Realtree, c'est un camouflage dense **et** un blaze qui claque contre lui. Le camouflage porte la
surface (dither, aplats, filets). Le signal est rare, et il claque.

**Un orange appliqué comme motif n'est plus un signal, c'est du papier peint.**

Où s'arrête le camouflage : voir la règle 7.

---

### 3 · ~~Chaque orange doit pouvoir nommer ce qu'il signale~~ — **RETIRÉE le 04/08/2026**

> **Ce que disait la règle.** Sur un écran donné, compter les oranges et dire, pour chacun, ce
> qu'il signale. Un orange qui ne signale rien était une régression.

**Motif du retrait, dans les mots de Ropat :** *« La règle n'a plus vraiment de sens, ce qui est
en orange n'a pas pour but de signaler, mais d'attirer l'attention, de claquer. »*

**Elle reposait sur une théorie sémantique de la couleur** — l'orange *désigne* quelque chose — et
le site en applique une autre : l'orange est une **intensité**. Les deux cohabitaient sans qu'on le
voie, parce que la règle 5 portait déjà la seconde.

⚠️ **LE FREIN NE DISPARAÎT PAS, IL CHANGE DE NATURE, et c'est ce qui autorise le retrait.** La
règle 3 freinait **élément par élément**, par un test sémantique. La règle 5 freine **séquence par
séquence** : *« si tout claque, plus rien ne claque »* interdit l'orange partout aussi sûrement,
mais par un critère qui correspond à ce que le site cherche. Retirer la 3 sans la 5 laisserait le
maximalisme sans contrepoids ; c'est la 5 qui le tient, et elle le tenait déjà.

⚠️ **CE QUE LE RETRAIT LÉGITIME, ET QUE LA RÈGLE 3 CONDAMNAIT :** l'aplat de
`--voile-transition`, qui couvre l'écran entier entre deux pages. Il ne signale rien, donc il était
une régression. Mesuré le 04/08, il est **le seul écart d'intensité du trajet portfolio → fiche
projet** : l'orange y passe de 3,46 % à 100 % de l'écran, puis retombe à 4,13 %. Sous la règle 5,
ce n'est pas une décoration en trop, c'est **la seule chose qui fasse le travail**.

⚠️ **LA NUMÉROTATION NE BOUGE PAS.** Les règles 4 à 9 gardent leur numéro : **33 mentions dans 14
fichiers** les citent, et renuméroter transformerait chacune en référence fausse sans qu'aucun
outil ne le signale. Le compte des règles **actives** passe de neuf à huit, ce qui rend enfin vrai
l'en-tête de ce fichier, qui annonçait huit depuis l'origine.

⚠️ **Les commentaires de code qui invoquent encore la règle 3 restent valables**, et il ne faut pas
les corriger mécaniquement : ils justifient des décisions de **retenue** (`_buttons.scss:112`,
`_project.scss:617` et `:770`) qui sont toujours bonnes. Seul leur fondement a changé, il est
désormais la règle 5. La sonde « Le test de la règle 3 » de `labo/design-system.html` mesure, elle,
une chose qui ne décide plus rien.

---

### 4 · Un jeton nomme un rôle, jamais une apparence

**Corollaire direct : aucun jeton n'empaquette épaisseur + couleur + style.**

Deux cas réels qui ont produit la règle : `--border-primary` valait « 3px d'orange » et rendait
le geste plus facile que de ne pas le faire ; `--surface-raised` assombrissait.

**Un nom qui décrit une apparence finit par l'imposer.**

Corollaire d'audit, posé par Ropat le 28/07/2026 : **toute couleur porte un nom, exceptions
comprises.** Une exception écrite en variable reste **visible** dans la palette, une exception
écrite en littéral est **invisible**. Tokeniser ne valide pas l'écart, ça le rend auditable.
⚠️ **Nommer n'est pas aligner.** On donne un nom à ce qui existe, on ne déplace aucun pixel.

---

### 5 · L'intensité est composée, pas répartie

Le site est une **pièce de démonstration** : sa navigation doit être une preuve de savoir-faire.
Donc le chrome a le droit d'être riche.

Ce qu'il n'a pas le droit d'être, c'est **uniformément** riche : deux écrans successifs ne
doivent pas avoir la même intensité.

**Baisser le volume partout n'est pas une réponse, c'est l'aveu qu'on n'a pas composé.**

⚠️ C'est la règle qui **conditionne le maximalisme** décidé le 31/07/2026, et non celle qui s'y
oppose. Le défaut diagnostiqué du site n'était pas que l'orange soit fort, c'est qu'il était fort
**partout**, donc devenu muet. Un maximalisme uniforme reproduit ce défaut, en plus cher. Si tout
claque, plus rien ne claque : **l'écart est le travail.**

⚠️ Corollaire, appris à la dure le 28/07/2026 : **ne jamais livrer la moitié soustractive d'un
geste.** « Retirer X et le remplacer par Y » n'est pas deux tâches dont une est optionnelle.
Livrer X seul ne donne pas un état neutre, il donne un état **pire que le départ**. Sur ce projet,
« safe » veut dire invisible.

**Le test d'acceptation, refondu le 04/08/2026** en reprenant celui que portait la règle 3.

Compter les oranges d'**un** écran ne décide plus de rien : la règle ne porte pas sur la quantité,
elle porte sur **l'écart**. Le test est donc comparatif. Pour deux écrans que le visiteur enchaîne,
relever la **part de surface peinte en orange** et la comparer.

⚠️ **La sonde ne doit compter que les propriétés RÉELLEMENT peintes** — `color`,
`background-color`, et les `border-*-color` dont la largeur est non nulle. Inclure `outline-color`,
`fill` ou `stroke` fait exploser le compte, ces propriétés héritant de `currentColor` : l'erreur a
été payée deux fois, à 63 marques comptées pour 18 réelles. **Un témoin sur une couleur absente,
le bleu, doit rendre zéro** avant qu'on croie un seul chiffre.

**Relevé du 04/08/2026**, témoin bleu à 0 sur les cinq écrans :

| Écran | Marques | Surface orange |
|---|---|---|
| accueil | 38 | **7,54 %** |
| fiche projet | 25 | 4,13 % |
| À propos | 39 | 3,63 % |
| portfolio | 64 | 3,46 % |
| contact | 23 | 3,09 % |

⚠️ **LA RÈGLE N'EST PAS TENUE AUJOURD'HUI, et le manquement est là où il coûte le plus.** Quatre
écrans sur cinq tiennent entre 3,09 et 4,13 %, soit un point d'écart, imperceptible. Le pire cas
est **portfolio → fiche projet**, 3,46 % puis 4,13 % : c'est le trajet le plus emprunté du site, le
moment où le visiteur passe de l'index à la preuve, et rien n'y change d'intensité. Seul l'accueil
se détache, à plus du double du plus calme.

**Ce que ce test ne dit pas**, et qu'il ne faut pas lui faire dire : la surface peinte n'est pas
l'intensité perçue. Un aplat de 3 % en plein centre pèse plus qu'un liseré de 6 % en périphérie, et
la mesure ne le sait pas. Elle sert à **repérer l'uniformité**, pas à noter une composition.

---

### 6 · Rien ne se décide sans mesure

Contraste, longueur de ligne, cible tactile, poids : des nombres, pris **au navigateur**, sur la
**vraie page**.

**Et un test qui ne peut pas échouer ne prouve rien : prévoir un témoin.**

⚠️ Deux limites à connaître, toutes deux payées :
- **Mesurer n'est pas regarder.** Une page peut avoir onze ratios justes et s'afficher en blanc
  sur blanc. Ouvrir la capture fait partie de la vérification.
- **Une mesure juste peut avoir une portée fausse.** Après une mesure, se demander **de quoi
  exactement elle est l'inventaire**, et ce que l'instant du relevé exclut.

---

### 7 · Le camouflage habille les surfaces, pas les encres

Posée par Ropat le 28/07/2026, après avoir vu le rendu d'un essai qui ramenait les deux gris de
texte sur l'axe vert. **Ses deux raisons sont distinctes et il faut les garder séparées :**
- **registre** : le texte vert ne fait pas assez sérieux pour l'ensemble ;
- **comptage** : la page porte déjà un sol vert, une encre neige, un orange de signal et deux
  états. Il n'y a pas de place pour une sixième famille.

Les aplats, eux, **doivent** être du camouflage : c'est là qu'il fait son travail.

⚠️ **Corollaire opposable : ne pas rouvrir `--ink-soft` et `--ink-muted` avec des arguments
chiffrés.** Ils ont été produits (le contraste *montait* même, 16,35 → 17,13 et 7,94 → 8,70) et
ils ne répondent pas à la question posée. Un raisonnement de palette valide sur une surface
isolée devient une **ambiance** quand on l'applique à tout le texte secondaire du site.

---

### 8 · L'œuvre ne paye jamais la lisibilité du chrome

Écrite le 28/07/2026 après **six arbitrages de Ropat dans le même sens en une journée**. Sont
tombés, dans l'ordre : le voile en bande de 180 px sur les pages projet (qui garantissait
pourtant 7,43:1 à la nav), le fond de la barre, le halo du logo, celui du burger, le liseré de la
nav, puis l'aplat opaque du bouton contact. À chaque fois le même motif : **un effet sombre posé
sur le travail du client pour rendre le chrome lisible.**

**La frontière :** un contrôle a le droit d'avoir son **propre remplissage**, parce que c'est sa
nature. Ce qu'il n'a pas le droit de faire, c'est **déborder** : voile, bande, ombre portée, tout
ce qui peint au-delà de sa propre boîte.

**Précision du 29/07/2026.** La règle interdit d'**assombrir** l'œuvre pour se rendre lisible.
Elle n'interdit pas de **peindre** dessus. Une lueur orange n'assombrit rien et n'existe qu'à
l'engagement.

⚠️ *Cette précision s'appuyait sur la règle 3, retirée le 04/08/2026. Elle tient sans elle : ce qui
l'autorise n'est pas que la lueur signale quelque chose, c'est qu'elle **n'existe pas au repos**,
donc qu'elle ne coûte rien à l'œuvre. Le test ci-dessous est le vrai fondement, et il n'a jamais eu
besoin de la règle 3.*

> **Le test qui tranche : l'effet existe-t-il au repos ?**
> Un voile, un fond de barre, un halo permanent sont posés en permanence sur le travail du
> client, donc ils tombent. Un effet qui n'apparaît qu'au survol ne concurrence jamais l'œuvre
> pendant qu'on la regarde.

**La sortie que la règle autorise, et c'est l'aboutissement :** la **bascule d'encre**. Commuter
l'encre du chrome ne peint rien sur l'œuvre. Critère un **contraste** et non une luminance, donc
seuil non arbitraire (4,5:1), hystérésis 4,5/7, et maintien de 400 ms imposé par la mesure.
Résultat : nav à 8,29 à 10,14:1 après bascule, contre 1,75 à 2,15 avant.

⚠️ **Ce qu'elle ne résout pas, laissé tel quel :** 17 pages projet sur 20 sont justes. Stelya a
un fond coupé en deux et demanderait un verdict **par contrôle** au lieu d'un pour la barre, ce
qui suppose d'accepter qu'un header porte deux encres à la fois. **Arbitrage en attente, ne pas
l'implémenter sans le demander.** Aélio et Stelya sont figés en `chrome: clair`, un champ réservé
aux ex æquo où la mesure n'a pas de préférence et l'œil si.
⚠️ **Ne pas « améliorer » les seuils en visant ces trois pages** : on dégraderait les dix-sept
autres pour rien.

---

### 9 · Le maximalisme ne coûte que de la sobriété

Énoncée par Ropat le 31/07/2026, en réponse directe à la question « qu'est-ce que tu acceptes de
perdre ? » : *« Le maximalisme peut seulement faire perdre de la sobriété, ça ne doit pas être au
dépend de la vitesse ou de la lisibilité, le plus important reste que le site soit facile d'accès,
fluide, rapide. »*

**Ce qu'elle autorise :** perdre en calme, en retenue, en discrétion. C'est la monnaie du
maximalisme, et elle est convertible sans limite fixée.

**Ce qu'elle interdit :** payer en **vitesse**, en **lisibilité** ou en **accessibilité**. Ces
trois-là ne sont pas des curseurs, ce sont des planchers.

> **Le test :** un changement qui améliore l'impression et **dégrade un nombre mesuré** sur la
> vitesse, la lisibilité ou l'accessibilité est refusé, quelle que soit sa beauté. Pas d'arbitrage
> au cas par cas, sinon la règle ne sert à rien : c'est toujours au cas par cas qu'on cède.

⚠️ **Le budget chiffré reste à fixer, et les deux chiffres que j'ai cités ici étaient faux.**
Corrigé le 02/08/2026 par une remesure :
- **Le plafond de 25,6 Ko est déjà franchi** : la chaîne rejouée donne **27 818 o** de CSS et de JS
  en première visite, soit 8,6 % au-dessus.
- **Il ne comptait pas les polices** : environ **91 Ko** de Google Fonts bloquantes, jamais
  incluses dans le budget. La graisse 300 de Chakra Petch y est chargée pour rien (**zéro**
  `font-weight: 300` dans tout le CSS, vérifié).
- Et le plancher doit porter sur le **poids total de la première visite** de la page concernée,
  médias d'ouverture compris : une page projet sert jusqu'à 9,5 Mo de vidéo.

⚠️ **Et la CI ne peut pas attraper un dépassement.** Les deux assertions de `deploy.yml`
(`-lt 20000` pour le CSS, `-lt 2000` pour le JS) sont des **planchers** : elles voient un fichier
tronqué, jamais un fichier qui gonfle. Il manque une assertion de **plafond**, à écrire à côté de
celles qui lui servent de modèle.

⚠️ Cette règle est la **contrepartie** de la direction maximaliste, pas une réserve à son égard.
Elle existe parce que le maximalisme a un prix connu et que Ropat a nommé la devise dans laquelle
il accepte de le payer. Voir la règle 3 des règles sur les règles.

---

## Le cadre en vigueur au 31/07/2026

**Direction : maximaliste.** Le site devient plus interactif et dynamique, et **tout l'acquis est
challengeable** : copy, structure, UI, UX, animation. Ce n'est pas une invitation à la retenue.

**Les règles 1 et 8 tiennent, y compris sous le maximalisme** (arbitrage de Ropat, 31/07/2026).
On est maximaliste **autour** de l'œuvre, jamais dessus. Restent donc entièrement ouverts sur une
page projet : le cadrage, le récit, le chrome, le mouvement, l'arrivée depuis la grille, la façon
dont l'œuvre entre et se présente.

**Le critère de réussite, l'offre et les publics ont quitté ce fichier le 02/08/2026** pour
`PRODUCT.md`. Ce n'était pas de la loi de design, et un document qui mélange les règles et les
raisons finit par ne plus être opposable ni sur les unes ni sur les autres. Ici : ce qu'on a le
droit de faire. Là-bas : pour qui, et à quoi on saura que ça a marché.

**Les points d'appui actuels** (⚠️ appelés « points fixes non négociables » jusqu'au 31/07/2026 ;
Ropat a corrigé le cadre ce jour-là : *« rien n'est figé, tout peut être mis en question à tout
moment, je ne prends rien pour acquis et je reste toujours ouvert »*) :
- `#FF5C00` et sa filiation **Realtree** : camouflage de chasse avec du blaze orange floqué ;
- l'orange n'est **jamais** du texte de labeur ;
- trio sombre du fond : `#030808 · #030F0C · #051510` ;
- typo : Chakra Petch / Plus Jakarta Sans / Underdog.

> **Comment lire « rien n'est figé » sans que la doctrine perde son sens.** Le registre et cette
> doctrine lient **l'exécutant**, pas Ropat : ils empêchent de rejouer en boucle des sujets déjà
> tranchés, sur les mêmes arguments et sans élément neuf. Ils n'ont jamais eu le pouvoir de lui
> interdire de changer d'avis. La différence pratique : rouvrir un sujet demande **un élément
> neuf** ou **sa décision**, et non l'un des deux seulement.

**Rien n'est publié avant la fin du chantier** (Ropat, 31/07/2026). Ce que cette décision coûte,
et l'atténuation proposée, sont au registre de `docs/PLAN-MAINTENANCE.md` §2.2. Sa conséquence sur
le critère de réussite est dans `PRODUCT.md` §3.

---

## Ce que la doctrine ne couvre pas

Ces questions sont **ouvertes** et ne se tranchent pas sans Ropat :

- la matière du skin clair (le dither est sombre par construction) ;
- grille de vignettes contre index typographique sur le portfolio ;
- le curseur blob : recomposer ou retirer ;
- la durée et le déclencheur du loader ;
- la curation des projets (8 projets perso, soit 40 % du portfolio) ;
- la **grammaire de composition de la planche**, à refaire : dériver le cadrage d'un seul nombre,
  le ratio, ne produit pas de composition (verdict du 28/07/2026).

---

## Comment on amende ce fichier

Une règle ne s'ajoute et ne se modifie qu'avec **trois choses** : sa **date**, la **preuve** sur
laquelle elle repose, et une clause **« reconsidérable si »**. Sans elles, une décision prise sur
une simulation pèse autant qu'une décision prise sur la chose.

Tout amendement entre aussi au **registre** de `docs/PLAN-MAINTENANCE.md` §2.2, dont la lecture
ouvre toute passe de jugement : ce qui le contredit est **écarté et compté**, pas rediscuté.
