# dotfiles

[![macOS](https://github.com/kyooo8/dotfiles/actions/workflows/macOS.yml/badge.svg)](https://github.com/kyooo8/dotfiles/actions/workflows/macOS.yml)
[![Ubuntu](https://github.com/kyooo8/dotfiles/actions/workflows/ubuntu.yml/badge.svg)](https://github.com/kyooo8/dotfiles/actions/workflows/ubuntu.yml)

macOSとUbuntu用の個人的な開発環境設定ファイル集です。

## 機能

- **シェル**: Zimフレームワークを使用したZsh設定
- **ターミナル**: WezTerm設定
- **エディタ**: Lazy.nvimを使用したNeovim設定
- **ターミナルマルチプレクサ**: tmux設定
- **パッケージ管理**: BrewfileによるHomebrew管理
- **プロンプト**: Starshipクロスシェルプロンプト

## インストール

このリポジトリをクローンしてインストールスクリプトを実行してください：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yadm-dev/yadm/master/yadm)" && \
yadm clone https://github.com/kyooo8/dotfiles.git --bootstrap
```

macOS / Ubuntu の両方で zsh へのシェル切り替えまで自動化されます。`chsh` がパスワード入力を求めることがあるため、完了後はログアウト／ログイン（またはターミナルを再起動）して新しい zsh が有効になっているか確認してください。

## 設定ファイル

- `.zshrc` - Zshシェル設定
- `.zimrc` - Zimフレームワーク設定
- `.tmux.conf` - tmux設定
- `.wezterm.lua` - WezTermターミナル設定
- `Brewfile` - Homebrewパッケージ定義
- `.config/nvim/` - Neovim設定
- `.config/starship.toml` - Starshipプロンプト設定

## 対応プラットフォーム

- macOS
- Ubuntu

GitHub Actionsにより両プラットフォームで自動テストを実行しています。
