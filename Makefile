DOTFILES_DIR := $(HOME)/dotfiles
.DEFAULT_GOAL := all

# WHY: 新Macでは Homebrew 導入直後も親シェルの PATH に /opt/homebrew/bin が無く、
# 後続ターゲット（mise-install 等）が mise を見つけられずスキップされるため、make 全体で PATH に足す。
export PATH := /opt/homebrew/bin:/usr/local/bin:$(PATH)
BREWFILE := $(DOTFILES_DIR)/brew/Brewfile

# npm グローバルに導入するツール（mise install では再現されないため別途入れる）
NPM_GLOBALS := @anthropic-ai/claude-code @redocly/cli ccusage

# 反映させたい設定ファイルのリスト (ホームディレクトリのファイル名)
FILES := .zshrc .vimrc .gvimrc .gitconfig

# Starship 関連の変数
STARSHIP_CONFIG_SRC := $(DOTFILES_DIR)/starship/starship.toml
STARSHIP_CONFIG_DST := $(HOME)/.config/starship.toml

# Ghostty 関連の変数
GHOSTTY_CONFIG_SRC := $(DOTFILES_DIR)/ghostty/config
GHOSTTY_CONFIG_DST := $(HOME)/.config/ghostty/config

# cmux 関連の変数
CMUX_CONFIG_SRC := $(DOTFILES_DIR)/cmux/cmux.json
CMUX_CONFIG_DST := $(HOME)/.config/cmux/cmux.json

# mise 関連の変数
MISE_CONFIG_SRC := $(DOTFILES_DIR)/mise/config.toml
MISE_CONFIG_DST := $(HOME)/.config/mise/config.toml

# VS Code 関連の変数
VSCODE_EXTENSIONS_FILE := $(DOTFILES_DIR)/vscode/extensions.txt
VSCODE_KEYBINDINGS_DST := $(DOTFILES_DIR)/vscode/keybindings.json
VSCODE_SETTINGS_DST := $(DOTFILES_DIR)/vscode/settings.json

# local（機密・マシン固有）ファイルの雛形。コピー先はリポジトリ管理外。
ZSHRC_LOCAL_SRC := $(DOTFILES_DIR)/zsh/.zshrc.local.example
ZSHRC_LOCAL_DST := $(HOME)/.zshrc.local
GITCONFIG_LOCAL_SRC := $(DOTFILES_DIR)/git/.gitconfig-work.example
GITCONFIG_LOCAL_DST := $(HOME)/.gitconfig-work

OS := $(shell uname -s)
ifeq ($(OS),Darwin) # macOS
    VSCODE_KEYBINDINGS_LINK := $(HOME)/Library/Application Support/Code/User/keybindings.json
    VSCODE_SETTINGS_LINK := $(HOME)/Library/Application Support/Code/User/settings.json
else ifeq ($(OS),Linux)
    VSCODE_KEYBINDINGS_LINK := $(HOME)/.config/Code/User/keybindings.json
    VSCODE_SETTINGS_LINK := $(HOME)/.config/Code/User/settings.json
else # Windows (未検証)
    VSCODE_KEYBINDINGS_LINK := $(APPDATA)/Code/User/keybindings.json
    VSCODE_SETTINGS_LINK := $(APPDATA)/Code/User/settings.json
endif

# 各設定ファイルのリンク処理を個別に記述（FORCE: リンク先が実ファイルで新しくても mtime 判定でスキップさせない）
$(HOME)/.zshrc: $(DOTFILES_DIR)/zsh/.zshrc FORCE
	@test -e "$<" || { echo "エラー: $< が見つかりません。"; exit 1; }
	@if [ -e "$@" ] && [ ! -L "$@" ]; then b="$@.bak.$$(date +%Y%m%d%H%M%S)"; mv "$@" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$<" "$@"
	@echo "リンクしました: $@"

$(HOME)/.vimrc: $(DOTFILES_DIR)/vim/.vimrc FORCE
	@test -e "$<" || { echo "エラー: $< が見つかりません。"; exit 1; }
	@if [ -e "$@" ] && [ ! -L "$@" ]; then b="$@.bak.$$(date +%Y%m%d%H%M%S)"; mv "$@" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$<" "$@"
	@echo "リンクしました: $@"

$(HOME)/.gvimrc: $(DOTFILES_DIR)/vim/.gvimrc FORCE
	@test -e "$<" || { echo "エラー: $< が見つかりません。"; exit 1; }
	@if [ -e "$@" ] && [ ! -L "$@" ]; then b="$@.bak.$$(date +%Y%m%d%H%M%S)"; mv "$@" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$<" "$@"
	@echo "リンクしました: $@"

$(HOME)/.gitconfig: $(DOTFILES_DIR)/git/.gitconfig FORCE
	@test -e "$<" || { echo "エラー: $< が見つかりません。"; exit 1; }
	@if [ -e "$@" ] && [ ! -L "$@" ]; then b="$@.bak.$$(date +%Y%m%d%H%M%S)"; mv "$@" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$<" "$@"
	@echo "リンクしました: $@"

$(STARSHIP_CONFIG_DST): $(STARSHIP_CONFIG_SRC) FORCE
	@test -e "$<" || { echo "エラー: $< が見つかりません。"; exit 1; }
	@mkdir -p "$(shell dirname $@)"
	@if [ -e "$@" ] && [ ! -L "$@" ]; then b="$@.bak.$$(date +%Y%m%d%H%M%S)"; mv "$@" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$<" "$@"
	@echo "リンクしました: $@"

$(GHOSTTY_CONFIG_DST): $(GHOSTTY_CONFIG_SRC) FORCE
	@test -e "$<" || { echo "エラー: $< が見つかりません。"; exit 1; }
	@mkdir -p "$(shell dirname $@)"
	@if [ -e "$@" ] && [ ! -L "$@" ]; then b="$@.bak.$$(date +%Y%m%d%H%M%S)"; mv "$@" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$<" "$@"
	@echo "リンクしました: $@"

$(CMUX_CONFIG_DST): $(CMUX_CONFIG_SRC) FORCE
	@test -e "$<" || { echo "エラー: $< が見つかりません。"; exit 1; }
	@mkdir -p "$(shell dirname $@)"
	@if [ -e "$@" ] && [ ! -L "$@" ]; then b="$@.bak.$$(date +%Y%m%d%H%M%S)"; mv "$@" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$<" "$@"
	@echo "リンクしました: $@"

$(MISE_CONFIG_DST): $(MISE_CONFIG_SRC) FORCE
	@test -e "$<" || { echo "エラー: $< が見つかりません。"; exit 1; }
	@mkdir -p "$(shell dirname $@)"
	@if [ -e "$@" ] && [ ! -L "$@" ]; then b="$@.bak.$$(date +%Y%m%d%H%M%S)"; mv "$@" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$<" "$@"
	@echo "リンクしました: $@"

all: $(addprefix $(HOME)/, $(FILES)) $(STARSHIP_CONFIG_DST) $(GHOSTTY_CONFIG_DST) $(CMUX_CONFIG_DST) $(MISE_CONFIG_DST)
	@echo "dotfiles のリンクが完了しました。"

# Homebrew 本体が無ければインストール（新マシン向け）
install-homebrew:
	@command -v brew >/dev/null 2>&1 || \
	  { echo "Homebrew をインストールします..."; \
	    /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; }

# Brewfile からパッケージを導入。Homebrew を PATH に通してから bundle する。
install-brew: install-homebrew
	@echo "Brewfile からパッケージを導入します: $(BREWFILE)"
	@eval "$$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"; \
	  brew bundle --file=$(BREWFILE)

# mise 管理のランタイム（node/go/terraform 等）を導入。
# WHY: brew で mise を入れただけでは実体は入らず、config に基づく `mise install` が必要。
mise-install:
	@if command -v mise >/dev/null 2>&1; then echo "mise 管理のランタイムを導入します..."; mise install; \
	  else echo "mise が見つからないためランタイムの導入をスキップします。"; fi

# npm グローバル（claude など）を導入。
# WHY: mise install は node を入れるが npm グローバルは再現しないため、mise の node 上で別途入れる。
# mise use -g は symlink 越しに dotfiles の mise/config.toml を書き換えるため使わない（node は config.toml で宣言済み）。
npm-globals:
	@command -v mise >/dev/null 2>&1 || { echo "mise が見つからないため npm グローバルの導入をスキップします。"; exit 0; }
	@echo "npm グローバルパッケージを導入します: $(NPM_GLOBALS)"
	@mise exec node@lts -- npm install -g $(NPM_GLOBALS)

# 機密・マシン固有の local ファイルを雛形から作成（既存は上書きしない）
local-files:
	@test -f "$(ZSHRC_LOCAL_DST)" || \
	  { cp "$(ZSHRC_LOCAL_SRC)" "$(ZSHRC_LOCAL_DST)" && echo "作成しました: $(ZSHRC_LOCAL_DST)（要編集: 機密値を記入）"; }
	@test -f "$(GITCONFIG_LOCAL_DST)" || \
	  { cp "$(GITCONFIG_LOCAL_SRC)" "$(GITCONFIG_LOCAL_DST)" && echo "作成しました: $(GITCONFIG_LOCAL_DST)（要編集）"; }

# zsh の設定をリロード
reload_zsh:
	@echo "zsh 設定をリロードします..."
	@zsh -ic 'source ~/.zshrc'

# vim の設定をリロード
reload_vim:
	@echo "vim 設定をリロードします..."
	@vim -c "source ~/.vimrc" -c "echom 'Vim configuration reloaded.'" || echo "vim 設定のリロードに失敗しました。"

reload: reload_zsh reload_vim
	@echo "すべての設定をリロードしました。"

clean:
	@echo "シンボリックリンクを削除します..."
	@find $(HOME) -maxdepth 1 -type l \( -name ".zshrc" -o -name ".vimrc" -o -name ".gvimrc" -o -name ".gitconfig" \) -exec rm {} \;
	@for f in "$(STARSHIP_CONFIG_DST)" "$(GHOSTTY_CONFIG_DST)" "$(CMUX_CONFIG_DST)" "$(MISE_CONFIG_DST)"; do [ -L "$$f" ] && rm "$$f"; done; true
	@echo "削除しました。"

brew:
	@echo "Brewfile のパッケージを導入・更新します..."
	@brew bundle --file=$(BREWFILE)
	@brew cleanup

apply-vscode-extensions:
	@echo "VS Code 拡張を導入します: $(VSCODE_EXTENSIONS_FILE)"
	@command -v code >/dev/null 2>&1 || \
	{ echo "'code' コマンドが見つからないため拡張のインストールをスキップします（VS Code 起動後に Cmd+Shift+P > Install 'code' command でPATHを通すと適用可能）。"; exit 0; }
	@test -f $(VSCODE_EXTENSIONS_FILE) || \
	{ echo "$(VSCODE_EXTENSIONS_FILE) が存在しません。'make list-vscode-extensions' を実行して作成してください。"; exit 0; }
	@while IFS= read -r extension; do \
        echo "VS Code 拡張を導入: $$extension"; \
        code --install-extension "$$extension"; \
    done < $(VSCODE_EXTENSIONS_FILE)

apply-vscode-keybindings:
	@echo "VS Code の keybindings をリンクします: $(VSCODE_KEYBINDINGS_LINK)"
	@mkdir -p "$(shell dirname "$(VSCODE_KEYBINDINGS_LINK)")"
	@f="$(VSCODE_KEYBINDINGS_LINK)"; if [ -e "$$f" ] && [ ! -L "$$f" ]; then b="$$f.bak.$$(date +%Y%m%d%H%M%S)"; mv "$$f" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$(VSCODE_KEYBINDINGS_DST)" "$(VSCODE_KEYBINDINGS_LINK)"

apply-vscode-settings:
	@echo "VS Code の settings をリンクします: $(VSCODE_SETTINGS_LINK)"
	@mkdir -p "$(shell dirname "$(VSCODE_SETTINGS_LINK)")"
	@f="$(VSCODE_SETTINGS_LINK)"; if [ -e "$$f" ] && [ ! -L "$$f" ]; then b="$$f.bak.$$(date +%Y%m%d%H%M%S)"; mv "$$f" "$$b"; echo "既存ファイルを退避しました: $$b"; fi
	@ln -sfn "$(VSCODE_SETTINGS_DST)" "$(VSCODE_SETTINGS_LINK)"

apply-vscode: apply-vscode-extensions apply-vscode-keybindings apply-vscode-settings
	@echo "VS Code の設定と拡張を適用しました。"

list-vscode-extensions:
	@echo "導入済みの VS Code 拡張を書き出します: $(VSCODE_EXTENSIONS_FILE)"
	command -v code >/dev/null 2>&1 || \
	{ echo "Visual Studio Codeの 'code' コマンドが見つかりません。"; exit 1; }
	code --list-extensions > $(VSCODE_EXTENSIONS_FILE)

vscode: apply-vscode
	@echo "VS Code のセットアップが完了しました。"

# 新しいマシンでこれ一つを実行すれば一通り完了する
# WHY: all（mise/config.toml のリンク）を mise-install より先に置かないと、設定が無いまま mise install が走り pnpm/gcloud が入らない
install: install-brew all mise-install npm-globals local-files vscode
	@echo ""
	@echo "セットアップ完了！"
	@echo "  1. ~/.zshrc.local と ~/.gitconfig-work に実際の値を記入してください。"
	@for f in .gitconfig-dena .gitconfig-zerocolor; do [ -f "$(HOME)/$$f" ] || echo "  ※ ~/$$f が無いため、対応ディレクトリ配下のコミットは個人メールになります（README 参照）。"; done
	@echo "  2. シェルを開き直すか exec zsh で設定を反映してください。"

.NOTPARALLEL:

.PHONY: all FORCE install-homebrew install-brew mise-install npm-globals local-files reload_zsh reload_vim reload clean brew \
        apply-vscode-extensions apply-vscode-keybindings apply-vscode-settings apply-vscode list-vscode-extensions vscode install

FORCE:
