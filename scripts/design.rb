# frozen_string_literal: true
# encoding: utf-8

# ══════════════════════════════════════════════════════════════════════════
#  DESIGN.md N'EST PLUS REDIGE : SON EN-TETE EST ENGENDRE PAR CE SCRIPT
# ══════════════════════════════════════════════════════════════════════════
#
#   bundle exec ruby scripts/design.rb            # reecrit l'en-tete
#   bundle exec ruby scripts/design.rb --diff     # dit ce qui bougerait, n'ecrit rien
#
# ── POURQUOI ──────────────────────────────────────────────────────────────
#
# DESIGN.md suit la convention Google (« design.md » : un en-tete YAML de
# jetons, puis de la prose). Il a ete ecrit a la main le 21/07/2026 et jamais
# remis a jour. Releve du 02/08, sur trois de ses declarations :
#
#   . `primary: "#FFFFFF"`      le blanc PUR a ete retire de la palette, l'encre
#                               reelle est #F0F4F1 (--ink)
#   . `heading-md: 2.25rem`     l'echelon reel plafonne a 2rem (--text-subhead)
#   . `nav: letterSpacing 3px`  soit 0,1875em, c'est-a-dire l'ANCIENNE valeur de
#                               --track-caps, ramenee a 0,10em depuis (elle
#                               faisait deborder les titres sur mobile)
#
# Aucune de ces trois derives ne se voyait. C'est le meme motif que la carte du
# depot : un document redige se perime au premier commit suivant, et il ment
# d'autant mieux qu'il a l'air precis.
#
# ── CE QUI EST ENGENDRE, ET CE QUI NE L'EST PAS ───────────────────────────
#
# ENGENDRE : l'en-tete YAML, entre les deux `---`. Ce sont des FAITS, ils
#            vivent dans `_variables.scss` et nulle part ailleurs.
# PRESERVE : tout le corps en prose. Ce sont des DECISIONS et des raisons, elles
#            ne se deduisent d'aucun fichier. Le script n'y touche jamais.
#
# ⚠️ Le corps peut donc encore mentir, et c'est assume : le script le dit dans
# l'en-tete du fichier produit plutot que de faire croire que tout est verifie.
#
# ── LE THEME LU ───────────────────────────────────────────────────────────
#
# Le bloc `:root` UNIQUEMENT, c'est-a-dire le theme sombre, qui est le defaut.
# Le bloc `[data-theme="light"]` est ignore.
#
# ⚠️ ET C'EST LE BON CHOIX, apres verification. Le corps de DESIGN.md affirme
# deux fois qu'il n'existe pas de theme clair. J'ai d'abord ecrit que c'etait
# faux, puisque `[data-theme="light"]` occupe une cinquantaine de lignes de
# `_variables.scss`. Mesure : AUCUN fichier de `assets/js/`, `_includes/`,
# `_layouts/` ni aucune page ne pose jamais l'attribut `data-theme`. Le skin
# clair est donc declare et INJOIGNABLE : du point de vue d'un visiteur, la
# prose a raison. Une branche qu'aucune donnee ne declenche n'est pas une
# branche qui existe.
# Ce qui merite d'etre su n'est donc pas « la prose ment », c'est « un jeu
# complet de jetons attend un interrupteur qui n'a jamais ete pose ».

require "json"

RACINE   = File.expand_path("..", __dir__)
VARIABLES = File.join(RACINE, "assets/css/_sass/base/_variables.scss")
CIBLE     = File.join(RACINE, "DESIGN.md")

# ══════════════════════════════════════════════════════════════════════════
#  LA CORRESPONDANCE, ET C'EST LA SEULE DECISION DE CE FICHIER
# ══════════════════════════════════════════════════════════════════════════
#
# La convention Google impose un vocabulaire fixe (primary, secondary, accent,
# neutral, surface, border, muted, success). Les jetons du depot ont leurs
# propres noms. Le pont entre les deux n'est pas un fait, c'est un choix : il est
# donc ECRIT ICI, en clair, et rappele en commentaire dans le fichier produit.
#
# ⚠️ `primary` NE SIGNIFIE PAS LA MEME CHOSE DES DEUX COTES, et c'est le piege
# de ce fichier. Cote Google, `primary` est l'encre dominante. Cote depot,
# `--primary-color` est un ALIAS DE L'ORANGE, garde pour 72 usages historiques.
# Quelqu'un qui lit l'un et ecrit l'autre se trompe de couleur. Le commentaire
# de source, dans le fichier produit, existe pour ca.
COULEURS = {
  "primary"     => "--ink",
  "secondary"   => "--ink-muted",
  "accent"      => "--accent",
  "accent-soft" => "--accent-soft",
  "neutral"     => "--p-vert-basse",
  "surface"     => "--surface-subtle",  # la surface SOULEVEE, pas --surface qui est le sol
  "border"      => "--line",
  "muted"       => "--ink-subtle",
  "success"     => "--success",
}.freeze

# Six echelons dans le depot, huit roles chez Google : deux roles (`nav` et
# `accent`) sont des COMBINAISONS de police et d'echelon, pas des echelons.
TYPO = {
  "display"    => { taille: "--text-display",  police: "--font-heading", graisse: 700 },
  "heading-lg" => { taille: "--text-title",    police: "--font-heading", graisse: 700 },
  "heading-md" => { taille: "--text-subhead",  police: "--font-heading", graisse: 700 },
  "nav"        => { taille: "--text-meta",     police: "--font-heading", graisse: 700, tracking: "--track-caps" },
  "body-lg"    => { taille: "--text-body",     police: "--font-body",    graisse: 400 },
  "body-md"    => { taille: "--text-meta",     police: "--font-body",    graisse: 400 },
  "caption"    => { taille: "--text-caption",  police: "--font-body",    graisse: 400 },
  "accent"     => { police: "--font-accent",   graisse: 400 },
}.freeze

ESPACEMENTS = %w[xs sm md lg xl 2xl 3xl 4xl 5xl 6xl].freeze
RAYONS = { "sm" => "--radius-sm", "md" => "--radius-md", "lg" => "--radius-lg",
           "xl" => "--radius-xl", "full" => "--radius-pill" }.freeze

# ══════════════════════════════════════════════════════════════════════════
#  LECTURE
# ══════════════════════════════════════════════════════════════════════════

# ⚠️ LES COMMENTAIRES SONT RETIRES AVANT TOUTE EXTRACTION, et cette ligne a une
# histoire : sur ce depot, trois outils successifs ont compte des declarations
# qui n'existaient que dans de la prose expliquant pourquoi elles avaient ete
# retirees. Sass conserve les blocs `/* */` jusque dans le CSS servi, donc
# mesurer sur l'artefact compile ne protege de rien non plus.
def sans_commentaires(source) = source.gsub(%r{/\*.*?\*/}m, "")

def bloc_racine(source)
  debut = source.index(":root")
  abort("design.rb : aucun bloc `:root` dans #{VARIABLES}") unless debut

  # On s'arrete au premier selecteur de theme : le clair n'est pas le defaut.
  fin = source.index(/^\[data-theme/, debut) || source.length
  source[debut...fin]
end

def jetons(bloc)
  bloc.scan(/^\s*(--[a-z0-9-]+)\s*:\s*([^;]+);/).to_h { |nom, valeur| [nom, valeur.strip] }
end

# ── Resolution ────────────────────────────────────────────────────────────
#
# Un jeton peut en citer un autre (`--accent: var(--p-orange)`), parfois sur
# plusieurs niveaux. On deroule jusqu'a une valeur litterale.
def resoudre(nom, table, vus = [])
  brut = table[nom]
  return nil if brut.nil?
  # Une boucle de definition ne doit pas faire tourner le script sans fin.
  return "⚠️ CYCLE" if vus.include?(nom)

  if (m = brut.match(/\Avar\((--[a-z0-9-]+)\)\z/))
    return resoudre(m[1], table, vus + [nom])
  end

  brut
end

# `color-mix(in srgb, var(--accent) 20%, transparent)` n'a pas d'equivalent
# litteral en YAML. On le rend en rgba, ce que la convention Google attend.
# ⚠️ SEUL LE MELANGE AVEC `transparent` EST TRAITE. Tout autre color-mix sort
# tel quel et se verra : mieux vaut une valeur visiblement non resolue qu'une
# valeur fausse qui a l'air juste.
def resoudre_melange(valeur, table)
  m = valeur.match(/\Acolor-mix\(in srgb,\s*var\((--[a-z0-9-]+)\)\s*(\d+)%,\s*transparent\)\z/)
  return valeur unless m

  base = resoudre(m[1], table)
  return valeur unless base&.match?(/\A#[0-9a-fA-F]{6}\z/)

  r, v, b = base[1..].scan(/../).map { |x| x.to_i(16) }
  alpha = format("%g", m[2].to_i / 100.0)
  "rgba(#{r}, #{v}, #{b}, #{alpha})"
end

# `clamp(min, fluide, max)` : la convention Google veut UNE taille. On prend le
# MAXIMUM, c'est-a-dire la valeur de grand ecran, et le corps du document le dit
# deja (« les tailles ci-dessus sont les valeurs de grand ecran »).
def resoudre_taille(valeur)
  return valeur unless valeur.start_with?("clamp(")

  # Le dernier argument de premier niveau. Une decoupe sur les virgules suffit
  # ici : aucune des trois bornes ne contient de fonction imbriquee.
  valeur[/\Aclamp\((.*)\)\z/, 1].split(",").last.strip
end

def valeur(nom, table)
  brut = resoudre(nom, table)
  return "⚠️ ABSENT #{nom}" if brut.nil?

  v = resoudre_taille(resoudre_melange(brut, table))
  # Presentation seulement : l'hexadecimal est insensible a la casse, mais
  # `--p-orange` est le seul jeton de la palette ecrit en minuscules. Sans cette
  # normalisation, `#ff5c00` contre `#FF5C00` ressort comme une divergence a
  # chaque execution, pour rien.
  v.match?(/\A#[0-9a-fA-F]{3,8}\z/) ? v.upcase : v
end

# ══════════════════════════════════════════════════════════════════════════
#  ECRITURE DE L'EN-TETE
# ══════════════════════════════════════════════════════════════════════════

# ⚠️ `version`, `name` et `description` NE SONT PAS ENGENDRES. Ce ne sont pas des
# jetons, ils ne se deduisent d'aucun fichier : ce sont des choix d'ecriture. On
# les RECUPERE dans l'en-tete existant plutot que de les recopier ici, sinon le
# script ecraserait un texte redige a chaque execution, et sa version accentuee
# ressortirait comme une divergence a chaque fois.
def metadonnees(ancien)
  defauts = {
    "version" => "alpha",
    "name" => "Ropat",
    "description" => "Portfolio de Ropat, directeur artistique et graphiste.",
  }
  defauts.to_h do |cle, defaut|
    trouve = ancien[/^#{cle}:\s*(.+)$/, 1]
    [cle, trouve&.strip.to_s.empty? ? defaut : trouve.strip]
  end
end

def entete(table, meta)
  l = []
  l << "---"
  l << "# ⚠️ CE BLOC EST ENGENDRE. Ne pas l'editer a la main : `bundle exec ruby"
  l << "# scripts/design.rb` le reecrit en entier depuis"
  l << "# `assets/css/_sass/base/_variables.scss`, theme sombre (`:root`)."
  l << "# Le CORPS en prose, lui, est ecrit a la main et n'est PAS verifie."
  l << "# Le commentaire a droite de chaque valeur donne le jeton source : les noms"
  l << "# de la convention Google et ceux du depot ne coincident pas toujours."
  l << "# `version`, `name` et `description` sont PRESERVES, pas engendres."
  l << "version: #{meta['version']}"
  l << "name: #{meta['name']}"
  l << "description: #{meta['description']}"
  l << "colors:"
  COULEURS.each { |slot, jeton| l << format("  %-12s %-34s # %s", "#{slot}:", "\"#{valeur(jeton, table)}\"", jeton) }

  l << "typography:"
  TYPO.each do |slot, spec|
    l << "  #{slot}:"
    l << format("    fontFamily: %-24s # %s", resoudre(spec[:police], table).sub(/,.*/, "").delete("'"), spec[:police])
    l << format("    fontSize: %-26s # %s", valeur(spec[:taille], table), spec[:taille]) if spec[:taille]
    l << "    fontWeight: #{spec[:graisse]}"
    l << format("    letterSpacing: %-21s # %s", valeur(spec[:tracking], table), spec[:tracking]) if spec[:tracking]
  end

  l << "spacing:"
  ESPACEMENTS.each { |k| l << format("  %-6s %-40s # --spacing-%s", "#{k}:", valeur("--spacing-#{k}", table), k) }

  l << "rounded:"
  RAYONS.each { |k, jeton| l << format("  %-6s %-40s # %s", "#{k}:", valeur(jeton, table), jeton) }

  # ⚠️ LES EXCEPTIONS SONT PUBLIEES, ET C'EST TOUT L'OBJET DE CE BLOC.
  # Ajoute le 02/08/2026. `RAYONS` ci-dessus est une liste ECRITE A LA MAIN des
  # cinq paliers : elle publiait donc l'echelle en taisant ce qui n'y est pas,
  # c'est-a-dire exactement ce qu'un document de design system ne doit pas
  # faire. Les rayons hors palier sont maintenant DEDUITS (tout `--radius-*`
  # moins les cinq paliers), donc la liste ne peut plus prendre du retard.
  # Nommer n'est pas aligner : ce bloc ne demande aucun deplacement, il rend
  # visible. Il est verrouille par `scripts/jetons-hors-echelle.rb`.
  hors_echelle = (table.keys.select { |n| n.start_with?("--radius-") } - RAYONS.values).sort
  unless hors_echelle.empty?
    l << "roundedOffScale:"
    l << "  # ⚠️ Engendre. Ces rayons servent et ne sont sur AUCUN palier de"
    l << "  # `rounded` ci-dessus. Voir _variables.scss pour la raison de chacun."
    hors_echelle.each do |n|
      l << format("  %-10s %-36s # %s", "#{n.delete_prefix('--radius-')}:", valeur(n, table), n)
    end
  end

  # ⚠️ ECRIT A LA MAIN, ET C'EST DELIBERE. Les composants ne vivent pas dans
  # `_variables.scss` mais dans `components/_buttons.scss` : les engendrer
  # demanderait de parser des regles CSS, pas des declarations de jetons. Tant
  # que ce bloc n'est pas engendre, il est signale comme tel.
  l << "components:"
  l << "  # ⚠️ Bloc NON engendre : les composants vivent dans components/_*.scss."
  l << "  button:"
  l << "    rounded: full"
  l << "    backgroundColor: accent-soft"
  l << "    textColor: primary"
  l << "    typography: nav"
  l << "    padding: 0.5rem 1.5rem"
  l << "---"
  l.join("\n")
end

# ══════════════════════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════════════════════

source = File.read(VARIABLES, encoding: "UTF-8")
table  = jetons(bloc_racine(sans_commentaires(source)))
abort("design.rb : aucun jeton lu, la lecture a echoue") if table.empty?

existant = File.read(CIBLE, encoding: "UTF-8")
# Le corps commence apres le SECOND `---`.
fin_entete = existant.index("\n---", existant.index("---") + 3)
abort("design.rb : #{CIBLE} n'a pas d'en-tete YAML delimite par deux `---`") unless fin_entete

ancien_entete = existant[0..fin_entete + 3]
corps = existant[(fin_entete + 4)..]

nouveau = entete(table, metadonnees(ancien_entete))

# ⚠️ LA COMPARAISON SE FAIT SUR DES CHEMINS COMPLETS (`typography.caption.fontSize`)
# ET NON SUR LE DERNIER SEGMENT. Premiere version de ce diff : une table indexee
# par le nom de propriete seul. Or `fontFamily`, `fontSize` et `fontWeight`
# reviennent huit fois chacun, donc `to_h` ne gardait que la DERNIERE occurrence
# et le diff annoncait trois changements au lieu de six.
# Second defaut de la meme version, plus vicieux : elle coupait les commentaires
# en excluant le caractere `#` de la valeur, ce qui excluait aussi toutes les
# couleurs hexadecimales. Les valeurs les plus importantes du fichier etaient
# donc les seules que la comparaison ne pouvait pas voir, et le rapport avait
# l'air credible.
def aplatir(entete)
  chemin = []
  entete.each_line.with_object({}) do |ligne, sortie|
    next if ligne.start_with?("---") || ligne.strip.start_with?("#") || ligne.strip.empty?

    # Le commentaire de source se coupe sur " #", jamais sur "#" seul : sinon
    # "#FFFFFF" est tronque a la premiere lettre.
    # ⚠️ `chomp` D'ABORD. Avec le saut de ligne encore la, `.*\z` ne peut pas
    # atteindre la fin de chaine (le point ne franchit pas `\n`), la coupe ne
    # se faisait jamais, et les 41 lignes ressortaient comme divergentes parce
    # qu'elles trainaient leur commentaire de source. Un diff qui signale tout
    # ne signale rien.
    utile = ligne.chomp.sub(/\s+#\s.*\z/, "").rstrip
    next if utile.strip.empty?

    profondeur = (utile[/\A */].size) / 2
    cle, valeur = utile.strip.split(":", 2)
    chemin = chemin[0...profondeur]
    chemin << cle

    v = valeur.to_s.strip.delete('"')
    sortie[chemin.join(".")] = v unless v.empty?
  end
end

if ARGV.include?("--diff")
  anciennes = aplatir(ancien_entete)
  nouvelles = aplatir(nouveau)
  ecarts = (anciennes.keys | nouvelles.keys).reject { |k| anciennes[k] == nouvelles[k] }

  if ecarts.empty?
    puts "en-tete a jour : rien a reecrire."
    exit 0
  end

  puts "L'en-tete DIVERGE de `_variables.scss`. #{ecarts.size} valeur(s) :"
  puts
  ecarts.each do |k|
    puts format("  %-32s %-28s -> %s", k, anciennes[k] || "(absent)", nouvelles[k] || "(retire)")
  end
  puts
  puts "Reecrire : bundle exec ruby scripts/design.rb"
  exit 1
end

File.write(CIBLE, nouveau + corps, encoding: "UTF-8")
puts "DESIGN.md : en-tete reecrit depuis #{File.basename(VARIABLES)} (#{table.size} jetons lus)."
puts "⚠️ Le corps en prose n'est PAS verifie : les valeurs qu'il cite dans le texte"
puts "   (blanc a 8 %, ratios de contraste, tailles) ne sont controlees par rien."
puts "   A savoir : le skin clair (`[data-theme=\"light\"]`) est declare dans le SCSS"
puts "   mais aucun code ne pose l'attribut, donc il reste injoignable."
