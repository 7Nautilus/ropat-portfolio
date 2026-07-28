// ================================
// ANNONCES : region vivante partagee
// ================================
// Le site changeait le contenu de la page sans jamais le dire. Un lecteur
// d'ecran qui filtrait le portfolio passait de 21 cartes a 4 dans le silence
// complet : rien n'indiquait que le choix avait ete pris en compte, ni combien
// de projets restaient.
// La region vit dans le layout, donc elle existe AVANT toute injection : une
// region creee en meme temps que son texte n'est pas annoncee, le lecteur ne
// surveille que les regions deja presentes quand elles changent.
// `polite` et non `assertive` : ces messages accompagnent une action de
// l'utilisateur, ils n'ont pas a couper la parole.
function annoncer(texte) {
  const region = document.getElementById('annonces');
  if (!region) return;
  // Vider puis reposer au tour suivant : reecrire le MEME texte ne declenche
  // aucune annonce, or filtrer deux fois de suite sur la meme categorie doit
  // bien confirmer deux fois.
  region.textContent = '';
  requestAnimationFrame(() => { region.textContent = texte; });
}

// ================================
// CURSEUR BLOB : Desktop uniquement
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
// DROPDOWN : controleur unique
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

    const navInteractiveSelectors = ['.nav-link', '.nav-contact'];
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

    filterTrigger.addEventListener('dropdown:change', e => {
      filterProjects(e.detail.value);
      // Le resultat du filtre doit se DIRE, pas seulement se voir.
      const lang = document.documentElement.lang === 'fr' ? 'fr' : 'en';
      let n = 0;
      projectCards.forEach(card => {
        const cats = (card.getAttribute('data-category') || '').split(' ');
        if (e.detail.value === 'all' || cats.includes(e.detail.value)) n++;
      });
      annoncer(lang === 'fr'
        ? `${e.detail.label} : ${n} projet${n > 1 ? 's' : ''} affiché${n > 1 ? 's' : ''}.`
        : `${e.detail.label}: ${n} project${n > 1 ? 's' : ''} shown.`);
    });
  }

  initDropdowns();

  // Le permutateur de vignettes a ete retire : la page projet n'a plus de
  // widget de galerie, les medias forment une sequence en flux (cf.
  // _includes/projects/project-main.html). C'etait la racine des bugs de
  // galerie. Les images de la sequence restent agrandissables par la
  // lightbox ci-dessous, via .lightbox-trigger.

  // ================================
  // LIGHTBOX - Image plein écran
  // ================================
  const lightbox = document.getElementById('lightbox');
  const lightboxClose = lightbox ? lightbox.querySelector('.lightbox-close') : null;
  const lightboxTriggers = lightbox ? document.querySelectorAll('.lightbox-trigger') : [];
  let activeLightboxTrigger = null;
  // Cree a la premiere ouverture. Le gabarit n'expedie plus d'image vide a
  // source nulle, qui serait une image cassee dans le DOM de chaque page
  // projet, meme masquee.
  let lightboxImage = null;

  if (lightbox && lightboxTriggers.length > 0) {
    // Confinement du Tab : sans lui, une tabulation depuis la lightbox
    // ouverte envoyait le focus derriere l'overlay (mesure : sur un lien du
    // pied de page a 9586 px), et `overflow: hidden` empechait la page de
    // defiler jusqu'a lui. L'utilisateur clavier perdait son curseur.
    const piegerTab = event => {
      if (event.key !== 'Tab' || !lightbox.classList.contains('active')) return;
      const focusables = lightbox.querySelectorAll('button, [href], [tabindex]:not([tabindex="-1"])');
      if (!focusables.length) return;
      const premier = focusables[0];
      const dernier = focusables[focusables.length - 1];
      if (event.shiftKey && document.activeElement === premier) {
        event.preventDefault();
        dernier.focus();
      } else if (!event.shiftKey && document.activeElement === dernier) {
        event.preventDefault();
        premier.focus();
      }
    };

    const openLightbox = (trigger) => {
      activeLightboxTrigger = trigger;
      if (!lightboxImage) {
        lightboxImage = document.createElement('img');
        lightboxImage.className = 'lightbox-image';
        // Source posee AVANT l'insertion : le noeud n'est jamais dans le
        // document sans image a afficher.
        lightboxImage.src = trigger.src;
        lightboxImage.alt = trigger.alt;
        lightbox.appendChild(lightboxImage);
      }
      lightboxImage.src = trigger.src;
      lightboxImage.alt = trigger.alt;
      lightbox.classList.add('active');
      body.style.overflow = 'hidden';
      // `aria-modal` seul ne promet rien : sans `inert`, le reste de la page
      // reste atteignable au clavier et annonce par les lecteurs d'ecran.
      const principal = document.getElementById('main-content');
      if (principal) principal.inert = true;
      document.addEventListener('keydown', piegerTab, true);
      lightboxClose.focus();
    };

    const closeLightbox = () => {
      lightbox.classList.remove('active');
      body.style.overflow = '';
      const principal = document.getElementById('main-content');
      if (principal) principal.inert = false;
      document.removeEventListener('keydown', piegerTab, true);
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
  // CHROME ESCAMOTABLE : pages projet
  // ================================
  // Le header ne doit jamais concurrencer l'oeuvre. Il se retire quand on
  // descend (on lit, on regarde) et revient quand on remonte (on cherche a
  // naviguer). En haut de page il reste transparent : il est alors pose sur
  // le sol dither, pas sur le travail du client.
  const pageProjet = document.querySelector('.project-page');
  const chrome = document.querySelector('header');
  if (pageProjet && chrome) {
    const SEUIL = 8;        // px de mouvement avant de reagir, evite le tremblement
    const HAUT = 120;       // en deca, on est encore dans l'ouverture
    let dernierY = window.scrollY;
    let enAttente = false;

    const majChrome = () => {
      // Libere le drapeau EN PREMIER : s'il restait arme, le moindre incident
      // gelait definitivement l'ecoute du defilement.
      enAttente = false;

      const y = window.scrollY;
      const delta = y - dernierY;

      if (y <= HAUT) {
        chrome.removeAttribute('data-chrome');
        dernierY = y;
        return;
      }
      if (delta > SEUIL) {
        chrome.setAttribute('data-chrome', 'retire');
        dernierY = y;
      } else if (delta < -SEUIL) {
        chrome.setAttribute('data-chrome', 'pose');
        dernierY = y;
      }
    };

    window.addEventListener('scroll', () => {
      if (enAttente) return;
      enAttente = true;
      requestAnimationFrame(majChrome);
    }, { passive: true });
  }

  // ================================
  // CHROME AU-DESSUS D'UN MEDIA
  // ================================
  // ⚠️ REMPLACE la jauge de luminance du 27/07/2026, retiree apres mesure.
  //
  // Cette jauge echantillonnait le quart superieur de chaque media, en
  // deduisait « fond clair » ou « fond sombre », et repeignait TOUTE la barre
  // en consequence. Trois defauts, tous mesures au navigateur :
  //
  //  1. UN verdict pour une barre de 1440 px. Le logo et la nav peuvent
  //     surplomber des contenus opposes. Sur Sipsmith, le meme verdict donnait
  //     15,4:1 sur la nav et 1:1 sur le logo.
  //  2. --p-vert-basse vaut #030808, c'est-a-dire EXACTEMENT --surface. L'encre
  //     du mode clair etait donc la couleur du sol : tout controle qui ne
  //     surplombait pas l'image mais le sol disparaissait purement et
  //     simplement.
  //  3. L'echantillon etait pris une fois, en haut du media, alors que la
  //     bande reellement sous la barre se deplace a chaque pixel de scroll.
  //
  // Mais le defaut de fond n'est aucun des trois : c'est que la question
  // n'a pas de reponse. Mesure du fond REEL sous chaque controle, 19 projets,
  // plusieurs positions de defilement : la luminance va de 0,000 a 1,000 sous
  // un meme controle (aelio, hdd-defrag, stelya, moon-vtc, jhag-*...).
  // Or une encre plate ne tient 3:1 partout que si Lmin >= 0,10 (encre sombre)
  // ou Lmax <= 0,30 (encre claire). Sur 16 projets sur 19, ni l'un ni l'autre :
  // AUCUNE couleur plate n'existe. Le probleme n'etait pas mal regle, il
  // etait insoluble sous cette forme.
  // (mix-blend-mode: difference echoue pour la meme raison : sur un fond a
  // 127,5 il renvoie 127,5, donc 1:1 pile au gris moyen.)
  //
  // On cesse donc de DEDUIRE la couleur du fond, et on la GARANTIT : chaque
  // controle porte son propre voile sombre local (cf. _project.scss). Le seul
  // etat a calculer devient binaire et sans echantillonnage : la barre
  // surplombe-t-elle un media, oui ou non.
  const barre = document.querySelector('header');
  const mediasPage = [...document.querySelectorAll('.project-open-media, .project-piece-media')];
  if (barre && mediasPage.length) {
    const hauteurBarre = () => barre.getBoundingClientRect().height || 76;
    const ouverture = document.querySelector('.project-open');

    const majFond = () => {
      const bas = hauteurBarre();

      // La barre surplombe-t-elle encore l'ouverture ? Tant que oui, elle se
      // pose sur l'oeuvre : ni fond ni bordure, sinon elle l'encadre.
      if (ouverture) {
        const o = ouverture.getBoundingClientRect();
        if (o.bottom > 0 && o.top < bas) barre.setAttribute('data-zone', 'ouverture');
        else barre.removeAttribute('data-zone');
      }

      const surMedia = mediasPage.some(el => {
        if (el.offsetParent === null && el.tagName !== 'VIDEO') return false;
        const r = el.getBoundingClientRect();
        return Math.min(r.bottom, bas) - Math.max(r.top, 0) > 0;
      });
      if (surMedia) barre.setAttribute('data-sur-media', '');
      else barre.removeAttribute('data-sur-media');

      majEncre(surMedia, bas);
    };

    // ══════════════════════════════════════════════════════════════════════
    //  LA BASCULE D'ENCRE
    // ══════════════════════════════════════════════════════════════════════
    //  Le chrome passe en encre sombre quand le blanc n'est plus lisible sur
    //  ce qu'il surplombe, et revient au blanc sinon.
    //
    //  ⚠️ LE CRITERE EST UN CONTRASTE, PAS UNE LUMINANCE, et c'est ce qui rend
    //  le seuil non arbitraire. Cadrage de Ropat le 28/07 : « si le contraste
    //  est assez bon pour que le texte des boutons de la nav soit lisible il
    //  reste en blanc, sinon le header change de variante ». On bascule donc
    //  exactement quand le texte cesse d'etre lisible, c'est-a-dire a 4,5:1,
    //  le seuil WCAG du texte courant. Il n'y a aucune valeur a regler a la
    //  main, contrairement a un seuil de luminance.
    //
    //  ⚠️ POURQUOI ON NE PEUT PAS SIMPLEMENT « LIRE CE QU'IL Y A DESSOUS » :
    //  aucune API n'expose l'arriere-plan composite d'une page. `backdrop-
    //  filter` le TRANSFORME sans jamais le rendre. On le RECONSTRUIT donc a
    //  partir de ses sources, qui sont toutes connues :
    //    . les medias, dessines dans un canvas hors ecran de 96 px de large ;
    //    . tout le reste, qui est le sol dither, quasi noir par construction,
    //      donc jamais un probleme pour une encre claire.
    //  Le canvas n'entre pas dans le DOM : il ne peint rien, ne declenche
    //  aucun layout, et ne telecharge rien. C'est un tampon memoire.

    const LARGEUR_SONDE = 96;
    const vignettes = new WeakMap();

    // ⚠️ LE PIEGE D'`object-fit`, et il m'a eu deux fois en mesurant. Le
    // contenu peint ne remplit PAS la boite de l'element : avec `contain` il y
    // est centre et borde de vide. Projeter des coordonnees d'ecran a travers
    // `getBoundingClientRect` sans en tenir compte fait echantillonner a cote.
    const rectContenu = (el) => {
      const b = el.getBoundingClientRect();
      const nw = el.naturalWidth || el.videoWidth || 0;
      const nh = el.naturalHeight || el.videoHeight || 0;
      const fit = getComputedStyle(el).objectFit;
      if (!nw || !nh || fit === 'fill' || fit === 'none') return b;
      const rb = b.width / b.height, rn = nw / nh;
      let w, h;
      if (fit === 'cover') {
        if (rn > rb) { h = b.height; w = h * rn; } else { w = b.width; h = w / rn; }
      } else {                                   // contain, scale-down
        if (rn > rb) { w = b.width; h = w / rn; } else { h = b.height; w = h * rn; }
      }
      return { left: b.left + (b.width - w) / 2, top: b.top + (b.height - h) / 2,
               width: w, height: h, right: b.left + (b.width + w) / 2,
               bottom: b.top + (b.height + h) / 2 };
    };

    const vignette = (el) => {
      const estVideo = el.tagName === 'VIDEO';
      let v = vignettes.get(el);
      if (!v) {
        const nw = el.naturalWidth || el.videoWidth || 0;
        const nh = el.naturalHeight || el.videoHeight || 0;
        if (!nw || !nh) return null;
        const c = document.createElement('canvas');
        c.width = LARGEUR_SONDE;
        c.height = Math.max(1, Math.round(LARGEUR_SONDE * nh / nw));
        v = { c: c, x: c.getContext('2d', { willReadFrequently: true }), dessine: false };
        vignettes.set(el, v);
      }
      // Une image ne se dessine qu'une fois ; une video a chaque passage.
      if (!v.dessine || estVideo) {
        try {
          v.x.drawImage(el, 0, 0, v.c.width, v.c.height);
          v.dessine = true;
        } catch (e) { return null; }        // media pas encore decode
      }
      return v;
    };

    const lin = (c) => { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); };
    const CONTRASTE = (a, b) => (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
    const L_CLAIRE = 0.2126 * lin(240) + 0.7152 * lin(244) + 0.0722 * lin(241);   // --ink

    // Luminance REPRESENTATIVE sous une boite : un percentile haut, pas le
    // maximum. Un seul pixel clair perdu dans une oeuvre sombre ne doit pas
    // faire basculer toute la barre ; il en existe sur presque chaque image.
    const PERCENTILE = 0.9;

    const luminanceSous = (boite) => {
      let vals = null;
      for (const el of mediasPage) {
        if (el.offsetParent === null && el.tagName !== 'VIDEO') continue;
        const r = rectContenu(el);
        const gx = Math.max(boite.left, r.left), dx = Math.min(boite.right, r.right);
        const hy = Math.max(boite.top, r.top), by = Math.min(boite.bottom, r.bottom);
        if (dx - gx <= 0 || by - hy <= 0) continue;
        const v = vignette(el);
        if (!v) continue;
        const kx = v.c.width / r.width, ky = v.c.height / r.height;
        const sx = Math.floor((gx - r.left) * kx), sy = Math.floor((hy - r.top) * ky);
        const sw = Math.max(1, Math.round((dx - gx) * kx)), sh = Math.max(1, Math.round((by - hy) * ky));
        let d;
        try { d = v.x.getImageData(sx, sy, sw, sh).data; } catch (e) { continue; }
        if (!vals) vals = [];
        for (let i = 0; i < d.length; i += 4) {
          vals.push(0.2126 * lin(d[i]) + 0.7152 * lin(d[i + 1]) + 0.0722 * lin(d[i + 2]));
        }
      }
      if (!vals || !vals.length) return null;    // rien d'autre que le sol
      vals.sort((a, b) => a - b);
      return vals[Math.min(vals.length - 1, Math.floor(PERCENTILE * (vals.length - 1)))];
    };

    // ⚠️ DEUX GARDE-FOUS, ET IL EN FALLAIT DEUX. Mesure a l'appui.
    //
    // 1. HYSTERESIS. On sort du blanc sous 4,5 et on n'y revient qu'au-dessus
    //    de 7. Sans bande morte, un controle pose pile au seuil basculerait a
    //    chaque pixel de defilement.
    //
    // 2. DUREE DE MAINTIEN. L'hysteresis seule ne suffisait pas, et c'est un
    //    test de defilement fin qui l'a montre : sur Ottony, une oeuvre pourtant
    //    SOMBRE mais brodee de fil clair, la sequence relevee tous les 10 px
    //    donnait `CCCCCCCCCCCCSSCCCCCCSSSS...`, soit un aller-retour de deux
    //    positions, donc un clignotement.
    //    La cause n'est pas un seuil mal choisi : a ces instants la barre
    //    surplombe VRAIMENT une zone claire, la mesure est juste. Le defaut est
    //    TEMPOREL, il fallait donc une reponse temporelle. On interdit deux
    //    bascules a moins de 400 ms : le chrome reste au pire un instant de
    //    retard sur le fond, ce qui se voit infiniment moins qu'un clignotement.
    const SEUIL_SORTIE = 4.5, SEUIL_RETOUR = 7;
    const MAINTIEN = 400;
    let encreSombre = false;
    let dernierChangement = 0;

    const majEncre = (surMedia, bas) => {
      if (!surMedia) {
        if (encreSombre) { encreSombre = false; barre.removeAttribute('data-encre'); }
        return;
      }
      // Tous les controles, et c'est le PIRE qui decide : la barre n'a qu'une
      // variante, elle doit donc servir celui qui est le plus en peine.
      let pire = null;
      barre.querySelectorAll('.logo, .nav-link, .nav-contact, .burger-menu').forEach(el => {
        const b = el.getBoundingClientRect();
        if (b.width < 1 || b.height < 1 || b.top > bas) return;
        const L = luminanceSous(b);
        if (L === null) return;
        if (pire === null || L > pire) pire = L;      // le plus CLAIR est le pire pour une encre claire
      });
      if (pire === null) {                             // que du sol dither
        if (encreSombre) { encreSombre = false; barre.removeAttribute('data-encre'); }
        return;
      }
      const c = CONTRASTE(L_CLAIRE, pire);
      const veutSombre = encreSombre ? c <= SEUIL_RETOUR : c < SEUIL_SORTIE;
      if (veutSombre === encreSombre) return;
      const t = performance.now();
      if (t - dernierChangement < MAINTIEN) return;
      dernierChangement = t;
      encreSombre = veutSombre;
      if (encreSombre) barre.setAttribute('data-encre', 'sombre');
      else barre.removeAttribute('data-encre');
    };

    let enAttenteFond = false;
    const planifier = () => {
      if (enAttenteFond) return;
      enAttenteFond = true;
      requestAnimationFrame(() => { enAttenteFond = false; majFond(); });
    };
    window.addEventListener('scroll', planifier, { passive: true });
    window.addEventListener('resize', planifier, { passive: true });
    window.addEventListener('load', planifier);
    planifier();
  }

  // ================================
  // GALERIE : voir plus
  // ================================
  // REGLE : des que la grille tombe a UNE COLONNE (une piece par rangee),
  // on n'en montre que trois. C'est la que le repli sert : chaque piece y
  // occupe toute la largeur, donc un projet a 6 pieces impose 6 images
  // plein ecran avant d'atteindre le recit. Sur une grille a plusieurs
  // colonnes, les memes 6 tiennent en 3 rangees et le repli n'a pas lieu.
  //
  // La condition est DEDUITE DE LA MISE EN PAGE REELLE, pas d'une media
  // query en dur : on compte les rangees occupees. Une valeur de rupture
  // recopiee dans le JS finit toujours par diverger du CSS.
  //
  // Rendu progressif : le gabarit emet TOUTES les pieces. Sans JS, tout
  // reste visible et le bouton n'existe pas. L'etat vit dans
  // `aria-expanded`, jamais dans une classe (convention du site).
  const galerie = document.querySelector('.project-sequence');
  if (galerie) {
    const piecesGalerie = [...galerie.querySelectorAll('.project-piece')];
    const seuilColonneUnique = parseInt(galerie.dataset.seuilMobile, 10) || 3;
    const seuilLarge = parseInt(galerie.dataset.seuil, 10) || 8;
    const fr = document.documentElement.lang === 'fr';

    const bouton = document.createElement('button');
    bouton.type = 'button';
    bouton.className = 'galerie-plus';
    bouton.setAttribute('aria-expanded', 'false');
    galerie.insertAdjacentElement('afterend', bouton);

    let deplie = false;

    // Une seule colonne ? On le mesure toutes pieces affichees, sinon les
    // pieces repliees n'ont plus de geometrie et le compte est faux.
    const estColonneUnique = () => {
      piecesGalerie.forEach(p => { p.hidden = false; });
      const rangees = new Set(piecesGalerie.map(p => Math.round(p.getBoundingClientRect().top)));
      return rangees.size === piecesGalerie.length;
    };

    const appliquer = () => {
      const seuil = estColonneUnique() ? seuilColonneUnique : seuilLarge;
      const caches = piecesGalerie.slice(seuil);

      // Un bouton pour une seule piece cachee ne vaut pas le clic.
      if (caches.length < 2) {
        bouton.hidden = true;
        // On vide le libelle : sinon, apres un passage mobile vers desktop,
        // le bouton conservait « Voir les N autres pieces » alors que tout
        // etait deja visible.
        bouton.textContent = '';
        piecesGalerie.forEach(p => { p.hidden = false; });
        return;
      }
      bouton.hidden = false;
      // Si le visiteur a deja deplie, on ne lui replie pas la galerie sous
      // les yeux parce qu'il a tourne son telephone.
      caches.forEach(p => { p.hidden = !deplie; });
      bouton.textContent = deplie
        ? (fr ? 'Voir moins' : 'See less')
        : (fr ? 'Voir les ' + caches.length + ' autres pièces'
              : 'See ' + caches.length + ' more pieces');
    };

    bouton.addEventListener('click', () => {
      deplie = !deplie;
      bouton.setAttribute('aria-expanded', String(deplie));
      appliquer();
      if (!deplie) {
        // Au repli, on ramene le regard en haut de la galerie : sinon le
        // visiteur reste suspendu dans le vide qu'il vient de creer.
        const doux = window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth';
        galerie.scrollIntoView({ behavior: doux, block: 'start' });
      }
    });

    // Le nombre de colonnes change avec la largeur : on reevalue au
    // redimensionnement, en throttlant sur la frame.
    let enAttenteGalerie = false;
    window.addEventListener('resize', () => {
      if (enAttenteGalerie) return;
      enAttenteGalerie = true;
      requestAnimationFrame(() => { enAttenteGalerie = false; appliquer(); });
    }, { passive: true });

    appliquer();
  }

  // ================================
  // VIDEOS DE SEQUENCE : chargement a l'approche
  // ================================
  // Le gabarit emet `data-src` + `preload="none"` et AUCUN `autoplay`.
  // Raison mesuree : avec `autoplay`, le navigateur telecharge la video
  // entiere des le chargement, meme tres loin sous la ligne de flottaison.
  // Sur jhag-banana-rush, 3 videos hors ecran totalisaient 51,2 Mo, toutes
  // integralement descendues. Ici la source n'est posee qu'a l'approche, et
  // la lecture s'arrete des que la piece sort de l'ecran.
  const videosSequence = document.querySelectorAll('video.project-piece-media[data-src]');
  if (videosSequence.length) {
    const mouvementReduit = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    const poserSource = video => {
      if (video.dataset.chargee) return;
      video.dataset.chargee = '1';
      video.src = video.dataset.src;
      // `load()` est OBLIGATOIRE ici : un <video> rendu sans source a deja
      // execute son algorithme de selection et se trouve en
      // NETWORK_NO_SOURCE. Poser `src` ensuite ne le relance pas tout seul,
      // et `play()` echoue sur « The element has no supported sources »
      // alors que l'URL est parfaitement valide.
      video.load();
    };

    if (mouvementReduit || !('IntersectionObserver' in window)) {
      // Mouvement reduit : aucune lecture automatique, et on rend les
      // controles pour que la video reste consultable (WCAG 2.2.2).
      videosSequence.forEach(video => {
        video.controls = true;
        video.removeAttribute('loop');
        poserSource(video);
      });
    } else {
      const observateur = new IntersectionObserver(entrees => {
        entrees.forEach(entree => {
          const video = entree.target;
          if (entree.isIntersecting) {
            poserSource(video);
            const lecture = video.play();
            if (lecture && lecture.catch) lecture.catch(() => { video.controls = true; });
          } else if (!video.paused) {
            video.pause();
          }
        });
      }, {
        // AUCUNE marge de prechargement : ces vidéos pesent 15 a 18 Mo piece.
        // Avec 200 px de marge, la planche etant compacte, la premiere se
        // trouvait a 89 px sous la ligne de flottaison et se telechargeait
        // AU CHARGEMENT : 19 Mo au lieu de 1. Le `poster` couvre l'attente,
        // donc le prechargement n'achete rien qu'on ne paie trop cher.
        rootMargin: '0px'
      });

      videosSequence.forEach(video => observateur.observe(video));
    }
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

  // Confirme au garde-fou du layout que les revelations sont prises en charge.
  // Sans ce drapeau, il desarme au bout de 2,5 s et tout redevient visible.
  window.__revelationPrete = true;

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
  // DROPDOWN CONTACT : sujet
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
  // FORMULAIRE CONTACT : validation
  // ================================
  // Le formulaire portait `novalidate` ET n'appelait que `checkValidity()`,
  // jamais `reportValidity()`. Resultat : sur une soumission invalide, le
  // navigateur n'affichait AUCUN message et le code se contentait d'ajouter
  // une classe qui rougit une bordure. L'erreur n'existait donc que sous
  // forme de couleur, sans texte nulle part :
  //   . WCAG 3.3.1 (niveau A) : l'erreur doit etre DECRITE en texte.
  //   . WCAG 1.4.1 (niveau A) : la couleur ne peut pas etre le seul vecteur.
  // Un daltonien, un lecteur d'ecran et un ecran en plein soleil echouaient
  // tous les trois de la meme facon : le bouton ne fait rien, sans dire
  // pourquoi.
  const contactForm = document.querySelector('.contact-form');
  if (contactForm) {
    const fr = document.documentElement.lang === 'fr';
    const MSG = {
      valueMissing: {
        'contact-name':    fr ? 'Le nom est obligatoire.' : 'Name is required.',
        'contact-email':   fr ? "L'adresse email est obligatoire." : 'Email address is required.',
        'contact-message': fr ? 'Le message est obligatoire.' : 'A message is required.'
      },
      typeMismatch: fr
        ? "Cette adresse email n'est pas valide. Exemple : nom@domaine.fr"
        : "This email address isn't valid. Example: name@domain.com"
    };

    // Le bloc d'erreur est cree a cote du champ et rattache par
    // aria-describedby : le lecteur d'ecran lit alors le libelle, puis le
    // message, a chaque fois que le champ reprend le focus.
    const zoneErreur = champ => {
      let z = document.getElementById(champ.id + '-erreur');
      if (!z) {
        z = document.createElement('p');
        z.id = champ.id + '-erreur';
        z.className = 'contact-erreur';
        (champ.closest('.contact-field') || champ.parentNode).appendChild(z);
      }
      return z;
    };

    const poser = (champ, texte) => {
      const z = zoneErreur(champ);
      z.textContent = texte;
      champ.setAttribute('aria-invalid', 'true');
      const d = (champ.getAttribute('aria-describedby') || '').split(' ').filter(Boolean);
      if (!d.includes(z.id)) champ.setAttribute('aria-describedby', [...d, z.id].join(' '));
    };

    const lever = champ => {
      const z = document.getElementById(champ.id + '-erreur');
      if (z) z.textContent = '';
      champ.removeAttribute('aria-invalid');
    };

    contactForm.addEventListener('submit', event => {
      const fautifs = [];

      contactForm.querySelectorAll('input:not([type="hidden"]):not(.contact-botcheck), textarea')
        .forEach(champ => {
          if (champ.validity.valid) { lever(champ); return; }
          const texte = champ.validity.typeMismatch
            ? MSG.typeMismatch
            : (MSG.valueMissing[champ.id] || (fr ? 'Ce champ est obligatoire.' : 'This field is required.'));
          poser(champ, texte);
          fautifs.push(champ);
        });

      // Le sujet est un dropdown maison sur un input cache : le navigateur ne
      // sait pas le valider, et un input cache ne peut pas recevoir le focus.
      // On rattache donc l'erreur au bouton, seul element atteignable.
      const sujet = document.getElementById('contact-subject-value');
      const bouton = document.getElementById('contact-subject-btn');
      if (sujet && bouton) {
        if (!sujet.value) {
          poser(bouton, fr ? 'Choisissez un sujet.' : 'Choose a subject.');
          bouton.classList.add('is-invalid');
          fautifs.push(bouton);
        } else {
          lever(bouton);
          bouton.classList.remove('is-invalid');
        }
      }

      if (!fautifs.length) return;

      event.preventDefault();
      contactForm.classList.add('was-validated');
      annoncer(fr
        ? `Le message n'a pas été envoyé : ${fautifs.length} champ${fautifs.length > 1 ? 's sont' : ' est'} à corriger.`
        : `Message not sent: ${fautifs.length} field${fautifs.length > 1 ? 's need' : ' needs'} fixing.`);
      // Le focus part sur la premiere erreur, sinon l'utilisateur doit
      // remonter le formulaire a l'aveugle pour trouver ce qui cloche.
      fautifs[0].focus({ preventScroll: false });
    });

    // Correction en cours de frappe : l'erreur se leve des que le champ
    // redevient valide, plutot que d'attendre une nouvelle soumission.
    contactForm.addEventListener('input', e => {
      if (e.target.validity && e.target.validity.valid) lever(e.target);
    });
    const boutonSujet = document.getElementById('contact-subject-btn');
    if (boutonSujet) boutonSujet.addEventListener('dropdown:change', () => {
      lever(boutonSujet);
      boutonSujet.classList.remove('is-invalid');
    });
  }
});

// ================================
// SCROLL PROGRESS BAR : Pages projet
// ================================
(function () {
  if (!document.querySelector('.project-page')) return;
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReducedMotion) return;

  const size = 44;
  const svgSize = size + 4;   // 48px : 2px de débordement de chaque côté pour bordure centrée
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
      <path class="stt-track" d="${sp}" fill="none" stroke="var(--surface-subtle)" stroke-width="0"/>
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
    // ⚠️ Etait 'white' en dur. Une couleur posee depuis le JS echappe a tout
    // balayage du CSS : c'est le pire endroit ou en cacher une.
    color:           'var(--ink)',
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
// PARALLAX HERO IMAGE : Fade + Scale (Desktop uniquement)
// ================================
(function () {
  if (!window.matchMedia('(pointer: fine)').matches) return;
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReducedMotion) return;

  // ⚠️ Le hero projet en deux colonnes n'existe plus : la page ouvre sur un
  // media bord a bord (.project-open). Ce parallax visait des couches
  // supprimees, il est donc inerte ici. Il sera re-cible sur l'ouverture en
  // Phase 4, avec le reste de la grammaire de mouvement.
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