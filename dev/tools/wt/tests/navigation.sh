#!/usr/bin/env bash
set -euo pipefail
WT_BIN="$(cd "$(dirname "$0")/../bin" && pwd)/wt"
export PATH="$(dirname "$WT_BIN"):$PATH"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home"
mkdir -p "$HOME/dev/agents" "$tmp/repo with spaces"
git init -q "$tmp/repo with spaces"
git -C "$tmp/repo with spaces" -c user.name=Test -c user.email=test@example.com commit -qm initial --allow-empty
git -C "$tmp/repo with spaces" worktree add -qb agent "$HOME/dev/agents/jarvis"
git init -q "$HOME/dev/agents/friday"

for shell in bash zsh; do
  "$shell" -c '
    set -eu
    eval "$(wt shell-init)"
    cd "$1"
    wt jarvis
    [ "$PWD" = "$HOME/dev/agents/jarvis" ]
    wt --help >/dev/null
    cd "$1"
    for name in friday edith unknown; do
      if wt "$name" > /dev/null 2>&1; then
        echo "unexpected success: $name" >&2
        exit 1
      fi
      [ "$PWD" = "$1" ]
    done
    if wt jarvis extra > /dev/null 2>&1; then exit 1; fi
    cd "$HOME"
    if wt jarvis > /dev/null 2>&1; then exit 1; fi
  ' test "$tmp/repo with spaces"
done
echo 'navigation tests passed (bash, zsh)'
