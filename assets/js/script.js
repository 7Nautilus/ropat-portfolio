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

// Menu burger toggle, filtrage, dropdowns et galerie projets
document.addEventListener('DOMContentLoaded', () => {
  const body = document.body;

  const burgerMenu = document.querySelector('.burger-menu');
  const navLinks = document.querySelector('.nav-links');
  if (burgerMenu && navLinks) {
    burgerMenu.addEventListener('click', () => {
      const isActive = navLinks.classList.toggle('active');
      burgerMenu.classList.toggle('active');
      burgerMenu.setAttribute('aria-expanded', String(isActive));
      body.style.overflow = isActive ? 'hidden' : '';
    });

    const navInteractiveSelectors = ['.nav-link', '.contact-link'];
    navInteractiveSelectors.forEach(selector => {
      document.querySelectorAll(selector).forEach(link => {
        link.addEventListener('click', () => {
          navLinks.classList.remove('active');
          burgerMenu.classList.remove('active');
          burgerMenu.setAttribute('aria-expanded', 'false');
          body.style.overflow = '';
        });
      });
    });

    document.addEventListener('keydown', event => {
      if (event.key === 'Escape' && navLinks.classList.contains('active')) {
        navLinks.classList.remove('active');
        burgerMenu.classList.remove('active');
        burgerMenu.setAttribute('aria-expanded', 'false');
        body.style.overflow = '';
      }
    });
  }

  const projectCards = document.querySelectorAll('.project-card');
  const filterOptions = document.querySelectorAll('.dropdown .menu li');
  if (projectCards.length && filterOptions.length) {
    projectCards.forEach(card => {
      card.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
    });

    const filterProjects = filterValue => {
      projectCards.forEach((card, index) => {
        const categoriesString = card.getAttribute('data-category') || '';
        const categories = categoriesString.split(' ');
        const shouldShow = filterValue === 'all' || categories.includes(filterValue);

        if (!shouldShow && card.style.display !== 'none') {
          card.style.opacity = '0';
          card.style.transform = 'scale(0.9)';
          setTimeout(() => {
            card.style.display = 'none';
          }, 300);
        }

        if (shouldShow && card.style.display === 'none') {
          card.style.display = 'block';
          setTimeout(() => {
            card.style.opacity = '1';
            card.style.transform = 'scale(1)';
          }, index * 50);
        }

        if (shouldShow && !card.style.display) {
          card.style.opacity = '1';
          card.style.transform = 'scale(1)';
        }
      });
    };

    filterOptions.forEach(option => {
      option.addEventListener('click', () => {
        const filterValue = option.getAttribute('data-filter') || 'all';
        filterProjects(filterValue);
      });
    });
  }

  document.querySelectorAll('.dropdown').forEach(dropdown => {
    const select = dropdown.querySelector('.select');
    const caret = dropdown.querySelector('.caret');
    const menu = dropdown.querySelector('.menu');
    const options = dropdown.querySelectorAll('.menu li');
    const selected = dropdown.querySelector('.selected');

    if (!select || !caret || !menu || !selected) {
      return;
    }

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
        options.forEach(opt => opt.classList.remove('active'));
        option.classList.add('active');
      });
    });
  });

  const mainImage = document.getElementById('main-image');
  const thumbnails = document.querySelectorAll('.thumbnail-image');
  if (mainImage && thumbnails.length) {
    const changeImage = newSrc => {
      if (mainImage.tagName.toLowerCase() === 'video') {
        mainImage.src = newSrc;
        mainImage.load();
      } else {
        mainImage.src = newSrc;
      }
    };

    thumbnails.forEach(thumbnail => {
      thumbnail.setAttribute('tabindex', '0');

      thumbnail.addEventListener('click', event => {
        const fullSrc = event.currentTarget.getAttribute('src');
        if (!fullSrc) {
          return;
        }

        changeImage(fullSrc);
        thumbnails.forEach(t => t.removeAttribute('data-active'));
        event.currentTarget.setAttribute('data-active', 'true');
      });

      thumbnail.addEventListener('keydown', event => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          thumbnail.click();
        }
      });
    });
  }

  const animatedBlocks = document.querySelectorAll('.animate-fade-up');
  if (animatedBlocks.length) {
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    if (prefersReducedMotion || !('IntersectionObserver' in window)) {
      animatedBlocks.forEach(element => element.classList.add('is-visible'));
    } else {
      const observer = new IntersectionObserver((entries, obs) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-visible');
            obs.unobserve(entry.target);
          }
        });
      }, {
        threshold: 0.2,
        rootMargin: '0px 0px -10% 0px'
      });

      animatedBlocks.forEach(element => observer.observe(element));
    }
  }
});