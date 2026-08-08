# Palio di Siena — Statistics Dashboard

An installable web app covering the Palio di Siena: every contrada, jockey, horse and
drappellone from 1633 to today, plus the field for the next race.

Data comes from [ilpalio.org](https://www.ilpalio.org/), the non-profit archive curated by
Orlando Papei and authorised by the Consorzio per la Tutela del Palio di Siena. This is an
unofficial personal project.

---

## What's in this folder

| File | What it does |
|---|---|
| `index.html` | The whole dashboard — data, styling and behaviour in one file |
| `manifest.webmanifest` | Tells the browser the app's name, colours and icons so it can be installed |
| `sw.js` | Service worker: makes the app open offline and remembers banners you've viewed |
| `icons/` | App icons for the home screen |
| `.nojekyll` | Stops GitHub trying to process the site as a blog. Leave it there |

---

## Putting it on GitHub Pages

You'll do this once. Afterwards, updating is just replacing `index.html`.

### 1. Create the repository

1. Go to **https://github.com/new** (sign in first).
2. **Repository name:** `palio` — or anything you like; it becomes part of the web address.
3. Set it to **Public**. GitHub Pages needs public on a free account.
4. Leave every checkbox unticked — no README, no .gitignore. This folder already has what it needs.
5. Click **Create repository**.

### 2. Upload the files

1. On the empty repository page, click **uploading an existing file**.
2. Open this `palio-pwa` folder on your Mac and drag **everything inside it** onto the
   browser window — `index.html`, `manifest.webmanifest`, `sw.js`, and the `icons` folder.
   Drag the *contents*, not the folder itself: `index.html` must sit at the top level of
   the repository, not inside a sub-folder.
3. `.nojekyll` starts with a dot, so Finder hides it. Press **⌘ + Shift + .** in Finder to
   show hidden files, drag it across too, then press the same keys to re-hide them.
4. Scroll down, click **Commit changes**.

### 3. Turn on Pages

1. In the repository, click **Settings** (top right).
2. In the left sidebar, click **Pages**.
3. Under **Source**, choose **Deploy from a branch**.
4. Set the branch to **main** and the folder to **/ (root)**. Click **Save**.
5. Wait a minute or two, then refresh. GitHub shows the address at the top:

   ```
   https://YOUR-USERNAME.github.io/palio/
   ```

   Replace `YOUR-USERNAME` with your GitHub username. That's your app.

> **Why GitHub Pages and not just the file on your Mac?** Service workers — the thing that
> makes an app installable and able to run offline — only work over `https`. Opening the
> `.html` from your hard drive skips that part. Everything else still works, you just don't
> get the install button.

### 4. Install it on a device

**iPhone / iPad.** Open the address in **Safari** (not Chrome — on iOS only Safari can
install web apps). Tap the **Share** button, scroll down, tap **Add to Home Screen**. It
gets an icon and opens without browser chrome, like any other app.

**Mac, Chrome or Edge.** Open the address, then click the small install icon at the right
of the address bar — or the **⋮** menu → **Cast, save and share** → **Install page as app**.

**Android.** Chrome usually offers "Add to home screen" on its own; if not, **⋮** →
**Add to Home screen**.

---

## Updating it later

When the dashboard is rebuilt after a new Palio:

1. In your repository, click `index.html`, then the **pencil** icon.
2. Delete everything in the box and paste in the new file's contents.
   *(Easier alternative: on the repository's main page use **Add file → Upload files** and
   drag the new `index.html` in — GitHub replaces the old one.)*
3. Click **Commit changes**. The live site updates within a minute.

**One catch worth knowing.** Installed apps hold on to the cached copy. If you've changed
`index.html` and want every device to pick it up straight away, also edit `sw.js` and bump
the version line near the top:

```js
const CACHE_VERSION = 'palio-v1';   →   'palio-v2'
```

Changing that name is what tells browsers to discard the old copy and fetch everything
fresh.

---

## What works offline

- **The dashboard itself** — every tab, chart, table and pop-up. All the data is inside
  `index.html`, so nothing needs fetching.
- **Drappellone photographs you've already viewed.** These live on ilpalio.org and are
  linked rather than copied; the service worker saves each one the first time you see it.
  Banners you've never opened won't appear until you're back online.

Copying all 537 banners into the app would add roughly 22 MB and make it slow to open, so
they're linked instead. The side benefit is that new banners appear on their own as soon
as ilpalio.org posts them, with no update needed here.

---

## A note on the linked images

The banner photographs are served from ilpalio.org. That's their bandwidth, and a public
site draws more of it than a file on your own machine. It's a small archive of small
thumbnails and this is a personal project, so the load is negligible — but if you'd rather
not lean on someone else's server at all, the alternative is to copy a subset into the app.
The last 25 years is about 1.5 MB, which is perfectly manageable.
