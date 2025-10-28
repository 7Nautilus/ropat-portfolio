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


// Filtrage des projets avec animations et compteur

document.addEventListener('DOMContentLoaded', () => {
    const filterSelect = document.getElementById('category-filter');
    const projectCards = document.querySelectorAll('.project-card');
    const projectsCount = document.getElementById('projects-count');

    // Fonction pour mettre à jour le compteur
    const updateCount = (count, total, category) => {
        if (projectsCount) {
            if (category === 'all') {
                projectsCount.textContent = `${total} projet${total > 1 ? 's' : ''}`;
            } else {
                projectsCount.textContent = `${count} projet${count > 1 ? 's' : ''}`;
            }
        }
    };

    // Fonction pour filtrer les projets avec animation
    const filterProjects = (filterValue) => {
        let visibleCount = 0;
        const total = projectCards.length;

        projectCards.forEach((card, index) => {
            const categoriesString = card.getAttribute('data-category');
            let shouldShow = false;

            if (filterValue === 'all') {
                shouldShow = true;
                visibleCount++;
            } else if (categoriesString && categoriesString.split(' ').includes(filterValue)) {
                shouldShow = true;
                visibleCount++;
            }

            // Animation de sortie
            if (!shouldShow && card.style.display !== 'none') {
                card.style.opacity = '0';
                card.style.transform = 'scale(0.9)';
                setTimeout(() => {
                    card.style.display = 'none';
                }, 300);
            }
            
            // Animation d'entrée
            if (shouldShow && card.style.display === 'none') {
                card.style.display = 'block';
                setTimeout(() => {
                    card.style.opacity = '1';
                    card.style.transform = 'scale(1)';
                }, index * 50); // Décalage progressif
            }

            if (shouldShow && !card.style.display) {
                card.style.opacity = '1';
                card.style.transform = 'scale(1)';
                visibleCount++;
            }
        });

        // Mise à jour du compteur
        updateCount(visibleCount, total, filterValue);
    };

    if (filterSelect && projectCards.length > 0) {
        // Initialiser les styles de transition
        projectCards.forEach(card => {
            card.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
        });

        // Compteur initial
        updateCount(projectCards.length, projectCards.length, 'all');

        // Écouter le changement de sélection
        filterSelect.addEventListener('change', (event) => {
            const filterValue = event.target.value;
            filterProjects(filterValue);
        });
    }
});