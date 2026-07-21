#!/usr/bin/env python3
"""Genere _data/typefaces.yml : les specimens typo des pages projet.

POURQUOI
    Le bloc « Typographie » d'une etude de cas affichait du texte vivant avec
    `font-family: '<nom de la police>'`, donc il pariait sur le fait que le
    VISITEUR ait la police du client installee. Il ne l'a jamais : sur 13
    specimens, 9 affichaient un Arial de repli sous le nom d'une autre police.
    Les 4 qui fonctionnaient etaient servis depuis des fichiers d'essai
    (« CoFo Raffine VF Trial », « FONTSPRING DEMO ») dont la licence ne couvre
    pas la diffusion web.

    On sert desormais le DESSIN des deux lettres, pas la fonte : rien a
    heberger, aucune licence a detenir, et le rendu est le meme pour tout le
    monde. Les 6 traces actuels pesent ensemble 4,8 Ko, contre 688 Ko pour le
    seul fichier CoFo Raffine.

UTILISATION
    py -m venv .venv && .venv/Scripts/pip install fonttools brotli
    .venv/Scripts/python scripts/contours-typo.py --fontes <dossier>

    <dossier> contient les fichiers de fonte que Google Fonts ne sert pas.
    Il vit HORS du depot, volontairement : ce sont des fontes clientes, on
    les convertit en contours mais on ne les versionne pas.

AJOUTER UNE POLICE
    Une entree dans SOURCES ci-dessous. La cle doit reprendre a la lettre
    pres le `name` du bloc `case_study.typography` du projet, sinon la carte
    s'affiche sans specimen (muette, mais jamais fausse).
"""

import argparse
import io
import os
import sys
import urllib.request

try:
    from fontTools.ttLib import TTFont
    from fontTools.pens.svgPathPen import SVGPathPen
    from fontTools.pens.transformPen import TransformPen
    from fontTools.pens.boundsPen import BoundsPen
    from fontTools.varLib import instancer
except ImportError:
    sys.exit(
        "fontTools est absent. Dans un venv :\n"
        "  py -m venv .venv && .venv/Scripts/pip install fonttools brotli"
    )

RACINE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CIBLE = os.path.join(RACINE, "_data", "typefaces.yml")

# Fenetre verticale commune a tous les traces, en unites de 1000/cadratin,
# ligne de base a 0. Elle est CONSTANTE par choix : un recadrage au plus juste
# ramenerait toutes les polices a la meme hauteur d'oeil, alors qu'une
# capitale haute doit rester visiblement plus haute que sa voisine.
HAUT, BAS = -800, 200
UPEM_CIBLE = 1000
LETTRES = "Aa"

UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")

# nom dans le YAML projet -> (source, poids, note)
#   source "google:<Famille>" = telechargee, sous-ensemble aux 2 glyphes
#   source "<fichier>"        = cherchee dans le dossier passe en --fontes
SOURCES = [
    ("Raleway",          "google:Raleway",    700, "Google Fonts (OFL)"),
    ("Montserrat",       "google:Montserrat", 700, "Google Fonts (OFL)"),
    ("Exo",              "google:Exo",        700, "Google Fonts (OFL)"),
    ("Anicon sans",      "ANICON SANS BLACK.OTF",            None, "fonte cliente, graisse Black"),
    ("CoFo Raffine",     "CoFoRaffine-VF-Trial.ttf",          700, "fonte cliente, VF instanciee a 700"),
    ("Resort Sans",      "Fontspring-DEMO-resort-sansregular.otf", None, "fonte cliente, graisse Regular"),
    # Manquantes, faute de fichier. Deposer la fonte dans --fontes et decommenter.
    # ("ABChannel",        "ABChannel.otf",        700, "fonte cliente"),
    # ("Joane",            "Joane.otf",            700, "fonte cliente"),
    # ("P22 Mackinac Pro", "P22Mackinac.otf",      700, "fonte cliente"),
]

ENTETE = """\
# Contours des specimens de typographie des pages projet.
# GENERE PAR scripts/contours-typo.py -- ne pas editer a la main.
#
# Le specimen sert le DESSIN des deux lettres, pas la fonte : rien a heberger,
# aucune licence a detenir, et le rendu est le meme pour tous les visiteurs.
# Avant, il declarait `font-family: '<nom>'` sur du texte vivant et pariait sur
# le fait que le visiteur ait la police du client installee.
#
# LA CLE est le `name` du bloc `case_study.typography` d'un projet, a la lettre
# pres. Une police sans entree ici n'affiche pas de specimen : la carte se
# replie sur son seul nom, ce qui est muet mais jamais faux.
#
# REPERE DE LECTURE. Traces normalises a 1000 unites par cadratin, poses sur une
# fenetre verticale CONSTANTE (viewBox de -800 a +200), ligne de base a 0. Un
# recadrage au plus juste aurait ramene toutes les polices a la meme hauteur
# d'oeil ; ici une capitale haute reste plus haute. La largeur suit la chasse
# reelle des deux lettres, d'ou des specimens plus ou moins larges.
"""


def telecharge_google(famille, poids):
    """Recupere le sous-ensemble Google Fonts reduit aux deux glyphes."""
    css_url = (f"https://fonts.googleapis.com/css2?family={famille}"
               f":wght@{poids}&text={LETTRES}&display=swap")
    req = urllib.request.Request(css_url, headers={"User-Agent": UA})
    css = urllib.request.urlopen(req, timeout=20).read().decode("utf-8")
    debut = css.index("url(") + 4
    url = css[debut:css.index(")", debut)]
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    return io.BytesIO(urllib.request.urlopen(req, timeout=20).read())


def trace(source, poids):
    f = TTFont(source, fontNumber=0)
    if "fvar" in f and poids is not None:
        axes = {a.axisTag: (a.minValue, a.maxValue) for a in f["fvar"].axes}
        if "wght" in axes:
            lo, hi = axes["wght"]
            f = instancer.instantiateVariableFont(f, {"wght": max(lo, min(hi, poids))})

    k = UPEM_CIBLE / f["head"].unitsPerEm
    gs, cmap = f.getGlyphSet(), f.getBestCmap()

    def parcourt(pen):
        x = 0.0
        for ch in LETTRES:
            nom = cmap.get(ord(ch))
            if nom is None:
                raise SystemExit(f"  !! glyphe '{ch}' absent")
            # symetrie verticale (les fontes montent, SVG descend) + chasse cumulee
            gs[nom].draw(TransformPen(pen, (k, 0, 0, -k, x, 0)))
            x += gs[nom].width * k
        return x

    plume = SVGPathPen(gs, ntos=lambda v: f"{v:.1f}".rstrip("0").rstrip("."))
    chasse = parcourt(plume)

    bp = BoundsPen(gs)
    parcourt(bp)
    # une italique tres inclinee peut deborder sa chasse : on prend le plus large
    largeur = max(chasse, bp.bounds[2] if bp.bounds else chasse)

    cap = getattr(f.get("OS/2"), "sCapHeight", 0)
    return {
        "path": plume.getCommands(),
        "viewBox": f"0 {HAUT} {largeur:.1f} {BAS - HAUT}",
        "cap": round(cap * k) if cap else None,
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--fontes", default="", help="dossier des fontes clientes")
    args = ap.parse_args()

    lignes, total, absentes = [ENTETE], 0, []
    for nom, source, poids, note in SOURCES:
        if source.startswith("google:"):
            src = telecharge_google(source.split(":", 1)[1], poids or 400)
        else:
            src = os.path.join(args.fontes, source)
            if not os.path.exists(src):
                absentes.append(f"{nom} ({source})")
                continue
        r = trace(src, poids)
        total += len(r["path"])
        lignes.append(
            '\n"%s":\n  # %s. Hauteur de capitale %s/1000.\n'
            '  viewBox: "%s"\n  path: "%s"\n'
            % (nom, note, r["cap"], r["viewBox"], r["path"])
        )

    io.open(CIBLE, "w", encoding="utf-8", newline="\n").write("".join(lignes))
    print("  %d contours, %.1f Ko de traces -> _data/typefaces.yml"
          % (len(lignes) - 1, total / 1024))
    for a in absentes:
        print("  fonte absente du dossier --fontes, specimen non genere :", a)


if __name__ == "__main__":
    main()
