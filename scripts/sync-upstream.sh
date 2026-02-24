#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

UPSTREAM_REMOTE="${SYMBOLS_UPSTREAM_REMOTE:-upstream}"
UPSTREAM_URL="${SYMBOLS_UPSTREAM_URL:-https://github.com/miguelsolorio/vscode-symbols.git}"
TARGET_BRANCH="${SYMBOLS_UPSTREAM_BRANCH:-main}"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree is not clean. Commit or stash local changes before syncing."
  exit 1
fi

if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
  git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
fi

git fetch "$UPSTREAM_REMOTE" --tags
git checkout "$TARGET_BRANCH"
git merge --ff-only "$UPSTREAM_REMOTE/$TARGET_BRANCH"

if [[ "${PUSH_AFTER_SYNC:-false}" == "true" ]]; then
  git push origin "$TARGET_BRANCH"
fi

echo "Synced $TARGET_BRANCH with $UPSTREAM_REMOTE/$TARGET_BRANCH"
