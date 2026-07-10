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

  function bindCursorState(selectors, stateClass) {
    document.querySelectorAll(selectors).forEach(el => {
      el.addEventListener('mouseenter', () => { clearCursorStates(); document.body.classList.add(stateClass); });
      el.addEventListener('mouseleave', clearCursorStates);
    });
  }

  // Éléments interactifs → état hover (blob orange élargi)
  bindCursorState('a, button, [role="button"], .project-card, .service-card, .partner-logo, .lang-selector, .burger-menu, .btn, .dropdown .select, .social-link, .socialContainer, label', 'cursor-hover');

  // Texte pur → état text (barre fine)
  bindCursorState('p, h1, h2, h3, h4, h5, li, blockquote, .section-description', 'cursor-text');

  // Images cliquables / lightbox → état zoom (cercle + croix)
  bindCursorState('.lightbox-trigger, .thumbnail-image, .zoomable', 'cursor-zoom');

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

// ================================
// DROPDOWN — controleur unique
// ================================
// Un seul comportement pour tous les dropdowns du site (filtre du portfolio,
// sujet du formulaire de contact). Les elements sont trouves par
// [data-dropdown-trigger] et leur menu par aria-controls : aucune dependance
// aux classes CSS, donc les deux habillages partagent le meme code.
//
// L'etat ouvert/ferme est porte par aria-expanded sur le declencheur ; le CSS
// s'y accroche. Le JS ne manipule aucune classe de presentation.
//
// Chaque selection emet un CustomEvent 'dropdown:change' { value, label }.
function initDropdowns(root) {
  (root || document).querySelectorAll('[data-dropdown-trigger]').forEach(trigger => {
    const menu = document.getElementById(trigger.getAttribute('aria-controls'));
    if (!menu) return;

    const options = Array.from(menu.querySelectorAll('[data-dropdown-option]'));
    const label = trigger.querySelector('[data-dropdown-selected]');
    if (!options.length || !label) return;

    const isOpen = () => trigger.getAttribute('aria-expanded') === 'true';

    const open = index => {
      trigger.setAttribute('aria-expanded', 'true');
      // Le menu du filtre est `visibility: hidden` tant qu'il est ferme, et un
      // element invisible n'est pas focalisable. On force le recalcul de style
      // avant de deplacer le focus : sans cela, la premiere ouverture au clavier
      // ne focalise aucune option.
      void menu.offsetHeight;
      // Si rien n'est selectionne, on focalise la premiere option.
      const selectedIndex = options.findIndex(o => o.getAttribute('aria-selected') === 'true');
      const target = typeof index === 'number' ? index : Math.max(selectedIndex, 0);
      options[target].focus();
    };

    const close = (focusTrigger = true) => {
      trigger.setAttribute('aria-expanded', 'false');
      if (focusTrigger) trigger.focus();
    };

    const select = option => {
      options.forEach(o => {
        o.setAttribute('aria-selected', 'false');
        o.classList.remove('active');
      });
      option.setAttribute('aria-selected', 'true');
      option.classList.add('active');
      label.textContent = option.textContent.trim();
      label.removeAttribute('data-empty');
      trigger.classList.remove('is-invalid');
      trigger.dispatchEvent(new CustomEvent('dropdown:change', {
        bubbles: true,
        detail: { value: option.getAttribute('data-value'), label: label.textContent }
      }));
      close();
    };

    trigger.addEventListener('click', () => (isOpen() ? close() : open()));

    trigger.addEventListener('keydown', event => {
      if (event.key === 'Enter' || event.key === ' ' || event.key === 'ArrowDown') {
        event.preventDefault();
        open();
      } else if (event.key === 'ArrowUp') {
        event.preventDefault();
        open(options.length - 1);
      } else if (event.key === 'Escape' && isOpen()) {
        close();
      }
    });

    options.forEach((option, i) => {
      option.addEventListener('click', () => select(option));
      option.addEventListener('keydown', event => {
        switch (event.key) {
          case 'Enter':
          case ' ':
            event.preventDefault(); select(option); break;
          case 'ArrowDown':
            event.preventDefault(); options[(i + 1) % options.length].focus(); break;
          case 'ArrowUp':
            event.preventDefault(); options[(i - 1 + options.length) % options.length].focus(); break;
          case 'Home':
            event.preventDefault(); options[0].focus(); break;
          case 'End':
            event.preventDefault(); options[options.length - 1].focus(); break;
          case 'Escape':
            event.preventDefault(); close(); break;
          case 'Tab':
            close(false); break;
        }
      });
    });

    document.addEventListener('click', event => {
      if (isOpen() && !trigger.contains(event.target) && !menu.contains(event.target)) {
        close(false);
      }
    });
  });
}

// Menu burger toggle, filtrage, dropdowns et galerie projets
document.addEventListener('DOMContentLoaded', () => {
  const body = document.body;

  const burgerMenu = document.querySelector('.burger-menu');
  const navLinks = document.querySelector('.nav-links');
  if (burgerMenu && navLinks) {
    const closeMenu = () => {
      navLinks.classList.remove('active');
      burgerMenu.classList.remove('active');
      burgerMenu.setAttribute('aria-expanded', 'false');
      body.style.overflow = '';
    };

    burgerMenu.addEventListener('click', () => {
      const isActive = navLinks.classList.toggle('active');
      burgerMenu.classList.toggle('active');
      burgerMenu.setAttribute('aria-expanded', String(isActive));
      body.style.overflow = isActive ? 'hidden' : '';
    });

    const navInteractiveSelectors = ['.nav-link', '.contact-link'];
    navInteractiveSelectors.forEach(selector => {
      document.querySelectorAll(selector).forEach(link => {
        link.addEventListener('click', closeMenu);
      });
    });

    document.addEventListener('keydown', event => {
      if (event.key === 'Escape' && navLinks.classList.contains('active')) {
        closeMenu();
      }
    });
  }

  const projectCards = document.querySelectorAll('.project-card');
  const filterTrigger = document.getElementById('portfolio-filter-btn');
  if (projectCards.length && filterTrigger) {
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

    filterTrigger.addEventListener('dropdown:change', e => filterProjects(e.detail.value));
  }

  initDropdowns();

  const mainImage = document.getElementById('main-image');
  const mainVideo = document.getElementById('main-video');
  // Supporte les <button class="thumbnail-btn"> (nouveau) et les <img class="thumbnail-image"> (legacy)
  const thumbnailBtns = document.querySelectorAll('.thumbnail-btn');
  const thumbnailImgs = document.querySelectorAll('.thumbnail-image');
  const thumbnails = thumbnailBtns.length ? thumbnailBtns : thumbnailImgs;

  if (mainImage && thumbnails.length) {
    const changeMedia = btn => {
      const mediaType = btn.getAttribute('data-media-type') || 'image';
      const fullSrc = btn.getAttribute('data-full-src');
      const previewImg = btn.querySelector('img');
      const src = fullSrc || (previewImg ? previewImg.getAttribute('src') : null);
      if (!src) return;

      if (mediaType === 'video' && mainVideo) {
        // Médias mixtes : afficher la vidéo, masquer l'image
        mainImage.style.display = 'none';
        mainImage.setAttribute('aria-hidden', 'true');
        mainVideo.src = src;
        mainVideo.load();
        mainVideo.style.display = '';
        mainVideo.removeAttribute('aria-hidden');
      } else if (mediaType === 'image' && mainVideo) {
        // Médias mixtes : afficher l'image, masquer la vidéo
        mainVideo.style.display = 'none';
        mainVideo.setAttribute('aria-hidden', 'true');
        mainImage.src = src;
        mainImage.style.display = '';
        mainImage.removeAttribute('aria-hidden');
      } else {
        // Comportement legacy (projet tout-image ou tout-vidéo)
        if (mainImage.tagName.toLowerCase() === 'video') {
          mainImage.src = src;
          mainImage.load();
        } else {
          mainImage.src = src;
        }
      }
    };

    thumbnails.forEach(thumb => {
      thumb.addEventListener('click', event => {
        const btn = event.currentTarget;
        changeMedia(btn);

        thumbnails.forEach(t => {
          t.removeAttribute('data-active');
          const tImg = t.querySelector('img');
          if (tImg) tImg.removeAttribute('data-active');
        });
        btn.setAttribute('data-active', 'true');
        const btnImg = btn.querySelector('img');
        if (btnImg) btnImg.setAttribute('data-active', 'true');
      });
    });
  }

  // ================================
  // LIGHTBOX - Image plein écran
  // ================================
  const lightbox = document.getElementById('lightbox');
  const lightboxImage = lightbox ? lightbox.querySelector('.lightbox-image') : null;
  const lightboxClose = lightbox ? lightbox.querySelector('.lightbox-close') : null;
  const lightboxTriggers = lightbox ? document.querySelectorAll('.lightbox-trigger') : [];
  let activeLightboxTrigger = null;

  if (lightbox && lightboxImage && lightboxTriggers.length > 0) {
    const openLightbox = (trigger) => {
      activeLightboxTrigger = trigger;
      lightboxImage.src = trigger.src;
      lightboxImage.alt = trigger.alt;
      lightbox.classList.add('active');
      body.style.overflow = 'hidden';
      lightboxClose.focus();
    };

    const closeLightbox = () => {
      lightbox.classList.remove('active');
      body.style.overflow = '';
      if (activeLightboxTrigger) activeLightboxTrigger.focus();
    };

    lightboxTriggers.forEach(trigger => {
      trigger.addEventListener('click', () => openLightbox(trigger));
      trigger.addEventListener('keydown', event => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          openLightbox(trigger);
        }
      });
    });

    lightboxClose.addEventListener('click', closeLightbox);

    lightbox.addEventListener('click', event => {
      if (event.target === lightbox) closeLightbox();
    });

    document.addEventListener('keydown', event => {
      if (event.key === 'Escape' && lightbox.classList.contains('active')) closeLightbox();
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

  // ================================
  // DROPDOWN CONTACT — sujet
  // ================================
  // Le comportement vient du controleur unique (initDropdowns).
  // Ici on ne fait que reporter la valeur choisie dans le champ cache soumis.
  const contactSubjectTrigger = document.getElementById('contact-subject-btn');
  const contactSubjectValue = document.getElementById('contact-subject-value');
  if (contactSubjectTrigger && contactSubjectValue) {
    contactSubjectTrigger.addEventListener('dropdown:change', e => {
      contactSubjectValue.value = e.detail.value;
    });
  }

  // ================================
  // FORMULAIRE CONTACT — validation
  // ================================
  const contactForm = document.querySelector('.contact-form');
  if (contactForm) {
    contactForm.addEventListener('submit', event => {
      if (!contactForm.checkValidity()) {
        event.preventDefault();
        contactForm.classList.add('was-validated');
      }
      // Validation manuelle du dropdown (hidden input)
      const subjectInput = document.getElementById('contact-subject-value');
      if (subjectInput && !subjectInput.value) {
        event.preventDefault();
        contactForm.classList.add('was-validated');
        const dropdown = document.getElementById('contact-subject-btn');
        if (dropdown) dropdown.classList.add('is-invalid');
      }
    });
  }
});

// ================================
// SCROLL PROGRESS BAR — Pages projet
// ================================
(function () {
  if (!document.querySelector('.hero-project')) return;
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReducedMotion) return;

  const size = 44;
  const svgSize = size + 4;   // 48px — 2px de débordement de chaque côté pour bordure centrée
  const r = 12;               // border-radius du squircle (28% de 44 ≈ 12px)

  // Périmètre du squircle : 4 côtés droits + 4 quarts de cercle
  const circumference = 4 * (size - 2 * r) + 2 * Math.PI * r; // ≈ 155.4

  // Chemin squircle dans le SVG 48x48, partant du centre-haut, sens horaire
  const sp = `M 24 2 L 34 2 Q 46 2 46 14 L 46 34 Q 46 46 34 46 L 14 46 Q 2 46 2 34 L 2 14 Q 2 2 14 2 Z`;

  const btn = document.createElement('button');
  btn.id = 'scroll-top-btn';
  btn.setAttribute('aria-label', 'Retour en haut');
  btn.innerHTML = `
    <svg width="${svgSize}" height="${svgSize}" viewBox="0 0 ${svgSize} ${svgSize}"
      style="position:absolute;top:-2px;left:-2px;pointer-events:none;" aria-hidden="true">
      <path class="stt-track" d="${sp}" fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="0"/>
      <path class="stt-progress" d="${sp}" fill="none"
        stroke="var(--primary-color)" stroke-width="2"
        stroke-dasharray="${circumference}"
        stroke-dashoffset="${circumference}"
        stroke-linecap="round"/>
    </svg>
    <svg width="22" height="22" viewBox="0 0 22 22" aria-hidden="true" style="position:relative;">
      <path d="M4 13 L11 5 L18 13 M11 5 V17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    </svg>`;

  Object.assign(btn.style, {
    position:        'fixed',
    bottom:          '2rem',
    right:           '2rem',
    width:           size + 'px',
    height:          size + 'px',
    background:      'var(--primary-color-alpha)',
    border:          'none',
    borderRadius:    '28%',
    cursor:          'pointer',
    zIndex:          '998',
    backdropFilter:  'none',
    opacity:         '0',
    transform:       'translateY(12px)',
    transition:      'opacity 0.3s ease, transform 0.3s ease',
    padding:         '0',
    display:         'flex',
    alignItems:      'center',
    justifyContent:  'center',
    color:           'white',
  });

  document.body.appendChild(btn);

  const progressCircle = btn.querySelector('.stt-progress');

  function updateProgress() {
    const scrollTop = window.scrollY;
    const docHeight = document.documentElement.scrollHeight - window.innerHeight;
    const progress  = docHeight > 0 ? scrollTop / docHeight : 0;

    progressCircle.style.strokeDashoffset = circumference * (1 - progress);

    // Apparaît après 10% de scroll
    if (progress > 0.1) {
      btn.style.opacity   = '1';
      btn.style.transform = 'translateY(0)';
    } else {
      btn.style.opacity   = '0';
      btn.style.transform = 'translateY(12px)';
    }
  }

  btn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });

  window.addEventListener('scroll', updateProgress, { passive: true });
  updateProgress();
})();

// ================================
// PARALLAX HERO IMAGE — Fade + Scale (Desktop uniquement)
// ================================
(function () {
  if (!window.matchMedia('(pointer: fine)').matches) return;
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReducedMotion) return;

  const heroSection = document.querySelector('.hero-project');
  if (!heroSection) return;

  // Layers avec leur vitesse propre : [sélecteur, facteurY, facteurScale]
  const layers = [
    { el: heroSection.querySelector('.hero-project-title-container'), speedY: 0.06, speedScale: 0 },
    { el: heroSection.querySelector('.bubble-container'),             speedY: 0.10, speedScale: 0 },
    { el: heroSection.querySelector('.hero-image-container'),         speedY: 0.18, speedScale: 0.05 },
  ].filter(l => l.el);

  layers.forEach(l => { l.el.style.willChange = 'transform, opacity, filter'; });
  heroSection.style.willChange = 'opacity, filter';

  let ticking = false;

  function updateParallax() {
    const heroHeight = heroSection.offsetHeight;
    const delay    = heroHeight * 0.25;
    const progress = Math.min(Math.max((window.scrollY - delay) / (heroHeight - delay), 0), 1);

    const opacity = Math.max(1 - progress * 0.85, 0.15);
    const blur    = progress * 12;

    // Fade + blur global sur le hero
    heroSection.style.opacity = opacity;
    heroSection.style.filter  = `blur(${blur}px)`;

    // Chaque layer bouge à sa propre vitesse
    layers.forEach(l => {
      const translateY = window.scrollY * l.speedY;
      const scale      = 1 + progress * l.speedScale;
      l.el.style.transform = `translateY(${translateY}px) scale(${scale})`;
    });

    ticking = false;
  }

  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(updateParallax);
      ticking = true;
    }
  }, { passive: true });
})();