# frozen_string_literal: true

# ══════════════════════════════════════════════════════════════════════════
#  LES ACTIONS QUI VISENT UN CHEMIN QUI N'EXISTE PLUS
# ══════════════════════════════════════════════════════════════════════════
#
# Constat du 12/08/2026 : `docs/PLAN-ACTIONS.md`, date du 12 mars, portait
# **89 cases non cochees et zero cochee** alors que la majeure partie etait faite,
# et visait quatorze chemins disparus (`assets/css/style.css`,
# `_data/services_old.yml`, `assets/js/matrix.js`). Dix-neuf documents cohabitent
# dans `docs/` sans aucune marque de peremption, et le seul qui se presente comme
# une liste d'actions etait integralement faux.
#
# ⚠️ LA REGLE N'EST PAS « UN DOCUMENT NOMME UN CHEMIN QUI N'EXISTE PLUS ».
# Elle serait fausse ici : ce depot CHRONIQUE ses suppressions, et `TODO.md`
# raconte a dessein des fichiers retires. Un tel controle rendrait des centaines
# de constats legitimes, donc il serait ignore, donc il serait pire qu'une note.
#
# La regle retenue est plus etroite et beaucoup plus sure :
#   **une action OUVERTE (`- [ ]`) qui vise un chemin absent est perimee.**
# Soit elle est faite et la case ment, soit sa cible a bouge. Les cases cochees
# et la prose historique ne sont pas regardees.
#
#   bundle exec ruby scripts/actions-perimees.rb
#   bundle exec ruby scripts/actions-perimees.rb --ecrire   # fige les admises
#   bundle exec ruby scripts/actions-perimees.rb --temoin
#
# ⚠️ CE CONTROLE EST LOCAL, ET IL NE PEUT PAS ETRE AUTRE CHOSE. `docs/`, `TODO.md`,
# `CLAUDE.md` et `VEILLE.md` sont gitignores : la CI ne les verra jamais. Le mettre
# dans un job serait un controle qui ne controle rien.

require "set"

RACINE    = File.expand_path("..", __dir__)
REFERENCE = File.join(RACINE, ".carte", "actions-perimees.txt")

EXCLUS = %w[_site .git .jekyll-cache node_modules vendor .carte/site _archives labo].freeze

# Un jeton n'est retenu comme chemin que s'il ressemble vraiment a un chemin du
# depot. Tout le reste est du bruit, et le bruit tue un controle.
EXTENSIONS = %w[md yml yaml html scss css js rb py sh bat ps1 json xml txt csv svg png jpg webp avif mp4 woff2 lock].freeze

def documents
  Dir.glob(File.join(RACINE, "**", "*.md"), File::FNM_DOTMATCH).reject do |f|
    rel = f.delete_prefix(RACINE + "/").tr("\\", "/")
    EXCLUS.any? { |d| rel == d || rel.start_with?("#{d}/") } || File.directory?(f)
  end.sort
end

# Les jetons entre accents graves, et eux seuls. La prose libre est trop bruyante :
# une phrase qui cite « le fichier index » n'est pas une reference verifiable.
#
# ⚠️ LA PREMIERE VERSION DE CE FILTRE RENDAIT 81 CONSTATS DONT UNE ECRASANTE
# MAJORITE DE BRUIT, et le bruit tue un controle plus surement que l'absence de
# controle. Deux causes, mesurees le 12/08/2026 :
#   - un nom NU (`script.js`, `main.css`, `_contact.scss`) etait teste a la racine
#     du depot, ou il n'est evidemment pas. Ces documents citent des chemins
#     PARTIELS, d'ou la recherche par suffixe dans `existe?`.
#   - un jeton avec des barres mais sans extension n'est presque jamais un chemin :
#     `axe/structure` est une regle webhint, `.dropdown/.select/.menu` des
#     selecteurs CSS. On exige donc une extension connue, ou un `/` final.
def chemins_dans(texte)
  texte.scan(/`([^`\n]+)`/).flatten.filter_map do |brut|
    jeton = brut.strip
    next if jeton.empty?
    next if jeton.include?("://")                  # une adresse, pas un fichier
    next unless jeton =~ %r{\A[A-Za-z0-9_./-]+\z}  # ecarte globs, variables, espaces
    next if jeton.start_with?("/")                 # une route du site
    next if jeton.start_with?("-")                 # une option de ligne de commande

    dossier = jeton.end_with?("/")
    nu      = jeton.chomp("/")
    next if nu.empty?

    # Une extension NUE n'est pas un fichier. `docs/PLAN-ACTIONS.md` ecrit
    # « convertir en `.webp` » neuf fois : neuf faux positifs si on l'accepte.
    next if !nu.include?("/") && nu.start_with?(".") && nu.count(".") == 1

    dernier      = nu.split("/").last.to_s
    a_extension  = dernier.include?(".") && EXTENSIONS.include?(dernier.split(".").last.to_s.downcase)
    next unless a_extension || dossier

    nu
  end.uniq
end

# Tous les chemins du depot, fichiers ET repertoires, pour la recherche par
# suffixe. `_site`, `.git` et les autres exclus n'en sont pas.
def index_chemins
  @index_chemins ||= Dir.glob(File.join(RACINE, "**", "*"), File::FNM_DOTMATCH).filter_map do |f|
    rel = f.delete_prefix(RACINE + "/").tr("\\", "/")
    next if rel.end_with?("/.", "/..") || rel == "." || rel == ".."
    next if rel.start_with?(".git/")
    next if EXCLUS.any? { |d| rel == d || rel.start_with?("#{d}/") }

    rel
  end
end

# ⚠️ UN CHEMIN PARTIEL COMPTE POUR EXISTANT. Ces documents ecrivent `script.js`
# pour `assets/js/script.js` et `jhag/x.mp4` pour `assets/videos/jhag/x.mp4`. Ne
# tester que le chemin exact rendrait un faux positif a chaque mention.
def existe?(jeton)
  return true if File.exist?(File.join(RACINE, jeton))

  suffixe = "/#{jeton}"
  index_chemins.any? { |p| p.end_with?(suffixe) }
end

# Un item de liste, c'est la ligne `- [ ]` PLUS son bloc indente : dans ce depot,
# les chemins vivent presque toujours dans la suite, pas dans le titre.
def actions_ouvertes(lignes)
  items = []
  i = 0
  while i < lignes.size
    ligne = lignes[i]
    unless ligne =~ /\A\s*[-*]\s+\[ \]/
      i += 1
      next
    end

    debut = i
    bloc  = [ligne]
    j = i + 1
    while j < lignes.size
      suite = lignes[j]
      break if suite =~ /\A\s*[-*]\s+\[[ xX]\]/   # un autre item
      break if suite =~ /\A#/                      # un titre
      break if suite =~ /\A\S/ && !suite.strip.empty? # retour a la colonne zero
      bloc << suite
      j += 1
    end
    items << { ligne: debut + 1, texte: bloc.join("\n") }
    i = j
  end
  items
end

def reference
  return Set.new unless File.exist?(REFERENCE)

  File.readlines(REFERENCE, encoding: "bom|utf-8").filter_map do |l|
    t = l.strip
    t unless t.empty? || t.start_with?("#")
  end.to_set
end

def releve
  trouves = []
  documents.each do |doc|
    rel = doc.delete_prefix(RACINE + "/").tr("\\", "/")
    lignes = File.read(doc, encoding: "bom|utf-8").split("\n", -1)
    actions_ouvertes(lignes).each do |item|
      chemins_dans(item[:texte]).each do |chemin|
        next if existe?(chemin)

        trouves << { doc: rel, ligne: item[:ligne], chemin: chemin }
      end
    end
  rescue StandardError => e
    warn("  (illisible : #{rel} — #{e.class})")
  end
  trouves
end

def cle(t) = "#{t[:doc]}\t#{t[:chemin]}"

# ── Entree ─────────────────────────────────────────────────────────────────
trouves = releve
admises = reference
nouvelles = trouves.reject { |t| admises.include?(cle(t)) }

if ARGV.include?("--ecrire")
  contenu = +"# Actions ouvertes visant un chemin absent, ADMISES.\n"
  contenu << "# Figees par `scripts/actions-perimees.rb --ecrire`. Une ligne vaut\n"
  contenu << "# « <document>\\t<chemin> ». Y figurer veut dire : on sait, et c'est voulu\n"
  contenu << "# (une action de CREATION, typiquement).\n#\n"
  contenu << "# ⚠️ Ce fichier est le seul endroit ou une peremption devient acceptable.\n"
  contenu << "# L'y mettre sans motif, c'est eteindre le controle.\n\n"
  trouves.map { |t| cle(t) }.uniq.sort.each { |l| contenu << l << "\n" }
  File.binwrite(REFERENCE, contenu)
  puts "Reference figee : #{trouves.map { |t| cle(t) }.uniq.size} entree(s) dans #{REFERENCE.delete_prefix(RACINE + '/')}."
  exit 0
end

# ── Le temoin : le controle sait-il voir une action perimee ? ───────────────
if ARGV.include?("--temoin")
  faux = File.join(RACINE, ".temoin-actions-perimees.md")
  File.binwrite(faux, "# Temoin\n\n- [ ] Supprimer `assets/css/ce-fichier-n-existe-pas.scss`\n")
  begin
    vu = releve.any? { |t| t[:chemin].include?("ce-fichier-n-existe-pas") }
  ensure
    File.delete(faux) if File.exist?(faux)
  end

  if vu
    puts "Temoin OK : le controle voit bien une action ouverte visant un chemin absent."
    exit 0
  end
  puts "⚠️ TEMOIN CASSE : le controle n'a pas vu une action perimee posee expres. Il ne garde rien."
  exit 1
end

puts "#{documents.size} documents lus, #{trouves.size} action(s) ouverte(s) visant un chemin absent."
puts "#{admises.size} admise(s) dans la reference." unless admises.empty?
puts

if nouvelles.empty?
  puts "Aucune action perimee non declaree."
  exit 0
end

nouvelles.group_by { |t| t[:doc] }.sort.each do |doc, ts|
  puts "#{doc}"
  ts.sort_by { |t| t[:ligne] }.each { |t| puts "  ligne #{t[:ligne]} : `#{t[:chemin]}`" }
  puts
end

puts "Soit l'action est faite et la case ment, soit sa cible a bouge."
puts "Si l'absence est normale (une action de CREATION), figer avec `--ecrire`."
exit 1
