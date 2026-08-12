# PRODUCT.md

**Pour qui ce site est fait, ce qu'il doit prouver, et à quoi on saura qu'il a marché.**

`DOCTRINE.md` dit ce qu'on a le droit de faire. Ce fichier-ci dit **pourquoi**, et pour qui.
Quand une décision de design ne peut pas être rattachée à une ligne de ce document, c'est
probablement une décision de goût déguisée en stratégie.

> ⚠️ **Ce fichier est versionné, donc potentiellement public.** Les chiffres de faiblesse
> (leads, part du travail non publié, tarifs, jugements sur les clients) vivent dans `docs/`,
> qui est dans le `.gitignore` : `docs/INVENTAIRE-2026-08.md` et
> `docs/PROJET-OPTIA-2026-07.md`. Ne pas les remonter ici.

---

## 1. Le métier

**Branding d'entreprise.** Identité visuelle, création de logo, design de présentation
(slide decks, plaquettes, catalogues), contenus et campagnes.

La musique est **l'origine, pas le métier actuel**. Elle explique l'œil et elle reste dans le
portfolio, elle ne dirige plus le discours.

⚠️ **Le site affiche encore le contraire au 02/08/2026.** `_config.yml` annonce « spécialisé
dans l'accompagnement visuel des artistes musicaux ». Mesure remise à jour le 12/08/2026, sur les
**21 projets publiés** : **3** portent une catégorie musicale (`btr`, `a-lone`, `jpeja`) et **2**
déclarent un secteur musical (`btr`, `a-lone`). Le numérateur n'a pas bougé depuis le 02/08, le
dénominateur si. La correction est un chantier
ouvert. Ne pas propager cette formulation dans de nouveaux textes.

---

## 2. Pour qui

Trois publics, et ils ne tirent pas dans le même sens.

| Public | Ce qu'il cherche | Priorité |
|---|---|---|
| **Le lead direct** (Malt, bouche à oreille, message) | de la preuve, vite, et une raison de faire confiance sur un budget | **le site est optimisé pour lui** |
| **La recherche froide** | quelqu'un qui travaille dans son secteur | chantier de contenu, séparé et postérieur |
| **Le réseau** (LinkedIn) | quelque chose qui mérite d'être partagé | servi gratuitement par le reste |

**Ce que cherche le lead direct, dans ses mots :** *des projets similaires au sien, ou dans son
secteur, ou les deux.* C'est le brief de navigation le plus direct qu'on ait, et il commande
**deux axes** : le **livrable** et le **secteur**.

Les deux axes ne jouent pas le même rôle. Le **livrable** est la requête avec intention d'achat,
c'est là qu'un lead se transforme. Le **secteur** est la preuve, faible en volume, quasi sans
concurrence, et c'est la vraie longue traîne. Le croisement des deux se **génère** à partir du
portfolio, il ne s'écrit pas à la main, et on ne le soutient que là où il y a du travail réel.

---

## 3. Le critère de réussite

> **La refonte aura marché si le site est devenu une source de leads.** (Ropat, 31/07/2026)

Ce n'est pas un critère esthétique, et il se mesure.

⚠️ **CORRECTION DU 02/08/2026 : LE SITE EST MESURÉ, ET J'AVAIS ÉCRIT L'INVERSE ICI.**
`_layouts/default.html` injecte **Google Analytics 4** (`G-JDE6T1D92Q`, ligne 343) et un conteneur
**Google Tag Manager** (`GTM-KN22K5FS`) sur les 64 routes. La propriété a été ouverte le 02/08 :
elle porte **douze mois de données**.

**Ce que la lecture a établi, et qui change le cadre :** le problème est le **trafic**, pas la
conversion. La refonte de design **seule** ne peut donc pas faire bouger le compteur de leads ;
il faut le contenu, la publication et la recherche avec.
Et le signal encourageant : **les visiteurs venus de la recherche s'engagent nettement plus, et
restent nettement plus longtemps, que ceux qui arrivent par un lien qu'on leur a tendu.** Le
public visé se comporte déjà comme espéré. La longue traîne n'est plus une hypothèse.

⚠️ **Les chiffres eux-mêmes ne sont pas dans ce fichier** (versionné, donc potentiellement public)
et **ils sont pollués** : aucun filtre de trafic interne n'existe, donc les sessions de travail de
Ropat sont dans la mesure, et une part importante des « utilisateurs » ne tient pas six secondes.
Détail, chiffres et réglages à faire : `docs/MESURE-AUDIENCE-2026-08.md`.

⚠️ Et un site non publié ne produit aucun lead et ne se mesure pas. **La date de mise en ligne
est la date à laquelle le chronomètre démarre.**

### Deux mécanismes, et le second est souvent oublié

1. **La recherche.** Être trouvé. Aucune animation ne le produit ; c'est du contenu, des pages,
   un ancrage sectoriel.
2. **Le rappel.** *« Je veux qu'un prospect mal ajusté reparte, mais en gardant un souvenir
   mémorable de mon site, car lui ou son entourage pourrait un jour avoir besoin de mes
   services. »*

Le second donne au maximalisme une **cible vérifiable**, bien meilleure que « effet waouh » :
quelqu'un qui n'a pas signé doit pouvoir **décrire le site en une phrase** à un tiers. Ça se
teste : montrer le site, revenir deux semaines plus tard, écouter. Si les phrases ne se
ressemblent pas, il n'y a rien à retenir.

⚠️ **Convertir et être trouvé sont deux métiers différents.** Le maximalisme fait le premier, très
bien. Il ne fait pas le second. Les confondre, c'est passer six mois sur du mouvement et retrouver
zéro au compteur.

---

## 4. L'offre

**Principe, posé par Ropat le 31/07/2026 :**

> Le dépôt tient l'inventaire complet. Le site en publie une sélection. Et le motif de
> non-publication est écrit à côté de la chose, daté.

**Trois états, parce que deux ne suffisent pas :**

| État | Ce que ça veut dire |
|---|---|
| `inventaire` | dans le dépôt, **aucune page**, invisible des moteurs |
| `publie` | page engendrée et indexable, **pas de carte, pas de lien** |
| `mis_en_avant` | carte, menu, liens internes |

L'état du milieu sert la **longue traîne** : une prestation rare peut mériter une page qui capte
une requête sans encombrer l'offre. ⚠️ Il doit être un **champ**, jamais une ligne absente : une
absence ne se relit pas, une valeur si.

**Règle qui décide seule : `mis_en_avant` exige `preuve: client`.** Une compétence n'est pas une
offre.

L'inventaire complet, avec ses quatre axes (`preuve`, `demande`, `appétit`, `autonome`), est dans
`docs/INVENTAIRE-2026-08.md`.

---

## 5. Ce que le site refuse, et c'est un positionnement

- **La génération de contenu par IA.** *« Je ne génère pas, je conçois. »*
- **L'association à la fabrication d'audience** (achat de followers).

Les deux refus ont **la même forme** : ne pas prêter le métier à de la production de volume sans
valeur. Ce n'est pas deux préférences, c'est une position.

⚠️ **Deux conditions pour qu'un refus rapporte.** Un refus **silencieux** ne gagne rien : la
demande arrive, repart, et personne ne sait pourquoi. Il doit donc être écrit sur le site.
Et il doit porter sur le **livrable**, pas sur l'outil : « je ne livre pas d'images ni de textes
générés » est défendable partout, « je n'utilise pas l'IA » ne l'est pas, y compris sur ce site.

---

## 6. Ce qui n'est pas tranché

- L'offre affichée, à arbitrer : voir `docs/INVENTAIRE-2026-08.md` §3.
- La curation du portfolio. ⚠️ La question a longtemps été mal posée : le document de juillet
  proposait de **couper** à 8 ou 12 projets, Ropat a répondu longue traîne. La mesure dit autre
  chose que les deux : le portfolio n'est pas trop gros, il est **trop petit** par rapport à ce
  qui a été livré. Le geste est d'**ajouter**, et l'ordre d'apparition remplace la coupe.
- La matière du skin clair, la grille contre l'index typographique, le curseur, le loader.
- La grammaire de composition de la planche, à refaire (voir `TODO.md`).
