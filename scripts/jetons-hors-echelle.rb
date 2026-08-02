# frozen_string_literal: true

# ══════════════════════════════════════════════════════════════════════════
#  LES VALEURS HORS ECHELLE, ET LE FAIT QU'AUCUNE N'ARRIVE EN SILENCE
# ══════════════════════════════════════════════════════════════════════════
#
#   bundle exec ruby scripts/jetons-hors-echelle.rb            liste et compare
#   bundle exec ruby scripts/jetons-hors-echelle.rb --ecrire   fige la reference
#   bundle exec ruby scripts/jetons-hors-echelle.rb --temoin   prouve qu'il sait echouer
#
# POURQUOI CE SCRIPT EXISTE. Ropat, le 02/08/2026 : « attribuer des variables aux
# valeurs hors echelle, mais en signalant justement qu'elles le sont, cela les
# rendrait auditables et suivables ».
#
# ⚠️ CE N'EST PAS LE NOM QUI REND UNE VALEUR SUIVABLE, C'EST CE SCRIPT.
# La convention retenue nomme par le ROLE (`--radius-carte`) et dit l'ecart en
# commentaire, comme `--spacing-2xl` et `--ink-decorative` avant elle. Mais un
# nom de role reste ambigu : `--radius-carte` peut se lire comme un simple alias
# semantique, c'est-a-dire l'inverse du message. La garantie est ici : deux
# listes commitees, et une sortie non nulle des qu'une valeur apparait sans
# avoir ete declaree. Le nom peut donc rester sobre, puisque rien ne derive en
# silence.
#
# DEUX CONTROLES, ET ILS NE SE RECOUVRENT PAS :
#   A. LES JETONS hors alphabet. Les suffixes d'une echelle sont un ALPHABET
#      FERME. Un jeton de cette famille dont le suffixe est un MOT est, par
#      construction, sur aucun palier. Il doit figurer dans la reference.
#   B. LES LITTERAUX sans jeton de leur famille. Produit par la meme passe que
#      la carte (`Carte::Css.scanner`), donc une seule logique pour deux
#      lecteurs. Ils doivent figurer dans la reference.
#
# ⚠️ ON VERROUILLE L'ENSEMBLE DES VALEURS, PAS LEUR NOMBRE D'OCCURRENCES.
# La question est « quelles valeurs hors echelle ce depot porte-t-il », pas
# « combien de fois ». Une neuvieme occurrence de `0.4rem` ne fait donc pas
# echouer le controle ; un `0.45rem` inedit, si. Verrouiller les comptes rendrait
# le controle bruyant au point qu'on le desactiverait, ce qui est la seule facon
# certaine de ne rien controler du tout.
#
# ⚠️ NOMMER N'EST PAS ALIGNER (Ropat, 30/07/2026). Ce script ne demande a
# personne de deplacer un pixel. Il demande que ce qui existe soit DECLARE.
# Une entree dans la reference n'est pas une dette, c'est une decision prise.

$LOAD_PATH.unshift(__dir__)

require "carte/socle"
require "carte/css"

REFERENCE = File.join(__dir__, "..", ".carte", "hors-echelle.txt")

# Les deux seules familles qui ont une ECHELLE A PALIERS, donc les deux seules
# ou la notion de « suffixe hors alphabet » a un sens. `--squircle-*`,
# `--hairline-width` et `--signal-width` sont des familles a deux ou trois
# membres nommes par des mots : elles n'ont pas d'echelle a trahir.
ALPHABET = {
  "--spacing-" => %w[xs sm md lg xl 2xl 3xl 4xl 5xl 6xl],
  "--radius-"  => %w[sm md lg xl pill]
}.freeze

def fichiers_scss = Carte.fichiers("assets/css/**/*.scss")

# nom => { valeur: } pour tous les jetons du depot.
def relever_jetons
  jetons = {}
  fichiers_scss.each do |f|
    Carte.sans_commentaires_css(Carte.lire(f)).scan(/(--[a-zA-Z0-9_-]+)\s*:\s*([^;{}]*);/) do |nom, valeur|
      jetons[nom] ||= { valeur: valeur.strip }
    end
  end
  jetons
end

# A. Les jetons dont le suffixe n'est pas une lettre de l'alphabet de leur echelle.
def jetons_hors_alphabet(jetons)
  jetons.filter_map do |nom, j|
    prefixe = ALPHABET.keys.find { |p| nom.start_with?(p) }
    next unless prefixe
    next if ALPHABET[prefixe].include?(nom.delete_prefix(prefixe))

    "jeton     #{nom} = #{j[:valeur]}"
  end
end

# B. Les litteraux qu'aucun jeton de leur famille ne porte.
def litteraux_hors_echelle(jetons)
  _egaux, orphelins = Carte::Css.scanner(fichiers_scss, jetons)
  orphelins.keys.map { |famille, valeur| "litteral  #{famille} #{valeur}" }
end

def constat
  jetons = relever_jetons
  (jetons_hors_alphabet(jetons) + litteraux_hors_echelle(jetons)).sort
end

def reference_lue
  return [] unless File.exist?(REFERENCE)

  # ⚠️ `binread` et non `read` : sous Windows, un fichier suivi par git sort en
  # CRLF apres un `checkout` et en LF quand ce script l'ecrit. Comparer les
  # octets bruts reviendrait a comparer deux conventions, pas deux contenus.
  File.binread(REFERENCE).force_encoding("utf-8")
      .split("\n").map(&:chomp).map(&:strip)
      .reject { |l| l.empty? || l.start_with?("#") }
end

def ecrire(lignes)
  entete = <<~TXT
    # LES VALEURS HORS ECHELLE DECLAREES DE CE DEPOT.
    #
    # Engendre par `bundle exec ruby scripts/jetons-hors-echelle.rb --ecrire`.
    # Ne pas editer a la main : le script est la seule source.
    #
    # Une ligne ici veut dire « on sait, et c'est assume ». Nommer n'est pas
    # aligner : rien dans ce fichier ne demande qu'un pixel bouge.
    # Le controle verrouille l'ENSEMBLE des valeurs, pas leurs occurrences.
    #
  TXT
  File.binwrite(REFERENCE, entete + lignes.join("\n") + "\n")
end

# ── Sorties ────────────────────────────────────────────────────────────────

actuel = constat

if ARGV.include?("--ecrire")
  ecrire(actuel)
  puts "Reference figee : #{actuel.size} valeurs hors echelle declarees."
  puts REFERENCE
  exit 0
end

attendu = reference_lue

# ⚠️ UN CONTROLE QU'AUCUNE ERREUR NE PEUT FAIRE ECHOUER N'EN EST PAS UN.
# Ce depot en a deja paye un (une sonde qui rendait 0 constat des deux cotes et
# que j'ai lue comme une preuve). Le temoin retire une entree de la reference et
# exige que la comparaison la signale.
if ARGV.include?("--temoin")
  if attendu.empty?
    warn "TEMOIN IMPOSSIBLE : la reference est vide, lancer --ecrire d'abord."
    exit 2
  end
  ampute = attendu[1..]
  vu = (actuel - ampute)
  if vu.empty?
    warn "TEMOIN EN ECHEC : la reference amputee de « #{attendu.first} » n'a rien signale."
    warn "Le controle ne sait donc pas echouer, et son silence ne prouve rien."
    exit 1
  end
  puts "Temoin OK : en retirant « #{attendu.first} » de la reference, le controle signale bien #{vu.size} entree(s)."
  exit 0
end

nouvelles = actuel - attendu
parties   = attendu - actuel

if nouvelles.empty? && parties.empty?
  puts "Hors echelle : #{actuel.size} valeurs, toutes declarees."
  exit 0
end

unless nouvelles.empty?
  puts "NON DECLAREES (#{nouvelles.size}) : elles sont apparues sans passer par la reference."
  nouvelles.each { |l| puts "  + #{l}" }
end

unless parties.empty?
  puts "DISPARUES (#{parties.size}) : la reference les annonce, le depot ne les porte plus."
  parties.each { |l| puts "  - #{l}" }
end

puts
puts "Si ces valeurs sont voulues : les nommer si elles meritent un jeton, puis"
puts "  bundle exec ruby scripts/jetons-hors-echelle.rb --ecrire"
exit 1
