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
  module_function

  # ⚠️ LIRE LE YAML, PAS UNE REGEXP, ET CE N'EST PAS UN GOUT PERSONNEL.
  # La premiere version cherchait le bloc `exclude:` par expression reguliere, ce
  # qui exigeait que CHAQUE ligne de la liste commence par un tiret. Le jour ou un
  # commentaire a ete insere au milieu de cette liste, l'extraction s'est arretee
  # la, et la carte a annonce que `labo/` etait publie en production alors qu'on
  # venait de l'exclure DANS LE MEME COMMIT.
  # Une carte qui se trompe sur le changement qu'on vient de faire est pire
  # qu'aucune carte : elle est fausse au moment precis ou on la consulte.
  # `Psych` sait lire du YAML. Il n'y a aucune raison de l'imiter a la main.
  def liste_exclue(yaml)
    return [] unless yaml

    Array(YAML.safe_load(yaml, permitted_classes: [Date, Time], aliases: true)&.fetch("exclude", nil))
  rescue Psych::Exception
    []
  end

  class Build
    attr_reader :faits, :anomalies

    def initialize(couverture)
      @couverture = couverture
      @faits      = {}
      @anomalies  = []
      analyser
    end

    private

    def liste_exclue(y) = Carte.liste_exclue(y)

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
      exclus = liste_exclue(config)
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

      # ── La derive entre les deux configurations ───────────────────────────
      #
      # `_config.dev.yml` doit redeclarer la liste d'exclusion ENTIERE, parce que
      # Jekyll remplace les tableaux au lieu de les completer. Cette duplication
      # est le prix a payer pour garder le labo accessible en local, et une
      # duplication non surveillee derive toujours. Ce controle est la surveillance.
      dev = lire("_config.dev.yml")
      if dev
        liste_dev = liste_exclue(dev)
        ecart_attendu = %w[labo/ TESTS/]
        manquants = (exclus - ecart_attendu) - liste_dev
        en_trop   = liste_dev - exclus
        if manquants.any? || en_trop.any?
          ecarts << {
            quoi: "`_config.dev.yml` a derive de `_config.yml`",
            ou: "_config.dev.yml (exclude)",
            pourquoi: "Attendu : la liste de production moins #{ecart_attendu.join(' et ')}. " \
                      "#{manquants.any? ? "Absent du dev : #{manquants.join(', ')}. " : ''}" \
                      "#{en_trop.any? ? "En trop dans le dev : #{en_trop.join(', ')}." : ''}"
          }
        end
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
