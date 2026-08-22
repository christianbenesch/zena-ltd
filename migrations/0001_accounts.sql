CREATE TABLE IF NOT EXISTS profiles (
  user_id text PRIMARY KEY,
  stripe_customer_id text UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS entitlements (
  id bigserial PRIMARY KEY,
  user_id text NOT NULL REFERENCES profiles(user_id) ON DELETE CASCADE,
  product_key text NOT NULL,
  status text NOT NULL CHECK (status IN ('active', 'trialing', 'past_due', 'cancelled', 'inactive')),
  stripe_subscription_id text UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, product_key)
);

CREATE INDEX IF NOT EXISTS entitlements_user_id_idx ON entitlements(user_id);

CREATE TABLE IF NOT EXISTS account_state (
  user_id text PRIMARY KEY REFERENCES profiles(user_id) ON DELETE CASCADE,
  data jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS stripe_events (
  stripe_event_id text PRIMARY KEY,
  processed_at timestamptz NOT NULL DEFAULT now()
);
