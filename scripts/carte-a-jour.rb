#!/usr/bin/env ruby
# ══════════════════════════════════════════════════════════════════════════
#  LA CARTE COMMITEE DECRIT-ELLE ENCORE LES SOURCES COMMITEES ?
# ══════════════════════════════════════════════════════════════════════════
#
#   bundle exec ruby scripts/carte-a-jour.rb
#
# Sort 0 si elle est a jour, 1 sinon, en nommant les sections qui divergent.
#
# ⚠️ IL REGENERE LA CARTE, donc il ecrase `CARTE.md` et `.carte/carte.json`, puis
# compare au contenu de HEAD. Ce n'est pas un effet de bord genant : si le verdict
# est « perimee », les fichiers regeneres sont deja les bons, il ne reste qu'a les
# commiter.
#
# ⚠️ POURQUOI PAS `carte.rb --check` : ce mode teste si une SOURCE est plus recente
# que le build lu. Avec `--build` le build vient d'etre fait, donc la reponse est
# toujours « non » et le controle serait vide. La seule question qui a du sens est
# celle-ci : ce qui est commite est-il ce qu'une generation fraiche produirait ?
#
# ⚠️ `genere_le` et `commit` sont IGNORES, et la ligne d'en-tete de `CARTE.md` est
# neutralisee. Ils changent a chaque execution par construction : la carte se genere
# forcement AVANT le commit qui l'embarque, donc elle ne peut pas le nommer. Voir
# l'en-tete de `CARTE.md` et `scripts/carte/rendu.rb`.

require "json"

JSON_CHEMIN = ".carte/carte.json"
MD_CHEMIN   = "CARTE.md"
VOLATILES   = %w[genere_le commit].freeze

# ⚠️ DEUX lignes de `CARTE.md` changent a chaque execution : l'en-tete et la date du
# build lu. J'ai d'abord neutralise la premiere seulement, et un `diff` de controle
# est passe quand meme parce que les deux generations comparees etaient tombees dans
# la MEME MINUTE. Un test qui reussit par hasard vaut un test qui echoue : verifier
# avec deux executions separees par un changement de minute.
#
# ⚠️ ET UNE TROISIEME S'EST REVELEE AU CHANGEMENT DE JOUR : la prose des verdicts
# reinserait la date du build (« Absent des 63 pages construites le 30/07 »). Elle a
# ete retiree de `scripts/carte/rendu.rb` le 31/07/2026 plutot qu'ajoutee ici : une
# date ecrite trois fois dans un fichier COMMITE le fait diverger tous les jours pour
# rien, et allonger la liste des exceptions n'aurait fait que deplacer le probleme.
# **Si une date reapparait dans la carte, la retirer a la source.**
LIGNES_VOLATILES = [
  /^> Generee le .*$/,
  /^\| Date du build lu \| .*$/,
].freeze

def neutraliser(md)
  LIGNES_VOLATILES.reduce(md) { |t, r| t.sub(r, "") }
end

# ⚠️ On compare au DISQUE, pas a `git show HEAD:`. Avec HEAD, le script melangerait
# deux questions differentes en local : « la carte est-elle perimee » et « as-tu des
# sources non commitees ». En CI les deux sont identiques (l'arbre EST HEAD), donc
# le disque donne la bonne reponse dans les deux contextes et supprime au passage
# toute dependance a git.
unless File.exist?(JSON_CHEMIN) && File.exist?(MD_CHEMIN)
  warn "Carte absente du disque. La generer d'abord : scripts/carte.rb --build"
  exit 1
end
json_avant = File.read(JSON_CHEMIN, encoding: "utf-8")
md_avant   = File.read(MD_CHEMIN, encoding: "utf-8")

unless system("bundle", "exec", "ruby", "scripts/carte.rb", "--build")
  warn "La generation a echoue : c'est elle qu'il faut regarder d'abord."
  exit 1
end

a = JSON.parse(json_avant)
b = JSON.parse(File.read(JSON_CHEMIN, encoding: "utf-8"))
VOLATILES.each { |k| a.delete(k); b.delete(k) }

md_a = neutraliser(md_avant)
md_b = neutraliser(File.read(MD_CHEMIN, encoding: "utf-8"))

structure_ok = (a == b)
rendu_ok     = (md_a == md_b)

if structure_ok && rendu_ok
  # ⚠️ ON REMET LES OCTETS D'ORIGINE. La generation vient de reecrire deux
  # horodatages identiques au sens du verdict mais differents au sens de git : sans
  # ca, un controle qui PASSE laisse l'arbre sale, et le bruit finit par etre
  # commite ou par masquer un vrai changement.
  File.write(JSON_CHEMIN, json_avant, encoding: "utf-8")
  File.write(MD_CHEMIN, md_avant, encoding: "utf-8")
  puts "Carte a jour : ce qui est commite est ce qu'une generation fraiche produit."
  exit 0
end

puts
puts "CARTE PERIMEE. Elle decrit un etat qui n'est plus celui des sources."
puts

unless structure_ok
  (a.keys | b.keys).reject { |k| a[k] == b[k] }.each do |k|
    va, vb = a[k], b[k]
    if va.is_a?(Array) && vb.is_a?(Array)
      puts "  #{k} : #{va.size} -> #{vb.size}"
      (vb - va).first(5).each { |x| puts "      + #{x.inspect[0, 110]}" }
      (va - vb).first(5).each { |x| puts "      - #{x.inspect[0, 110]}" }
    else
      puts "  #{k} : #{va.inspect[0, 90]} -> #{vb.inspect[0, 90]}"
    end
  end
end

if !rendu_ok && structure_ok
  puts "  La structure est identique, seul le RENDU differe : `scripts/carte/rendu.rb`"
  puts "  a change sans que `CARTE.md` soit regeneree."
end

puts
puts "Correction : `bundle exec ruby scripts/carte.rb --build`, puis commiter"
puts "`CARTE.md` et `.carte/carte.json`. Ils viennent d'etre regeneres par ce script."
exit 1
