@echo off
start cmd /k "bundle exec jekyll serve --livereload --watch"
start cmd /k "sass assets/css/main.scss assets/css/main.css --load-path=assets/css/_sass --watch"