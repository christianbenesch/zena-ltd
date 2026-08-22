Build a minimal persistent account system for the app so paying users can return on another browser/device, or after clearing browser storage, and recover their account and paid access.

Goal

Stripe should remain the billing system, not the identity system.

The app should maintain its own stable user_id and associate that user with a Stripe Customer.

Target architecture:

App User
├── id
├── email
├── email_verified_at
├── stripe_customer_id
└── created_at
Stripe Customer
├── id: cus_...
├── email
└── metadata.app_user_id

Authentication for v1 should be passwordless email magic link / one-time login link.

Do not implement username/password authentication.

Design the identity model so Google/Apple/social login can be added later as additional identities linked to the same app user.

Required behavior

First-time user

A user should be able to use the app anonymously if the current application supports that.

When persistence is required — ideally before/while purchasing or saving durable state — ask for their email address.

Verify the email using a short-lived, single-use magic link.

After verification:

1. Create or retrieve the app user.
2. Associate any current anonymous data/session state with that user.
3. Create a Stripe Customer if the user does not already have one.
4. Store the Stripe Customer ID on the user.
5. Add the app user ID to Stripe Customer metadata.
6. Create an authenticated application session.

Returning user

The user enters their email.

Send a new magic link.

After successful verification, restore their existing account using the app user record.

Their access must not depend on:

* cookies surviving forever
* localStorage
* browser cache
* using the original browser/device

Cookies/localStorage may cache a session, but persistent identity and entitlements must live server-side.

Stripe rules

Never use Stripe email as the primary account identifier.

Use:

app user_id → stripe_customer_id

as the durable relationship.

When creating Stripe Checkout for an existing user, pass their existing Stripe Customer rather than creating a new customer.

Use Stripe webhooks as the authoritative source for payment/subscription state.

Persist relevant entitlement state against the app user, for example:

user_id
product / plan
status
stripe_subscription_id
stripe_customer_id
updated_at

Webhook processing must be idempotent.

At minimum handle the Stripe events relevant to the app’s existing payment model, such as successful checkout/payment and subscription lifecycle events if subscriptions are used.

Suggested database model

Adapt this to the database already used by the project rather than introducing unnecessary infrastructure.

users
-----
id
email UNIQUE
email_verified_at
stripe_customer_id UNIQUE NULL
created_at
updated_at
sessions
--------
id / token_hash
user_id
expires_at
created_at
magic_links
-----------
token_hash
email
expires_at
used_at
created_at
entitlements
------------
id
user_id
product_key
status
stripe_subscription_id NULL
created_at
updated_at

If anonymous sessions currently contain app data, add an appropriate mechanism for claiming/migrating that data to the authenticated user_id.

Magic-link security

Magic links must:

* use cryptographically secure random tokens
* expire quickly, e.g. 10–20 minutes
* be single use
* store only a hash of the token server-side
* become invalid after successful use
* not expose authentication secrets in logs

On successful authentication, create a secure session cookie.

Use appropriate cookie flags:

HttpOnly
Secure
SameSite=Lax

Set a sensible expiration and support server-side logout/session invalidation.

Avoid account-enumeration responses. The login endpoint should respond similarly whether or not an email already exists.

Email identity

The app’s verified email is the canonical email identity.

Do not query Stripe by email to decide which application account someone owns.

Do not assume Stripe email uniqueness.

Billing email changes must not accidentally create or switch application accounts.

Normalize email addresses appropriately before lookup while preserving the original/display value if needed.

Social login

Do not implement social login in this first pass unless it is trivial given the project’s existing auth stack.

However, structure the model so future providers can map to one user, e.g.:

auth_identities
---------------
id
user_id
provider       # email / google / apple
provider_user_id
email
created_at

A social login should eventually resolve to the same internal user.id, not create a parallel Stripe/customer system.

UX

Keep account creation low friction.

Preferred flow:

anonymous use
→ user wants to pay/save/sync
→ enter email
→ receive magic link
→ verify
→ existing anonymous state becomes persistent
→ Stripe Checkout

Returning flow:

enter email
→ magic link
→ authenticated session
→ load user data
→ load entitlement/payment state

Do not display “create an account” versus “log in” as two fundamentally separate flows unless required. An email magic-link form can handle both.

Implementation requirements

First inspect the existing codebase and reuse its:

* runtime/framework
* database
* Stripe integration
* routing conventions
* environment-variable system
* email infrastructure, if present
* existing session/auth utilities, if present

Avoid introducing a large authentication framework unless it substantially reduces complexity.

Prefer a small implementation native to the existing stack.

Before changing code, identify:

1. current Stripe Checkout/payment creation path
2. current Stripe webhook handling
3. how application state is currently associated with a browser/session
4. existing database/storage layer
5. whether an email provider is already configured

Then implement the smallest coherent end-to-end solution.

Environment/config

Add only the configuration actually needed, likely including:

APP_BASE_URL
MAGIC_LINK_SECRET or equivalent
EMAIL_FROM
email-provider credentials
STRIPE_SECRET_KEY        # probably already exists
STRIPE_WEBHOOK_SECRET    # probably already exists

Do not hardcode secrets.

Important edge cases

Handle:

* repeated magic-link requests
* expired links
* already-used links
* user opens link on another browser
* existing user without a Stripe Customer
* existing Stripe customer linkage
* duplicate webhook deliveries
* cancelled/expired subscriptions
* payment succeeds while user closes the browser
* logout and session expiration
* simultaneous login attempts
* anonymous data being claimed exactly once

Do not automatically merge two established accounts purely because they have matching unverified emails.

Deliverable

Implement the feature rather than only describing it.

After implementation, provide:

1. a short architecture summary
2. database/schema changes
3. routes/endpoints added or modified
4. Stripe changes
5. required environment variables
6. any migration steps
7. tests added
8. any remaining risks or TODOs

Add tests for the critical auth and Stripe-account-linkage behavior.

Preserve existing behavior wherever possible and keep the implementation minimal.

Cloud Flare as the DB provider