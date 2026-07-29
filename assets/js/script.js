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

  /* ⚠️ INVISIBLE TANT QUE LA SOURIS N'A PAS BOUGE. Au chargement, le blob est
     a (0, 0) et son `translate(-50%, -50%)` le centre sur ce point : son quart
     inferieur droit depasse donc dans le coin haut-gauche de la page, soit un
     eclat orange de 10x10 visible sur CHAQUE page jusqu'au premier mouvement.
     Il ne se voyait pas au DOM : `pointer-events: none` le rend invisible a
     `elementsFromPoint`, donc la sonde ne le trouvait pas et le rapportait
     absent. C'est une capture d'ecran zoomee sur le coin qui l'a montre.
     On ne peut pas connaitre la position du pointeur avant qu'il bouge, donc
     la seule reponse juste est de ne rien peindre avant. */
  blob.style.opacity = '0';
  let jamaisBouge = true;

  // Suivi de la position souris
  document.addEventListener('mousemove', e => {
    mouseX = e.clientX;
    mouseY = e.clientY;
    if (jamaisBouge) {
      jamaisBouge = false;
      // Se poser sans glisser depuis le coin : sinon le premier mouvement
      // ferait traverser tout l'ecran au blob.
      blobX = mouseX; blobY = mouseY;
      blob.style.opacity = '1';
    }
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
  // ⚠️ `.lang-selector-container` ET NON `.lang-selector`. La classe emise par
  // `_includes/lang-selector.html` est `lang-selector-container` : le selecteur
  // d'origine ne matchait donc RIEN, et le lien de langue du pied de page n'a
  // jamais eu son etat de curseur. Ce n'etait pas du code mort mais un BUG,
  // c'est-a-dire l'inverse : du code qui aurait du servir.
  // Le defaut restait invisible parce que le `a` du meme selecteur attrape le
  // lien lui-meme, donc le curseur changeait quand meme, pour une autre raison.
  bindCursorState('a, button, [role="button"], .project-card, .service-card, .partner-logo, .lang-selector-container, .burger-menu, .btn, .dropdown .select, .social-link, .socialContainer, label', 'cursor-hover');

  // Texte pur → état text (barre fine)
  // `.section-description` retire : absent des 63 pages construites.
  bindCursorState('p, h1, h2, h3, h4, h5, li, blockquote', 'cursor-text');

  // Images cliquables / lightbox → état zoom (cercle + croix)
  // `.thumbnail-image` et `.zoomable` retires : absents des 63 pages
  // construites. Vestiges du permutateur de vignettes, remplace par la
  // sequence en flux pendant la Phase 1.
  bindCursorState('.lightbox-trigger', 'cursor-zoom');

  // Masquer le blob quand la souris quitte la fenêtre
  document.addEventListener('mouseleave', () => { blob.style.opacity = '0'; });
  document.addEventListener('mouseenter', () => { blob.style.opacity = '1'; });
})();

// ================================
// PAGE LOADER
// ================================
//
// Le composant est decompose en trois roles dans `_includes/ui/loader.html` et
// `components/_loader.scss` : la surface, la marque, l'indice. Ce module ne
// connait que la surface, et c'est voulu : changer l'indice ne doit rien lui
// demander.
//
// ⚠️ LES DEUX DUREES SONT LUES, PAS RECOPIEES. Elles etaient ecrites trois
// fois : `0.5s` dans la transition du voile, `800` et `500` ici. Le fondu du
// CSS et l'attente du JS devaient s'accorder et rien ne le verifiait. La meme
// faute, entre le radar de favicon et ce loader, a coute une desynchronisation
// le 29/07/2026. La source unique est maintenant `base/_variables.scss`.
function dureeJeton(nom, repli) {
  const v = getComputedStyle(document.documentElement).getPropertyValue(nom).trim();
  // ⚠️ TESTER `ms` AVANT `s` : toute valeur en millisecondes se termine aussi
  // par « s », donc l'ordre inverse lirait 800ms comme 800 secondes.
  if (v.endsWith('ms')) return parseFloat(v) || repli;
  if (v.endsWith('s')) return (parseFloat(v) * 1000) || repli;
  // Jeton absent : la feuille de style n'est pas chargee. On garde les valeurs
  // historiques plutot que de tomber a zero et de faire disparaitre le voile
  // d'un coup.
  return repli;
}

window.addEventListener('load', () => {
  const loader = document.getElementById('pageLoader');
  if (!loader) return;

  setTimeout(() => {
    loader.classList.add('loaded');
    // Retirer du DOM une fois le fondu termine.
    setTimeout(() => loader.remove(), dureeJeton('--dur-loader-fade', 500));
  }, dureeJeton('--dur-loader-hold', 800));
});

// ================================
// RADAR DE CHARGEMENT DANS LE FAVICON
// ================================
//
// Un balayage de radar dans l'onglet, le temps que le loader de page acheve
// son travail. Motif dessine par Ropat le 29/07/2026 : grille de 5x5 points,
// un rayon de trois points du centre vers le bord, huit directions, sens
// horaire, depart a midi.
//
// ── LA GEOMETRIE EST CHOISIE POUR SURVIVRE A 16 PIXELS ────────────────────
// Toutes les mesures sont PAIRES : premier point a 2, cote 4, pas 6, donc les
// points occupent 2-6, 8-12, 14-18, 20-24, 26-30. Reduites de moitie elles
// tombent sur 1-3, 4-6, 7-9, 10-12, 13-15, toutes entieres. Une seule image de
// 32 px suffit donc pour les deux tailles d'affichage.
//
// ⚠️ DES CARRES, PAS DES CERCLES, ET C'EST MESURE. A 16 px un point rond de
// 2 px de diametre n'est fait que d'anti-crenelage : l'alpha reellement peint
// tombe a 0,79 pour le 100 %, 0,48 pour le 60 %, 0,32 pour le 40 % et 0,16
// pour le 20 %. Les quatre niveaux se resserrent, donc la trainee cesse de se
// lire. En carres, les quatre sortent exacts aux deux tailles.
//
// ── CE QU'IL RACONTE ──────────────────────────────────────────────────────
// Rien de mesurable, et c'est l'arbitrage de Ropat. Le loader de page se
// declenche sur `window.load` puis tient 800 ms fixes : il n'a AUCUNE
// progression a rapporter, donc inventer une barre qui se remplit aurait ete
// du theatre. Un radar balaie, il ne promet pas d'arriver quelque part.
// Ce qu'il dit de vrai est la seule chose qu'il puisse dire : le loader est
// encore la, la page n'a pas fini de se poser.
(function () {
  const lien = document.getElementById('favicon');
  if (!lien) return;
  // Un favicon anime EST du mouvement. Le reglage systeme s'applique ici comme
  // au reste, et il n'y a pas de repli a inventer : l'icone reste l'icone.
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  if (document.readyState === 'complete') return;

  const ORIGINE = lien.getAttribute('href');
  const T = 32, PREMIER = 2, COTE = 4, PAS = 6;
  const REPOS = 0.2;                 // toute la grille au repos
  const TRAINE = [1, 0.6, 0.4];      // image courante, la precedente, l'avant
  const PAS_MS = 100;                // huit images, un tour en 800 ms
  // Mesure du 29/07 : le navigateur relit le favicon environ quinze fois par
  // seconde. Dix reste dessous, donc aucune image n'est sautee.

  const DIRS = [[0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1]];

  // ── Pre-rendu ───────────────────────────────────────────────────────────
  // Les huit images sont encodees UNE fois, au demarrage. L'animation n'est
  // ensuite qu'un changement d'attribut : redessiner soixante fois par seconde
  // pendant le chargement aurait charge le fil principal au pire moment,
  // c'est-a-dire pendant ce qu'on pretend accompagner.
  const images = [];
  try {
    for (let f = 0; f < 8; f++) {
      const c = document.createElement('canvas');
      c.width = c.height = T;
      const g = c.getContext('2d');

      // La trainee se pose de la plus PALE a la plus vive, pour que le centre,
      // qui appartient aux trois rayons, garde le niveau le plus fort.
      const niveau = {};
      for (let t = TRAINE.length - 1; t >= 0; t--) {
        const [dx, dy] = DIRS[(f - t + 8) % 8];
        for (let i = 0; i < 3; i++) niveau[(2 + dx * i) + ',' + (2 + dy * i)] = TRAINE[t];
      }

      for (let col = 0; col < 5; col++) {
        for (let lig = 0; lig < 5; lig++) {
          g.fillStyle = 'rgba(255, 92, 0, ' + (niveau[col + ',' + lig] || REPOS) + ')';
          g.fillRect(PREMIER + col * PAS, PREMIER + lig * PAS, COTE, COTE);
        }
      }
      images.push(c.toDataURL('image/png'));
    }
  } catch (e) {
    return;   // canvas indisponible : l'icone d'origine reste, rien ne casse
  }

  let image = 0, minuterie = null, courant = lien, finir = false;

  // ⚠️ ON REMPLACE L'ELEMENT, ON NE MODIFIE PAS `href`.
  // Premiere version : `lien.setAttribute('href', ...)`. Le navigateur ALLAIT
  // BIEN CHERCHER la nouvelle icone, prouve par le journal du serveur, mais il
  // ne repeignait pas l'onglet : Ropat n'a rien vu. Aller chercher et peindre
  // sont deux choses, et ma mesure d'hier ne portait que sur la premiere.
  // Retirer le noeud et en poser un neuf force Chrome a reconsiderer l'icone
  // du document. C'est la seule forme qui marche de facon fiable.
  function poser(href) {
    const neuf = document.createElement('link');
    neuf.id = 'favicon';
    neuf.rel = 'icon';
    neuf.type = 'image/png';
    neuf.href = href;
    courant.replaceWith(neuf);
    courant = neuf;
  }

  function tourner() {
    // ⚠️ LA SORTIE SE PREND ICI, PAS AILLEURS, et elle se compte en IMAGES.
    // `image` revient a zero quand la huitieme vient d'etre affichee : c'est le
    // seul instant ou le tour est entier. Attendre celui-la, plutot que de
    // calculer un reste au chronometre, rend l'arret exact quoi qu'il arrive au
    // loader. La version precedente soustrayait le temps ecoule d'un tour et
    // bornait a zero : des que le loader s'attardait au-dela de 800 ms, le
    // reste valait zero et le radar se coupait en pleine image.
    if (finir && image === 0) {
      clearInterval(minuterie);
      minuterie = null;
      poser(ORIGINE);
      return;
    }
    poser(images[image]);
    image = (image + 1) % 8;
  }

  // ⚠️ NE COUPE PAS, DEMANDE LA SORTIE. Un tour commence va jusqu'au bout :
  // s'arreter a la troisieme image se lit comme un defaut d'affichage, pas
  // comme une intention. Le radar est de la decoration, arbitrage de Ropat du
  // 29/07/2026 ; une decoration qui s'interrompt en plein geste rate ce pour
  // quoi elle existe.
  // C'est deja la regle du loader de page, qui tient 800 ms apres `load` au
  // lieu de disparaitre net.
  function arreter() {
    if (minuterie === null) return;   // deja arrete, ou jamais parti
    finir = true;
  }

  // ── QUAND IL TOURNE, ET POURQUOI PAS PENDANT LE CHARGEMENT ──────────────
  //
  // ⚠️ PENDANT LE CHARGEMENT, L'ONGLET NE NOUS APPARTIENT PAS. Chrome y dessine
  // son propre indicateur, un anneau bleu tournant autour du favicon EN CACHE
  // pour cette URL. Releve par Ropat le 29/07/2026 : la premiere version de ce
  // module echangeait les images exactement dans cette fenetre, donc elle ne
  // pouvait rien montrer, quelle que soit la methode d'echange. Ni le
  // remplacement de noeud ni de vrais fichiers PNG n'y changent quoi que ce
  // soit : ce n'est pas une question de repeindre, c'est que la place est
  // prise. J'ai mesure si le navigateur ALLAIT CHERCHER l'icone, puis s'il la
  // REPEIGNAIT, sans jamais me demander s'il l'AFFICHAIT a ce moment-la.
  //
  // La fenetre utile est APRES `load` : Chrome rend l'onglet, et le loader de
  // page, lui, est encore a l'ecran. Il ne part pas a `load`, il attend 800 ms
  // puis s'efface sur 500 ms de plus. Le radar vit donc exactement le temps que
  // le loader est plein, et les deux disent la meme chose au meme instant.
  //
  // Consequence assumee : pas de loader, pas de radar. Le loader n'existe que
  // sur l'accueil (`_includes/pages/index.html`), donc le radar aussi. Le faire
  // tourner ailleurs serait de la decoration sans rien a accompagner.
  const loader = document.getElementById('pageLoader');
  if (!loader) return;

  window.addEventListener('load', function () {
    // `load` ne devrait se produire qu'une fois, mais un second passage
    // relancerait une minuterie par-dessus la premiere, et si le tour est deja
    // conclu elle reposerait l'icone d'origine toutes les 100 ms sans fin.
    if (minuterie !== null || finir) return;
    tourner();
    minuterie = setInterval(tourner, PAS_MS);

    // ⚠️ LA FIN EST LUE SUR LE LOADER, PAS RECOPIEE DE LUI. Le module de loader
    // pose la classe `loaded` quand il commence a s'effacer : on l'observe au
    // lieu de reecrire son 800 ms ici. Sinon les deux durees derivent le jour
    // ou l'une des deux change, et rien ne le signale.
    const obs = new MutationObserver(function () {
      if (!loader.classList.contains('loaded')) return;
      obs.disconnect();
      arreter();
    });
    obs.observe(loader, { attributes: true, attributeFilter: ['class'] });

    // Filet : si le loader disparaissait sans passer par `loaded`, le radar
    // tournerait indefiniment dans l'onglet. Trois tours et il rend la main.
    setTimeout(function () { obs.disconnect(); arreter(); }, PAS_MS * 24);
  });
})();

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
  // CHROME ESCAMOTABLE : toutes les pages
  // ================================
  // Il se retire quand on descend (on lit, on regarde) et revient quand on
  // remonte (on cherche a naviguer).
  //
  // ⚠️ Etendu a TOUTES les pages le 28/07, sur demande de Ropat. La garde
  // `pageProjet` a saute : le comportement etait justifie par l'oeuvre, mais
  // l'argument vaut plus largement, une barre qui suit pendant qu'on lit prend
  // de la hauteur d'ecran a du contenu sans rien apporter.
  // Seule la barre TRANSPARENTE sur l'ouverture reste propre a la page projet,
  // et elle est geree ailleurs, par `data-zone`.
  const chrome = document.querySelector('header');
  if (chrome) {
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
  if (barre) {
    const hauteurBarre = () => barre.getBoundingClientRect().height || 78;
    const ouverture = document.querySelector('.project-open');

    // ══════════════════════════════════════════════════════════════════════
    //  LA BASCULE D'ENCRE
    // ══════════════════════════════════════════════════════════════════════
    //  Le chrome passe en encre sombre quand le blanc n'est plus lisible sur
    //  ce qu'il surplombe, et revient au blanc sinon.
    //
    //  ⚠️ AUCUNE LISTE, AUCUNE CLASSE A POSER. Refonte du 28/07 sur demande de
    //  Ropat : « si j'ajoute un element clair sur une page il faut que le
    //  script s'applique directement a lui, sans qu'on ait a faire quoi que ce
    //  soit ». La version precedente enumerait deux classes de media, donc elle
    //  ignorait tout le reste : une section au fond clair, une image ajoutee
    //  plus tard, un bloc injecte par du JS. Une liste blanche est un reglage
    //  deguise, et il fallait la supprimer.
    //
    //  On INTERROGE donc la page au lieu de la decrire : `elementsFromPoint`
    //  rend la pile REELLE des elements sous un point, dans l'ordre de
    //  peinture, et elle inclut tout ce qui existe a cet instant. Un element
    //  ajoute une seconde plus tot y est. Il n'y a rien a declarer.
    //
    //  ⚠️ Ce n'est toujours PAS une lecture de l'arriere-plan composite :
    //  aucune API n'expose ca. On refait la PILE, couche par couche, du bas
    //  vers le haut : sol, fonds, degrades, pseudo-elements, images. La
    //  difference avec la version d'avant est qu'on ne choisit plus QUELLES
    //  couches comptent, on les prend toutes.
    //
    //  Le critere est un CONTRASTE et non une luminance, cadrage de Ropat : on
    //  bascule quand le texte cesse d'etre lisible, donc a 4,5:1, seuil WCAG.
    //  Rien a regler a la main.

    const lin = (c) => { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); };
    const LUM = (c) => 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
    const CONTRASTE = (a, b) => (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);

    // Resolution de couleur par le canvas : une expression reguliere ne sait
    // lire ni `color(srgb ...)` ni `oklch(...)`, et les navigateurs rendent
    // desormais ces formes-la.
    const cvC = document.createElement('canvas'); cvC.width = cvC.height = 1;
    const cxC = cvC.getContext('2d', { willReadFrequently: true });
    const cacheCouleur = new Map();
    const resoudre = (txt) => {
      if (cacheCouleur.has(txt)) return cacheCouleur.get(txt);
      cxC.clearRect(0, 0, 1, 1); cxC.fillStyle = '#000'; cxC.fillStyle = txt;
      cxC.clearRect(0, 0, 1, 1); cxC.fillRect(0, 0, 1, 1);
      const d = cxC.getImageData(0, 0, 1, 1).data;
      const out = { r: d[0], g: d[1], b: d[2], a: d[3] / 255 };
      cacheCouleur.set(txt, out); return out;
    };

    const composer = (fond, dessus) => {
      if (!dessus || dessus.a <= 0.003) return fond;
      const a = dessus.a;
      return { r: dessus.r * a + fond.r * (1 - a),
               g: dessus.g * a + fond.g * (1 - a),
               b: dessus.b * a + fond.b * (1 - a) };
    };

    // ── DEGRADES ────────────────────────────────────────────────────────
    // Seuls les degrades VERTICAUX sont evalues. Un oblique demanderait de
    // projeter le point sur l'axe du degrade : faisable, mais aucun n'existe
    // sur le site, et une implementation jamais exercee est une implementation
    // fausse qui s'ignore.
    const RE_COULEUR = /(?:rgba?|color|oklch|hsla?)\([^)]*\)|#[0-9a-fA-F]{3,8}/g;
    const cacheDegrade = new Map();
    const lireDegrade = (img) => {
      if (cacheDegrade.has(img)) return cacheDegrade.get(img);
      let out = null;
      if (img && img !== 'none' && /linear-gradient/.test(img)) {
        const dedans = img.slice(img.indexOf('(') + 1, img.lastIndexOf(')'));
        const parts = dedans.split(/,(?![^(]*\))/);
        // ⚠️ LA DIRECTION PEUT ETRE ABSENTE, et c'est le cas le plus COURANT.
        // Chrome omet `to bottom` de la valeur calculee, puisque c'est la
        // valeur par defaut de CSS. Ma premiere version exigeait le mot-cle,
        // donc elle ignorait silencieusement tout degre descendant ecrit sans
        // direction, c'est-a-dire la facon normale de les ecrire.
        // Trouve par un test d'injection : un voile noir a 95 % pose sur une
        // image ne changeait RIEN au verdict, au pixel pres.
        const tete = parts[0].trim();
        const aUneDirection = /^(to\s|[-\d.]+deg|[-\d.]+turn|[-\d.]+rad)/.test(tete);
        let versLeHaut = false, connu = true;
        if (!aUneDirection) versLeHaut = false;                 // defaut CSS : to bottom
        else if (/to top$/.test(tete)) versLeHaut = true;
        else if (/to bottom$/.test(tete)) versLeHaut = false;
        else if (/^0deg$|^360deg$/.test(tete)) versLeHaut = true;
        else if (/^180deg$/.test(tete)) versLeHaut = false;
        else connu = false;                                     // oblique : non traite
        if (connu) {
          const morceaux = aUneDirection ? parts.slice(1) : parts;
          const arrets = [];
          morceaux.forEach((m, i) => {
            const c = m.match(RE_COULEUR); if (!c) return;
            const pc = m.match(/(-?[\d.]+)%/);
            const p = pc ? parseFloat(pc[1]) / 100 : i / Math.max(1, morceaux.length - 1);
            arrets.push(Object.assign({ p: p }, resoudre(c[0])));
          });
          if (arrets.length >= 2) out = { arrets: arrets, versLeHaut: versLeHaut };
        }
      }
      cacheDegrade.set(img, out); return out;
    };
    const evaluerDegrade = (g, rect, y) => {
      if (rect.height < 1) return null;
      const t = g.versLeHaut ? (rect.bottom - y) / rect.height : (y - rect.top) / rect.height;
      const a = g.arrets;
      let i = 0; while (i < a.length - 2 && a[i + 1].p < t) i++;
      const d0 = a[i], d1 = a[i + 1];
      const k = d1.p === d0.p ? 0 : Math.min(1, Math.max(0, (t - d0.p) / (d1.p - d0.p)));
      return { r: d0.r + (d1.r - d0.r) * k, g: d0.g + (d1.g - d0.g) * k,
               b: d0.b + (d1.b - d0.b) * k, a: d0.a + (d1.a - d0.a) * k };
    };

    // ── IMAGES ET VIDEOS ────────────────────────────────────────────────
    // Une vignette de 96 px suffit pour une luminance : l'oeil ne juge pas la
    // lisibilite sur un pixel isole. Le canvas n'entre jamais dans le DOM.
    const LARGEUR_SONDE = 96;
    const vignettes = new WeakMap();
    const estPeinture = (el) => el.tagName === 'IMG' || el.tagName === 'VIDEO' || el.tagName === 'CANVAS';
    let compteurFrame = 0;

    // ⚠️ `object-fit` : le contenu peint ne remplit PAS la boite de l'element.
    // Projeter des coordonnees d'ecran sans en tenir compte fait echantillonner
    // a cote, et ca m'a eu deux fois en mesurant.
    const rectContenu = (el) => {
      const b = el.getBoundingClientRect();
      const nw = el.naturalWidth || el.videoWidth || el.width || 0;
      const nh = el.naturalHeight || el.videoHeight || el.height || 0;
      const fit = getComputedStyle(el).objectFit;
      if (!nw || !nh || fit === 'fill' || fit === 'none') return b;
      const rb = b.width / b.height, rn = nw / nh;
      let w, h;
      if (fit === 'cover') { if (rn > rb) { h = b.height; w = h * rn; } else { w = b.width; h = w / rn; } }
      else { if (rn > rb) { w = b.width; h = w / rn; } else { h = b.height; w = h * rn; } }
      return { left: b.left + (b.width - w) / 2, top: b.top + (b.height - h) / 2,
               width: w, height: h, right: b.left + (b.width + w) / 2,
               bottom: b.top + (b.height + h) / 2 };
    };

    // ⚠️ `manqueDonnees` distingue les deux facons dont une lecture peut rendre
    // null : le point est HORS du contenu peint (bande letterbox, cas normal),
    // ou le media n'est PAS ENCORE LISIBLE. Le second cas rend la mesure
    // incomplete, et il faut donc la refaire ; le premier non.
    let manqueDonnees = false;

    const pixelDe = (el, x, y) => {
      const r = rectContenu(el);
      if (x < r.left || x > r.right || y < r.top || y > r.bottom) return null;  // bande letterbox
      let v = vignettes.get(el);
      if (!v) {
        const nw = el.naturalWidth || el.videoWidth || el.width || 0;
        const nh = el.naturalHeight || el.videoHeight || el.height || 0;
        if (!nw || !nh) { manqueDonnees = true; return null; }
        const c = document.createElement('canvas');
        c.width = LARGEUR_SONDE; c.height = Math.max(1, Math.round(LARGEUR_SONDE * nh / nw));
        v = { c: c, x: c.getContext('2d', { willReadFrequently: true }), frame: -1 };
        vignettes.set(el, v);
      }
      // Une image ne se redessine jamais ; une video a chaque frame.
      if (v.frame < 0 || (el.tagName === 'VIDEO' && v.frame !== compteurFrame)) {
        try { v.x.drawImage(el, 0, 0, v.c.width, v.c.height); v.frame = compteurFrame; }
        catch (e) { manqueDonnees = true; return null; }   // pas encore decode, ou tainte
      }
      const sx = Math.min(v.c.width - 1, Math.max(0, Math.floor((x - r.left) / r.width * v.c.width)));
      const sy = Math.min(v.c.height - 1, Math.max(0, Math.floor((y - r.top) / r.height * v.c.height)));
      let d; try { d = v.x.getImageData(sx, sy, 1, 1).data; } catch (e) { manqueDonnees = true; return null; }
      return { r: d[0], g: d[1], b: d[2], a: d[3] / 255 };
    };

    // ── LA PILE REELLE SOUS UN POINT ────────────────────────────────────
    const SOL = () => resoudre(getComputedStyle(document.documentElement).getPropertyValue('--surface').trim() || '#030808');

    // ⚠️ CACHE DE STYLES, PAR FRAME. Sans lui, les 40 points relisaient les
    // memes elements encore et encore : la pile sous un point contient html,
    // body, la section, le conteneur... et ces elements sont les MEMES pour
    // presque tous les points. Mesure avant : 5,9 ms par frame sur une page
    // projet, soit 35 % du budget de 16,7 ms a 60 images par seconde. C'est du
    // gaspillage pur, pas le prix de la methode.
    // Le cache est vide a chaque frame : rien ne peut donc se peremer, et un
    // element qui change de style entre deux frames est vu.
    let cacheStyles = new Map();
    const style = (el, pseudo) => {
      const cle = pseudo ? pseudo : '';
      let m = cacheStyles.get(el);
      if (!m) { m = {}; cacheStyles.set(el, m); }
      if (m[cle] === undefined) {
        const cs = pseudo ? getComputedStyle(el, pseudo) : getComputedStyle(el);
        m[cle] = { fond: cs.backgroundColor, image: cs.backgroundImage,
                   contenu: pseudo ? cs.content : null,
                   position: cs.position, visibilite: cs.visibility, opacite: cs.opacity };
      }
      return m[cle];
    };

    const couleurEn = (x, y) => {
      const pile = document.elementsFromPoint(x, y);
      if (!pile.length) return null;
      let c = SOL();
      // `elementsFromPoint` rend du plus HAUT au plus BAS. On peint a l'envers,
      // donc du bas vers le haut.
      for (let i = pile.length - 1; i >= 0; i--) {
        const el = pile[i];
        if (el === barre || barre.contains(el)) continue;   // ne pas se mesurer soi-meme
        const cs = style(el, null);
        if (cs.visibilite === 'hidden' || cs.opacite === '0') continue;
        c = composer(c, resoudre(cs.fond));
        const g = lireDegrade(cs.image);
        if (g) c = composer(c, evaluerDegrade(g, el.getBoundingClientRect(), y));
        if (estPeinture(el)) {
          const p = pixelDe(el, x, y);
          if (p) c = composer(c, p);
        }
        // Les pseudo-elements ne sont pas dans la pile mais ils peignent.
        for (const pseudo of ['::before', '::after']) {
          const ps = style(el, pseudo);
          if (ps.contenu === 'none' || ps.position === 'static') continue;
          c = composer(c, resoudre(ps.fond));
          const gp = lireDegrade(ps.image);
          if (gp) c = composer(c, evaluerDegrade(gp, el.getBoundingClientRect(), y));
        }
      }
      return c;
    };

    // ── LA DECISION ─────────────────────────────────────────────────────
    // Chaque encre a son pire cas, et ce n'est pas le meme point : la claire
    // souffre du plus CLAIR, la sombre du plus SOMBRE. On ne prend pas les
    // extremes absolus, un point isole ne doit pas decider.
    const P_HAUT = 0.9, P_BAS = 0.1;
    const L_CLAIRE = LUM(resoudre('#F0F4F1'));
    const L_SOMBRE = LUM(resoudre('#05100F'));
    // ⚠️ UNE MARGE ADDITIVE, ET NON UN RAPPORT. Corrige le 28/07 apres releve
    // sur les 20 pages projet.
    // Un rapport de 1,25 semblait raisonnable, mais un ratio de contraste vit
    // entre 1 et 21 : 25 % ne veut pas dire la meme chose a 1,1 qu'a 15. Or la
    // decision se joue TOUJOURS en bas de cette echelle, la ou les deux encres
    // sont mediocres. Consequence mesuree : a-lone (3,51 contre 4,09), jpeja
    // (1,23 contre 1,39) et stelya (1,09 contre 1,36) gardaient l'encre claire
    // alors que la sombre etait meilleure, faute d'atteindre le rapport.
    // Une marge additive de 0,3 point est uniforme la ou ca compte.
    const MARGE = 0.3;
    const MAINTIEN = 400;        // ms entre deux bascules
    // ⚠️ AUCUNE MARGE SUR LE PREMIER CHOIX. L'hysteresis sert a resister a un
    // CHANGEMENT ; au chargement il n'y a rien a quoi resister, et lui imposer
    // une marge revient a privilegier arbitrairement l'encre claire.
    let etabli = false;
    let encreSombre = false, dernierChangement = 0, rappel = 0;

    // ⚠️ LA BASCULE N'A PAS BESOIN DE 60 Hz, et la faire tourner a cette
    // cadence etait le vrai cout. Mesure sur une page projet : 5,9 ms par
    // frame avant le cache de styles, 3,6 ms apres, soit encore 22 % du budget
    // de 16,7 ms. Le reste est le hit-test lui-meme, incompressible.
    // Plutot que d'echantillonner moins bien, on echantillonne moins SOUVENT :
    // 10 fois par seconde. La duree de maintien etant de 400 ms, ca laisse
    // quatre mesures par bascule, et l'oeil ne peut pas voir la difference.
    // Cout amorti : environ 36 ms par seconde de defilement, soit 3,6 % du
    // temps, contre 22 % a chaque frame.
    const PERIODE_MESURE = 100;
    let derniereMesure = 0;

    // ══════════════════════════════════════════════════════════════════
    //  ⚠️ CE QUE CETTE BASCULE NE RESOUT PAS, releve du 28/07 sur les 20
    //  pages projet. 17 sur 20 sont justes. Les trois autres sont CONNUS et
    //  laisses tels quels par Ropat : ce ne sont pas des regressions, et
    //  aucun reglage ne les corrige.
    //
    //  1. STELYA, le seul vrai defaut. Son fond est COUPE EN DEUX : sombre a
    //     gauche sous le logo, clair a droite sous la nav. Une barre qui n'a
    //     qu'une variante ne peut pas servir les deux, donc en `sombre` le
    //     logo devient sombre-sur-sombre et disparait presque.
    //     C'est exactement le cas qui avait tue la tentative du 27/07.
    //     La sortie EXISTE et elle est mesuree : un verdict par CONTROLE au
    //     lieu d'un pour la barre, le logo gardant l'orange et la nav passant
    //     au sombre. Ce desaccord entre controles est rare, 1 position sur 24
    //     dans les releves, mais il existe.
    //     ⚠️ Ce n'est pas une question technique : elle demande d'accepter
    //     qu'un header porte DEUX encres a la fois. Arbitrage de Ropat, en
    //     attente. Ne pas l'implementer sans le lui demander.
    //
    //  2. AELIO (clair 1,86 / sombre 1,30) et EXIT (1,96 / 1,04). Les deux
    //     encres sont mauvaises, le systeme prend le moindre mal, et c'est la
    //     politique documentee. Aucun reglage ne les sauve : il faudrait une
    //     COMPOSITION differente, un autre cadrage du hero ou une zone calme
    //     reservee en haut de l'oeuvre.
    //
    //  Ne pas « ameliorer » les seuils en visant ces trois pages : on
    //  degraderait les dix-sept autres pour rien.
    // ══════════════════════════════════════════════════════════════════
    // ⚠️ LA SURCHARGE EDITORIALE. Une piece peut FIGER l'encre du chrome, via
    // `chrome: clair` ou `chrome: sombre` dans son YAML, lu ici sur
    // `.project-page[data-chrome-fige]`.
    //
    // Ce n'est pas un retour de la liste blanche qu'on a supprimee, et la
    // nuance est le coeur du sujet : une liste blanche demande qu'on pense a
    // elle a chaque ajout et echoue en silence quand on oublie. Ici le DEFAUT
    // reste la mesure ; une page qui ne dit rien est traitee comme les autres.
    // Le champ n'existe que pour les EX AEQUO, ces cas ou les deux encres sont
    // a moins de la marge l'une de l'autre : la mesure n'a alors pas de
    // preference et le resultat depend de l'ordre, alors que l'oeil, lui,
    // tranche. Releve du 28/07 : stelya (1,09 / 1,36) et aelio (1,88 / 1,92),
    // les deux figes en `clair` par Ropat.
    const fige = (document.querySelector('.project-page[data-chrome-fige]') || {}).dataset;
    const ENCRE_FIGEE = fige ? fige.chromeFige : null;

    const majEncre = (bas, force) => {
      const maintenant = performance.now();
      if (!force && maintenant - derniereMesure < PERIODE_MESURE) return;
      derniereMesure = maintenant;
      compteurFrame++;
      cacheStyles = new Map();          // une passe, un cache
      manqueDonnees = false;
      const vals = [];
      barre.querySelectorAll('.logo, .nav-link, .nav-contact, .burger-menu').forEach(el => {
        const b = el.getBoundingClientRect();
        if (b.width < 1 || b.height < 1 || b.top > bas || b.bottom < 0) return;
        // Une grille grossiere par controle : ce qui decide, c'est la
        // distribution sous les glyphes, pas chaque pixel.
        for (let ix = 0; ix < 4; ix++) {
          for (let iy = 0; iy < 2; iy++) {
            const x = b.left + b.width * (ix + 0.5) / 4;
            const y = b.top + b.height * (iy + 0.5) / 2;
            if (x < 0 || y < 0 || x > innerWidth || y > innerHeight) continue;
            const c = couleurEn(x, y);
            if (c) vals.push(LUM(c));
          }
        }
      });
      if (!vals.length) return;
      // ⚠️ NE PAS CONCLURE SUR UNE MESURE INCOMPLETE. Une image pas encore
      // decodee ne contribue pas : les points qui la surplombent lisent le sol
      // nu, donc quasi noir, ce qui EFFONDRE le pire cas de l'encre sombre et
      // fait choisir le clair a tort.
      // Symptome releve sur les 20 pages projet : `crow` rendait
      // « sombre 4,83 » a un passage et « sombre 1,06 » au suivant, sur la
      // meme page. Un etat correct qui depend du hasard du decodage n'est pas
      // un etat correct.
      if (manqueDonnees) { clearTimeout(rappel); rappel = setTimeout(() => majEncre(hauteurBarre(), true), 200); return; }
      vals.sort((a, b) => a - b);
      const q = (f) => vals[Math.min(vals.length - 1, Math.floor(f * (vals.length - 1)))];
      const haut = q(P_HAUT), basL = q(P_BAS);

      // Le garde-fou CSS : la variante sombre n'existe que sous cet attribut.
      // Il ne depend plus d'une classe de media mais du fond RECONSTRUIT, donc
      // il se pose des que le fond s'ecarte vraiment du sol.
      if (haut > 0.05) barre.setAttribute('data-sur-media', '');
      else barre.removeAttribute('data-sur-media');

      const pireClair = CONTRASTE(L_CLAIRE, haut);
      const pireSombre = CONTRASTE(L_SOMBRE, basL);
      if (window.__debugEncre) {
        barre.setAttribute('data-dbg', 'clair ' + pireClair.toFixed(2) + ' / sombre ' + pireSombre.toFixed(2) + ' / n=' + vals.length);
      }
      // La surcharge court-circuite la DECISION, pas la mesure : `data-sur-media`
      // vient d'etre pose au-dessus, donc le garde-fou CSS reste juste, et les
      // valeurs restent lisibles en debug pour comprendre pourquoi on a fige.
      const veutSombre = ENCRE_FIGEE ? (ENCRE_FIGEE === 'sombre')
        : (!etabli
        ? pireSombre > pireClair                          // premier choix : le meilleur, point
        : (encreSombre ? !(pireClair > pireSombre + MARGE)
                       : pireSombre > pireClair + MARGE));
      if (veutSombre === encreSombre && etabli) return;
      if (!etabli) {
        etabli = true; dernierChangement = performance.now();
        encreSombre = veutSombre;
        if (encreSombre) barre.setAttribute('data-encre', 'sombre');
        else barre.removeAttribute('data-encre');
        return;
      }
      const t = performance.now();
      const reste = MAINTIEN - (t - dernierChangement);
      if (reste > 0) {
        // Sans ce rappel l'etat pouvait rester FAUX indefiniment : la bascule
        // n'est recalculee que sur scroll et resize, donc si la derniere frame
        // d'un geste tombait dans la duree de maintien, plus rien ne repassait.
        clearTimeout(rappel); rappel = setTimeout(() => majEncre(hauteurBarre(), true), reste + 20); return;
      }
      dernierChangement = t;
      encreSombre = veutSombre;
      if (encreSombre) barre.setAttribute('data-encre', 'sombre');
      else barre.removeAttribute('data-encre');
    };

    const majFond = () => {
      const bas = hauteurBarre();
      // La barre surplombe-t-elle encore l'ouverture ? Tant que oui, elle se
      // pose sur l'oeuvre : ni fond ni bordure, sinon elle l'encadre.
      if (ouverture) {
        const o = ouverture.getBoundingClientRect();
        if (o.bottom > 0 && o.top < bas) barre.setAttribute('data-zone', 'ouverture');
        else barre.removeAttribute('data-zone');
      }
      majEncre(bas, false);
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

    // ⚠️ SANS CE QUI SUIT, RIEN NE RECALCULE TANT QU'ON NE DEFILE PAS, et deux
    // cas reels tombent alors a cote.
    //
    // 1. AU CHARGEMENT. Si une image n'est pas encore decodee a la premiere
    //    mesure, elle ne contribue pas : le fond est lu comme le sol nu et
    //    l'encre reste claire a tort. Trouve en comparant deux sondes, l'une
    //    qui defilait et l'autre non : sipsmith rendait `sombre` avec la
    //    premiere et `clair` avec la seconde, sur la meme page.
    //    `load` couvre les images normales, pas les images differees.
    //
    // 2. QUAND LA PAGE CHANGE. C'est la demande de Ropat : « si j'ajoute un
    //    element clair sur une page il faut que le script s'applique
    //    directement a lui ». Un element ajoute sans que l'utilisateur defile
    //    n'aurait jamais ete vu.
    //
    // L'observateur est borne par les deux etranglements deja en place : une
    // frame d'animation, puis 100 ms. Une rafale de mutations coute donc une
    // seule mesure.
    // ⚠️ TROIS RENDEZ-VOUS NE SUFFISAIENT PAS. Releve sur les 20 pages projet :
    // hors-champ rendait `clair` a un passage et `sombre` au suivant, sur la
    // meme page, parce que son image n'etait pas decodee a la derniere mesure.
    // Un etat correct qui depend du hasard du decodage n'est pas un etat
    // correct. On mesure donc a intervalle regulier pendant les premieres
    // secondes, jusqu'a ce que deux mesures consecutives s'accordent.
    // Quelques rendez-vous au chargement : le vrai filet est `manqueDonnees`
    // ci-dessus, qui refait la mesure tant qu'un media n'est pas lisible. Ceux-ci
    // couvrent le reste (polices, mise en page qui se pose, images differees).
    [250, 700, 1600, 3200].forEach(d => setTimeout(planifier, d));

    if ('MutationObserver' in window) {
      const observateur = new MutationObserver(entrees => {
        // ⚠️ Ignorer nos PROPRES ecritures, sinon poser `data-encre` declenche
        // une mesure qui repose `data-encre` : la boucle serait bornee par les
        // etranglements, mais elle tournerait pour rien en permanence.
        for (const e of entrees) {
          const c = e.target;
          if (c === barre || (barre.contains && barre.contains(c))) continue;
          planifier();
          return;
        }
      });
      observateur.observe(document.body, {
        childList: true, subtree: true,
        attributes: true, attributeFilter: ['style', 'class', 'src', 'hidden']
      });
    }

    // Une image qui finit de charger APRES tout le reste (chargement differe,
    // lightbox, carrousel) doit elle aussi declencher une mesure.
    document.addEventListener('load', planifier, true);
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
    // ⚠️ La forme de coin doit etre posee ICI aussi. Ce bouton est dessine par
    // le JS avec un style en ligne : aucune regle CSS ne l'atteint, donc le
    // passage au squircle du 28/07 l'avait laisse rond. Meme piege que les deux
    // couleurs trouvees le matin meme, et meme lecon : ce qui est ecrit depuis
    // le JS echappe a tout balayage de la feuille de style.
    cornerShape:     'squircle',
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
// BARRE DE DEFILEMENT SUR MESURE
// ================================
//
// ⚠️ AMELIORATION PROGRESSIVE, PAS UN REMPLACEMENT SEC. La barre native n'est
// masquee qu'a la DERNIERE ligne de ce module, une fois la sienne posee et
// branchee. Sans JS, ou si ce bloc jette avant la fin, la barre native stylee
// de base/_scrollbar.scss reste en place : on ne retire jamais un moyen de
// defiler sur une promesse.
//
// Elle existe pour une raison mesuree et une seule : une gouttiere native est
// HORS de la zone de contenu, Chrome y ecrete les elements `position: fixed`,
// donc le dither ne peut pas y peindre et la bande restait plate le long d'un
// fond texture. Le detail est dans base/_scrollbar.scss.
(function () {
  const doc = document.documentElement;

  // Elle ne sert que la ou la barre native VOLE de la place. Sur les systemes
  // a barre flottante (tactile) la gouttiere vaut zero, le dither atteint deja
  // le bord, et il n'y a rien a corriger.
  //
  // ⚠️ LA QUESTION SE POSE A UNE SONDE, PAS AU DOCUMENT. Mesurer
  // `innerWidth - clientWidth` aurait rendu zero sur une page qui ne defile pas
  // ENCORE au chargement, images non arrivees : le module se serait tu, et la
  // barre native serait reapparue quand la page a grandi. La sonde repond a la
  // vraie question, « une barre prend-elle de la place sur cette plateforme »,
  // et elle y repond meme sur une page courte.
  const sonde = document.createElement('div');
  sonde.style.cssText = 'position:absolute;top:-9999px;width:100px;height:100px;overflow:scroll';
  document.body.appendChild(sonde);
  const gouttiere = sonde.offsetWidth - sonde.clientWidth;
  sonde.remove();
  if (gouttiere === 0) return;

  const TAILLE_MIN = 44;   // en dessous, le pouce n'est plus une prise
  const DELAI = 900;       // ms d'immobilite avant que le pouce s'efface
  const ZONE_BORD = 28;    // px depuis le bord droit qui le font reapparaitre

  const barre = document.createElement('div');
  barre.className = 'scrollbar';
  // Purement une prise a la souris : le clavier et les lecteurs d'ecran
  // defilent par leurs propres moyens, que masquer la barre native ne touche
  // pas. L'annoncer serait du bruit.
  barre.setAttribute('aria-hidden', 'true');
  const pouce = document.createElement('div');
  pouce.className = 'scrollbar-thumb';
  barre.appendChild(pouce);
  document.body.appendChild(barre);

  let position = 0;        // derniere ordonnee peinte, en px depuis le haut
  let saisie = null;
  let enAttente = false;
  let utilisable = false;  // la page defile-t-elle, et n'est-elle pas verrouillee
  let auBord = false;      // le pointeur est-il dans la zone du bord droit
  let minuterie = null;

  // ── Apparition et effacement ────────────────────────────────────────────
  // Deux etats distincts, et les confondre serait faux : `utilisable` dit s'il
  // y a quelque chose a montrer, `data-actif` dit si on le montre maintenant.
  function effacer() {
    clearTimeout(minuterie);
    if (barre.dataset.actif !== 'false') barre.dataset.actif = 'false';
  }

  function montrer() {
    if (!utilisable) return;
    // Ecrire un attribut a la valeur qu'il a deja reste une mutation, et le
    // defilement passe ici a chaque evenement.
    if (barre.dataset.actif !== 'true') barre.dataset.actif = 'true';
    clearTimeout(minuterie);
    // Tant que le pointeur est au bord ou que le pouce est saisi, rien ne
    // s'efface : on ne retire pas une prise sous la main de quelqu'un.
    if (auBord || saisie) return;
    minuterie = setTimeout(effacer, DELAI);
  }

  function peindre() {
    const hauteurDoc = doc.scrollHeight;
    const vue = window.innerHeight;
    const course = hauteurDoc - vue;

    // Lecture d'un style EN LIGNE, pas de `getComputedStyle` : c'est
    // exactement ce que pose le verrouillage de la lightbox et de la nav
    // (`body.style.overflow = 'hidden'`), et une lecture calculee a chaque
    // image forcerait un recalcul de disposition pour rien.
    const verrouille = document.body.style.overflow === 'hidden';

    utilisable = course > 0 && !verrouille;
    if (!utilisable) {
      effacer();
      return;
    }

    const piste = barre.clientHeight;
    const hauteur = Math.max(TAILLE_MIN, Math.round(piste * vue / hauteurDoc));
    const libre = piste - hauteur;
    position = libre > 0 ? (window.scrollY / course) * libre : 0;

    pouce.style.height = hauteur + 'px';
    pouce.style.transform = 'translateY(' + position + 'px)';
  }

  // Toutes les entrees passent par une seule image : molette, redimensionnement
  // et changement de hauteur du document ne peuvent pas se peindre trois fois.
  function demander() {
    if (enAttente) return;
    enAttente = true;
    requestAnimationFrame(function () {
      enAttente = false;
      peindre();
    });
  }

  pouce.addEventListener('pointerdown', function (e) {
    // ⚠️ PAS DE `preventDefault()` ICI, ET CE N'EST PAS UN OUBLI.
    // Il y en avait un, pour empecher la selection de texte pendant le glisser.
    // Effet de bord mesure le 29/07/2026 : `preventDefault` sur `pointerdown`
    // supprime les evenements souris de COMPATIBILITE pour ce pointeur. Or le
    // curseur sur mesure n'ecoute que `mousemove` (script.js:50). Comptage
    // pendant un glisser reel : 0 `mousemove` contre des `pointermove` qui
    // arrivent normalement. Le blob restait donc fige pendant qu'on faisait
    // defiler la page avec le pouce.
    // La selection de texte est desormais empechee par `user-select`, qui ne
    // coupe rien d'autre.
    pouce.setPointerCapture(e.pointerId);
    saisie = { depart: e.clientY, origine: position };
    barre.dataset.saisi = 'true';
    doc.classList.add('scrollbar-saisie');
  });

  pouce.addEventListener('pointermove', function (e) {
    if (!saisie) return;
    const libre = barre.clientHeight - pouce.offsetHeight;
    if (libre <= 0) return;
    const course = doc.scrollHeight - window.innerHeight;
    const y = Math.min(libre, Math.max(0, saisie.origine + (e.clientY - saisie.depart)));

    // ⚠️ `instant` EST OBLIGATOIRE ICI. `html` porte `scroll-behavior: smooth`
    // (base/_reset.scss:16), donc un `scrollTo` par defaut lancerait une
    // animation a chaque mouvement du pointeur : le pouce trainerait derriere
    // la souris et le glisser deviendrait inutilisable.
    window.scrollTo({ top: (y / libre) * course, behavior: 'instant' });
  });

  function relacher() {
    if (!saisie) return;
    saisie = null;
    barre.dataset.saisi = 'false';
    doc.classList.remove('scrollbar-saisie');
    montrer();   // relance la minuterie, que la saisie tenait suspendue
  }
  pouce.addEventListener('pointerup', relacher);
  pouce.addEventListener('pointercancel', relacher);

  window.addEventListener('scroll', function () {
    demander();
    montrer();
  }, { passive: true });
  window.addEventListener('resize', demander, { passive: true });

  // Le pouce reapparait quand le pointeur approche du bord droit, sans quoi il
  // faudrait viser un element invisible pour le saisir a l'arret.
  // On ne fait rien tant que l'etat ne CHANGE pas : cet evenement se declenche
  // des centaines de fois par seconde, et la comparaison est tout ce qu'il
  // paie dans l'immense majorite des cas.
  window.addEventListener('pointermove', function (e) {
    const bord = e.clientX >= doc.clientWidth - ZONE_BORD;
    if (bord === auBord) return;
    auBord = bord;
    montrer();
  }, { passive: true });

  // La hauteur du document bouge sans qu'on defile : images qui arrivent,
  // revelations, filtre du portfolio qui recompose la grille. Sans cette
  // observation le pouce garderait la taille d'une page qui n'existe plus.
  if (window.ResizeObserver) new ResizeObserver(demander).observe(document.body);

  peindre();

  // Dernier geste, et seulement maintenant : la gouttiere native disparait.
  doc.classList.add('custom-scrollbar');
  // La zone de contenu vient de gagner la largeur de la gouttiere, donc les
  // hauteurs calculees juste au-dessus sont perimees d'une image.
  demander();
})();

// ================================
// PARALLAX HERO IMAGE : RETIRE LE 29/07/2026
// ================================
//
// ⚠️ 53 LIGNES QUI NE POUVAIENT PLUS RIEN FAIRE. Le bloc cherchait
// `.hero-project` et sortait aussitot : cette classe est absente des 63 pages
// construites, comme `.hero-project-title-container` et `.hero-image-container`
// qu'il visait ensuite. Le hero projet en deux colonnes a ete remplace par une
// ouverture bord a bord (`.project-open`) pendant la Phase 1.
// Le code etait donc telecharge et analyse sur chaque page pour s'arreter a sa
// premiere ligne utile, et son propre commentaire le disait deja. Un
// commentaire qui signale du code mort ne le supprime pas.
//
// Ce qu'il faisait, pour la Phase 4 qui devra le refaire sur la bonne cible :
// fondu et flou progressifs du hero au defilement, plus trois couches a
// vitesses distinctes (0,06 / 0,10 / 0,18) avec une legere mise a l'echelle sur
// la derniere. Recuperable dans l'historique.
