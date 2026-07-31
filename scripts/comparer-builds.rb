# frozen_string_literal: true
# encoding: utf-8

# ══════════════════════════════════════════════════════════════════════════
#  PROUVER QU'UN CHANGEMENT N'A FAIT QUE CE QU'IL ANNONCE
# ══════════════════════════════════════════════════════════════════════════
#
#   bundle exec ruby scripts/comparer-builds.rb <build_avant> <build_apres>
#
# Mode d'emploi complet :
#
#   bundle exec jekyll build --quiet -d ../avant     # AVANT de toucher au code
#   ... on fait le changement ...
#   bundle exec jekyll build --quiet -d ../apres
#   bundle exec ruby scripts/comparer-builds.rb ../avant ../apres
#
# ⚠️ CET OUTIL EST LA RAISON POUR LAQUELLE LES COMMITS DU CHANTIER DE JUILLET
# 2026 PEUVENT DIRE « rien n'a change » SANS QUE CE SOIT UNE FIGURE DE STYLE.
# Il a d'abord vecu dans un dossier temporaire, ce qui rendait chacune de ces
# preuves irreproductible : le chantier entier reposait sur des mesures que
# personne d'autre ne pouvait refaire. Il est donc dans le depot.
#
# ── TROIS CONTROLES, DU PLUS FORT AU PLUS FAIBLE ──────────────────────────
#
#   1. CHEMINS      les memes fichiers sont-ils produits ? Aucune URL creee ni
#                   perdue. C'est le controle qui compte pour le referencement.
#   2. OCTETS       combien de fichiers sont identiques au bit pres, apres
#                   normalisation de ce qui bouge a chaque build.
#   3. SEMANTIQUE   pour ceux qui restent : memes balises, memes attributs,
#                   meme texte ? Si oui, seuls les blancs different, ce qui ne
#                   change rien au rendu.
#
# Un changement « inerte » doit passer les trois. Un changement voulu doit
# echouer au troisieme sur EXACTEMENT les pages visees, et nulle part ailleurs.

require "digest"
require "set"

# ── Les trois normalisations, toutes trouvees a la dure ───────────────────
#
# Sans elles, deux builds du meme commit sont declares differents et l'outil ne
# sert a rien.
#
#   `?v=1234567890`         jeton de version pose sur main.css et les scripts
#   <lastmod>...</lastmod>  horodatage du sitemap
#   "dateModified": "..."   le Schema.org de CHAQUE page
#
# ⚠️ Le troisieme a coute une fausse alerte complete : un premier releve a
# annonce que les 66 pages avaient change alors qu'on venait de retirer un bloc
# de configuration INERTE. Une seule ligne differait par page, et c'etait
# celle-la. Au passage, c'est un defaut du site : chaque page declare avoir ete
# modifiee a chaque deploiement, ce qui prive `dateModified` de tout sens.
def normaliser(texte)
  texte.gsub(/\?v=\d+/, "?v=FIGE")
       .gsub(%r{<lastmod>[^<]*</lastmod>}, "<lastmod>FIGE</lastmod>")
       .gsub(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}/, "FIGE")
end

def lire(chemin)
  brut = File.binread(chemin)
  return brut unless chemin =~ /\.(html|xml|txt|css|js)\z/i

  normaliser(brut.force_encoding("UTF-8").scrub("?"))
end

# La suite des balises avec leurs attributs, dans l'ordre. Deux pages qui ont la
# meme suite ont la meme structure ET les memes liens ; seuls les blancs entre
# balises peuvent differer.
def balises(html) = html.scan(/<[^>]+>/).map { |b| b.gsub(/\s+/, " ").strip }

# Le texte hors balises, espaces reduits.
#
# ⚠️ LE CONTENU DES `<script>` EST RETIRE, donc cet outil ne voit pas un
# changement de JS EN LIGNE. C'est un angle mort assume : le comparer
# demanderait de normaliser du code, pas du texte. Quand on touche a un script
# inline, il faut regarder le diff a la main.
def texte(html)
  html.gsub(%r{<script\b.*?</script>}m, " ")
      .gsub(%r{<style\b.*?</style>}m, " ")
      .gsub(/<[^>]+>/, " ")
      .gsub(/\s+/, " ")
      .strip
end

avant, apres = ARGV[0], ARGV[1]
abort("usage: comparer-builds.rb <build_avant> <build_apres>") unless avant && apres

# ⚠️ SOUS WINDOWS, `Dir.glob` TRAITE L'ANTISLASH COMME UN ECHAPPEMENT et non
# comme un separateur. Une racine donnee sous sa forme naturelle (`C:\...\avant`)
# ne fait donc correspondre AUCUN fichier, et l'outil repondait alors :
#
#   0 fichiers, identiques : aucune URL creee ni perdue.
#   DIFFERENCES REELLES    : 0
#
# ... avec un code de sortie 0. Un vert qu'AUCUN changement n'aurait pu rendre
# rouge, produit par l'outil meme dont c'est la seule raison d'exister. Releve le
# 31/07/2026, en s'en servant.
#
# `File::ALT_SEPARATOR` vaut "\\" sous Windows et nil ailleurs : un antislash
# dans un nom de fichier Unix, ou il est un caractere legal, reste donc intact.
sous_forme_glob = ->(r) { File::ALT_SEPARATOR ? r.tr(File::ALT_SEPARATOR, "/") : r }
avant, apres = sous_forme_glob.call(avant), sous_forme_glob.call(apres)

lister = lambda do |racine|
  Dir.glob(File.join(racine, "**", "*")).select { |f| File.file?(f) }
     .map { |f| f.delete_prefix(racine.chomp("/") + "/").tr("\\", "/") }.sort
end

fa, fb = lister.call(avant), lister.call(apres)

# ⚠️ LE GARDE. La normalisation ci-dessus ferme le cas connu ; celui-ci ferme
# tous les autres, y compris ceux qu'on n'a pas encore rencontres : un build
# jamais lance, un dossier deja nettoye, un chemin mal recopie. Une racine vide
# n'est pas une comparaison reussie, c'est une comparaison qui n'a pas eu lieu.
[[avant, fa], [apres, fb]].each do |racine, fichiers|
  next unless fichiers.empty?

  abort("#{racine} : aucun fichier. Build absent, deja supprime, ou chemin errone.\n" \
        "Rien n'a ete compare, et surtout : rien n'a ete prouve.")
end

puts "═══ 1. CHEMINS ═══"
perdus = fa - fb
crees  = fb - fa
if perdus.empty? && crees.empty?
  puts "  #{fa.size} fichiers, identiques : aucune URL creee ni perdue."
else
  perdus.each { |f| puts "  - PERDU : #{f}" }
  crees.each  { |f| puts "  + CREE  : #{f}" }
end

puts
puts "═══ 2. OCTETS ET 3. SEMANTIQUE ═══"
identiques = 0
blancs = []
reels = []

(fa & fb).each do |rel|
  a = lire(File.join(avant, rel))
  b = lire(File.join(apres, rel))

  if a == b
    identiques += 1
    next
  end

  # Le sitemap : son ORDRE n'est pas stable (il depend du parcours du systeme de
  # fichiers), mais son ENSEMBLE d'URLs doit l'etre. C'est la seule chose qui
  # compte pour un moteur.
  if rel.end_with?(".xml")
    ua = a.scan(%r{<loc>([^<]*)</loc>}).flatten.sort
    ub = b.scan(%r{<loc>([^<]*)</loc>}).flatten.sort
    if !ua.empty? && ua == ub
      blancs << "#{rel} : #{ua.size} URLs identiques, ordre different"
    else
      reels << "#{rel} : #{(ua - ub).size} URL(s) perdue(s), #{(ub - ua).size} gagnee(s)"
    end
    next
  end

  unless rel.end_with?(".html")
    reels << "#{rel} : contenu different (fichier non HTML, comparaison brute)"
    next
  end

  if balises(a) == balises(b) && texte(a) == texte(b)
    blancs << "#{rel} : memes balises, meme texte, blancs differents"
  else
    d = balises(a).zip(balises(b)).find { |x, y| x != y }
    reels << "#{rel} : STRUCTURE differente\n      avant = #{d&.first.inspect}\n      apres = #{d&.last.inspect}"
  end
end

puts "  identiques au bit pres     : #{identiques}"
puts "  identiques aux blancs pres : #{blancs.size}"
blancs.each { |x| puts "      #{x}" }
puts "  DIFFERENCES REELLES        : #{reels.size}"
reels.each { |x| puts "      #{x}" }

exit(reels.empty? && perdus.empty? && crees.empty? ? 0 : 1)
