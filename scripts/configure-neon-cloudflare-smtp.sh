#!/usr/bin/env bash
# Configure Cloudflare Email Service as the Neon Auth SMTP provider.
#
# Optional environment variables: NEON_API_KEY, NEON_PROJECT_ID,
# NEON_BRANCH_ID, CF_EMAIL_API_TOKEN, SENDER_EMAIL, SENDER_NAME.
# Values not supplied are requested interactively.

set -euo pipefail

prompt_value() {
  local variable_name="$1"
  local prompt="$2"
  local default_value="${3:-}"
  local current_value="${!variable_name:-$default_value}"

  if [[ -n "${!variable_name:-}" ]]; then
    printf -v "$variable_name" '%s' "$current_value"
    return
  fi

  read -r -p "$prompt${default_value:+ [$default_value]}: " current_value
  current_value="${current_value:-$default_value}"
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
prompt_secret CF_EMAIL_API_TOKEN "Cloudflare Email Sending API token"
prompt_value SENDER_EMAIL "Verified sender email" "hello@zena.ltd"
prompt_value SENDER_NAME "Sender name" "Zena"

payload="$(CF_EMAIL_API_TOKEN="$CF_EMAIL_API_TOKEN" SENDER_EMAIL="$SENDER_EMAIL" SENDER_NAME="$SENDER_NAME" node -e '
  process.stdout.write(JSON.stringify({
    type: "standard",
    host: "smtp.mx.cloudflare.net",
    port: 465,
    username: "api_token",
    password: process.env.CF_EMAIL_API_TOKEN,
    sender_email: process.env.SENDER_EMAIL,
    sender_name: process.env.SENDER_NAME,
  }));
')"

response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

status="$(curl -sS -o "$response_file" -w '%{http_code}' \
  -X PATCH "https://console.neon.tech/api/v2/projects/${NEON_PROJECT_ID}/branches/${NEON_BRANCH_ID}/auth/email_provider" \
  -H "Authorization: Bearer ${NEON_API_KEY}" \
  -H 'Content-Type: application/json' \
  --data "$payload")"

if [[ "$status" =~ ^2 ]]; then
  echo "Cloudflare SMTP is configured for Neon Auth (HTTP ${status})."
  cat "$response_file"
  echo
else
  echo "Neon rejected the SMTP configuration (HTTP ${status}):" >&2
  cat "$response_file" >&2
  echo >&2
  exit 1
fi
