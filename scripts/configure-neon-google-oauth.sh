#!/usr/bin/env bash
# Configure Google as a Neon Auth OAuth provider for one database branch.
#
# Optional environment variables: NEON_API_KEY, NEON_PROJECT_ID,
# NEON_BRANCH_ID, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET.
# Values not supplied are requested interactively.

set -euo pipefail

prompt_value() {
  local variable_name="$1"
  local prompt="$2"
  local current_value="${!variable_name:-}"

  if [[ -n "$current_value" ]]; then
    printf -v "$variable_name" '%s' "$current_value"
    return
  fi

  read -r -p "$prompt: " current_value
  if [[ -z "$current_value" ]]; then
    echo "$prompt is required." >&2
    exit 1
  fi
  printf -v "$variable_name" '%s' "$current_value"
}

prompt_secret() {
  local variable_name="$1"
  local prompt="$2"
  local current_value="${!variable_name:-}"

  if [[ -n "$current_value" ]]; then
    printf -v "$variable_name" '%s' "$current_value"
    return
  fi

  read -r -s -p "$prompt: " current_value
  echo
  if [[ -z "$current_value" ]]; then
    echo "$prompt is required." >&2
    exit 1
  fi
  printf -v "$variable_name" '%s' "$current_value"
}

command -v curl >/dev/null || { echo "curl is required." >&2; exit 1; }
command -v node >/dev/null || { echo "node is required." >&2; exit 1; }

prompt_secret NEON_API_KEY "Neon API key"
prompt_value NEON_PROJECT_ID "Neon project ID"
prompt_value NEON_BRANCH_ID "Neon production branch ID"
prompt_value GOOGLE_CLIENT_ID "Google OAuth client ID"
prompt_secret GOOGLE_CLIENT_SECRET "Google OAuth client secret"

payload="$(GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET" node -e '
  process.stdout.write(JSON.stringify({
    id: "google",
    client_id: process.env.GOOGLE_CLIENT_ID,
    client_secret: process.env.GOOGLE_CLIENT_SECRET,
  }));
')"

response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

status="$(curl -sS -o "$response_file" -w '%{http_code}' \
  -X POST "https://console.neon.tech/api/v2/projects/${NEON_PROJECT_ID}/branches/${NEON_BRANCH_ID}/auth/oauth_providers" \
  -H "Authorization: Bearer ${NEON_API_KEY}" \
  -H 'Content-Type: application/json' \
  --data "$payload")"

if [[ "$status" =~ ^2 ]]; then
  echo "Google OAuth is configured for Neon Auth (HTTP ${status})."
  cat "$response_file"
  echo
else
  echo "Neon rejected the OAuth provider configuration (HTTP ${status}):" >&2
  cat "$response_file" >&2
  echo >&2
  exit 1
fi
