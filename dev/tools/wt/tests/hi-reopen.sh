#!/usr/bin/env bash
set -euo pipefail
source <(sed '/^case "${1:-}" in/,$d' "$(dirname "$0")/../bin/wt")
tmp=$(mktemp -d)
tmp=$(cd "$tmp" && pwd -P)
trap 'rm -rf "$tmp"' EXIT
AGENTS_DIR="$tmp/worktrees"
mkdir -p "$tmp/repo with spaces"
git init -q "$tmp/repo with spaces"
git -C "$tmp/repo with spaces" -c user.name=Test -c user.email=test@example.com commit -qm initial --allow-empty
target="$AGENTS_DIR/repo with spaces/feat_foo"
git -C "$tmp/repo with spaces" worktree add -qb feat/foo "$target"
printf 'keep me\n' > "$target/uncommitted"
# A remote ref also guards against moving a checked-out branch before reopening.
git -C "$tmp/repo with spaces" update-ref refs/remotes/origin/feat/foo HEAD
mock_workspace_id=null
herdr() {
  case "$1 $2" in
    'worktree list')
      [ "$3" = --cwd ] && [ "$4" = "$target" ]
      jq -n --arg path "$target" --argjson id "$mock_workspace_id" \
        '{result:{worktrees:[{path:$path,open_workspace_id:$id}]}}'
      ;;
    'worktree open')
      [ "$#" -eq 8 ]
      [ "$3" = --cwd ] && [ "$4" = "$tmp/repo with spaces" ]
      [ "$5" = --path ] && [ "$6" = "$target" ]
      [ "$7" = --label ] && [ "$8" = feat_foo ]
      touch "$tmp/opened"
      ;;
    *) echo "unexpected herdr operation: $1 $2" >&2; return 1 ;;
  esac
}
cd "$tmp/repo with spaces"
cmd_hi feat/foo
[ -f "$tmp/opened" ]
[ "$(cat "$target/uncommitted")" = 'keep me' ]
# An already-open worktree retains the existing safety checks.
mock_workspace_id='"workspace-test"'
rm "$tmp/opened"
if (cmd_hi feat/foo) > "$tmp/output" 2>&1; then
  echo 'unexpected success for an open, dirty worktree' >&2; exit 1
fi
[ ! -f "$tmp/opened" ]
[ -f "$target/uncommitted" ]
echo 'hi reopen tests passed'
