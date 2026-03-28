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
// CURSEUR BLOB — Desktop uniquement
// ================================
(function () {
  // Activer uniquement sur appareil avec souris précise
  if (!window.matchMedia('(pointer: fine)').matches) return;

  const blob = document.getElementById('cursor-blob');
  if (!blob) return;

  let mouseX = 0, mouseY = 0;
  let blobX = 0, blobY = 0;
  const LERP = 0.12; // Facteur de lissage (trailing)

  // Suivi de la position souris
  document.addEventListener('mousemove', e => {
    mouseX = e.clientX;
    mouseY = e.clientY;
  });

  // Boucle d'animation fluide (trailing)
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  (function animateBlob() {
    if (prefersReducedMotion) {
      // Pas de trailing si prefers-reduced-motion
      blobX = mouseX;
      blobY = mouseY;
    } else {
      blobX += (mouseX - blobX) * LERP;
      blobY += (mouseY - blobY) * LERP;
    }
    blob.style.left = blobX + 'px';
    blob.style.top  = blobY + 'px';
    requestAnimationFrame(animateBlob);
  })();

  // Gestion des états hover
  function clearCursorStates() {
    document.body.classList.remove('cursor-hover', 'cursor-text', 'cursor-zoom');
  }

  // Éléments interactifs → état hover (blob orange élargi)
  const hoverSelectors = 'a, button, [role="button"], .project-card, .service-card, .partner-logo, .lang-selector, .burger-menu, .cta, .dropdown .select, .social-link, .socialContainer, label';
  document.querySelectorAll(hoverSelectors).forEach(el => {
    el.addEventListener('mouseenter', () => { clearCursorStates(); document.body.classList.add('cursor-hover'); });
    el.addEventListener('mouseleave', clearCursorStates);
  });

  // Texte pur → état text (barre fine)
  const textSelectors = 'p, h1, h2, h3, h4, h5, li, blockquote, .section-description';
  document.querySelectorAll(textSelectors).forEach(el => {
    el.addEventListener('mouseenter', () => { clearCursorStates(); document.body.classList.add('cursor-text'); });
    el.addEventListener('mouseleave', clearCursorStates);
  });

  // Images cliquables / lightbox → état zoom (cercle + croix)
  const zoomSelectors = '.lightbox-trigger, .thumbnail-image, .zoomable';
  document.querySelectorAll(zoomSelectors).forEach(el => {
    el.addEventListener('mouseenter', () => { clearCursorStates(); document.body.classList.add('cursor-zoom'); });
    el.addEventListener('mouseleave', clearCursorStates);
  });

  // Masquer le blob quand la souris quitte la fenêtre
  document.addEventListener('mouseleave', () => { blob.style.opacity = '0'; });
  document.addEventListener('mouseenter', () => { blob.style.opacity = '1'; });
})();

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

  // ================================
  // LIGHTBOX - Image plein écran
  // ================================
  const lightbox = document.getElementById('lightbox');
  const lightboxImage = lightbox ? lightbox.querySelector('.lightbox-image') : null;
  const lightboxClose = lightbox ? lightbox.querySelector('.lightbox-close') : null;
  const lightboxTrigger = document.querySelector('.lightbox-trigger');

  if (lightbox && lightboxImage && lightboxTrigger) {
    const openLightbox = () => {
      lightboxImage.src = lightboxTrigger.src;
      lightboxImage.alt = lightboxTrigger.alt;
      lightbox.classList.add('active');
      body.style.overflow = 'hidden';
      lightboxClose.focus();
    };

    const closeLightbox = () => {
      lightbox.classList.remove('active');
      body.style.overflow = '';
      lightboxTrigger.focus();
    };

    // Ouvrir au clic sur l'image principale
    lightboxTrigger.addEventListener('click', openLightbox);

    // Ouvrir avec clavier (Enter ou Espace)
    lightboxTrigger.addEventListener('keydown', event => {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        openLightbox();
      }
    });

    // Fermer avec le bouton X
    lightboxClose.addEventListener('click', closeLightbox);

    // Fermer en cliquant sur le fond
    lightbox.addEventListener('click', event => {
      if (event.target === lightbox) {
        closeLightbox();
      }
    });

    // Fermer avec Échap
    document.addEventListener('keydown', event => {
      if (event.key === 'Escape' && lightbox.classList.contains('active')) {
        closeLightbox();
      }
    });
  }

  // ================================
  // SÉLECTEUR DE LANGUE
  // ================================
  document.addEventListener('click', event => {
    const langLink = event.target.closest('[data-set-lang]');
    if (langLink) {
      const lang = langLink.dataset.setLang;
      const expires = new Date();
      expires.setTime(expires.getTime() + 30 * 24 * 60 * 60 * 1000); // 30 jours
      document.cookie = `lang_choice=${lang};expires=${expires.toUTCString()};path=/;SameSite=Lax`;
    }
  });

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
        threshold: 0,
        rootMargin: '-20% 0px -25% 0px'
      });

      animatedBlocks.forEach(element => observer.observe(element));
    }
  }
});