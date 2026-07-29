source "https://rubygems.org"

# ⚠️ CONTRAINTE DE VERSION AJOUTEE LE 29/07/2026. `gem "jekyll"` nu laissait
# entrer une majeure suivante sans que rien ne l'annonce : le site aurait pu
# changer de comportement un matin ou personne n'a rien commite.
# `~> 4.4` accepte les correctifs et les mineures de la 4, refuse la 5.
gem "jekyll", "~> 4.4"

# ⚠️ `gem "webrick"` A ETE RETIRE. Il etait declare comme une dependance
# DIRECTE, ce qui laissait croire que le site en avait besoin pour lui-meme.
# Il n'en a besoin que pour `jekyll serve`, et jekyll le declare deja :
# `Gemfile.lock` le montre sous `jekyll (4.4.1)` en `webrick (~> 1.7)`.
# Il reste donc installe, il cesse seulement de mentir sur son role.

# Surveillance de fichiers native sous Windows, pour le `--watch` local.
gem "wdm", ">= 0.1.0" if Gem.win_platform?