// ============================================================================
//  FOND DITHER TRICOLORE — moteur
//
//  Remplace l'image de fond du site (main-bg.webp, 453 Ko) par un rendu
//  procedural en shader. Le fond DEFILE avec le document, se REFERME sur
//  lui-meme tous les `periode` pixels, et se DEFORME lentement sur place.
//  Un clic dans le vide y revele le logo un court instant.
//
//  Reglages et mesures : docs/CHANTIER-HERO-HOME-2026-07.md
//
//  USAGE
//    const fond = RopatDither.init(canvas);            // valeurs retenues
//    const fond = RopatDither.init(canvas, { ... });    // surcharges
//    fond.detruire();
//
//  Rend `null` si WebGL est indisponible : c'est alors la couleur de fond CSS
//  qui prend le relais. Le chemin CPU du fichier de chantier n'est PAS embarque
//  ici, il est dix fois trop lent pour servir de repli reel.
//
//  Script classique, pas un module : meme convention que assets/js/script.js.
// ============================================================================

window.RopatDither = (function () {
  'use strict';

  // --- VALEURS RETENUES (Ropat, juillet 2026) ---------------------------------
  // Chacune est le resultat d'une mesure, pas d'un gout au hasard. Les
  // justifications sont dans le chantier ; l'essentiel en une ligne chacune :
  const DEFAUTS = {
    // TRIO ASSOMBRI (21/07/2026). Le plancher ne bouge pas, les deux autres
    // descendent d'un cran : le releve devient l'ancienne mediane.
    //
    // Motif : le fond paraissait plus clair que l'ancienne image, et c'etait
    // mesure (L* 4,56 contre 3,12). Or la clarte moyenne est fixee par la
    // repartition : viser 20 % de releve imposait un fond plus clair. Plutot
    // que de sacrifier le 50/30/20, on abaisse le trio.
    // Resultat : L* moyen 3,10 a 50/30/20, soit la clarte de l'ancienne image.
    //
    // ⚠️ PRIX A CONNAITRE : la separation tombe de dE 6,3/6,4 a 3,1/3,2, donc
    // la texture est deux fois plus discrete. Elle reste perceptible (au-dela
    // de 3, on voit d'un coup d'oeil) mais c'est un fond qui murmure.
    // L'orange tient partout : 6,51 / 6,29 / 6,05.
    couleurs: ['#030808', '#030F0C', '#051510'],
    blaze: '#FF5C00',

    pixelScale: 2,     // grosseur du pixel
    trame: 1,          // cellule de Bayer, en px de canvas. 0 = aucune trame
    aplat: 8,          // carreau qui aplatit le champ. 0 ou 1 = aucun

    // RECUL : retrecit les formes sans toucher au pixel.
    // Une forme mesure 64 x pixelScale / recul px CSS, soit 128 px ici.
    // A pleine echelle (recul 1) le bruit reste interpole : des taches
    // lissees, 8,4 par hauteur d'ecran de 1080.
    //
    // ⚠️ CONTRAINTE : `periode x 64 / recul` doit tomber sur un nombre ENTIER
    // de lignes de canvas ET depasser LARGEMENT le carreau d'aplat, sinon tous
    // les carreaux echantillonnent le meme point et l'ecran devient uniforme.
    // La periode SUIT donc le recul : elle se compte en formes. A recul 128 il
    // fallait 1024 pour un raccord de 1024 px ; a recul 1 il faut 8, la meme
    // valeur laissee en place aurait donne un raccord a 131 072 px, autant
    // dire jamais.
    recul: 1,
    periode: 8,        // raccord tous les 1024 px CSS

    // 0.24 / 4.0 donne 50/30/20, la repartition visee. Etait passee a 0.36
    // pour assombrir, puis ramenee ici : c'est le TRIO qui a ete abaisse a la
    // place, ce qui rend la profondeur sans sacrifier le mouchetage.
    //
    // A noter : la LISIBILITE n'a jamais ete en cause. Contraste avec le texte
    // 19,07:1 contre 19,64:1 pour l'ancienne image, et agitation locale a
    // 0,68x celle de l'ancienne, donc un fond plus CALME sous le texte. Le
    // grief portait sur un fond qui reculait moins, pas sur la lecture.
    assise: 0.24,
    etalement: 4.0,

    // EVOLUTION du champ, l'equivalent du curseur Evolution de Fractal Noise
    // sous After Effects : le motif se transforme SUR PLACE, il ne glisse pas.
    // Une unite de temps renouvelle entierement le champ ; le module avance de
    // 0,012 x vitesse unite par seconde, d'ou un cycle de 1/(0,012 x vitesse).
    //
    // Porte de 1 a 4 le 21/07/2026 : a 1, l'evolution ne changeait que 1,4 %
    // de l'ecran par seconde (cycle de 83 s), donc invisible sans comparer
    // deux captures. A 4, cycle de 21 s, environ 6 %/s : ca vit sans agiter.
    // Mesure de l'echelle : 3 -> 4,6 %/s · 8 -> 13,3 %/s · 20 -> 32,5 %/s.
    // Au-dela de 20 ca sature, le champ se renouvelant deja entre deux images.
    vitesse: 4.0,
    curseur: 1.2,      // force du halo et de la derive au repos

    // ⏸ EN STAND BY (21/07/2026) : le revele au clic ne rendait pas bien.
    // Rien n'est supprime — mecanisme, courbes, chargement du logo et filtre
    // du clic restent en place. `revele: true` le rallume, c'est tout.
    // Le bac a sable l'active explicitement, il est fait pour l'essayer.
    revele: false,
    logoPlein: false,      // false = le dessin d'origine, en contour
    logoLarge: 0.55,       // part de la largeur d'ecran occupee par le logo
    logoSecours: '/assets/images/branding/logo%20ropat%20orange.svg'
  };

  // Cellules et periode doivent DIVISER 64 : une periode vaut `periode` x 64
  // lignes de canvas, donc une taille qui ne divise pas 64 couperait le raccord
  // en deux et laisserait une couture au bouclage.

  // --- MATRICE DE BAYER 4x4 ---------------------------------------------------
  const BAYER = [
    [0, 8, 2, 10],
    [12, 4, 14, 6],
    [3, 11, 1, 9],
    [15, 7, 13, 5]
  ];

  const VERT = `
    attribute vec2 aPos;
    void main() { gl_Position = vec4(aPos, 0.0, 1.0); }
  `;

  const FRAG = `
    precision highp float;

    uniform vec2  uResolution;
    uniform float uTime;
    uniform float uScrollLines;
    uniform vec2  uMouse;
    uniform float uMouseForce;
    uniform float uAssise;
    uniform float uEtalement;
    uniform float uPeriode;

    // DEUX REGLAGES INDEPENDANTS, et c'est le point :
    //   uTrame : taille de la cellule de Bayer. 0 = aucune trame (seuil fixe).
    //   uAplat : taille du carreau qui aplatit le champ. 1 = aucun aplatissement.
    // Les confondre interdisait la combinaison la plus interessante : une trame
    // GROSSE sur un champ CONTINU.
    uniform float uTrame;
    uniform float uAplat;
    uniform float uRecul;   // retrecit les formes du bruit, pas le pixel

    // LE REVELE. 0 = camouflage au repos, 1 = logo pleinement apparu.
    uniform sampler2D uLogo;
    uniform float uReveal;      // l'encre du logo
    uniform float uGrain;       // resserrement du carreau, plus rapide
    uniform float uLogoLarge;   // largeur du logo, en pixels de canvas
    uniform vec3  uBlaze;
    uniform vec3  uC0, uC1, uC2;
    uniform sampler2D uBayer;

    // Hachage stable en 32 bits (Dave Hoskins). Le classique
    // fract(sin(...) * 43758.5453) est inutilisable ici : il prend la partie
    // fractionnaire d'un nombre proche de 43 000, ce qui ne laisse que deux ou
    // trois decimales fiables en float 32 bits. Mesure a l'appui, ca deformait
    // la distribution (+50 % de releve) et cassait la dominante sombre.
    float pseudoNoise(vec3 p) {
      vec3 p3 = fract(p * 0.1031);
      p3 += dot(p3, p3.zyx + 31.32);
      return fract((p3.x + p3.y) * p3.z);
    }

    // Value noise 3D interpole (Hermite), RACCORDABLE EN X ET Y.
    //
    // La 3e dimension est LE TEMPS. Le motif se DEFORME sur place au lieu de
    // glisser : une translation verticale aurait ete indiscernable du
    // defilement de la page, qui translate deja verticalement.
    //
    // Seuls x et y sont replies sur la periode ; z n'est pas borne, le temps
    // n'ayant pas a boucler. Le motif reste donc periodique en espace a chaque
    // instant, tout en evoluant.
    // (Pas d'accent grave dans ce bloc : il est dans un litteral gabarit JS.)
    float smoothNoise3D(vec3 p, float per) {
      vec3 i = floor(p);
      vec3 f = p - i;
      vec3 u = f * f * (3.0 - 2.0 * f);

      vec2 xy0 = mod(i.xy, per);
      vec2 xy1 = mod(i.xy + 1.0, per);   // le voisin de la derniere cellule est la premiere
      float z0 = i.z, z1 = i.z + 1.0;

      float a000 = pseudoNoise(vec3(xy0.x, xy0.y, z0));
      float a100 = pseudoNoise(vec3(xy1.x, xy0.y, z0));
      float a010 = pseudoNoise(vec3(xy0.x, xy1.y, z0));
      float a110 = pseudoNoise(vec3(xy1.x, xy1.y, z0));
      float a001 = pseudoNoise(vec3(xy0.x, xy0.y, z1));
      float a101 = pseudoNoise(vec3(xy1.x, xy0.y, z1));
      float a011 = pseudoNoise(vec3(xy0.x, xy1.y, z1));
      float a111 = pseudoNoise(vec3(xy1.x, xy1.y, z1));

      float bas  = mix(mix(a000, a100, u.x), mix(a010, a110, u.x), u.y);
      float haut = mix(mix(a001, a101, u.x), mix(a011, a111, u.x), u.y);
      return mix(bas, haut, u.z);
    }

    // Trois octaves (0.5 / 0.25 / 0.125). La periode suit la frequence, sinon
    // les octaves ne se refermeraient pas ensemble et le raccord serait visible.
    float fbm(vec3 p, float per) {
      float v = 0.0, amp = 0.5, freq = 1.0;
      for (int i = 0; i < 3; i++) {
        v += amp * smoothNoise3D(p * freq, per * freq);
        freq *= 2.0;
        amp *= 0.5;
      }
      return v;
    }

    void main() {
      // gl_FragCoord part d'en BAS, le canvas 2D d'en HAUT : on retourne y.
      float x = gl_FragCoord.x - 0.5;
      float y = uResolution.y - gl_FragCoord.y - 0.5;

      // Coordonnees ANCREES AU DOCUMENT : la grille de cellules doit defiler
      // avec la page, sinon les carreaux glisseraient sous le contenu.
      vec2 pDoc = vec2(x, y + uScrollLines);
      vec2 pTrame = pDoc;

      // APLAT : un seul echantillon par carreau, pris en son centre, ce qui
      // aplatit tout le carreau. N'affecte QUE l'echantillonnage du champ.
      //
      // Pendant le revele, le carreau se resserre vers 1 : le camouflage ne se
      // contente pas de se resoudre, il se PRECISE. Necessite autant
      // qu'intention : a 24 px de carreau, une hampe du logotype couvre moins
      // d'un carreau, donc le logo serait illisible.
      // Pilote par uGrain et non uReveal : le grain se resserre AVANT que
      // l'encre ne paraisse, ce qui donne au clic une reponse immediate.
      float aplatEff = uAplat;
      if (uAplat > 1.5) aplatEff = mix(uAplat, 1.0, uGrain);

      if (aplatEff > 1.5) {
        vec2 cell = floor(pDoc / aplatEff);
        pDoc = (cell + 0.5) * aplatEff;
      }

      // Le curseur vit en coordonnees d'ECRAN : on retire le defilement.
      float yEcran = pDoc.y - uScrollLines;
      float dist = length(vec2(pDoc.x, yEcran) - uMouse);

      float distFactor = 0.0;
      if (dist < 120.0) distFactor = (1.0 - dist / 120.0) * uMouseForce;

      // 1/64 et non 0.015 : il FAUT que la periode tombe sur un nombre entier
      // de lignes de canvas, sinon aucun defilement ne retombe jamais sur un
      // raccord. Avec 1/64, une unite de bruit = 64 lignes, pile.
      //
      // uRecul retrecit les FORMES sans toucher a la grosseur du pixel.
      float noiseScale = uRecul / 64.0;
      float nx = pDoc.x * noiseScale + sin(yEcran * 0.02 + uTime * 40.0) * distFactor * 0.3;
      float ny = pDoc.y * noiseScale;

      // Le temps est la 3e coordonnee : le motif se deforme, il ne glisse pas.
      float val = fbm(vec3(nx, ny, uTime), uPeriode) * (1.0 / 0.875);

      // fbm se concentre autour de sa moyenne, donc sans correction c'est la
      // MEDIANE qui occupe le fond : elle apparait dans les DEUX bandes, elle a
      // deux chances de sortir. Une simple courbe de gamma ne suffit pas, elle
      // fait disparaitre le releve. D'ou deux reglages independants :
      //   assise    decale la masse vers le sombre
      //   etalement ecarte la distribution, pour garder le releve en mouchetage
      val = (val - 0.5) * uEtalement + 0.5 - uAssise;
      val = clamp(val, 0.0, 1.0);

      if (dist < 150.0) val += (1.0 - dist / 150.0) * 0.35 * uMouseForce;
      val = clamp(val, 0.0, 1.0);

      // LE REVELE : le champ se deforme vers la silhouette du logo.
      // En coordonnees d'ECRAN, pas de document : la forme doit paraitre la ou
      // se porte le regard, pas a une position figee dans la page.
      float encre = 0.0;
      if (uGrain > 0.001) {
        vec2 boite = vec2(uLogoLarge, uLogoLarge * 36.0 / 123.0);
        vec2 coin = (uResolution - boite) * 0.5;
        vec2 uv = (vec2(pDoc.x, yEcran) - coin) / boite;
        if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0) {
          // Pas de retournement en V : sans UNPACK_FLIP_Y_WEBGL, la premiere
          // ligne du canvas source atterrit deja en V=0, donc en haut.
          encre = texture2D(uLogo, uv).r * uReveal;
        }
        // Hors du logo, le champ s'assombrit : la forme se detache au lieu de
        // se surimprimer sur un fond inchange.
        val = mix(val, 0.0, uGrain * 0.55);
      }

      // Le SEUIL. uTrame a 0 signifie aucune trame : le seuil reste a 0.5 et on
      // obtient une quantification franche, donc des aplats.
      // L'indice de Bayer se calcule sur les coordonnees d'ORIGINE divisees par
      // uTrame, jamais sur le carreau d'aplat : c'est ce qui rend les deux
      // reglages reellement independants.
      float seuil = 0.5;
      if (uTrame > 0.5) {
        vec2 bc = mod(floor(pTrame / uTrame), 4.0);
        // La texture stocke v*17, donc texture2D rend v/15 : on remet a v/16.
        seuil = texture2D(uBayer, (bc + 0.5) / 4.0).r * (15.0 / 16.0);
      }

      vec3 couleur;
      if (val < 0.5) couleur = (val * 2.0        > seuil) ? uC1 : uC0;
      else           couleur = ((val - 0.5) * 2.0 > seuil) ? uC2 : uC1;

      // L'encre du logo passe par la MEME trame que le fond : elle se compose
      // en pixels, elle n'est pas posee par-dessus. C'est ce qui la fait
      // emerger du camouflage au lieu d'y etre collee.
      if (encre > seuil) couleur = uBlaze;

      gl_FragColor = vec4(couleur, 1.0);
    }
  `;

  // --- RYTHME DU REVELE -------------------------------------------------------
  //
  // DEUX COURBES, parce qu'il y a deux choses a faire en meme temps.
  //   Le GRAIN (le carreau qui se resserre) est la reponse au clic : il part
  //   tout de suite, donc ease-out et court. C'est lui qui dit "j'ai entendu",
  //   et il rend le depart lent de l'encre acceptable.
  //   L'ENCRE (le logo qui parait) est la revelation : rien n'entre, le champ
  //   se transforme, donc ease-in-out. Son demarrage lent porte le sens, le
  //   camouflage resiste avant de ceder.
  //
  // Ce n'est PAS un retour de bouton : rien n'est soumis, rien n'attend. Donc
  // pas de plafond a 300 ms.
  const REV_GRAIN = 220;    // ms, la reponse
  const REV_MONTEE = 900;   // ms, la revelation
  const REV_TENUE = 700;
  const REV_RETOUR = 1100;

  // Resolution de bezier cubique facon navigateur (Newton-Raphson), pour
  // disposer en JS des memes courbes qu'en feuille de style.
  function bezier(x1, y1, x2, y2) {
    const cx = t => 3 * x1 * t * (1 - t) ** 2 + 3 * x2 * t * t * (1 - t) + t ** 3;
    const cy = t => 3 * y1 * t * (1 - t) ** 2 + 3 * y2 * t * t * (1 - t) + t ** 3;
    const dcx = t => 3 * x1 * ((1 - t) ** 2 - 2 * t * (1 - t)) + 3 * x2 * (2 * t * (1 - t) - t * t) + 3 * t * t;
    return x => {
      let t = x;
      for (let i = 0; i < 8; i++) {
        const e = cx(t) - x;
        if (Math.abs(e) < 1e-6) break;
        const d = dcx(t);
        if (Math.abs(d) < 1e-6) break;
        t -= e / d;
      }
      return cy(t < 0 ? 0 : (t > 1 ? 1 : t));
    };
  }

  const COURBE_GRAIN = bezier(0.23, 1, 0.32, 1);     // ease-out franc
  const COURBE_ENCRE = bezier(0.77, 0, 0.175, 1);    // ease-in-out
  const COURBE_RETOUR = bezier(0.77, 0, 0.175, 1);

  // Ce qui, sous le pointeur, signifie que le clic avait une intention.
  // A elargir si le site gagne d'autres elements interactifs.
  const INTERACTIF = 'a, button, input, label, select, textarea, summary, ' +
                     '[role="button"], [onclick], [tabindex]:not([tabindex="-1"])';

  function hexToRgb(hex) {
    const n = parseInt(hex.replace('#', ''), 16);
    return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
  }

  // --- INIT -------------------------------------------------------------------
  function init(canvas, options) {
    if (!canvas) return null;
    const o = Object.assign({}, DEFAUTS, options || {});
    const reduit = matchMedia('(prefers-reduced-motion: reduce)');

    let gl;
    try {
      const attrs = { antialias: false, depth: false, alpha: false };
      gl = canvas.getContext('webgl', attrs) || canvas.getContext('experimental-webgl', attrs);
    } catch (e) { gl = null; }
    if (!gl) return null;

    function compiler(type, src) {
      const s = gl.createShader(type);
      gl.shaderSource(s, src);
      gl.compileShader(s);
      if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
        console.error('Dither, shader :', gl.getShaderInfoLog(s));
        return null;
      }
      return s;
    }

    const vs = compiler(gl.VERTEX_SHADER, VERT);
    const fs = compiler(gl.FRAGMENT_SHADER, FRAG);
    if (!vs || !fs) return null;

    const prog = gl.createProgram();
    gl.attachShader(prog, vs);
    gl.attachShader(prog, fs);
    gl.linkProgram(prog);
    if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
      console.error('Dither, programme :', gl.getProgramInfoLog(prog));
      return null;
    }
    gl.useProgram(prog);

    // Un seul triangle couvrant l'ecran : moins de sommets qu'un quad.
    const buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
    const loc = gl.getAttribLocation(prog, 'aPos');
    gl.enableVertexAttribArray(loc);
    gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);

    const uni = {};
    ['uResolution', 'uTime', 'uScrollLines', 'uMouse', 'uMouseForce',
     'uAssise', 'uEtalement', 'uPeriode', 'uTrame', 'uAplat', 'uRecul',
     'uLogo', 'uReveal', 'uGrain', 'uLogoLarge', 'uBlaze',
     'uC0', 'uC1', 'uC2', 'uBayer'].forEach(n => { uni[n] = gl.getUniformLocation(prog, n); });

    // Bayer en texture 4x4. On stocke v*17 : 15*17 = 255, donc la lecture rend
    // exactement v/15, converti en v/16 dans le shader.
    const donnees = new Uint8Array(16);
    for (let r = 0; r < 4; r++)
      for (let c = 0; c < 4; c++) donnees[r * 4 + c] = BAYER[r][c] * 17;

    const texBayer = gl.createTexture();
    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, texBayer);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.LUMINANCE, 4, 4, 0, gl.LUMINANCE, gl.UNSIGNED_BYTE, donnees);
    [gl.TEXTURE_MIN_FILTER, gl.TEXTURE_MAG_FILTER].forEach(p => gl.texParameteri(gl.TEXTURE_2D, p, gl.NEAREST));
    [gl.TEXTURE_WRAP_S, gl.TEXTURE_WRAP_T].forEach(p => gl.texParameteri(gl.TEXTURE_2D, p, gl.CLAMP_TO_EDGE));
    gl.uniform1i(uni.uBayer, 0);

    // Logo : 1x1 noir en attendant, pour que le shader ait toujours de quoi
    // echantillonner.
    const texLogo = gl.createTexture();
    gl.activeTexture(gl.TEXTURE1);
    gl.bindTexture(gl.TEXTURE_2D, texLogo);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.LUMINANCE, 1, 1, 0, gl.LUMINANCE, gl.UNSIGNED_BYTE, new Uint8Array([0]));
    [gl.TEXTURE_MIN_FILTER, gl.TEXTURE_MAG_FILTER].forEach(p => gl.texParameteri(gl.TEXTURE_2D, p, gl.LINEAR));
    [gl.TEXTURE_WRAP_S, gl.TEXTURE_WRAP_T].forEach(p => gl.texParameteri(gl.TEXTURE_2D, p, gl.CLAMP_TO_EDGE));
    gl.uniform1i(uni.uLogo, 1);
    gl.activeTexture(gl.TEXTURE0);

    const state = {
      pixelScale: o.pixelScale, trame: o.trame, aplat: o.aplat,
      recul: o.recul, periode: o.periode,
      assise: o.assise, etalement: o.etalement,
      waveSpeed: o.vitesse, mouseForce: o.curseur,
      couleurs: o.couleurs.map(hexToRgb),
      blaze: hexToRgb(o.blaze),
      logoPlein: o.logoPlein, logoLarge: o.logoLarge,
      time: 0, scrollPx: 0,
      reveal: 0, grain: 0, revealDebut: 0,
      mouse: { x: -1000, y: -1000, targetX: -1000, targetY: -1000, active: false }
    };

    let width = 0, height = 0, logoPret = false, boucle = 0, vivant = true;

    // --- LOGO -----------------------------------------------------------------
    // Le DOM d'abord : `svg.logo` est present sur toutes les pages du site,
    // donc zero requete et aucun risque qu'il derive du logo affiche a cote.
    // NE PAS aller chercher _includes/ : Jekyll ne publie pas ce dossier.
    async function sourceSvg() {
      const dansLeDom = document.querySelector('svg.logo');
      if (dansLeDom) return new XMLSerializer().serializeToString(dansLeDom);
      const r = await fetch(o.logoSecours);
      if (!r.ok) throw new Error('ni DOM ni fichier (HTTP ' + r.status + ')');
      return await r.text();
    }

    async function chargerLogo() {
      try {
        const brut = await sourceSvg();
        const trouve = brut.match(/<svg[\s\S]*<\/svg>/);
        if (!trouve) throw new Error('pas de <svg>');

        // Contour : on garde le fill-opacity d'origine, seul le trait blanchit.
        // Plein : les lettres deviennent des masses.
        let src = trouve[0].replace(/(fill|stroke)="#FF5C00"/g, '$1="#FFFFFF"');
        if (state.logoPlein) src = src.replace(/fill-opacity="[^"]*"/g, 'fill-opacity="1"');

        const img = new Image();
        const url = URL.createObjectURL(new Blob([src], { type: 'image/svg+xml' }));
        await new Promise((ok, ko) => { img.onload = ok; img.onerror = ko; img.src = url; });

        const c = document.createElement('canvas');
        c.width = 512; c.height = Math.round(512 * 36 / 123);
        const x = c.getContext('2d');
        x.fillStyle = '#000'; x.fillRect(0, 0, c.width, c.height);
        x.drawImage(img, 0, 0, c.width, c.height);
        URL.revokeObjectURL(url);

        if (!vivant) return;
        gl.activeTexture(gl.TEXTURE1);
        gl.bindTexture(gl.TEXTURE_2D, texLogo);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.LUMINANCE, gl.LUMINANCE, gl.UNSIGNED_BYTE, c);
        gl.activeTexture(gl.TEXTURE0);
        logoPret = true;
      } catch (e) {
        console.warn('Dither, logo non charge, le revele restera inerte :', e.message);
      }
    }

    // --- DIMENSIONS -----------------------------------------------------------
    function resize() {
      width = Math.ceil(window.innerWidth / state.pixelScale);
      // Une ligne de rab : le canvas est remonte de 0 a pixelScale-1 px par le
      // transform de rattrapage, il ne doit pas decouvrir de vide en bas.
      height = Math.ceil(window.innerHeight / state.pixelScale) + 1;
      if (canvas.width !== width || canvas.height !== height) {
        canvas.width = width;
        canvas.height = height;
      }
      // Dimensions d'affichage posees a la main : une ligne de canvas doit
      // valoir EXACTEMENT pixelScale px CSS, sinon le verrouillage 1:1 tombe
      // a cote.
      canvas.style.width = (width * state.pixelScale) + 'px';
      canvas.style.height = (height * state.pixelScale) + 'px';
      dessiner();
    }

    // --- RENDU ----------------------------------------------------------------
    function dessiner() {
      if (!vivant || !width || !height) return;

      // Le defilement est lu DANS la frame, pas dans un ecouteur : le champ et
      // le rattrapage sous-pixel proviennent ainsi de la MEME valeur au meme
      // instant. Separes, ils se decalent d'une frame en defilement rapide et
      // le fond tremble.
      state.scrollPx = window.scrollY;
      const decalLignes = Math.floor(state.scrollPx / state.pixelScale);
      const reste = state.scrollPx - decalLignes * state.pixelScale;
      canvas.style.transform = reste ? 'translateY(' + (-reste) + 'px)' : '';

      const c = state.couleurs;
      gl.viewport(0, 0, width, height);
      gl.uniform2f(uni.uResolution, width, height);
      gl.uniform1f(uni.uTime, state.time);
      gl.uniform1f(uni.uScrollLines, decalLignes);
      gl.uniform2f(uni.uMouse, state.mouse.x, state.mouse.y);
      gl.uniform1f(uni.uMouseForce, state.mouseForce);
      gl.uniform1f(uni.uAssise, state.assise);
      gl.uniform1f(uni.uEtalement, state.etalement);
      gl.uniform1f(uni.uPeriode, state.periode);
      gl.uniform1f(uni.uTrame, state.trame);
      gl.uniform1f(uni.uAplat, state.aplat);
      gl.uniform1f(uni.uRecul, state.recul);
      gl.uniform1f(uni.uReveal, state.reveal);
      gl.uniform1f(uni.uGrain, state.grain);
      gl.uniform1f(uni.uLogoLarge, width * state.logoLarge);
      gl.uniform3f(uni.uBlaze, state.blaze[0] / 255, state.blaze[1] / 255, state.blaze[2] / 255);
      gl.uniform3f(uni.uC0, c[0][0] / 255, c[0][1] / 255, c[0][2] / 255);
      gl.uniform3f(uni.uC1, c[1][0] / 255, c[1][1] / 255, c[1][2] / 255);
      gl.uniform3f(uni.uC2, c[2][0] / 255, c[2][1] / 255, c[2][2] / 255);
      gl.drawArrays(gl.TRIANGLES, 0, 3);
    }

    // --- REVELE ---------------------------------------------------------------
    function declencherRevele() {
      if (!o.revele || reduit.matches || !logoPret || state.revealDebut) return;
      state.revealDebut = performance.now();
    }

    function avancerReveal(maintenant) {
      if (!state.revealDebut) return;
      const t = maintenant - state.revealDebut;
      if (t < REV_MONTEE) {
        // Le grain a fini de se resserrer bien avant que l'encre ne paraisse :
        // c'est ce decalage qui donne une reponse immediate au clic sans faire
        // surgir le logo d'un coup.
        state.grain = COURBE_GRAIN(Math.min(1, t / REV_GRAIN));
        state.reveal = COURBE_ENCRE(t / REV_MONTEE);
      } else if (t < REV_MONTEE + REV_TENUE) {
        state.grain = 1; state.reveal = 1;
      } else {
        const p = Math.min(1, (t - REV_MONTEE - REV_TENUE) / REV_RETOUR);
        const r = 1 - COURBE_RETOUR(p);
        state.grain = r; state.reveal = r;
        if (p >= 1) { state.grain = 0; state.reveal = 0; state.revealDebut = 0; }
      }
    }

    // --- ECOUTEURS ------------------------------------------------------------
    function surSouris(e) {
      state.mouse.active = true;
      state.mouse.targetX = e.clientX / state.pixelScale;
      state.mouse.targetY = e.clientY / state.pixelScale;
    }
    function surSortie() {
      state.mouse.active = false;
      state.mouse.targetX = -1000;
      state.mouse.targetY = -1000;
    }
    function surClic(e) {
      if (e.target.closest(INTERACTIF)) return;
      const sel = getSelection();
      if (sel && !sel.isCollapsed) return;    // fin d'une selection de texte
      declencherRevele();
    }

    addEventListener('resize', resize);
    addEventListener('mousemove', surSouris);
    addEventListener('mouseleave', surSortie);
    if (o.revele) addEventListener('pointerdown', surClic);

    // --- BOUCLE ---------------------------------------------------------------
    let dernierInstant = performance.now();

    function animer() {
      if (!vivant) return;
      boucle = requestAnimationFrame(animer);
      const maintenant = performance.now();

      // Le temps est la 3e coordonnee du bruit : une unite renouvelle
      // ENTIEREMENT le champ. 0,012 unite/s donne un cycle d'environ 83 s :
      // une respiration, pas une animation.
      // Indexe sur l'horloge et non sur les frames, sinon la vitesse doublerait
      // sur un ecran a 120 Hz.
      state.time += (maintenant - dernierInstant) / 1000 * 0.012 * state.waveSpeed;
      dernierInstant = maintenant;

      // La derive au repos a SA propre base de temps : elle est voulue, et
      // state.time est trop lent depuis qu'il sert de coordonnee au bruit.
      const secondes = maintenant / 1000;
      if (state.mouse.active) {
        state.mouse.x += (state.mouse.targetX - state.mouse.x) * 0.08;
        state.mouse.y += (state.mouse.targetY - state.mouse.y) * 0.08;
      } else {
        state.mouse.x = width / 2 + Math.sin(secondes * 0.75) * (width / 3);
        state.mouse.y = height / 2 + Math.cos(secondes * 0.54) * (height / 3);
      }

      avancerReveal(maintenant);
      dessiner();
    }

    function detruire() {
      vivant = false;
      cancelAnimationFrame(boucle);
      removeEventListener('resize', resize);
      removeEventListener('mousemove', surSouris);
      removeEventListener('mouseleave', surSortie);
      removeEventListener('pointerdown', surClic);
    }

    // Le logo n'est charge que si le revele sert : en stand by, meme une
    // lecture du DOM et une rasterisation seraient du travail mort.
    // `chargerLogo()` reste expose pour le charger a la demande.
    if (o.revele) chargerLogo();
    resize();

    // Mouvement reduit : une image fixe, pas de boucle. Le fond garde sa
    // texture, il cesse seulement de respirer.
    if (reduit.matches) dessiner();
    else animer();

    return { state, dessiner, resize, chargerLogo, declencherRevele, detruire,
             get logoPret() { return logoPret; },
             get taille() { return { width: width, height: height }; },
             gl: gl };
  }

  // --- AUTO-INITIALISATION ----------------------------------------------------
  // Le site n'a qu'a poser <canvas id="fond-dither"> : pas de script en ligne
  // dans le layout, et le chargement reste en `defer` comme le reste du JS.
  // Le bac a sable, lui, appelle init() lui-meme sur un autre identifiant, il
  // n'est donc pas concerne.
  let auto = null;
  function autoInit() {
    const cv = document.getElementById('fond-dither');
    if (!cv || auto) return;
    auto = init(cv);
    if (!auto) {
      // Repli assume : la couleur de fond CSS prend le relais. On retire le
      // canvas vide plutot que de laisser un element mort dans le document.
      cv.remove();
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', autoInit);
  } else {
    autoInit();
  }

  return {
    init: init,
    DEFAUTS: DEFAUTS,
    get instance() { return auto; }
  };
})();
