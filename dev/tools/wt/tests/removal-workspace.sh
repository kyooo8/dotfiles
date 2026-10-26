#!/usr/bin/env bash
set -euo pipefail
source <(sed '/^case "${1:-}" in/,$d' "$(dirname "$0")/../bin/wt")
check_clean_and_pushed() { :; }
herdr() {
  if [ "$2" = list ]; then
    printf '{"result":{"worktrees":[{"path":"/agent","open_workspace_id":null}]}}\n'
  else
    echo 'must not pass null to herdr remove' >&2
    return 1
  fi
}
git() { printf '%s\n' "$*" > "$tmp/call"; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
remove_worktree /agent friday
[ "$(cat "$tmp/call")" = '-C /agent worktree remove /agent' ]
echo 'closed workspace removal test passed'
