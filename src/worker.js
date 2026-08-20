const STRIPE_API = 'https://api.stripe.com/v1';
const JSON_HEADERS = {
  'content-type': 'application/json; charset=UTF-8',
  'cache-control': 'no-store',
};

function json(body, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: JSON_HEADERS });
}

function stripeAuth(secretKey) {
  return `Basic ${btoa(`${secretKey}:`)}`;
}

async function stripeRequest(env, path, options = {}) {
  if (!env.STRIPE_SECRET_KEY) {
    throw new Error('Stripe is not configured. Add STRIPE_SECRET_KEY to this Worker.');
  }
  const response = await fetch(`${STRIPE_API}${path}`, {
    ...options,
    headers: { authorization: stripeAuth(env.STRIPE_SECRET_KEY), ...options.headers },
  });
  const payload = await response.json();
  if (!response.ok) throw new Error(payload?.error?.message || 'Stripe could not process the request.');
  return payload;
}

function checkoutSuccessUrl(origin) {
  return `${origin}/?checkout=success&session_id={CHECKOUT_SESSION_ID}`;
}

async function createCheckoutSession(request, env) {
  const { plan } = await request.json().catch(() => ({}));
  const price = plan === 'annual' ? env.STRIPE_PRICE_ANNUAL : plan === 'monthly' ? env.STRIPE_PRICE_MONTHLY : null;
  if (!price) return json({ error: 'Choose a valid subscription plan.' }, 400);

  const origin = new URL(request.url).origin;
  const form = new URLSearchParams({
    mode: 'subscription',
    success_url: checkoutSuccessUrl(origin),
    cancel_url: `${origin}/?checkout=cancelled`,
    allow_promotion_codes: 'true',
    'line_items[0][price]': price,
    'line_items[0][quantity]': '1',
  });
  const session = await stripeRequest(env, '/checkout/sessions', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: form.toString(),
  });
  return json({ url: session.url });
}

async function getCheckoutSession(url, env) {
  const sessionId = url.searchParams.get('session_id');
  if (!sessionId || !sessionId.startsWith('cs_')) return json({ error: 'Invalid Checkout Session.' }, 400);
  const session = await stripeRequest(env, `/checkout/sessions/${encodeURIComponent(sessionId)}?expand[]=subscription`);
  const subscription = typeof session.subscription === 'object' ? session.subscription : null;
  const active = session.status === 'complete' && ['active', 'trialing'].includes(subscription?.status);
  return json({ active });
}

async function createPortalSession(request, env) {
  const { session_id: sessionId } = await request.json().catch(() => ({}));
  if (!sessionId || !sessionId.startsWith('cs_')) return json({ error: 'Invalid Checkout Session.' }, 400);
  const checkout = await stripeRequest(env, `/checkout/sessions/${encodeURIComponent(sessionId)}`);
  if (!checkout.customer) return json({ error: 'No Stripe customer was found for this session.' }, 400);

  const origin = new URL(request.url).origin;
  const form = new URLSearchParams({ customer: checkout.customer, return_url: `${origin}/` });
  const portal = await stripeRequest(env, '/billing_portal/sessions', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: form.toString(),
  });
  return json({ url: portal.url });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    try {
      if (url.pathname === '/api/create-checkout-session' && request.method === 'POST') return createCheckoutSession(request, env);
      if (url.pathname === '/api/checkout-session' && request.method === 'GET') return getCheckoutSession(url, env);
      if (url.pathname === '/api/create-portal-session' && request.method === 'POST') return createPortalSession(request, env);
      if (url.pathname.startsWith('/api/')) return json({ error: 'Not found.' }, 404);
      return env.ASSETS.fetch(request);
    } catch (error) {
      console.error('Stripe integration error:', error);
      return json({ error: error.message || 'Unable to process your request.' }, 500);
    }
  },
};
