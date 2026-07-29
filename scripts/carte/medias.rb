# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  PASSE 8 : LES RATIOS DECLARES CONTRE LES DIMENSIONS REELLES
# ══════════════════════════════════════════════════════════════════════════
#
# ⚠️ CETTE PASSE EXISTE PARCE QUE DEUX PROJETS MENTAIENT ET QUE RIEN NE POUVAIT
# LE VOIR. Le 29/07/2026, `chat-noir` declarait `aspect: "1158/1638"` et
# `jhag-discovery-set` `aspect: "4/5"` pour des images CARREES de 1440x1440.
# Cinq autres omettaient le champ alors que leur image n'est pas carree.
# Le defaut a ete trouve a la main ; sans cette passe il reviendrait au premier
# projet ajoute, et personne ne le saurait.
#
# Un champ ABSENT est rattrape par le defaut `1/1`, qui est parfois juste. Un
# champ FAUX ne l'est jamais : il fait reserver la mauvaise place et, surtout,
# il place la piece dans le mauvais rythme de cadrage.
#
# ── CE QUE `aspect` PILOTE VRAIMENT ───────────────────────────────────────
#   1. `width` et `height` de l'ouverture (project-main.html:188)
#   2. la valeur par defaut de CHAQUE piece de sequence sans ratio propre (:232)
#   3. le RYTHME de cadrage, calcule a partir du ratio (:247-254) :
#        r >= 1,40  pleine  |  r >= 0,80  marge  |  sinon  etroite
# Le troisieme est le plus couteux : un ratio faux ne decale pas une image, il
# la met dans la mauvaise colonne de la composition.

module Carte
  class Medias
    # Les trois seuils du calcul de rythme de `project-main.html`.
    def self.rythme(ratio)
      return "pleine" if ratio >= 1.40
      return "marge"  if ratio >= 0.80

      "etroite"
    end

    attr_reader :anomalies, :mesures

    def initialize(couverture)
      @couverture = couverture
      @anomalies  = []
      @mesures    = []
      analyser
    end

    # ── Lecture des dimensions, sans dependance ─────────────────────────────
    #
    # ⚠️ RECOUPEE CONTRE UN SECOND DECODEUR (PIL) SUR LES 17 IMAGES DU SITE AU
    # MOMENT DE l'ECRITURE : concordance exacte. Un parseur d'en-tetes maison qui
    # n'a pas ete recoupe ne vaut pas mieux qu'une supposition, et celui-ci
    # allait servir a corriger des donnees.
    def self.dimensions(chemin)
      d = File.binread(chemin, 65_536)
      case File.extname(chemin).downcase
      when ".png"
        return [d[16, 4].unpack1("N"), d[20, 4].unpack1("N")] if d[1, 3] == "PNG"
      when ".jpg", ".jpeg"
        i = 2
        while i < d.bytesize - 9
          break unless d.getbyte(i) == 0xFF

          marqueur = d.getbyte(i + 1)
          taille = d[i + 2, 2].unpack1("n")
          if (0xC0..0xCF).cover?(marqueur) && ![0xC4, 0xC8, 0xCC].include?(marqueur)
            return [d[i + 7, 2].unpack1("n"), d[i + 5, 2].unpack1("n")]
          end

          i += 2 + taille
        end
      when ".webp"
        # Trois encodages, trois entetes differents. VP8X porte les dimensions
        # sur 24 bits, moins un.
        if d[12, 4] == "VP8X"
          return [(d[24, 3] + "\0").unpack1("V") + 1, (d[27, 3] + "\0").unpack1("V") + 1]
        elsif d[12, 4] == "VP8 "
          return [d[26, 2].unpack1("v") & 0x3FFF, d[28, 2].unpack1("v") & 0x3FFF]
        elsif d[12, 4] == "VP8L"
          b = d[21, 4].unpack1("V")
          return [(b & 0x3FFF) + 1, ((b >> 14) & 0x3FFF) + 1]
        end
      when ".avif", ".heic"
        # ISOBMFF : la boite `ispe` porte largeur puis hauteur sur 32 bits,
        # apres 4 octets de version et drapeaux.
        i = d.index("ispe")
        return [d[i + 8, 4].unpack1("N"), d[i + 12, 4].unpack1("N")] if i
      when ".mp4", ".mov", ".m4v"
        return dimensions_video(chemin)
      when ".svg"
        # Un SVG n'a pas de taille intrinseque en pixels : c'est son `viewBox`
        # qui donne le rapport, et lui seul.
        t = File.read(chemin, 4096, encoding: "bom|utf-8")
        if (vb = t[/viewBox\s*=\s*["']\s*[\d.-]+\s+[\d.-]+\s+([\d.]+)\s+([\d.]+)/m, 0])
          n = vb.scan(/[\d.-]+/).map(&:to_f)
          return [n[2].round, n[3].round] if n.size >= 4 && n[3].positive?
        end
      end
      nil
    rescue StandardError
      nil
    end

    # ⚠️ UNE VIDEO NE SE LIT PAS PAR SON DEBUT. La premiere version cherchait
    # `tkhd` dans les 64 premiers kilo-octets, comme pour une image : les SEPT
    # videos du site sont ressorties « dimensions illisibles ». En MP4, la boite
    # `moov`, qui contient les pistes et donc les dimensions, est tres souvent
    # placee a la FIN du fichier, apres les donnees.
    # On parcourt donc la structure de boites au lieu de lire un prefixe : une
    # boite est [taille:4][type:4], il suffit de sauter de l'une a l'autre
    # jusqu'a `moov`. Un fichier de 18 Mo se lit ainsi en quelques lectures de
    # huit octets.
    def self.dimensions_video(chemin)
      File.open(chemin, "rb") do |io|
        taille_fichier = io.size
        position = 0

        while position < taille_fichier - 8
          io.seek(position)
          entete = io.read(8) or break

          taille = entete[0, 4].unpack1("N")
          type   = entete[4, 4]

          # `taille == 1` signale une taille etendue sur 64 bits ; `0` veut dire
          # « jusqu'a la fin du fichier ».
          if taille == 1
            taille = io.read(8).unpack1("Q>")
          elsif taille.zero?
            taille = taille_fichier - position
          end
          break if taille < 8

          if type == "moov"
            io.seek(position)
            bloc = io.read([taille, 8 * 1024 * 1024].min)
            i = bloc.index("tkhd")
            return nil unless i

            # ⚠️ LARGEUR A +80, PAS A +84. Compte depuis le type `tkhd` :
            #   +4 version et drapeaux, +4 creation, +4 modification, +4 track_ID,
            #   +4 reserve, +4 duree, +8 reserve, +2 couche, +2 groupe, +2 volume,
            #   +2 reserve, +36 matrice  =  80, puis largeur et hauteur en 16.16.
            # Mon premier jet lisait a +84 et rendait « 1080x0 » : la largeur
            # tombait sur la hauteur et la hauteur sur le vide. Un zero en
            # denominateur, et la mesure etait rejetee comme illisible plutot que
            # rapportee comme fausse, ce qui l'a rendue difficile a voir.
            # En version 1, creation, modification et duree passent a 8 octets,
            # d'ou +12.
            base = i + (bloc.getbyte(i + 4) == 1 ? 92 : 80)
            w = bloc[base, 4].unpack1("N") >> 16
            h = bloc[base + 4, 4].unpack1("N") >> 16
            return (w.positive? && h.positive? ? [w, h] : nil)
          end

          position += taille
        end
      end
      nil
    rescue StandardError
      nil
    end

    private

    def reduire(w, h)
      p = w.gcd(h)
      [w / p, h / p]
    end

    def analyser
      declares_faux = []
      manquants = []

      Carte.fichiers("_data/projects/*.yml").each do |f|
        nom = File.basename(f, ".yml")
        next if %w[index categories].include?(nom)

        projet = begin
          YAML.safe_load(Carte.lire(f), permitted_classes: [Date, Time], aliases: true)
        rescue Psych::Exception => e
          # ⚠️ UN FICHIER ILLISIBLE SE DIT, IL NE SE SAUTE PAS. Le premier jet
          # faisait un `next` muet : un YAML casse disparaissait de la passe sans
          # laisser de trace, donc la carte annoncait « rien a signaler » sur un
          # projet qu'elle n'avait pas lu. C'est exactement le mode de
          # defaillance que toute cette carte existe pour empecher.
          # Verifie en cassant reellement `stelya.yml` : la passe se taisait.
          @couverture.indetermine("yaml illisible", Carte.relatif(f), e.message[0, 70])
          next
        end
        next unless projet.is_a?(Hash)

        # L'ouverture, puis chaque piece qui declare son propre ratio.
        cibles = [[projet["main_image"], projet["aspect"], "ouverture"]]
        (Array(projet["thumbnails"]) + Array(projet.dig("case_study", "mockups"))).each do |p|
          next unless p.is_a?(Hash) && p["src"]

          cibles << [p["src"], p["aspect"], File.basename(p["src"].to_s)]
        end

        cibles.each do |src, declare, ou|
          next if src.nil? || src.to_s.empty?

          chemin = Carte.chemin(src.to_s.delete_prefix("/"))
          unless File.exist?(chemin)
            @couverture.indetermine("media introuvable", "#{nom} / #{ou}", src.to_s)
            next
          end

          dim = self.class.dimensions(chemin)
          unless dim
            @couverture.indetermine("dimensions illisibles", "#{nom} / #{ou}", File.extname(chemin))
            next
          end

          w, h = dim
          next unless h.positive?

          reel = w.to_f / h
          rw, rh = reduire(w, h)
          @mesures << { projet: nom, ou: ou, w: w, h: h, declare: declare }

          if declare.nil?
            # Le defaut `1/1` : correct pour une image carree, faux sinon.
            next if w == h
            # Une piece sans `aspect` herite de celui du projet, pas du defaut.
            next if ou != "ouverture" && projet["aspect"]

            manquants << format("**%s** / %s : %dx%d, soit %d/%d. Sans le champ, le defaut `1/1` " \
                                "s'applique, et le rythme calcule est `%s` au lieu de `%s`.",
                                nom, ou, w, h, rw, rh,
                                self.class.rythme(1.0), self.class.rythme(reel))
            next
          end

          dw, dh = declare.to_s.split("/").map { |x| x.strip.to_f }
          if dw.nil? || dh.nil? || dh.zero?
            @couverture.indetermine("aspect illisible", "#{nom} / #{ou}", declare.to_s)
            next
          end

          annonce = dw / dh
          ecart = ((annonce - reel).abs / reel * 100).round
          next if ecart < 2

          rythme_change = self.class.rythme(annonce) != self.class.rythme(reel)
          declares_faux << format("**%s** / %s : declare `%s` (%.2f), mesure %dx%d soit %d/%d " \
                                  "(%.2f). Ecart de %d %%.%s",
                                  nom, ou, declare, annonce, w, h, rw, rh, reel, ecart,
                                  rythme_change ? " ⚠️ Le rythme bascule de `#{self.class.rythme(annonce)}` a `#{self.class.rythme(reel)}`." : "")
        end
      end

      unless declares_faux.empty?
        @anomalies << {
          titre: "Ratios DECLARES qui ne correspondent pas a l'image",
          detail: "Un champ faux est pire qu'un champ absent : absent, le defaut `1/1` est " \
                  "parfois juste ; faux, il ne l'est jamais, et il place la piece dans le " \
                  "mauvais rythme de cadrage.",
          cas: declares_faux
        }
      end

      return if manquants.empty?

      @anomalies << {
        titre: "Ratios ABSENTS sur une image qui n'est pas carree",
        detail: "Le defaut `1/1` s'applique et decrit l'image faux.",
        cas: manquants
      }
    end
  end
end
