/**
 * PriceWizard website - minimal JS
 */

(function () {
  'use strict';

  // Smooth scroll for anchor links (backup for CSS scroll-behavior)
  document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
    anchor.addEventListener('click', function (e) {
      var id = this.getAttribute('href');
      if (id === '#') return;
      var target = document.querySelector(id);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

  // Optional: log for download CTA (replace with real link when you have a build)
  var downloadCta = document.getElementById('download-cta');
  if (downloadCta) {
    downloadCta.addEventListener('click', function (e) {
      if (this.getAttribute('href') === 'https://github.com') {
        e.preventDefault();
        // When you have a real URL, update index.html and remove this block
        this.textContent = 'Coming soon';
      }
    });
  }
})();
