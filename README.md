# dotfiles

watanabe-sota の macOS dotfiles。

## セットアップ（新しいマシン）

```shell
# 0. git を用意する。まっさらな Mac は git が無い（Xcode CLT に含まれる）ため、まず CLT を入れる。
#    Homebrew を先に入れる場合はそのインストーラが CLT も入れるのでこの手順は不要。
xcode-select --install

# 1. clone（public リポジトリなので SSH 鍵が無くても HTTPS で取得できる）
git clone https://github.com/sotabkw/dotfiles.git ~/dotfiles

# 2. cmux を brew 管理外で導入済みの Mac のみ: brew bundle が既存 app と衝突しないよう先に取り込む
#    brew install --cask --adopt cmux

# 3. Homebrew パッケージ・symlink・mise ランタイム・npm グローバル・local 雛形・VS Code をまとめて適用
#    （Homebrew 未導入なら自動で入る。~/.zshrc.local と ~/.gitconfig-work は雛形から作成され、既存は上書きしない）
cd ~/dotfiles && make install
#    作成された ~/.zshrc.local（JIRA / gcloud など）と ~/.gitconfig-work に実際の値を記入する。
#    ~/DeNA/ 用 ~/.gitconfig-dena、~/ZeroColor/ 用 ~/.gitconfig-zerocolor は自動作成されないため、
#    必要なら ~/dotfiles/git/.gitconfig-work.example をコピーして [user] email を記入する。

# 4. 以後この dotfiles に push したくなったら GitHub 認証を通す（どちらか）。
#    - HTTPS: gh auth login（.gitconfig の credential helper が gh を使う。gh は Brewfile で導入済み）
#    - SSH:   ssh-keygen で鍵を作り GitHub に登録し、remote を git@github.com:sotabkw/dotfiles.git に変更
```

## 構成

| ディレクトリ | 内容 |
|---|---|
| `zsh/` | `.zshrc`（`.zshrc.local` で機密を分離）、雛形 `.zshrc.local.example` |
| `git/` | `.gitconfig`（`~/work/`・`~/DeNA/`・`~/ZeroColor/` 配下はそれぞれ `~/.gitconfig-work`・`-dena`・`-zerocolor` を include）、雛形 `.gitconfig-work.example` |
| `vim/` | `.vimrc` / `.gvimrc` |
| `brew/` | `Brewfile`（バージョン管理は mise に一本化） |
| `ghostty/` | Ghostty 設定 |
| `mise/` | mise のグローバル設定（`~/.config/mise/config.toml`） |
| `cmux/` | cmux 設定（`~/.config/cmux/cmux.json`、JSONC） |
| `starship/` | プロンプト設定 |
| `vscode/` | 拡張機能リスト・keybindings・settings |
| `config/iterm2/` | iTerm2 設定（バックアップ用。通常は Ghostty を使用） |

## make ターゲット

| コマンド | 内容 |
|---|---|
| `make install` | install-brew → all → mise-install → npm-globals → local-files → vscode を順に実行 |
| `make all`（`make` のみでも可） | 各設定の symlink を作成（既存の実ファイルは `.bak.<日時>` に退避） |
| `make brew` | Brewfile の適用 + cleanup |
| `make mise-install` | mise/config.toml のランタイムを導入 |
| `make npm-globals` | npm グローバル（claude / redocly / ccusage）を導入 |
| `make local-files` | `~/.zshrc.local`・`~/.gitconfig-work` を雛形から作成（既存は上書きしない） |
| `make vscode` | VS Code の拡張導入と settings / keybindings のリンク |
| `make list-vscode-extensions` | 導入済み拡張を `vscode/extensions.txt` に書き出す |
| `make reload` | zsh / vim 設定を読み込み確認（実行中のシェルには反映されないので `exec zsh` を使う） |
| `make clean` | dotfiles が張った symlink を削除（実ファイルと `.bak` は残す） |
