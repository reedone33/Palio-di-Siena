/* ============================================================================
   SERVICE WORKER — Palio di Siena dashboard
   ============================================================================
   A service worker is a small script the browser keeps running in the
   background, between the page and the network. It lets the app open when
   there's no connection, and lets it be installed to a home screen.

   Three jobs here:
     1. On install, save the app itself (the page, the manifest, the icons)
        so it opens offline.
     2. Serve the app from that saved copy — always, and instantly. It is NOT
        replaced quietly in the background; a new version is only taken up when
        the reader presses "Check for updates" in the page.
     3. For the drappellone photographs on ilpalio.org, save each one the
        first time it's seen. Banners you've already looked at then work
        offline too, without ever bulk-downloading the archive.

   TO PUBLISH AN UPDATE: change CACHE_VERSION below. That name change is what
   tells every browser to throw away the old copy and fetch everything again.
   ========================================================================== */

const CACHE_VERSION = 'palio-a30cf58f';
const SHELL_CACHE = CACHE_VERSION + '-shell';
const IMAGE_CACHE = CACHE_VERSION + '-banners';

// The files that make up the app itself.
const SHELL = [
  './',
  './index.html',
  './readme.html',
  './manifest.webmanifest',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/icon-512-maskable.png',
  './icons/apple-touch-icon.png',
  './icons/favicon-32.png'
];

// Chart.js comes from a CDN. Cached opportunistically at runtime rather than
// at install, so a CDN hiccup can't stop the app installing.
const CDN = 'https://cdnjs.cloudflare.com/';
const BANNERS = 'https://www.ilpalio.org/';

/* --- Install: save the app shell ---------------------------------------- */
self.addEventListener('install', event => {
  // Note: no skipWaiting here. A newly downloaded version sits and waits until
  // the reader asks for it, so the app never changes under them mid-read.
  event.waitUntil(
    caches.open(SHELL_CACHE).then(cache => cache.addAll(SHELL))
  );
});

/* The page sends this when the reader presses "Update now". Only then does a
   waiting version take over. */
self.addEventListener('message', event => {
  if(event.data && event.data.type === 'SKIP_WAITING') self.skipWaiting();
});

/* --- Activate: delete caches from older versions ------------------------ */
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(names => Promise.all(
        names.filter(n => !n.startsWith(CACHE_VERSION))
             .map(n => caches.delete(n))
      ))
      .then(() => self.clients.claim())        // control open tabs immediately
  );
});

/* --- Fetch: decide where each request should be answered from ----------- */
self.addEventListener('fetch', event => {
  const req = event.request;
  if(req.method !== 'GET') return;             // never interfere with anything else

  const url = req.url;

  // 1. Banner photographs — cache first. They never change once published,
  //    so a saved copy is always good, and this is what makes previously
  //    viewed banners work offline.
  if(url.startsWith(BANNERS)){
    event.respondWith(
      caches.open(IMAGE_CACHE).then(cache =>
        cache.match(req).then(hit =>
          hit || fetch(req, {mode: 'no-cors'})
            .then(res => { cache.put(req, res.clone()); return res; })
            .catch(() => hit)                  // offline and never seen: let it fail quietly
        )
      )
    );
    return;
  }

  // 2. Chart.js from the CDN — cache first, it's a fixed version.
  if(url.startsWith(CDN)){
    event.respondWith(
      caches.open(SHELL_CACHE).then(cache =>
        cache.match(req).then(hit =>
          hit || fetch(req).then(res => { cache.put(req, res.clone()); return res; })
        )
      )
    );
    return;
  }

  // 3. Everything of our own — cache first. The saved copy is served every
  //    time, so the app opens instantly and works offline, and it is never
  //    swapped out behind the reader's back. Pressing "Check for updates" in
  //    the page clears this cache, which is what lets a new version through.
  event.respondWith(
    caches.match(req).then(hit =>
      hit || fetch(req)
        .then(res => {
          const copy = res.clone();
          caches.open(SHELL_CACHE).then(cache => cache.put(req, copy));
          return res;
        })
        .catch(() => caches.match('./index.html'))   // offline, unknown page
    )
  );
});
