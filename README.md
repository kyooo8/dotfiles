# dotfiles

[![macOS](https://github.com/kyooo8/dotfiles/actions/workflows/macOS.yml/badge.svg)](https://github.com/kyooo8/dotfiles/actions/workflows/macOS.yml)
[![Ubuntu](https://github.com/kyooo8/dotfiles/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/kyooo8/dotfiles/actions/workflows/ubuntu.yml)

macOSとUbuntu用の個人的な開発環境設定ファイル集です。

## インストール

このインストールスクリプトを実行：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yadm-dev/yadm/master/yadm)" -- clone https://github.com/kyooo8/dotfiles.git --bootstrap
```

macOS / Ubuntu の両方で zsh へのシェル切り替えまで自動化されます。`chsh` がパスワード入力を求めることがあるため、完了後はログアウト／ログイン（またはターミナルを再起動）して新しい zsh が有効になっているか確認してください。

## スクリプトが終了したら以下を実行

- Gitのユーザー情報を設定（`.gitconfig.local`はyadm管理外なので個別に作成する）

    ```bash
    git config --file ~/.gitconfig.local user.name "[your name]"
    git config --file ~/.gitconfig.local user.email "[your@email.com]"
    ```

- vendorリポジトリを`~/dev/vendor/`にclone（`.gitconfig`と`.zshrc`が参照している）

    ```bash
    mkdir -p ~/dev/vendor
    git clone git@github.com:junegunn/fzf-git.sh.git ~/dev/vendor/fzf-git.sh
    git clone git@github.com:catppuccin/delta.git ~/dev/vendor/catppuccin-delta
    ```

- mise管理のツールをインストール
    ```bash
    mise install
    ```

## windowsの場合以下の対応を追加で行ってください

- JetBrainsMono Nerd Fontのインストール
    - https://www.nerdfonts.com/font-downloads
- Cica fontのインストール
    - https://github.com/miiton/Cica
- AutoHotKey v2のインストール
    - https://www.autohotkey.com/v2/
    - 設定の反映（`Documents/AutoHotKey`フォルダが無いとcpが失敗するので事前に作成しておく）
        ```bash
        cp ~/.config/windows/autohotkey/* /mnt/c/Users/[username]/Documents/AutoHotKey
        ```
    - ```

      ```
- Weztermのインストール
    - https://wezterm.org/index.html
    - 設定の反映
        ```bash
        cp ~/.wezterm.lua /mnt/c/Users/[username]/

        ```
- win32yankインストール（クリップボード共有）
    - インストール
        ```bash
        mkdir -p ~/.local/bin
        curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
        unzip -o /tmp/win32yank.zip win32yank.exe -d ~/.local/bin
        chmod +x ~/.local/bin/win32yank.exe
        rm /tmp/win32yank.zip
        ```

## 対応プラットフォーム

- macOS
- Ubuntu

GitHub Actionsにより両プラットフォームで自動テストを実行しています。
