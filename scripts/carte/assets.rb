# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  PASSE 6 : LES ASSETS
# ══════════════════════════════════════════════════════════════════════════
#
# Trois sorties, dans l'ordre de gravite decroissante :
#
#  1. Les REFERENCES MANQUANTES. Un fichier reference qui n'existe pas est une
#     image cassee en production. C'est pire qu'un orphelin et ca passe pourtant
#     apres lui dans toutes les listes qu'on lit d'habitude.
#  2. Les OCTETS AVIDES PAR PAGE : ce qu'un visiteur telecharge sans l'avoir
#     demande. C'est le chiffre qui transforme « les videos sont lourdes » en
#     decision. Une video en `data-src` ne compte pas : elle attend d'etre vue.
#  3. Les ORPHELINS, par taille.
#
# ⚠️ LA DETECTION D'ORPHELIN SE FAIT PAR NOM DE FICHIER, donc un chemin construit
# dynamiquement lui echapperait. La carte le dit au lieu de le taire : un asset
# n'est jamais declare orphelin sans que cette reserve soit rappelee.

module Carte
  class Assets
    attr_reader :fichiers, :orphelins, :manquants, :avides, :anomalies

    def initialize(couverture, emis)
      @couverture = couverture
      @emis       = emis
      @fichiers   = {}
      @orphelins  = []
      @manquants  = []
      @avides     = {}
      @anomalies  = []
      inventorier
      confronter
      peser_les_pages
    end

    def total = @fichiers.values.sum

    private

    def inventorier
      Carte.fichiers("assets/**/*").each do |f|
        next if Carte.relatif(f).start_with?("assets/css/", "assets/js/")

        @fichiers["/" + Carte.relatif(f)] = File.size(f)
      end
    end

    # L'origine du site, pour reconnaitre ses propres URLs absolues.
    def origine
      @origine ||= begin
        cfg = Carte.chemin("_config.yml")
        File.exist?(cfg) ? Carte.lire(cfg)[/^url:\s*["']?([^"'\s]+)/, 1].to_s : ""
      end
    end

    def normaliser(ref)
      r = ref.to_s.strip
      return nil if r.empty?

      # ⚠️ UNE URL ABSOLUE VERS LE SITE LUI-MEME EST UNE REFERENCE, et la
      # rejeter a failli faire supprimer SEPT images vivantes. Les images Open
      # Graph et Twitter ne sont citees nulle part ailleurs que dans un
      # `<meta content="https://ropat.art/assets/...">` : absolues par
      # obligation, puisqu'un reseau social ne resout pas un chemin relatif.
      # La carte les rangeait donc parmi les orphelines, avec leur taille et une
      # invitation a les supprimer. Ce sont pourtant les images que voit
      # quiconque partage un lien du site.
      r = r.delete_prefix(origine) if !origine.empty? && r.start_with?(origine)
      return nil if r.start_with?("http", "//", "mailto:", "tel:", "data:", "#")

      r = r.split("#").first.to_s.split("?").first.to_s
      r = "/#{r}" unless r.start_with?("/")
      begin
        require "uri"
        URI::DEFAULT_PARSER.unescape(r)
      rescue StandardError
        r
      end
    end

    def confronter
      return unless @emis.existe?

      references = Set.new
      @emis.references.each_key do |r|
        n = normaliser(r)
        references << n if n
      end
      # Le CSS servi et le JS peuvent aussi citer un asset.
      (Carte.fichiers("assets/css/*.css") + Carte.fichiers("assets/js/*.js")).each do |f|
        Carte.lire(f).scan(%r{["'(](/assets/[^"')\s]+)}) do |(r)|
          n = normaliser(r)
          references << n if n
        end
      end

      @orphelins = @fichiers.keys.reject { |f| references.include?(f) }
                            .sort_by { |f| -@fichiers[f] }

      @manquants = references.select { |r| r.start_with?("/assets/") && !@fichiers.key?(r) }
                             .reject { |r| r.start_with?("/assets/css/", "/assets/js/") }
                             .sort

      unless @manquants.empty?
        @anomalies << {
          titre: "Assets REFERENCES qui n'existent pas",
          detail: "Chacun est une ressource cassee en production. A traiter avant tout orphelin.",
          cas: @manquants.map { |m| "#{m}   cite par #{@emis.references.keys.grep(/#{Regexp.escape(File.basename(m))}/).size} endroit(s)" }
        }
      end

      return if @orphelins.empty?

      poids = @orphelins.sum { |o| @fichiers[o] }
      @anomalies << {
        titre: "Assets qu'aucune page construite ne reference (#{ko(poids)})",
        detail: "Detection par nom de fichier : un chemin construit dynamiquement y echapperait. Verifier avant de supprimer.",
        cas: @orphelins.first(25).map { |o| "#{ko(@fichiers[o]).rjust(9)}  #{o}" }
      }
    end

    # ── Le poids avide, page par page ────────────────────────────────────────
    #
    # `data-src` et `loading="lazy"` ne comptent pas : ces ressources attendent
    # d'etre approchees. Tout le reste part au chargement.
    def peser_les_pages
      return unless @emis.existe?

      racine = Carte.dossier_build
      @emis.pages.each_key do |page|
        html = Carte.lire(File.join(racine, page))
        somme = 0
        detail = []
        html.scan(/<(img|video|source|audio)\b([^>]*)>/i) do |_balise, attrs|
          next if attrs =~ /\bdata-src\s*=/         # differe par le JS
          next if attrs =~ /loading\s*=\s*["']lazy/ # differe par le navigateur
          next if attrs =~ /preload\s*=\s*["']none/

          src = attrs[/\b(?:src|poster)\s*=\s*(["'])(.*?)\1/m, 2]
          n = normaliser(src)
          next unless n && @fichiers.key?(n)

          somme += @fichiers[n]
          detail << [n, @fichiers[n]]
        end
        @avides[page] = { octets: somme, detail: detail } if somme.positive?
      end

      lourdes = @avides.sort_by { |_, v| -v[:octets] }.first(10)
      return if lourdes.empty?

      @anomalies << {
        titre: "Pages les plus lourdes au chargement (medias non differes)",
        detail: "Ce que le visiteur telecharge sans l'avoir demande. Le CSS, le JS et les polices ne sont pas comptes.",
        cas: lourdes.map { |p, v| "#{ko(v[:octets]).rjust(9)}  #{p}   #{v[:detail].map { |(f, _)| File.basename(f) }.uniq.join(', ')}" }
      }
    end

    def ko(o)
      return "#{o} o" if o < 1024
      return format("%.1f Ko", o / 1024.0) if o < 1024 * 1024

      format("%.1f Mo", o / 1048576.0)
    end
  end
end
