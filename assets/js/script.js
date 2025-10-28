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
    const filterButtons = document.querySelectorAll('.filter-btn');
    const projectCards = document.querySelectorAll('.project-card'); // Assurez-vous que chaque carte de projet a cette classe

    filterButtons.forEach(button => {
        button.addEventListener('click', () => {
            // 1. Gérer la classe 'active' sur les boutons
            filterButtons.forEach(btn => btn.classList.remove('active'));
            button.classList.add('active');

            // 2. Récupérer la catégorie
            const filterValue = button.getAttribute('data-filter');

            // 3. Filtrer les cartes
            projectCards.forEach(card => {
                const categories = card.getAttribute('category'); // Récupère la/les catégorie(s) de la carte

                if (filterValue === 'all' || categories.includes(filterValue)) {
                    // Afficher la carte (ajuster selon votre CSS, souvent en changeant l'opacité ou le 'display')
                    card.style.display = 'block'; 
                    // Si vous utilisez des transitions CSS, vous préférerez peut-être :
                    // card.classList.remove('hidden');
                } else {
                    // Masquer la carte
                    card.style.display = 'none';
                    // Ou : card.classList.add('hidden');
                }
            });
        });
    });
});