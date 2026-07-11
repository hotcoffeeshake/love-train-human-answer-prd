#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STABLE_BASE="${STABLE_BASE:-https://love-train-v12.vercel.app}"
LEGACY_BASE="${LEGACY_BASE:-https://love-train-v12-cz63n5bqu-flyxqc1s-projects.vercel.app}"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/lovetrain-production-audit.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

fetch() {
  curl --fail --location --silent --show-error --max-time 20 "$1" --output "$2"
}

status() {
  curl --location --silent --show-error --max-time 20 --output /dev/null --write-out '%{http_code}' "$1"
}

echo "Stable site: $STABLE_BASE"
echo "Legacy PRD URL: $LEGACY_BASE"

fetch "$STABLE_BASE/" "$TMP_DIR/stable-index.html"
fetch "$STABLE_BASE/human-answer" "$TMP_DIR/stable-human-answer.html"
fetch "$STABLE_BASE/human-answer.js" "$TMP_DIR/stable-human-answer.js"
fetch "$LEGACY_BASE/" "$TMP_DIR/legacy-index.html"

local_hash="$(shasum -a 256 "$ROOT_DIR/human-answer.js" | awk '{print $1}')"
remote_hash="$(shasum -a 256 "$TMP_DIR/stable-human-answer.js" | awk '{print $1}')"

echo "Local human-answer.js SHA-256:  $local_hash"
echo "Remote human-answer.js SHA-256: $remote_hash"

if [[ "$local_hash" != "$remote_hash" ]]; then
  echo "ERROR: deployed Human Answer script no longer matches this repository." >&2
  exit 1
fi

if ! grep -q 'const tasks = \[' "$TMP_DIR/stable-human-answer.js"; then
  echo "ERROR: deployed script no longer contains the expected mock task array." >&2
  exit 1
fi

for route in /api/questions /api/human/tasks /api/chat; do
  code="$(status "$STABLE_BASE$route")"
  printf '%-24s %s\n' "$route" "$code"
  if [[ "$code" != "404" ]]; then
    echo "ERROR: expected $route to remain unavailable until the production integration is delivered." >&2
    exit 1
  fi
done

if ! grep -q '爱之列车 — 情感导师' "$TMP_DIR/legacy-index.html"; then
  echo "ERROR: legacy PRD deployment fingerprint changed." >&2
  exit 1
fi

echo "Audit result: production still serves the PRD mock and required APIs are absent."
