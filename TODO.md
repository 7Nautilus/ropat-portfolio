# PROJECTS

## ✅ Migration DRY - TERMINÉE

Tous les projets ont été migrés vers le système YAML centralisé :
- ✅ A-LONE (pochette album)
- ✅ BTR (pochette EP)
- ✅ Cheetah Animation (vidéo stop-motion)
- ✅ EXIT (affiche)
- ✅ HDD DEFRAG (affiche)
- ✅ Logo Design Process (galerie)

**Nouveau système** :
- Données modulaires dans `_data/projects/<slug>.yml`
- Ordre contrôlé par `_data/projects/index.yml`
- Script d'amorçage : `scripts/new-project.ps1`
- Templates mis à jour : `_includes/project-card.html`, `_includes/project-main.html`, `_includes/schema-org.html`, `_layouts/default.html`
- Support images ET vidéos (fallbacks automatiques)
- Métadonnées SEO intégrées par langue

📖 **Voir `README.md` (section "Ajouter un nouveau projet") pour la procédure complète**

---

## Projets à ajouter

Pour ajouter un projet :
- Lancer `scripts/new-project.ps1`
- Compléter le YAML généré (FR/EN, SEO, miniatures)
- Voir `README.md` pour les étapes détaillées

- JPeJA
- Crow animation
- Poster "Outlast"
- Poster "Carti"
- Logo design process 2