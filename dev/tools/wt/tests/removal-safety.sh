#!/usr/bin/env bash
set -euo pipefail
source <(sed '/^case "${1:-}" in/,$d' "$(dirname "$0")/../bin/wt")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git init -q "$tmp"
git -C "$tmp" -c user.name=Test -c user.email=test@example.com commit -qm initial --allow-empty
git -C "$tmp" update-ref refs/remotes/origin/published HEAD
(check_clean_and_pushed "$tmp" friday)
git -C "$tmp" -c user.name=Test -c user.email=test@example.com commit -qm unpublished --allow-empty
if (check_clean_and_pushed "$tmp" friday) >/dev/null 2>&1; then
  echo 'unpublished commit was accepted' >&2
  exit 1
fi
git -C "$tmp" update-ref refs/remotes/origin/published HEAD
touch "$tmp/untracked"
if (check_clean_and_pushed "$tmp" friday) >/dev/null 2>&1; then
  echo 'uncommitted changes were accepted' >&2
  exit 1
fi
echo 'removal safety tests passed'
