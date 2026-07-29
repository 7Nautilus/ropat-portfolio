# frozen_string_literal: true

# ══════════════════════════════════════════════════════════════════════════
#  CARTE DU DEPOT
# ══════════════════════════════════════════════════════════════════════════
#
#   bundle exec ruby scripts/carte.rb            regenere CARTE.md et .carte/carte.json
#   bundle exec ruby scripts/carte.rb --diff     n'affiche QUE ce qui a bouge
#   bundle exec ruby scripts/carte.rb --check    sortie non nulle si la carte est perimee
#   bundle exec ruby scripts/carte.rb --routes   la seule table des routes
#   bundle exec ruby scripts/carte.rb --build    construit dans .carte/site d'abord
#
# ⚠️ `bundle exec` N'EST PAS UNE CONVENTION, C'EST UNE CONTRAINTE. Deux raisons,
# toutes deux mesurees sur cette machine :
#   1. `ruby` seul echoue au chargement de `json/parser.so` (la strategie de
#      controle d'application de Windows le bloque). Sous bundler, tout passe.
#   2. La carte a besoin de `require "jekyll"` AVANT de parser du Liquid : sans
#      lui, les nœuds `include` perdent silencieusement leurs parametres, et la
#      passe qui confronte parametres passes et parametres lus rend une reponse
#      vide sans se plaindre.
#
# Le script ne LIT que le depot. Il n'ecrit que `CARTE.md`, `.carte/carte.json`,
# et `.carte/site/` quand on lui passe `--build`. Il ne touche JAMAIS `_site`.

$LOAD_PATH.unshift(__dir__)

require "jekyll" # doit preceder tout parse Liquid, cf. ci-dessus
require "carte/socle"
require "carte/emis"
require "carte/routes"
require "carte/includes"
require "carte/donnees"
require "carte/css"
require "carte/js"
require "carte/assets"
require "carte/build"
require "carte/rendu"

module Carte
  SORTIE_MD   = chemin("CARTE.md")
  SORTIE_JSON = chemin(".carte", "carte.json")

  module_function

  def executer(argv)
    mode = argv.find { |a| a.start_with?("--") } || "--tout"

    construire if argv.include?("--build")

    couverture = Couverture.new
    emis = Emis.new(couverture)

    passes = { emis: emis }
    passes[:routes]   = Routes.new(couverture, emis)
    passes[:includes] = Includes.new(couverture)
    passes[:donnees]  = Donnees.new(couverture)
    passes[:css]      = Css.new(couverture, emis)
    passes[:js]       = Js.new(couverture, emis)
    passes[:assets]   = Assets.new(couverture, emis)
    passes[:build]    = Build.new(couverture)

    rendu = Rendu.new(passes, couverture)

    case mode
    when "--routes"
      passes[:routes].routes.each { |r| puts "#{r.url.ljust(46)} #{r.source}" }
      return 0
    when "--diff"
      return diff(rendu)
    when "--check"
      return emis.perime ? 2 : 0
    end

    Carte.ecrire(SORTIE_MD, rendu.markdown)
    Carte.ecrire(SORTIE_JSON, JSON.pretty_generate(rendu.json))
    puts "CARTE.md          #{File.size(SORTIE_MD)} o"
    puts ".carte/carte.json #{File.size(SORTIE_JSON)} o"
    puts "#{emis.nb_pages} pages lues, #{couverture.total} indetermine(s)"
    puts "PERIME : #{emis.perime}" if emis.perime
    emis.perime ? 2 : 0
  end

  # ⚠️ `jekyll clean` D'ABORD, ET CE N'EST PAS DE LA PRUDENCE DECORATIVE.
  # `_site` peut contenir des pages que le build ne produit plus. C'est arrive le
  # 29/07 : apres avoir exclu `labo/` et `TESTS/`, l'oracle lisait encore 65 pages
  # dont deux qui n'existaient plus. La carte affirmait alors des choses sur des
  # pages fantomes, et surtout elle comptait faux, ce qui contamine la phrase
  # « absent des N pages construites » qui est le fondement de tous ses verdicts.
  # La CI ne connait pas ce probleme (le checkout est neuf a chaque fois), donc
  # c'est un piege PUREMENT local, c'est-a-dire le plus difficile a voir.
  def construire
    dest = chemin(BUILD_PROPRE)
    puts "construction dans #{BUILD_PROPRE} ..."
    require "fileutils"
    FileUtils.rm_rf(dest)
    ok = system("bundle", "exec", "jekyll", "build", "--quiet", "-d", dest, chdir: RACINE)
    abort("le build a echoue, la carte s'arrete") unless ok
    puts "construit : #{Dir.glob(File.join(dest, "**", "*.html")).size} pages"
  end

  def diff(rendu)
    unless File.exist?(SORTIE_JSON)
      warn "aucune carte de reference (#{relatif(SORTIE_JSON)}). Lancer d'abord sans --diff."
      return 1
    end
    avant = JSON.parse(File.read(SORTIE_JSON))
    apres = rendu.json
    lignes = Rendu.diff(avant, apres)
    if lignes.empty?
      puts "aucun changement depuis la derniere carte."
      0
    else
      puts "#{lignes.size} changement(s) depuis #{avant['genere_le']} :"
      puts lignes
      0
    end
  end
end

exit(Carte.executer(ARGV)) if $PROGRAM_NAME == __FILE__
