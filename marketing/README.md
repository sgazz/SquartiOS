# Squart Marketing Page

Static landing page for the App Store **Marketing URL** field.

## Local preview

Open `index.html` in a browser, or:

```bash
cd marketing && python3 -m http.server 8080
```

Then visit `http://localhost:8080`.

## GitHub Pages

1. Push this repo to GitHub.
2. **Settings → Pages → Build and deployment**
   - Source: **Deploy from a branch**
   - Branch: `main` (or your default)
   - Folder: **`/marketing`**
3. Marketing URL for App Store Connect:

   **https://sgazz.github.io/Squart/**

   GitHub project Pages uses the repository name in the path. The GitHub repo must be named **`Squart`** (rename from `SquartiOS` in repo Settings if needed).

## Before submit

- [ ] Set `APP_STORE_URL` in `index.html` (or replace the `href` on the CTA).
- [ ] Replace `support@example.com` with your real support email.
- [ ] Add a Privacy Policy link in the footer if you publish one elsewhere.
