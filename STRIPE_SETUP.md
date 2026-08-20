# Stripe setup

The Stripe secret key never appears in browser code. Configure these as **Worker secrets** in Cloudflare: **Workers & Pages → zena-ltd → Settings → Variables and Secrets**.

| Secret | Value |
|---|---|
| `STRIPE_SECRET_KEY` | Stripe secret API key (`sk_live_...` in production) |
| `STRIPE_PRICE_MONTHLY` | Stripe recurring monthly Price ID for Zena+ ($5.99) |
| `STRIPE_PRICE_ANNUAL` | Stripe recurring annual Price ID for Zena+ ($49.99) |

Create the two recurring Prices in Stripe before adding the values. Configure the Stripe Customer Portal as well, including cancellation and payment-method management. The app sends paid customers to it from **Manage Zena+ subscription**.

## Deploy

Deploy this Worker with its static assets first. The deployable site files are in `public/`; credentials and project files are outside that directory and are never bundled as public assets:

```sh
npx wrangler deploy
```

If the existing Worker has a different name, change `name` in `wrangler.jsonc` to that exact Worker name before deploying.

Once this script-backed Worker is deployed, add the three values above in the Cloudflare dashboard. They take effect immediately; no second deploy is required.

## Scope

This implementation creates Stripe Checkout Sessions server-side, verifies a completed subscription after the checkout return, and opens Stripe's hosted Customer Portal. It remembers the successful Checkout Session on the current browser only.

For login-based, cross-device entitlements or server-side premium APIs, add user authentication and persist Stripe's `customer`/`subscription` data from verified Stripe webhook events. Do not treat browser-side feature gating as access control for sensitive server data.
