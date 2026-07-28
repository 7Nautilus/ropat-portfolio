# frozen_string_literal: true

require_relative "socle"

# ══════════════════════════════════════════════════════════════════════════
#  PASSE 7 : LE BUILD, ET LES ENDROITS OU IL SE CONTREDIT
# ══════════════════════════════════════════════════════════════════════════
#
# Cette passe ne mesure pas du code, elle mesure des DESACCORDS entre les trois
# endroits qui decrivent le meme build : `_config.yml`, le workflow, et la tache
# locale. Ils ont divergé sans que rien ne le dise, et le cas le plus couteux
# etait invisible : la tache locale compressait le CSS, la CI non, et la tache
# locale n'etait meme pas versionnee, donc personne ne pouvait comparer.

module Carte
  class Build
    attr_reader :faits, :anomalies

    def initialize(couverture)
      @couverture = couverture
      @faits      = {}
      @anomalies  = []
      analyser
    end

    private

    def lire(f)
      chemin = Carte.chemin(f)
      File.exist?(chemin) ? Carte.lire(chemin) : nil
    end

    def analyser
      config   = lire("_config.yml")
      deploy   = lire(".github/workflows/deploy.yml")
      taches   = lire(".vscode/tasks.json")
      gemfile  = lire("Gemfile")
      lock     = lire("Gemfile.lock")
      ignore   = lire(".gitignore")

      ecarts = []

      # ── Compression du CSS ────────────────────────────────────────────────
      ci_compresse    = deploy&.include?("--style=compressed")
      local_compresse = taches&.include?("--style=compressed")
      config_compresse = config =~ /^\s*style:\s*compressed/

      css = Carte.chemin("assets/css/main.css")
      if File.exist?(css)
        brut = File.size(css)
        require "zlib"
        gz = Zlib::Deflate.deflate(Carte.lire(css), 9).bytesize
        sans = Carte.sans_commentaires_css(Carte.lire(css)).gsub(/\n\s*\n/, "\n")
        gz_sans = Zlib::Deflate.deflate(sans, 9).bytesize
        @faits[:css] = { brut: brut, gzip: gz, sans_commentaires: sans.bytesize, gzip_sans: gz_sans }
      end

      unless ci_compresse
        ecarts << {
          quoi: "Le CSS deploye n'est PAS compresse",
          ou: ".github/workflows/deploy.yml, etape dart-sass",
          pourquoi: "La tache locale porte `--style=compressed`#{local_compresse ? '' : ' (absente aussi)'}, " \
                    "la CI non. C'est donc la version commentee qui part en production."
        }
      end

      if config_compresse
        ecarts << {
          quoi: "Le bloc `sass:` de `_config.yml` est inerte",
          ou: "_config.yml",
          pourquoi: "`main.scss` n'a pas de front matter, donc Jekyll ne le compile jamais, il le COPIE. " \
                    "Le reglage n'a jamais rien fait, et il donne a lire que la compression est configuree."
        }
      end

      if config&.match?(/^\s*sass_dir:\s*_sass/) && !Dir.exist?(Carte.chemin("_sass"))
        ecarts << {
          quoi: "`sass_dir: _sass` pointe vers un repertoire inexistant",
          ou: "_config.yml",
          pourquoi: "Les partiels vivent dans `assets/css/_sass/` et sont resolus par les `@use` relatifs."
        }
      end

      # ── La negation de .gitignore ─────────────────────────────────────────
      if ignore&.match?(%r{^\.vscode/\s*$}) && ignore.include?("!.vscode/")
        ecarts << {
          quoi: "La reinclusion `!.vscode/...` de `.gitignore` est inoperante",
          ou: ".gitignore",
          pourquoi: "Git ne peut pas reinclure un fichier dont le REPERTOIRE parent est exclu. " \
                    "Il faut `.vscode/*` puis `!.vscode/tasks.json`."
        }
      end

      # ── Publication ───────────────────────────────────────────────────────
      exclus = config.to_s[/^exclude:\s*\n((?:\s+-.*\n)+)/, 1].to_s.scan(/-\s*(\S+)/).flatten
      @faits[:exclus] = exclus
      %w[labo/ TESTS/].each do |d|
        next unless Dir.exist?(Carte.chemin(d))
        next if exclus.any? { |e| e.chomp("/") == d.chomp("/") }

        ecarts << {
          quoi: "`#{d}` est publie en production",
          ou: "_config.yml (exclude)",
          pourquoi: "Rien ne l'exclut du build. Seul un `noindex` le protege, ce qui n'est pas une exclusion."
        }
      end

      # ── Epinglage ─────────────────────────────────────────────────────────
      if deploy&.include?("snap install dart-sass") && !deploy.match?(/dart-sass[^\n]*--channel|dart-sass=\d/)
        ecarts << {
          quoi: "dart-sass est installe en version flottante",
          ou: ".github/workflows/deploy.yml",
          pourquoi: "`snap install dart-sass` prend la derniere version publiee au moment du build. " \
                    "Le CSS peut changer un jour ou personne n'a rien change."
        }
      end
      if deploy&.include?("bundler-cache: false")
        ecarts << { quoi: "Aucun cache de gems en CI", ou: ".github/workflows/deploy.yml",
                    pourquoi: "`bundle install` complet a chaque push." }
      end
      if gemfile&.match?(/^gem\s+["']jekyll["']\s*$/)
        ecarts << { quoi: "`gem \"jekyll\"` sans contrainte de version", ou: "Gemfile",
                    pourquoi: "Une majeure suivante entrerait sans que rien ne l'annonce." }
      end
      if lock && !lock.include?("x86_64-linux")
        ecarts << {
          quoi: "`Gemfile.lock` ne declare pas la plateforme Linux",
          ou: "Gemfile.lock (PLATFORMS)",
          pourquoi: "D'ou le contournement `bundle lock --add-platform x86_64-linux` a chaque build."
        }
      end
      if gemfile&.include?('gem "webrick"') && lock&.match?(/jekyll \(4\..*\n(?:.*\n)*?\s+webrick/)
        ecarts << { quoi: "`webrick` declare alors que jekyll le tire deja", ou: "Gemfile",
                    pourquoi: "Redondance sans effet, mais elle laisse croire a une dependance directe." }
      end

      # ── Plugins ───────────────────────────────────────────────────────────
      @faits[:plugins_possibles] = !gemfile.to_s.include?("github-pages") &&
                                   deploy.to_s.include?("bundle exec jekyll build")

      # ── Workflows inertes ─────────────────────────────────────────────────
      Carte.fichiers(".github/workflows/*.yml").each do |f|
        contenu = Carte.lire(f)
        next unless contenu =~ /^on:\s*\n\s+workflow_call:/

        ecarts << {
          quoi: "`#{Carte.relatif(f)}` ne peut etre declenche par rien",
          ou: Carte.relatif(f),
          pourquoi: "Son seul declencheur est `workflow_call`, et aucun workflow ne l'appelle."
        }
      end

      return if ecarts.empty?

      @anomalies << {
        titre: "Desaccords entre la configuration, le workflow et la tache locale",
        detail: "Chacun decrit le meme build. Quand ils divergent, c'est toujours le workflow qui gagne.",
        cas: ecarts.map { |e| "#{e[:quoi]}\n      #{e[:ou]}\n      #{e[:pourquoi]}" }
      }
    end
  end
end
