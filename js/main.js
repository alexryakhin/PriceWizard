/**
 * Price Wizard website: mobile menu and download click tracking.
 */
(function () {
  'use strict';

  // Mobile menu
  var header = document.querySelector('.site-header');
  var toggle = document.querySelector('.nav-toggle');
  var nav = document.getElementById('site-nav');
  function setMenu(open) {
    header.classList.toggle('nav-open', open);
    toggle.setAttribute('aria-expanded', open);
    toggle.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
  }
  if (header && toggle && nav) {
    toggle.addEventListener('click', function () { setMenu(!header.classList.contains('nav-open')); });
    nav.querySelectorAll('a').forEach(function (a) { a.addEventListener('click', function () { setMenu(false); }); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') setMenu(false); });
  }

  // App Store clicks in Google Analytics
  document.querySelectorAll('.download-cta').forEach(function (link) {
    link.addEventListener('click', function () {
      if (typeof gtag === 'function') {
        gtag('event', 'download_click', { event_category: 'engagement', event_label: link.textContent.trim() });
      }
    });
  });
})();
