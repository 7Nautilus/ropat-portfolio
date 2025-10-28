// ================================
// OPTIMISATIONS & PERFORMANCES
// ================================

// Utilisation de la délégation d'événements
// Débounce pour les événements répétitifs
const debounce = (func, wait) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};

// ================================
// PAGE LOADER
// ================================
window.addEventListener('load', () => {
  const loader = document.getElementById('pageLoader');
  if (loader) {
    setTimeout(() => {
      loader.classList.add('loaded');
      // Retirer du DOM après la transition
      setTimeout(() => {
        loader.remove();
      }, 500);
    }, 800);
  }
});

// Menu burger toggle
document.addEventListener('DOMContentLoaded', function() {
  const burgerMenu = document.querySelector('.burger-menu');
  const navLinks = document.querySelector('.nav-links');
  const body = document.body;

  // Toggle du menu
  burgerMenu.addEventListener('click', function() {
    const isActive = navLinks.classList.toggle('active');
    burgerMenu.classList.toggle('active');
    burgerMenu.setAttribute('aria-expanded', isActive);
    
    // Empêcher le scroll quand le menu est ouvert
    if (isActive) {
      body.style.overflow = 'hidden';
    } else {
      body.style.overflow = '';
    }
  });

  // Fermer le menu en cliquant sur un lien
  const links = document.querySelectorAll('.nav-link, .contact-link');
  links.forEach(link => {
    link.addEventListener('click', function() {
      navLinks.classList.remove('active');
      burgerMenu.classList.remove('active');
      burgerMenu.setAttribute('aria-expanded', 'false');
      body.style.overflow = '';
    });
  });

  // Fermer le menu avec la touche Échap
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && navLinks.classList.contains('active')) {
      navLinks.classList.remove('active');
      burgerMenu.classList.remove('active');
      burgerMenu.setAttribute('aria-expanded', 'false');
      body.style.overflow = '';
    }
  });
});


// Filtrage des projets

document.addEventListener('DOMContentLoaded', () => {
    // Cibler l'élément SELECT par son ID
    const filterSelect = document.getElementById('category-filter');
    const projectCards = document.querySelectorAll('.project-card');

    if (filterSelect) {
        // Écouter le changement de sélection (l'événement 'change')
        filterSelect.addEventListener('change', (event) => {
            // La valeur du filtre est la valeur de l'option sélectionnée
            const filterValue = event.target.value; 

            // Parcourir et filtrer les cartes de projet
            projectCards.forEach(card => {
                // Récupère la chaîne de catégories (ex: "music branding")
                const categoriesString = card.getAttribute('data-category'); 

                // Si 'all' est sélectionné, on affiche tout.
                if (filterValue === 'all') {
                    card.style.display = 'block';
                    return; // Passe à la carte suivante
                }

                // Pour les filtres spécifiques:
                // Vérifie si la chaîne de catégories existe et contient le filtre actif.
                if (categoriesString && categoriesString.split(' ').includes(filterValue)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    }
    // Si l'élément filterSelect n'existe pas, rien ne se passe, ce qui est robuste.
});