/* ==========================================================================
   CPBP 8306 — minimal slide engine
   No dependencies. Works from file:// with no network.

   Keys:  → / ↓ / space / PgDn   next
          ← / ↑ / PgUp           previous
          Home / End             first / last
          o                      overview (click a thumbnail to jump)
          s                      speaker notes
          f                      fullscreen
          b                      black out screen
          ?                      help
          p                      print / save as PDF
   ========================================================================== */

(function () {
  'use strict';

  var slides = [], idx = 0, blanked = false;
  var stage, scaler, notesEl, counterEl, progressEl, helpEl;

  /* ---------------------------------------------------------------- setup */

  function init() {
    scaler    = document.getElementById('scaler');
    stage     = document.getElementById('stage');
    slides    = Array.prototype.slice.call(document.querySelectorAll('.slide'));

    buildChrome();
    slides.forEach(function (s, i) {
      s.setAttribute('data-n', i + 1);
      wrapInner(s);
      s.addEventListener('click', function () {
        if (document.body.classList.contains('overview')) {
          go(i);
          toggleOverview();
        }
      });
    });

    highlightAll();
    autofit();

    window.addEventListener('resize', fit);
    window.addEventListener('keydown', onKey);
    window.addEventListener('hashchange', fromHash);

    fit();
    fromHash();
  }

  /* Authors write plain children; everything gets boxed into a measurable
     `.inner` so autofit and overview mode have something to scale. */
  function wrapInner(slide) {
    var inner = document.createElement('div');
    inner.className = 'inner';
    while (slide.firstChild) inner.appendChild(slide.firstChild);
    slide.appendChild(inner);
  }

  /* Safety net: if a slide's content runs past the bottom of the 1280x720
     frame, shrink it to fit rather than clipping it mid-sentence. Line
     wrapping is unaffected because we scale after layout, not before.
     Anything that trips this is also logged so it can be edited properly. */
  function autofit() {
    slides.forEach(function (s, i) {
      var inner = s.querySelector('.inner');
      if (!inner) return;
      var wasHidden = !s.classList.contains('current');
      if (wasHidden) { s.style.display = 'block'; s.style.visibility = 'hidden'; }
      inner.style.transform = 'none';
      var have = inner.clientHeight;
      var need = inner.scrollHeight;
      if (need > have + 1) {
        var k = Math.max(0.6, have / need);
        inner.style.transform = 'scale(' + k + ')';
        console.warn('[deck] slide ' + (i + 1) + ' overflows by ' +
                     (need - have) + 'px — auto-shrunk to ' + k.toFixed(3) +
                     '. Consider trimming it.');
      }
      if (wasHidden) { s.style.display = ''; s.style.visibility = ''; }
    });
  }

  function buildChrome() {
    progressEl = el('div', 'progress');
    counterEl  = el('div', 'counter');
    notesEl    = el('div', 'notes');
    helpEl     = el('div', 'help');
    helpEl.innerHTML =
      '<table><tbody>' +
      row('&rarr; &darr; space', 'next slide') +
      row('&larr; &uarr;', 'previous slide') +
      row('Home / End', 'first / last slide') +
      row('o', 'overview grid') +
      row('s', 'speaker notes') +
      row('f', 'fullscreen') +
      row('b', 'black out the screen') +
      row('p', 'print / save as PDF') +
      row('?', 'this help') +
      '</tbody></table>';
    [progressEl, counterEl, notesEl, helpEl].forEach(function (n) {
      document.body.appendChild(n);
    });
  }

  function row(k, v) { return '<tr><td>' + k + '</td><td>' + v + '</td></tr>'; }

  function el(tag, id) { var n = document.createElement(tag); n.id = id; return n; }

  /* ------------------------------------------------------------ scaling */

  function fit() {
    if (document.body.classList.contains('overview')) return;
    var cs = getComputedStyle(document.documentElement);
    var w  = parseInt(cs.getPropertyValue('--slide-w'), 10) || 1280;
    var h  = parseInt(cs.getPropertyValue('--slide-h'), 10) || 720;
    var notesOpen = notesEl.classList.contains('on');
    var availH = window.innerHeight * (notesOpen ? 0.58 : 1);
    var scale  = Math.min(window.innerWidth / w, availH / h);
    scaler.style.transform = 'scale(' + scale + ')';
    stage.style.alignItems = notesOpen ? 'flex-start' : 'center';
  }

  /* ---------------------------------------------------------- navigation */

  function go(n) {
    idx = Math.max(0, Math.min(slides.length - 1, n));
    slides.forEach(function (s, i) { s.classList.toggle('current', i === idx); });
    counterEl.textContent = (idx + 1) + ' / ' + slides.length;
    progressEl.style.width = ((idx + 1) / slides.length * 100) + '%';
    renderNotes();
    if (location.hash !== '#/' + (idx + 1)) {
      history.replaceState(null, '', '#/' + (idx + 1));
    }
  }

  function fromHash() {
    var m = /^#\/(\d+)$/.exec(location.hash);
    go(m ? parseInt(m[1], 10) - 1 : idx);
  }

  function renderNotes() {
    var src = slides[idx].querySelector('script[type="text/notes"]');
    notesEl.innerHTML = '<h4>Speaker notes &mdash; slide ' + (idx + 1) + '</h4>' +
      (src ? src.innerHTML : '<p class="none">(no notes for this slide)</p>');
  }

  function toggleOverview() {
    document.body.classList.toggle('overview');
    var on = document.body.classList.contains('overview');
    if (on) {
      scaler.style.transform = 'none';
      // thumbnails are laid out by CSS grid; scale slide innards to match
      var cell = slides[0].clientWidth || 320;
      document.documentElement.style.setProperty('--thumb-scale', cell / 1280);
      var cur = slides[idx];
      if (cur) cur.scrollIntoView({ block: 'center' });
    } else {
      fit();
      autofit();
    }
  }

  function onKey(e) {
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    var k = e.key;

    if (k === '?' || k === '/') { helpEl.classList.toggle('on'); e.preventDefault(); return; }
    if (helpEl.classList.contains('on')) { helpEl.classList.remove('on'); return; }

    switch (k) {
      case 'ArrowRight': case 'ArrowDown': case ' ': case 'PageDown':
        go(idx + 1); e.preventDefault(); break;
      case 'ArrowLeft': case 'ArrowUp': case 'PageUp':
        go(idx - 1); e.preventDefault(); break;
      case 'Home': go(0); e.preventDefault(); break;
      case 'End':  go(slides.length - 1); e.preventDefault(); break;
      case 'o': case 'O': toggleOverview(); e.preventDefault(); break;
      case 's': case 'S':
        notesEl.classList.toggle('on'); fit(); e.preventDefault(); break;
      case 'f': case 'F':
        if (document.fullscreenElement) document.exitFullscreen();
        else document.documentElement.requestFullscreen();
        e.preventDefault(); break;
      case 'b': case 'B':
        blanked = !blanked;
        stage.style.visibility = blanked ? 'hidden' : 'visible';
        document.body.style.background = blanked ? '#000' : '';
        e.preventDefault(); break;
      case 'p': case 'P': window.print(); e.preventDefault(); break;
    }
  }

  /* -------------------------------------------------- syntax highlighting
     Deliberately small. Scans left-to-right and takes the earliest match, so
     a `#` inside a string is not mistaken for a comment and vice versa.
     ------------------------------------------------------------------- */

  var RULES = [
    ['com', '#[^\\n]*'],
    ['str', '"""[\\s\\S]*?"""|\'\'\'[\\s\\S]*?\'\'\'|"(?:\\\\.|[^"\\\\\\n])*"|\'(?:\\\\.|[^\'\\\\\\n])*\''],
    ['kw',  '\\b(?:def|return|if|elif|else|for|while|in|not|and|or|import|from|as|lambda|class|with|try|except|finally|raise|pass|break|continue|is|None|True|False|' +
            'function|TRUE|FALSE|NA|NULL|NaN|Inf|library|require|next|repeat)\\b'],
    ['num', '\\b\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?\\b'],
    ['fn',  '\\b[A-Za-z_.][A-Za-z0-9_.]*(?=\\s*\\()'],
    ['op',  '<-|\\|>|%>%|%%|\\*\\*|[+\\-*/=<>!&|^~]+']
  ];

  var SCANNER = new RegExp(RULES.map(function (r) { return '(' + r[1] + ')'; }).join('|'), 'g');

  function esc(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function highlight(src) {
    var out = '', last = 0, m;
    SCANNER.lastIndex = 0;
    while ((m = SCANNER.exec(src)) !== null) {
      if (m[0] === '') { SCANNER.lastIndex++; continue; }
      out += esc(src.slice(last, m.index));
      var kind = 'op';
      for (var i = 1; i < m.length; i++) {
        if (m[i] !== undefined) { kind = RULES[i - 1][0]; break; }
      }
      out += '<span class="tok-' + kind + '">' + esc(m[0]) + '</span>';
      last = m.index + m[0].length;
    }
    return out + esc(src.slice(last));
  }

  function highlightAll() {
    document.querySelectorAll('pre:not(.plain)').forEach(function (pre) {
      pre.innerHTML = highlight(pre.textContent.replace(/^\n/, '').replace(/\s+$/, ''));
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
