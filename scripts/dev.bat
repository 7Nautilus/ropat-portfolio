@echo off
rem ⚠️ CE LANCEUR DIVERGEAIT DE CELUI QUI FAIT AUTORITE, `.vscode/tasks.json`.
rem Sans `--config _config.yml,_config.dev.yml`, `_config.yml` exclut `labo/` et
rem `TESTS/` (lignes 75-76, depuis le 29/07/2026) et les quinze bancs du labo
rem repondaient 404. Et sans `--no-source-map`, Sass ecrit un `main.css.map`.
start cmd /k "bundle exec jekyll serve --livereload --watch --config _config.yml,_config.dev.yml"
start cmd /k "sass assets/css/main.scss assets/css/main.css --load-path=assets/css/_sass --no-source-map --watch"