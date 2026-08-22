# zena.ltd — SEO setup

Three files, plus one Search Console task. Nothing here changes how the app
works — it is all metadata and indexing.

---

## 1. `zena-seo-head.html` — paste into the app

Open `zena-ltd.html`. Inside `<head>`:

- **Delete** the existing line:
  `<title>zena.ltd — Daily Breath Hold</title>`
- **Paste** the whole contents of `zena-seo-head.html` directly after the
  `<meta name="viewport">` line and before `<style>`.

Result: one `<title>`, a meta description, canonical URL, Open Graph and
Twitter cards, icon links, and two JSON-LD blocks (the app itself + an FAQ).

⚠️ **This has to be redone every time the HTML file is replaced.** The app is
a single self-contained file, so overwriting it wipes the head block. Keep
`zena-seo-head.html` alongside the project and re-paste after each deploy.

---

## 2. `robots.txt` and `sitemap.xml` — upload to the site root

They must resolve at:

- `https://zena.ltd/robots.txt`
- `https://zena.ltd/sitemap.xml`

Not in a subfolder — root only, or Google ignores them.

---

## 3. Assets still needed

The head block references files that need to exist, or the links 404:

| File | Size | Purpose |
|---|---|---|
| `/og-image.jpg` | 1200×630 | Preview image when the link is shared |
| `/favicon.ico` | 32×32 | Browser tab |
| `/icon.svg` | any | Modern browser tab icon |
| `/apple-touch-icon.png` | 180×180 | iOS home screen |
| `/manifest.webmanifest` | — | PWA install |

If any aren't ready yet, delete that line from the head block rather than
leaving a broken reference.

---

## 4. Google Search Console

1. Add `zena.ltd` as a property (DNS or HTML-file verification).
2. **Sitemaps** → submit `sitemap.xml`.
3. **URL Inspection** → enter `https://zena.ltd/` → **Request Indexing**.

After a deploy you do **not** need to redo this. Google re-crawls on its own.
Requesting indexing again just speeds it up.

---

## 5. Verify it worked

- **Rich Results Test** — https://search.google.com/test/rich-results
  Paste the live URL. Should detect **WebApplication** and **FAQPage** with no
  errors.
- **Social preview** — paste the URL into a Slack/WhatsApp message and check
  the card renders.

---

## Note on wording

The in-app tagline is *"Zena. Age backwards."* That is deliberately **not**
used in the meta description or structured data. Search engines and ad
platforms treat literal anti-ageing claims as health claims requiring
substantiation, and unsupported ones risk manual action or ad rejection. The
metadata describes what the app does instead. Keep it that way.
