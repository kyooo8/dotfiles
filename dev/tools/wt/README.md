# wt

git worktreeを `~/dev/.worktrees/` 配下にまとめて、一覧・移動・削除を簡単にするための薄いラッパー。herdr前提。

## 背景

worktreeをブランチごとに作って消すのは、ディレクトリが増え続けて片付けが手間になる。
固定名のスロットを使い回す方式も試したが、名前自体に意味はなく、数を制限する理由もなかった。
今はディレクトリ名を `<リポジトリ名>/<ブランチ名>`（ブランチ名の`/`は`_`に変換）にし、代わりに一覧・インタラクティブな切り替え・安全な削除で管理の手間を減らす。

## 使い方

bash / zsh の設定ファイル（`~/.bashrc` / `~/.zshrc`）で、`wt` の PATH 設定の後に追加する。

```sh
eval "$(wt shell-init)"
```

現在のシェルでもこの行を実行すれば有効になる。

```sh
# 対象リポジトリのディレクトリで実行する
wt hi feature/foo            # ~/dev/.worktrees/<repo>/feature_foo にworktreeを作成/切り替え
wt feature/foo               # このリポジトリのworktreeに移動（ディレクトリ名かブランチ名で指定）
wt                            # 既存worktreeを一覧から選んで移動
wt bye feature/foo            # ディレクトリ名でもブランチ名でも指定できる
wt bye .                      # 今いるworktreeを削除する
wt list                       # 全worktreeの状態を一覧表示
wt --help
```

`wt <name>` はメインのチェックアウトやその配下、同じリポジトリのworktreeから使える。
対象が未作成、または別リポジトリのworktreeならエラーにし、移動しない。
worktreeは全リポジトリで共有する一つの場所（`~/dev/.worktrees/`）にまとめる。
引数なしの `wt` はリポジトリを問わず全worktreeから選べる（シェル連携が必要）。
シェル連携なしの場合は移動先のパスを出力する。

`wt bye .` はworktreeのルートやその配下から使える。メインのチェックアウトでは削除を拒否する。
通常の削除と同じ安全確認を行い、シェル連携が有効なら削除成功後にメインのチェックアウトへ移動する。

herdrの表示ラベルには変換後のブランチ名（例: `feature_foo`）を使う。
既存の旧形式のworktreeも一覧・移動・削除の対象になるが、自動移行はしない。
`wt bye` で名前が重複する場合は `wt bye <repo>/feature_foo` のように指定する。
`feature/foo` と `feature_foo` のように変換後の名前が衝突する場合、`wt hi` は既存の別ブランチを置き換えずエラーにする。

`wt hi` は次の順で動く。

1. `~/dev/.worktrees/<リポジトリ名>/<ブランチ名>` が既にあれば、未コミットの変更・未pushのコミットがないか確認する
   - どちらかあれば**削除を拒否して終了**する（取り返しのつかない削除を防ぐ）
   - upstream 未設定でも、HEAD がリモート追跡ブランチに含まれていれば削除できる（ローカルにある取得済みの情報で判定）
   - 何もなければ既存のworktreeを削除してから、指定ブランチで作り直す
2. 元リポジトリの `mise.toml` をコピーする（`.claude/settings.local.json` はworktreeでもメインチェックアウトのものを自動で見るのでコピー不要）

## 既知の制約

- herdr専用（`herdr worktree create/remove`を使う）。herdrがない環境は未対応
- 削除は `herdr worktree list` から開いている workspace ID を逆引きする。ID がない場合は `git worktree remove` を使う
