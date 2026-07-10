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
  const contactDropdownBtn = document.getElementById('contact-subject-btn');
  const contactDropdownMenu = document.getElementById('contact-subject-list');
  const contactDropdownSelected = contactDropdownBtn ? contactDropdownBtn.querySelector('.contact-dropdown-selected') : null;
  const contactSubjectValue = document.getElementById('contact-subject-value');

  if (contactDropdownBtn && contactDropdownMenu && contactDropdownSelected && contactSubjectValue) {
    const options = contactDropdownMenu.querySelectorAll('.contact-dropdown-option');
    let focusedIndex = -1;

    const openDropdown = () => {
      contactDropdownBtn.setAttribute('aria-expanded', 'true');
      contactDropdownMenu.classList.add('is-open');
      focusedIndex = [...options].findIndex(o => o.getAttribute('aria-selected') === 'true');
      if (focusedIndex >= 0) options[focusedIndex].focus();
    };

    const closeDropdown = (focusBtn = true) => {
      contactDropdownBtn.setAttribute('aria-expanded', 'false');
      contactDropdownMenu.classList.remove('is-open');
      if (focusBtn) contactDropdownBtn.focus();
    };

    const selectOption = (option) => {
      options.forEach(o => {
        o.setAttribute('aria-selected', 'false');
        o.removeAttribute('tabindex');
      });
      option.setAttribute('aria-selected', 'true');
      contactSubjectValue.value = option.getAttribute('data-value');
      // Affiche le texte sans l'icône SVG
      contactDropdownSelected.textContent = option.textContent.trim();
      contactDropdownSelected.removeAttribute('data-empty');
      contactDropdownBtn.classList.remove('is-invalid');
      closeDropdown();
    };

    // Initialise les options comme non-focusables
    options.forEach((option, i) => {
      option.setAttribute('tabindex', '-1');
      option.addEventListener('click', () => selectOption(option));
      option.addEventListener('keydown', e => {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); selectOption(option); }
        if (e.key === 'ArrowDown') { e.preventDefault(); const next = options[i + 1]; if (next) next.focus(); }
        if (e.key === 'ArrowUp') { e.preventDefault(); const prev = options[i - 1]; if (prev) prev.focus(); else contactDropdownBtn.focus(); }
        if (e.key === 'Escape') closeDropdown();
      });
    });

    contactDropdownBtn.addEventListener('click', () => {
      const isOpen = contactDropdownBtn.getAttribute('aria-expanded') === 'true';
      isOpen ? closeDropdown() : openDropdown();
    });

    contactDropdownBtn.addEventListener('keydown', e => {
      if (e.key === 'Enter' || e.key === ' ' || e.key === 'ArrowDown') {
        e.preventDefault();
        openDropdown();
      }
      if (e.key === 'Escape') closeDropdown();
    });

    document.addEventListener('click', e => {
      if (contactDropdownBtn.getAttribute('aria-expanded') === 'true') {
        if (!contactDropdownBtn.contains(e.target) && !contactDropdownMenu.contains(e.target)) {
          closeDropdown(false);
        }
      }
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