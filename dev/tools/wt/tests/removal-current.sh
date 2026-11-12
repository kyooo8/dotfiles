#!/usr/bin/env bash
set -euo pipefail
WT_BIN="$(cd "$(dirname "$0")/../bin" && pwd)/wt"
export PATH="$(dirname "$WT_BIN"):$PATH"
tmp=$(mktemp -d)
tmp=$(cd "$tmp" && pwd -P)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/main repo"
cat > "$tmp/bin/herdr" <<'MOCK'
#!/usr/bin/env bash
set -eu
[ "$1 $2" = 'worktree list' ]
printf '{"result":{"worktrees":[]}}\n'
MOCK
chmod +x "$tmp/bin/herdr"
export PATH="$tmp/bin:$PATH"
git init -q "$tmp/main repo"
git -C "$tmp/main repo" -c user.name=Test -c user.email=test@example.com commit -qm initial --allow-empty
git -C "$tmp/main repo" update-ref refs/remotes/origin/published HEAD
for shell in bash zsh; do
  git -C "$tmp/main repo" worktree add -qb "$shell" "$tmp/$shell tree"
  mkdir -p "$tmp/$shell tree/subdir"
  touch "$tmp/$shell tree/dirty"
  "$shell" -c '
    set -eu
    eval "$(wt shell-init)"
    cd "$1"
    if wt bye . >/dev/null 2>&1; then
      echo "main checkout was accepted" >&2; exit 1
    fi
    [ "$PWD" = "$1" ]
    cd "$2/subdir"
    if wt bye . >/dev/null 2>&1; then
      echo "dirty worktree was accepted" >&2; exit 1
    fi
    [ "$PWD" = "$2/subdir" ]
    rm "$2/dirty"
    wt bye .
    [ "$PWD" = "$1" ]
    [ ! -d "$2" ]
    cd "$3"
    if wt bye . >/dev/null 2>&1; then
      echo "non-repository was accepted" >&2; exit 1
    fi
    [ "$PWD" = "$3" ]
  ' test "$tmp/main repo" "$tmp/$shell tree" "$tmp"
done
echo 'current worktree removal tests passed (bash, zsh)'
