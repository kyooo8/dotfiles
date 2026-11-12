#!/usr/bin/env bash
set -euo pipefail
source <(sed '/^case "${1:-}" in/,$d' "$(dirname "$0")/../bin/wt")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
AGENTS_DIR="$tmp/worktrees"
mkdir -p "$tmp/repo" "$AGENTS_DIR"
git init -q "$tmp/repo"
git -C "$tmp/repo" -c user.name=Test -c user.email=test@example.com commit -qm initial --allow-empty
herdr() {
  [ "$1 $2" = 'worktree create' ]
  shift 2
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --branch) branch="$2" ;;
      --cwd) repo="$2" ;;
      --path) target="$2" ;;
      --label) label="$2" ;;
    esac
    shift 2
  done
  [ "$label" = feat_foo ]
  git -C "$repo" worktree add -qb "$branch" "$target"
}
cd "$tmp/repo"
cmd_hi feat/foo
[ -f "$AGENTS_DIR/repo/feat_foo/.git" ]
[ "$(cmd_path feat/foo)" = "$AGENTS_DIR/repo/feat_foo" ]
[ "$(cmd_path feat_foo)" = "$AGENTS_DIR/repo/feat_foo" ]
[ "$(resolve_agent_dir feat/foo)" = "$AGENTS_DIR/repo/feat_foo" ]
[ "$(resolve_agent_dir repo/feat_foo)" = "$AGENTS_DIR/repo/feat_foo" ]
(cd "$AGENTS_DIR/repo/feat_foo"; [ "$(cmd_path feat/foo)" = "$AGENTS_DIR/repo/feat_foo" ])
if (cmd_hi feat_foo) > /dev/null 2>&1; then
  echo 'accepted a colliding branch name' >&2; exit 1
fi
[ "$(git -C "$AGENTS_DIR/repo/feat_foo" branch --show-current)" = feat/foo ]
git -C "$tmp/repo" worktree add -qb legacy "$AGENTS_DIR/repo__legacy"
[ "$(cmd_path legacy)" = "$AGENTS_DIR/repo__legacy" ]
output=$(cmd_list)
[[ "$output" == *'feat_foo:'* ]]
[[ "$output" == *'repo__legacy:'* ]]
[[ "$output" != *'repo:'* ]]
mkdir -p "$tmp/other"
git init -q "$tmp/other"
git -C "$tmp/other" -c user.name=Test -c user.email=test@example.com commit -qm initial --allow-empty
mkdir -p "$AGENTS_DIR/other"
git -C "$tmp/other" worktree add -qb feat/foo "$AGENTS_DIR/other/feat_foo"
[ "$(cmd_path feat/foo)" = "$AGENTS_DIR/repo/feat_foo" ]
if (resolve_agent_dir feat/foo) > /dev/null 2>&1; then
  echo 'accepted ambiguous removal' >&2; exit 1
fi
if (cmd_path other/feat_foo) > /dev/null 2>&1; then
  echo 'accepted another repository' >&2; exit 1
fi
git -C "$tmp/repo" update-ref refs/remotes/origin/published HEAD
herdr() { printf '{"result":{"worktrees":[]}}\n'; }
cmd_bye repo/feat_foo
[ ! -d "$AGENTS_DIR/repo/feat_foo" ]
[ -d "$AGENTS_DIR/other/feat_foo" ]
echo 'layout tests passed' 
