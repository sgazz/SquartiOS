# Squart Marketing Page

Static landing page for the App Store **Marketing URL** field.

## Local preview

Open `index.html` in a browser, or:

```bash
cd marketing && python3 -m http.server 8080
```

Then visit `http://localhost:8080`.

## GitHub Pages

1. Push this repo to GitHub ([sgazz/SquartiOS](https://github.com/sgazz/SquartiOS)).
2. Run workflow **Deploy marketing site** once (Actions → workflow → Run workflow), or push to `main`.
3. **Settings → Pages → Build and deployment**
   - Source: **Deploy from a branch**
   - Branch: **`gh-pages`**
   - Folder: **`/ (root)`**
4. App Store Connect URLs:

   | Field | URL |
   |-------|-----|
   | Marketing URL | **https://sgazz.github.io/SquartiOS/** |
   | Support URL | **https://sgazz.github.io/SquartiOS/support/** |

   Repository: [github.com/sgazz/SquartiOS](https://github.com/sgazz/SquartiOS)

## Before submit

- [ ] Set `APP_STORE_URL` in `index.html` (or replace the `href` on the CTA).
- [ ] Set `SUPPORT_EMAIL` in `index.html` and `support/index.html`.
- [ ] Add a Privacy Policy link in the footer if you publish one elsewhere.

## Pages

- `index.html` — marketing / overview
- `support/index.html` — support & FAQ (App Store Support URL)
- `site.css` — shared styles
