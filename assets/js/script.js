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


// ================================
// FILTRAGE DES PROJETS
// ================================

document.addEventListener('DOMContentLoaded', () => {
    const projectCards = document.querySelectorAll('.project-card');
    const filterOptions = document.querySelectorAll('.dropdown .menu li');

    // Fonction pour filtrer les projets avec animation
    const filterProjects = (filterValue) => {
        projectCards.forEach((card, index) => {
            const categoriesString = card.getAttribute('data-category');
            let shouldShow = false;

            if (filterValue === 'all') {
                shouldShow = true;
            } else if (categoriesString && categoriesString.split(' ').includes(filterValue)) {
                shouldShow = true;
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
            }
        });
    };

    if (filterOptions.length > 0 && projectCards.length > 0) {
        // Initialiser les styles de transition
        projectCards.forEach(card => {
            card.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
        });

        // Ajouter l'écouteur d'événement sur chaque option du dropdown
        filterOptions.forEach(option => {
            option.addEventListener('click', () => {
                const filterValue = option.getAttribute('data-filter');
                filterProjects(filterValue);
            });
        });
    }
});


// Get all dropdown elements
const dropdowns = document.querySelectorAll('.dropdown');

dropdowns.forEach(dropdown => {
  const select = dropdown.querySelector('.select');
  const caret = dropdown.querySelector('.caret');
  const menu = dropdown.querySelector('.menu');
  const options = dropdown.querySelectorAll('.menu li');
  const selected = dropdown.querySelector('.selected');

  select.addEventListener('click', () => {
    select.classList.toggle('select-clicked');
    caret.classList.toggle('caret-rotate');
    menu.classList.toggle('menu-open');
  });

  options.forEach(option => {
    option.addEventListener('click', () => {
      selected.innerText = option.innerText;
      select.classList.remove('select-clicked');
      caret.classList.remove('caret-rotate');
      menu.classList.remove('menu-open');
      options.forEach(opt => {
        opt.classList.remove('active');
      });

      option.classList.add('active');
    });
  });
});


document.addEventListener('DOMContentLoaded', () => {
    // 1. Récupérer les éléments du DOM
    const mainImage = document.getElementById('main-image');
    const thumbnails = document.querySelectorAll('.thumbnail-item');

    // 2. Définir la fonction de changement d'image
    const changeImage = (newSrc) => {
        // Mettre à jour la source de l'image principale
        mainImage.src = newSrc;
    };

    // 3. Boucler sur toutes les miniatures pour ajouter l'écouteur d'événement
    thumbnails.forEach(thumbnail => {
        
        // Ajouter le gestionnaire au clic (ou touche Entrée/Espace)
        thumbnail.addEventListener('click', (event) => {
            // Récupérer le chemin de l'image stocké dans l'attribut data
            const fullSrc = event.currentTarget.getAttribute('data-full-src');

            // Changer l'image
            changeImage(fullSrc);

            // Gérer l'état 'actif' pour le CSS
            thumbnails.forEach(t => t.removeAttribute('data-active'));
            event.currentTarget.setAttribute('data-active', 'true');
        });
        
        // Ajouter le support clavier (si l'utilisateur navigue avec Tab)
        thumbnail.addEventListener('keydown', (event) => {
             if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault(); // Empêche le défilement de la page avec Espace
                event.currentTarget.click(); // Simule un clic
            }
        });

    });
});