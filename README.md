# dotfiles

watanabe-sota の macOS dotfiles。

## セットアップ（新しいマシン）

```shell
# 1. clone
git clone git@github.com:sotabkw/dotfiles.git ~/dotfiles

# 2. Homebrew パッケージ + symlink + VS Code をまとめて適用
cd ~/dotfiles && make install

# 3. 機密情報・マシン固有の環境変数を手動作成（リポジトリ管理外）
cp ~/dotfiles/zsh/.zshrc.local.example ~/.zshrc.local           # JIRA / gcloud などの値を記入
cp ~/dotfiles/git/.gitconfig-zerocolor.example ~/.gitconfig-zerocolor   # 仕事用 git 設定
```

## 構成

| ディレクトリ | 内容 |
|---|---|
| `zsh/` | `.zshrc`（`.zshrc.local` で機密を分離） |
| `git/` | `.gitconfig`（`~/ZeroColor/` 配下は `.gitconfig-zerocolor` を include） |
| `vim/` | `.vimrc` / `.gvimrc` |
| `brew/` | `Brewfile`（バージョン管理は mise に一本化） |
| `ghostty/` | Ghostty 設定 |
| `starship/` | プロンプト設定 |
| `vscode/` | 拡張機能リスト・keybindings・settings |
| `config/iterm2/` | iTerm2 設定（バックアップ用。通常は Ghostty を使用） |

## make ターゲット

| コマンド | 内容 |
|---|---|
| `make install` | brew + symlink + vscode を一括適用 |
| `make all` | symlink のみ |
| `make brew` | Brewfile の適用 + cleanup |
| `make reload` | zsh / vim 設定をリロード |
| `make clean` | symlink を削除 |
