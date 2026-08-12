# frozen_string_literal: true

# ══════════════════════════════════════════════════════════════════════════
#  CE QUE LE SITE PUBLIE REPOND VRAIMENT
# ══════════════════════════════════════════════════════════════════════════
#
# Toutes les autres gardes de ce depot lisent des FICHIERS. Celle-ci lit des
# REPONSES HTTP, et c'est la seule qui parle de la surface qu'un client voit.
#
# Elle existe a cause d'un constat du 12/08/2026 : trois fontes sous licence
# d'essai et 64 Mo de rushes clients etaient telechargeables sur ropat.art alors
# que le depot les avait retirees depuis des semaines. Le correctif existait, il
# n'etait pas deploye, et rien ne pouvait le dire.
#
#   bundle exec ruby scripts/verifier-en-ligne.rb
#   bundle exec ruby scripts/verifier-en-ligne.rb --url http://localhost:4000
#   bundle exec ruby scripts/verifier-en-ligne.rb --temoin
#
# Sortie 0 si tout concorde, 1 sinon, 2 si le controle n'a pas pu s'executer.
#
# ⚠️ LE CDN DE GITHUB PAGES PEUT SERVIR UN FICHIER SUPPRIME PENDANT QUELQUES
# INSTANTS. D'ou les tentatives espacees ci-dessous. Un echec unique juste apres
# un deploiement se rejoue avant d'etre cru.

require "net/http"
require "uri"
require "yaml"

RACINE    = File.expand_path("..", __dir__)
REFERENCE = File.join(RACINE, ".carte", "en-ligne.txt")
TENTATIVES = 3
REPOS      = 4 # secondes entre deux tentatives

def base_par_defaut
  config = YAML.load_file(File.join(RACINE, "_config.yml"))
  url = config["url"].to_s.strip
  abort("verifier-en-ligne : `url` est vide dans _config.yml.") if url.empty?
  url.chomp("/")
rescue StandardError => e
  abort("verifier-en-ligne : impossible de lire `url` dans _config.yml (#{e.message}).")
end

# Chaque ligne utile vaut « <code attendu> <chemin> ».
def lire_reference(chemin)
  abort("verifier-en-ligne : `#{chemin}` est introuvable.") unless File.exist?(chemin)

  entrees = []
  File.readlines(chemin, encoding: "bom|utf-8").each_with_index do |ligne, i|
    texte = ligne.strip
    next if texte.empty? || texte.start_with?("#")

    code, route = texte.split(/\s+/, 2)
    unless code =~ /\A\d{3}\z/ && route && !route.strip.empty?
      abort("verifier-en-ligne : ligne #{i + 1} illisible dans la reference : #{texte.inspect}")
    end
    entrees << { code: code.to_i, route: route.strip }
  end
  abort("verifier-en-ligne : la reference ne contient aucune entree.") if entrees.empty?
  entrees
end

# ⚠️ ON DEMANDE EN GET, PAS EN HEAD. Certains hebergeurs repondent 405 ou 200 a un
# HEAD la ou le GET rend 404. On ne lit pas le corps, seul le code compte.
def code_http(base, route)
  uri = URI.join(base + "/", route.sub(%r{\A/}, ""))
  reponse = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 20) do |http|
    http.request(Net::HTTP::Get.new(uri))
  end
  reponse.code.to_i
rescue StandardError => e
  "erreur : #{e.class}"
end

def controler(base, entrees, bavard: true)
  ecarts = []
  entrees.each do |e|
    obtenu = nil
    TENTATIVES.times do |n|
      obtenu = code_http(base, e[:route])
      break if obtenu == e[:code]

      sleep(REPOS) if n < TENTATIVES - 1
    end

    if obtenu == e[:code]
      puts "  ✓ #{e[:code]}  #{e[:route]}" if bavard
    else
      puts "  ✗ #{e[:route]} : attendu #{e[:code]}, obtenu #{obtenu}" if bavard
      ecarts << { route: e[:route], attendu: e[:code], obtenu: obtenu }
    end
  end
  ecarts
end

# ── Le temoin : un controle qu'aucune erreur ne peut faire echouer n'en est ──
#    pas un. On retourne l'attente d'une seule entree et on exige que le
#    controle la signale.
def temoin(base, entrees)
  cible = entrees.first
  faux  = cible[:code] == 404 ? 200 : 404
  puts "TEMOIN : on attend #{faux} sur `#{cible[:route]}`, qui repond #{cible[:code]}."
  puts

  ecarts = controler(base, [{ code: faux, route: cible[:route] }], bavard: false)
  if ecarts.empty?
    puts "⚠️ TEMOIN CASSE : le controle n'a pas vu une attente fausse. Il ne garde rien."
    exit 1
  end

  puts "Temoin OK : le controle signale bien `#{cible[:route]}` (attendu #{faux}, obtenu #{ecarts.first[:obtenu]})."
  exit 0
end

# ── Entree ─────────────────────────────────────────────────────────────────
args = ARGV.dup
base = if (i = args.index("--url"))
         args[i + 1] || abort("verifier-en-ligne : `--url` attend une adresse.")
       else
         base_par_defaut
       end
base = base.chomp("/")

entrees = lire_reference(REFERENCE)
temoin(base, entrees) if args.include?("--temoin")

puts "Verification de #{base}, #{entrees.size} entrees."
puts
ecarts = controler(base, entrees)
puts

if ecarts.empty?
  puts "Tout concorde : le site publie est celui que le depot decrit."
  exit 0
end

puts "#{ecarts.size} ecart(s) entre ce que le depot decrit et ce que le site sert."
ecarts.each do |e|
  quoi = e[:attendu] == 404 ? "devrait avoir disparu et repond encore" : "devrait repondre et ne repond pas"
  puts "  #{e[:route]} : #{quoi} (#{e[:obtenu]})"
end
puts
puts "Un 404 attendu qui rend 200 veut presque toujours dire la meme chose : le"
puts "correctif est dans le depot et le deploiement n'a pas eu lieu."
exit 1
