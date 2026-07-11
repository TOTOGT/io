/**
 * nav.js — shared navigation bar + language switcher for TOTOGT/io
 * Adapted from the Principia Orthogona book 4 nav.js
 *
 * Usage: <script src="../NAV/nav.js"></script>  (from io/io.html)
 *
 * Features:
 *   - Sticky nav bar (Home / GitHub / AXLE)
 *   - Language dropdown (EN native, FR + others via Google Translate)
 *   - Works fully offline except the optional Google Translate widget
 *
 * G6 LLC (c) Pablo Nogueira Grossi 2026 - MIT License (code)
 */
(function () {
    'use strict';

   var LANGS = [
     { code: 'en', flag: 'US', label: 'English', note: 'Primary' },
     { code: 'fr', flag: 'FR', label: 'Francais', note: 'French' },
     { code: 'pt', flag: 'BR', label: 'Portugues', note: 'Brasil' },
     { code: 'es', flag: 'ES', label: 'Espanol', note: 'Spanish' },
     { code: 'de', flag: 'DE', label: 'Deutsch', note: 'German' },
     { code: 'zh', flag: 'CN', label: 'Zhongwen', note: 'Mandarin' },
     { code: 'ar', flag: 'SA', label: 'Arabiya', note: 'Arabic - RTL' },
       ];

   var UI = {
         en: { home: 'Home', github: 'GitHub', axle: 'AXLE', lang: 'Language' }
   };

   var currentLang = localStorage.getItem('io_lang') || 'en';

   function t(key) {
         return (UI[currentLang] || UI.en)[key] || UI.en[key] || key;
   }

   var gtLoaded = false;
    function loadGoogleTranslate() {
          if (gtLoaded) return;
          gtLoaded = true;
          window.googleTranslateElementInit = function () {
                  new window.google.translate.TranslateElement(
                    { pageLanguage: 'en', autoDisplay: false },
                            'google_translate_element'
                          );
          };
          var s = document.createElement('script');
          s.src = '//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit';
          s.async = true;
          document.head.appendChild(s);
    }

   function translateTo(langCode) {
         currentLang = langCode;
         localStorage.setItem('io_lang', langCode);
         document.documentElement.lang = langCode;

      if (langCode !== 'en') {
              loadGoogleTranslate();
              setTimeout(function () {
                        var sel = document.querySelector('.goog-te-combo');
                        if (sel) {
                                    sel.value = langCode;
                                    sel.dispatchEvent(new Event('change'));
                        }
              }, 1000);
      }

      var rtlLangs = ['ar', 'fa', 'ur', 'he'];
         document.documentElement.dir = rtlLangs.indexOf(langCode) >= 0 ? 'rtl' : 'ltr';

      renderLangDropdown();
         closeLangMenu();
   }

   function injectStyles() {
         var id = 'io-nav-styles';
         if (document.getElementById(id)) return;
         var style = document.createElement('style');
         style.id = id;
         style.textContent = [
                 '#io-nav{',
                   'position:sticky;top:0;z-index:9000;',
                   'background:rgba(10,22,40,.97);',
                   'backdrop-filter:blur(8px);',
                   '-webkit-backdrop-filter:blur(8px);',
                   'border-bottom:1px solid rgba(201,168,76,.15);',
                   'font-family:system-ui,sans-serif;',
                   'height:52px;',
                   'display:flex;align-items:center;',
                   'padding:0 1.2rem;',
                   'gap:1.2rem;',
                   'box-sizing:border-box;',
                 '}',
                 '#io-nav a{',
                   'color:rgba(255,255,255,.55);',
                   'font-size:.76rem;text-decoration:none;',
                   'letter-spacing:.04em;',
                   'transition:color .15s;',
                   'white-space:nowrap;',
                 '}',
                 '#io-nav a:hover{color:#c9a84c;}',
                 '#io-nav .io-brand{',
                   'color:#c9a84c;',
                   'font-weight:700;letter-spacing:.18em;',
                   'text-transform:uppercase;font-size:.77rem;',
                   'margin-right:.5rem;',
                 '}',
                 '#io-nav .io-sep{color:rgba(255,255,255,.15);font-size:.7rem;}',
                 '#io-nav .io-spacer{flex:1;}',
                 '#io-lang-btn{',
                   'background:rgba(201,168,76,.08);',
                   'border:1px solid rgba(201,168,76,.2);',
                   'color:#c9a84c;',
                   'font-family:system-ui,sans-serif;',
                   'font-size:.72rem;letter-spacing:.06em;',
                   'padding:.25rem .6rem;',
                   'cursor:pointer;',
                   'display:flex;align-items:center;gap:.3rem;',
                   'white-space:nowrap;',
                 '}',
                 '#io-lang-btn:hover{background:rgba(201,168,76,.15);}',
                 '#io-lang-menu{',
                   'position:absolute;top:52px;right:0;',
                   'background:#0a1628;',
                   'border:1px solid rgba(201,168,76,.2);',
                   'border-top:none;',
                   'min-width:200px;',
                   'max-height:60vh;overflow-y:auto;',
                   'z-index:9100;',
                   'display:none;',
                 '}',
                 '#io-lang-menu.open{display:block;}',
                 '.io-lang-item{',
                   'display:flex;align-items:center;gap:.6rem;',
                   'padding:.45rem .8rem;',
                   'cursor:pointer;',
                   'border-bottom:1px solid rgba(255,255,255,.04);',
                 '}',
                 '.io-lang-item:hover{background:rgba(201,168,76,.07);}',
                 '.io-lang-item.active{background:rgba(201,168,76,.1);}',
                 '.io-lang-flag{font-size:1rem;line-height:1;}',
                 '.io-lang-label{font-family:system-ui,sans-serif;font-size:.78rem;color:rgba(255,255,255,.75);flex:1;}',
                 '.io-lang-note{font-size:.64rem;color:rgba(255,255,255,.3);font-style:italic;}',
                 '#google_translate_element{display:none;}',
                 '.skiptranslate{display:none!important;}',
                 'body{top:0!important;}',
               ].join('');
         document.head.appendChild(style);
   }

   function buildNav() {
         var nav = document.createElement('nav');
         nav.id = 'io-nav';
         nav.setAttribute('role', 'navigation');
         nav.setAttribute('aria-label', 'Site navigation');
         nav.innerHTML = [
                 '<a href="../index.html" class="io-brand" aria-label="Home">IO</a>',
                 '<a href="../index.html">' + t('home') + '</a>',
                 '<span class="io-sep">.</span>',
                 '<a href="https://github.com/TOTOGT/io" target="_blank" rel="noopener">' + t('github') + '</a>',
                 '<span class="io-sep">.</span>',
                 '<a href="https://github.com/TOTOGT/AXLE" target="_blank" rel="noopener">' + t('axle') + '</a>',
                 '<div class="io-spacer"></div>',
                 '<div style="position:relative;">',
                   '<button id="io-lang-btn" aria-haspopup="true" aria-expanded="false" aria-label="Select language">',
                     '<span id="io-lang-flag">' + getCurrentFlag() + '</span>',
                     '<span id="io-lang-label">' + getCurrentLabel() + '</span>',
                     '<span style="opacity:.5">v</span>',
                   '</button>',
                   '<div id="io-lang-menu" role="menu">',
                     buildLangItems(),
                   '</div>',
                 '</div>',
                 '<div id="google_translate_element"></div>',
               ].join('');
         return nav;
   }

   function getCurrentFlag() {
         for (var i = 0; i < LANGS.length; i++) {
                 if (LANGS[i].code === currentLang) return LANGS[i].flag;
         }
         return 'EN';
   }

   function getCurrentLabel() {
         for (var i = 0; i < LANGS.length; i++) {
                 if (LANGS[i].code === currentLang) return LANGS[i].label;
         }
         return 'EN';
   }

   function buildLangItems() {
         return LANGS.map(function (l) {
                 var active = l.code === currentLang ? ' active' : '';
                 return [
                           '<div class="io-lang-item' + active + '" role="menuitem" tabindex="0"',
                             ' data-lang="' + l.code + '"',
                             ' aria-label="Switch to ' + l.label + '">',
                             '<span class="io-lang-flag">' + l.flag + '</span>',
                             '<span class="io-lang-label">' + l.label + '</span>',
                             '<span class="io-lang-note">' + l.note + '</span>',
                           '</div>',
                         ].join('');
         }).join('');
   }

   function renderLangDropdown() {
         var btn = document.getElementById('io-lang-btn');
         var menu = document.getElementById('io-lang-menu');
         if (!btn || !menu) return;
         document.getElementById('io-lang-flag').textContent = getCurrentFlag();
         document.getElementById('io-lang-label').textContent = getCurrentLabel();
         menu.innerHTML = buildLangItems();
         attachLangItemEvents();
   }

   function attachLangItemEvents() {
         var items = document.querySelectorAll('.io-lang-item');
         for (var i = 0; i < items.length; i++) {
                 (function (item) {
                           item.addEventListener('click', function () {
                                       translateTo(item.getAttribute('data-lang'));
                           });
                           item.addEventListener('keydown', function (e) {
                                       if (e.key === 'Enter' || e.key === ' ') {
                                                     translateTo(item.getAttribute('data-lang'));
                                       }
                           });
                 })(items[i]);
         }
   }

   function openLangMenu() {
         var menu = document.getElementById('io-lang-menu');
         var btn = document.getElementById('io-lang-btn');
         if (!menu || !btn) return;
         menu.classList.add('open');
         btn.setAttribute('aria-expanded', 'true');
   }

   function closeLangMenu() {
         var menu = document.getElementById('io-lang-menu');
         var btn = document.getElementById('io-lang-btn');
         if (!menu || !btn) return;
         menu.classList.remove('open');
         btn.setAttribute('aria-expanded', 'false');
   }

   function inject() {
         injectStyles();
         var nav = buildNav();
         document.body.insertBefore(nav, document.body.firstChild);
         document.documentElement.lang = currentLang;

      var btn = document.getElementById('io-lang-btn');
         if (btn) {
                 btn.addEventListener('click', function (e) {
                           e.stopPropagation();
                           var menu = document.getElementById('io-lang-menu');
                           if (menu && menu.classList.contains('open')) {
                                       closeLangMenu();
                           } else {
                                       openLangMenu();
                           }
                 });
         }

      document.addEventListener('click', function (e) {
              var menu = document.getElementById('io-lang-menu');
              if (menu && !menu.contains(e.target) && e.target !== btn) {
                        closeLangMenu();
              }
      });

      document.addEventListener('keydown', function (e) {
              if (e.key === 'Escape') closeLangMenu();
      });

      attachLangItemEvents();

      if (currentLang !== 'en') {
              setTimeout(function () { translateTo(currentLang); }, 500);
      }
   }

   if (document.readyState === 'loading') {
         document.addEventListener('DOMContentLoaded', inject);
   } else {
         inject();
   }
})();
