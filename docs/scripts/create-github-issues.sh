#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash docs/scripts/create-github-issues.sh --dry-run
  bash docs/scripts/create-github-issues.sh --repo OWNER/REPO [--with-labels]

Creates GitHub issues from docs/tasks/issue-*.md using GitHub CLI.
Use --dry-run first to inspect titles and files without writing to GitHub.
By default creation skips labels so it works on repositories where labels are not pre-created. Add --with-labels only after the labels exist in the target repo.
USAGE
}

mode=""
repo=""
with_labels="false"

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)
      mode="dry-run"
      shift
      ;;
    --repo)
      mode="create"
      repo="${2:-}"
      shift 2
      ;;
    --with-labels)
      with_labels="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "$mode" ]; then
  usage >&2
  exit 2
fi

if [ "$mode" = "create" ] && [ -z "$repo" ]; then
  echo "--repo OWNER/REPO is required when creating issues." >&2
  exit 2
fi

if [ "$mode" = "create" ]; then
  command -v gh >/dev/null 2>&1 || {
    echo "GitHub CLI 'gh' is required." >&2
    exit 1
  }
  gh auth status >/dev/null
fi

for file in docs/tasks/issue-*.md; do
  title=$(sed -n '1s/^# //p' "$file")
  if [ -z "$title" ]; then
    echo "Skipping $file because no H1 title was found." >&2
    continue
  fi

  labels=$(awk -F': ' '/^Labels:/ { print $2; exit }' "$file" | tr -d '`' | tr ',' '\n' | sed 's/^ *//; s/ *$//' | paste -sd, -)

  if [ "$mode" = "dry-run" ]; then
    printf 'DRY RUN: %s\n  file: %s\n  labels: %s\n\n' "$title" "$file" "${labels:-none}"
  else
    if [ "$with_labels" = "true" ] && [ -n "$labels" ]; then
      gh issue create --repo "$repo" --title "$title" --body-file "$file" --label "$labels"
    else
      gh issue create --repo "$repo" --title "$title" --body-file "$file"
    fi
  fi
done
