import { createAuthClient } from '@neondatabase/auth';

let client;
async function getClient() {
  if (client) return client;
  const response = await fetch('/api/auth-config', { cache: 'no-store' });
  const { url } = await response.json();
  if (!url) throw new Error('Account sign-in is not configured yet.');
  client = createAuthClient(url);
  return client;
}

export async function session() { return (await getClient()).getSession(); }
export async function token() { const auth = await getClient(); return auth.getJWTToken?.() || auth.getJwtToken?.() || null; }
export async function signInGoogle() { return (await getClient()).signIn.social({ provider: 'google', callbackURL: window.location.origin }); }
export async function signInEmail(email, password) { return (await getClient()).signIn.email({ email, password }); }
export async function signUpEmail(email, password) { return (await getClient()).signUp.email({ email, password, name: email.split('@')[0] }); }
export async function signOut() { return (await getClient()).signOut(); }

window.zenaAuth = { session, token, signInGoogle, signInEmail, signUpEmail, signOut };
window.dispatchEvent(new Event('zena-auth-ready'));
