# Zena.ltd — SEO & Schema Handoff for IT

**Domain:** https://zena.ltd  
**Purpose:** Google indexing + structured data for the breath-training web app

---

## Important before you start

1. Prefer **one host only**: `zena.ltd` (apex). 301-redirect `www.zena.ltd` → `https://zena.ltd` (or the reverse — pick one and use it everywhere).
2. Replace placeholder image URLs (`/og-image.png`, `/logo.png`) with real assets. OG image ideally **1200×630**.
3. Replace Paddle checkout URLs in the schema when live.
4. Do **not** invent star ratings in schema until real, visible reviews exist on the page.

---

## 1. Add these tags inside `<head>`

Merge with the existing page.

```html
<title>Zena — Daily Breath Hold Training | CO₂ Tolerance & Calm</title>

<meta name="description"
      content="Free daily breath-hold training. Build CO₂ tolerance, calm under pressure, and track progress with guided holds, box breathing, 4-7-8, and an 8-week progression. Age backwards — one hold at a time.">

<meta name="robots" content="index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1">

<link rel="canonical" href="https://zena.ltd/">

<!-- Open Graph -->
<meta property="og:type" content="website">
<meta property="og:url" content="https://zena.ltd/">
<meta property="og:title" content="Zena — Daily Breath Hold Training">
<meta property="og:description"
      content="Guided breath holds, CO₂ tolerance training, and nervous-system practices. Free core timer + Zena+ for full program and tracking.">
<meta property="og:image" content="https://zena.ltd/og-image.png">
<meta property="og:site_name" content="Zena">
<meta property="og:locale" content="en_US">

<!-- Twitter / X -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Zena — Daily Breath Hold Training">
<meta name="twitter:description"
      content="Build breath-hold capacity and calm. Free daily practice + optional progression program.">
<meta name="twitter:image" content="https://zena.ltd/og-image.png">

<!-- Mobile / theme -->
<meta name="theme-color" content="#071620">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="Zena">

<!-- Icons (upload real files) -->
<link rel="icon" href="/favicon.ico" sizes="any">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32.png">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<!-- Optional PWA: <link rel="manifest" href="/manifest.webmanifest"> -->
```

---

## 2. Schema.org JSON-LD

Paste once in `<head>` or just before `</body>`.

### Main schema (required)

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Organization",
      "@id": "https://zena.ltd/#organization",
      "name": "Zena",
      "url": "https://zena.ltd/",
      "logo": {
        "@type": "ImageObject",
        "url": "https://zena.ltd/logo.png"
      },
      "sameAs": []
    },
    {
      "@type": "WebSite",
      "@id": "https://zena.ltd/#website",
      "url": "https://zena.ltd/",
      "name": "Zena",
      "description": "Daily breath-hold and breathwork training for CO₂ tolerance, calm, and endurance.",
      "publisher": { "@id": "https://zena.ltd/#organization" },
      "inLanguage": "en"
    },
    {
      "@type": "WebApplication",
      "@id": "https://zena.ltd/#app",
      "name": "Zena — Daily Breath Hold",
      "url": "https://zena.ltd/",
      "description": "Browser-based breath-hold timer and breathwork practices. Free core breath-hold sessions plus Zena+ for box breathing, physiological sigh, 4-7-8, coherent breathing, extended exhale, 8-week progression, streaks, and resting heart-rate trends.",
      "applicationCategory": "HealthApplication",
      "applicationSubCategory": "Breathwork / Breath-hold training",
      "operatingSystem": "Any (Web browser)",
      "browserRequirements": "Requires JavaScript and HTML5. Modern mobile or desktop browser recommended.",
      "offers": [
        {
          "@type": "Offer",
          "name": "Free",
          "price": "0",
          "priceCurrency": "USD",
          "availability": "https://schema.org/InStock",
          "url": "https://zena.ltd/"
        },
        {
          "@type": "Offer",
          "name": "Zena+ Monthly",
          "price": "5.99",
          "priceCurrency": "USD",
          "availability": "https://schema.org/InStock",
          "url": "https://REPLACE-WITH-YOUR-PADDLE-CHECKOUT-LINK-MONTHLY"
        },
        {
          "@type": "Offer",
          "name": "Zena+ Annual",
          "price": "49.99",
          "priceCurrency": "USD",
          "availability": "https://schema.org/InStock",
          "url": "https://REPLACE-WITH-YOUR-PADDLE-CHECKOUT-LINK-ANNUAL"
        }
      ],
      "featureList": [
        "Timed breath holds with guided prep breathing",
        "Box breathing, physiological sigh, 4-7-8, coherent breathing, extended exhale (Zena+)",
        "8-week CO₂ tolerance progression program",
        "Streaks, personal bests, and session history",
        "Resting heart-rate logging and trends",
        "Shareable progress cards and badges"
      ],
      "screenshot": "https://zena.ltd/og-image.png",
      "isAccessibleForFree": true,
      "publisher": { "@id": "https://zena.ltd/#organization" }
    },
    {
      "@type": "WebPage",
      "@id": "https://zena.ltd/#webpage",
      "url": "https://zena.ltd/",
      "name": "Zena — Daily Breath Hold Training",
      "isPartOf": { "@id": "https://zena.ltd/#website" },
      "about": { "@id": "https://zena.ltd/#app" },
      "description": "Practice daily breath holds and guided breathwork. Free core timer; Zena+ unlocks full practices, program, and progress tracking.",
      "inLanguage": "en"
    }
  ]
}
</script>
```

### Optional FAQ schema

Only add if the matching answers are **visible on the page** (ideally in the initial HTML, not only after JS).

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Why practice a 90-second breath hold?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Short, repeated hypoxic holds can support EPO-related adaptations, improved CO₂ tolerance, more efficient oxygen use, and a calmer nervous-system response. It is a stress-adaptation practice, not medical treatment."
      }
    },
    {
      "@type": "Question",
      "name": "Is breath-hold training safe?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Never practice breath holds in or near water, while driving, or standing. Sit or lie down. Stop if lightheaded. Skip if pregnant or if you have cardiovascular, respiratory, or seizure conditions — check with a doctor. Not medical advice."
      }
    },
    {
      "@type": "Question",
      "name": "What is included in free vs Zena+?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Free includes the core breath-hold session. Zena+ adds box breathing, physiological sigh, 4-7-8, coherent breathing, extended exhale, the 8-week program, custom hold length and rounds, streaks, badges, and resting heart-rate trends."
      }
    }
  ]
}
</script>
```

---

## 3. File: `/robots.txt` (site root)

```
User-agent: *
Allow: /

Sitemap: https://zena.ltd/sitemap.xml
```

---

## 4. File: `/sitemap.xml` (site root)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://zena.ltd/</loc>
    <lastmod>2026-08-20</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

Update `<lastmod>` when the homepage changes meaningfully. Add more `<url>` entries if you create real path-based routes later.

---

## 5. Google Search Console (after deploy)

1. Verify property for `zena.ltd` (DNS TXT preferred, or HTML file upload).
2. Confirm preferred host (apex vs www) and that the other 301-redirects.
3. Submit sitemap: `https://zena.ltd/sitemap.xml`
4. URL Inspection → `https://zena.ltd/` → Test live URL → Request indexing.
5. Validate structured data:
   - https://search.google.com/test/rich-results
   - https://validator.schema.org/
6. Monitor Pages report for “Crawled – currently not indexed” (common with heavy client-side apps).

---

## 6. Technical notes

- **HTTPS only** — force HTTPS; no mixed content.
- **One preferred host** — 301 redirect the other (www ↔ apex).
- **SPA caveat** — Google can render JS, but important text (benefits, safety) should ideally exist in the initial HTML, not only after hydration. Pre-render or SSR static copy if indexing stays thin.
- **No noindex** on production. Ensure staging does not leak a noindex robots meta or `X-Robots-Tag`.
- **Assets to put on the server:**
  - `/og-image.png` — ~1200×630 social share image
  - `/logo.png` — square logo for schema
  - `/favicon.ico`, `/favicon-32.png`, `/apple-touch-icon.png`
- **Paddle links** — replace the two `REPLACE-WITH-YOUR-PADDLE-…` URLs in the WebApplication offers (and in the app UI) before launch.
- **Do not add `aggregateRating`** until real ratings are visible on the page and match the numbers.

---

## 7. Deploy checklist

- [ ] Meta tags + canonical in live HTML
- [ ] JSON-LD schema live and validating
- [ ] `/robots.txt` live
- [ ] `/sitemap.xml` live
- [ ] OG image + logo + favicons uploaded
- [ ] Apex/www 301 decision applied
- [ ] Search Console verified + sitemap submitted
- [ ] Homepage requested for indexing
- [ ] Paddle URLs updated in schema and app
