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
#
# ⚠️ `platforms:` ET NON `if Gem.win_platform?`, CORRIGE LE 12/08/2026. La forme
# conditionnelle est evaluee A LA LECTURE du Gemfile : sur Windows bundler voyait
# une dependance, sur le runner Linux il n'en voyait aucune. Les deux cotes ne
# pouvaient donc PAS produire le meme `Gemfile.lock`, et la section `DEPENDENCIES`
# du lock commite annoncait `jekyll` sans contrainte, `wdm` sans plateforme et
# `webrick`, trois desaccords avec ce fichier. Le workflow lance
# `ruby/setup-ruby` avec `bundler-cache: true` dans SES DEUX JOBS, mode qui exige
# un lock complet : voir `.github/workflows/deploy.yml`, qui documente qu'il
# « echoue net » sinon.
# Avec `platforms:`, la dependance est declaree des DEUX cotes et le lock note
# a quelle plateforme elle s'applique : la resolution devient reproductible.
gem "wdm", ">= 0.1.0", platforms: [:windows]