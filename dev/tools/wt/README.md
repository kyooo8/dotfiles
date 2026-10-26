# wt

git worktreeを「エージェント専用スロット」として使い回すための薄いラッパー。herdr前提。

## 背景

worktreeをブランチごとに作って消すのは、ディレクトリが増え続けて片付けが手間になる。
代わりに固定名のスロット（`jarvis` / `friday` / `edith`。MCUのAI名、役割の意味はない）を用意し、
使い終わったら同じスロットを次のブランチに使い回す。

## 使い方

```sh
# 対象リポジトリのディレクトリで実行する
wt open jarvis feature/foo   # ~/dev/agents/jarvis にworktreeを作成/切り替え
wt remove feature/foo        # エージェント名でもブランチ名でも指定できる
wt list                      # 各スロットの状態を一覧表示
wt --help
```

`wt open` は次の順で動く。

1. 名前が `jarvis` / `friday` / `edith` のいずれでもなければ、確認すら出さずエラーで終了する
2. `~/dev/agents/<name>` が既にあれば、未コミットの変更・未pushのコミットがないか確認する
   - どちらかあれば**削除を拒否して終了**する（取り返しのつかない削除を防ぐ）
   - 何もなければ既存のworktreeを削除してから、指定ブランチで作り直す
3. 元リポジトリの `mise.toml` をコピーする（`.claude/settings.local.json` はworktreeでもメインチェックアウトのものを自動で見るのでコピー不要）

## 名前を増やす

`bin/wt` 先頭の `VALID_AGENTS` を直接編集する。誤字で知らない名前のスロットが増えるのを防ぐため、リスト外の名前は確認すら出さずエラーにする。役割は持たせない想定。

## 既知の制約

- herdr専用（`herdr worktree create/remove`を使う）。herdrがない環境は未対応
- `herdr worktree remove` はパス指定ではなく `--workspace <ID>` が必要なため、`herdr worktree list` から逆引きしている
