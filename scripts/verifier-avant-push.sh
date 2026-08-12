#!/bin/sh
# ══════════════════════════════════════════════════════════════════════════
#  LA GARDE DE LA CI, JOUEE AVANT LE PUSH, DANS UN WORKTREE JETABLE
# ══════════════════════════════════════════════════════════════════════════
#
# Le probleme qu'il ferme, en une phrase : les gardes de ce depot tournaient
# dans l'environnement ou la reponse est deja « oui ». La machine de Ropat porte
# `.claude/`, le chantier « mise en situation » gitignore, des fiches non suivies
# et des bancs de labo ; le checkout de la CI n'en a aucun. Un controle qui passe
# en local ne prouvait donc rien sur la CI, et c'est ce qui a laisse partir une
# carte publiant une route fantome.
#
# Ce script rejoue les TROIS etapes du job `carte` de `.github/workflows/deploy.yml`
# sur un checkout de ce qui est sur le point d'etre pousse. S'il sort en 1, le
# push est refuse et le deploiement n'est jamais bloque pour cette raison.
#
# ⚠️ POURQUOI UN WORKTREE, ET PAS UNE EXECUTION SUR PLACE.
# `deploy.yml:176-179` interdit d'en faire un hook local, au motif que
# `carte.rb --build` cree et detruit `.carte/site`, ce qui tue le fil `listen`
# d'un `jekyll serve` en cours : le serveur continue alors de servir l'ancien
# HTML en silence. Cette objection tombe ici, et c'est verifie : `Carte::RACINE`
# est calcule depuis `__dir__`, donc le `.carte/site` du worktree est DANS le
# worktree. Deux serveurs tournaient pendant les essais du 12/08/2026, aucun n'a
# bronche.
#
# ⚠️ ET LE WORKTREE N'EST PAS UNE COMMODITE, C'EST LE FOND DU CORRECTIF.
# Une extraction `git archive` ne marcherait plus : depuis le 12/08/2026 la carte
# lit `git ls-files`, donc elle exige un vrai depot git. Voir `scripts/carte/socle.rb`.
#
# Usage :
#   scripts/verifier-avant-push.sh <sha>...   verifie ces commits
#   scripts/verifier-avant-push.sh --temoin   prouve que le controle sait dire
#                                             oui ET non
#   git push --no-verify                      passe outre, en connaissance de cause

set -u

RACINE=$(git rev-parse --show-toplevel) || exit 2
cd "$RACINE" || exit 2

# ── Le coeur : monter un checkout de <sha> et y jouer les trois etapes ──────
verifier_sha() {
  sha=$1
  court=$(git rev-parse --short "$sha" 2>/dev/null || echo "$sha")
  base=$(mktemp -d 2>/dev/null) || base="${TMPDIR:-/tmp}/carte-prepush-$$"
  mkdir -p "$base"
  wt="$base/wt"

  if ! git worktree add --detach --quiet "$wt" "$sha" 2>/dev/null; then
    echo "  ✗ impossible de monter un worktree sur $court"
    rm -rf "$base"
    return 2
  fi

  code=0
  for etape in "scripts/carte-a-jour.rb" "scripts/jetons-hors-echelle.rb" "scripts/jetons-hors-echelle.rb --temoin"; do
    sortie=$( cd "$wt" && bundle exec ruby $etape 2>&1 )
    if [ $? -ne 0 ]; then
      code=1
      echo "  ✗ $court : \`$etape\` sort en 1"
      echo "$sortie" | grep -v "^C:/Ruby\|^You can add\|^	from" | sed 's/^/      /'
      break
    fi
    echo "  ✓ $court : $etape"
  done

  git worktree remove --force "$wt" 2>/dev/null
  rm -rf "$base"
  git worktree prune
  return $code
}

# ── Le temoin : un controle qu'aucune erreur ne peut faire echouer n'en est ──
#    pas un. Deux cotes, parce qu'un seul ne prouverait rien : le controle doit
#    savoir dire OUI sur l'etat courant, et NON sur un etat abime expres.
temoin() {
  echo "TEMOIN, deux cotes."
  idx=$(mktemp) || return 2
  cp .git/index "$idx"
  GIT_INDEX_FILE="$idx" git add -u >/dev/null 2>&1
  tree_ok=$(GIT_INDEX_FILE="$idx" git write-tree) || return 2
  sha_ok=$(git commit-tree "$tree_ok" -p HEAD -m "temoin : etat courant") || return 2

  echo
  echo "1. L'etat courant doit PASSER."
  if ! verifier_sha "$sha_ok"; then
    echo
    echo "  ⚠️ LE TEMOIN NE PEUT PAS CONCLURE : l'etat courant echoue deja."
    echo "     Corrige-le d'abord, sinon le second cote ne prouverait rien."
    rm -f "$idx"
    return 1
  fi

  # On abime CARTE.md d'une ligne. C'est exactement ce que produit une carte
  # generee ailleurs que dans le checkout, donc le defaut qu'on veut attraper.
  blob=$( { git cat-file blob "$tree_ok:CARTE.md"; echo "TEMOIN, cette ligne n'a rien a faire ici."; } | git hash-object -w --stdin ) || return 2
  GIT_INDEX_FILE="$idx" git update-index --cacheinfo "100644,$blob,CARTE.md" || return 2
  tree_ko=$(GIT_INDEX_FILE="$idx" git write-tree) || return 2
  sha_ko=$(git commit-tree "$tree_ko" -p HEAD -m "temoin : CARTE.md abimee") || return 2
  rm -f "$idx"

  echo
  echo "2. Une CARTE.md abimee doit ECHOUER."
  if verifier_sha "$sha_ko"; then
    echo
    echo "  ⚠️ TEMOIN CASSE : le controle a laisse passer une carte abimee."
    echo "     Il ne garde rien. Ne pas s'y fier tant que ce n'est pas repare."
    return 1
  fi

  echo
  echo "TEMOIN OK : le controle dit oui sur l'etat courant, et non sur une carte abimee."
  return 0
}

# ── Entree ─────────────────────────────────────────────────────────────────
if [ "${1:-}" = "--temoin" ]; then
  temoin
  exit $?
fi

if [ $# -gt 0 ]; then
  echec=0
  for sha in "$@"; do
    verifier_sha "$sha" || echec=1
  done
  exit $echec
fi

# Sans argument : on lit le protocole de `pre-push` sur l'entree standard,
# soit des lignes « <ref locale> <sha local> <ref distante> <sha distant> ».
echec=0
vus=""
while read -r ref_locale sha_local ref_distante sha_distant; do
  [ -z "${sha_local:-}" ] && continue
  # Une suppression de branche pousse un sha tout a zero : rien a verifier.
  case "$sha_local" in
    *[!0]*) ;;
    *) continue ;;
  esac
  case " $vus " in *" $sha_local "*) continue ;; esac
  vus="$vus $sha_local"
  verifier_sha "$sha_local" || echec=1
done

if [ $echec -ne 0 ]; then
  echo
  echo "  Push refuse. Corrige, puis :"
  echo "    bundle exec ruby scripts/carte.rb --build   # et commite CARTE.md + .carte/carte.json"
  echo "  Pour passer outre en connaissance de cause : git push --no-verify"
fi
exit $echec
