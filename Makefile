DOTFILES_DIR := $(HOME)/dotfiles
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

# VS Code 関連の変数
VSCODE_EXTENSIONS_FILE := $(DOTFILES_DIR)/vscode/extensions.txt
VSCODE_KEYBINDINGS_DST := $(DOTFILES_DIR)/vscode/keybindings.json
VSCODE_SETTINGS_DST := $(DOTFILES_DIR)/vscode/settings.json

# local（機密・マシン固有）ファイルの雛形。コピー先はリポジトリ管理外。
ZSHRC_LOCAL_SRC := $(DOTFILES_DIR)/zsh/.zshrc.local.example
ZSHRC_LOCAL_DST := $(HOME)/.zshrc.local
GITCONFIG_LOCAL_SRC := $(DOTFILES_DIR)/git/.gitconfig-zerocolor.example
GITCONFIG_LOCAL_DST := $(HOME)/.gitconfig-zerocolor

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

# 各設定ファイルのリンク処理を個別に記述
$(HOME)/.zshrc: $(DOTFILES_DIR)/zsh/.zshrc
	@test -e "$<" || { echo "Error: $< not found."; exit 1; }
	@test -e "$@" || cp "$<" "$@"
	@rm -f "$@"
	@ln -sf "$<" "$@"
	@echo "Linked: $@"

$(HOME)/.vimrc: $(DOTFILES_DIR)/vim/.vimrc
	@test -e "$<" || { echo "Error: $< not found."; exit 1; }
	@test -e "$@" || cp "$<" "$@"
	@rm -f "$@"
	@ln -sf "$<" "$@"
	@echo "Linked: $@"

$(HOME)/.gvimrc: $(DOTFILES_DIR)/vim/.gvimrc
	@test -e "$<" || { echo "Error: $< not found."; exit 1; }
	@test -e "$@" || cp "$<" "$@"
	@rm -f "$@"
	@ln -sf "$<" "$@"
	@echo "Linked: $@"

$(HOME)/.gitconfig: $(DOTFILES_DIR)/git/.gitconfig
	@test -e "$<" || { echo "Error: $< not found."; exit 1; }
	@test -e "$@" || cp "$<" "$@"
	@rm -f "$@"
	@ln -sf "$<" "$@"
	@echo "Linked: $@"

$(STARSHIP_CONFIG_DST): $(STARSHIP_CONFIG_SRC)
	@test -e "$<" || { echo "Error: $< not found."; exit 1; }
	@mkdir -p "$(shell dirname $@)"
	@rm -f "$@"
	@ln -sf "$<" "$@"
	@echo "Linked: $@"

$(GHOSTTY_CONFIG_DST): $(GHOSTTY_CONFIG_SRC)
	@test -e "$<" || { echo "Error: $< not found."; exit 1; }
	@mkdir -p "$(shell dirname $@)"
	@rm -f "$@"
	@ln -sf "$<" "$@"
	@echo "Linked: $@"

all: $(addprefix $(HOME)/, $(FILES)) $(STARSHIP_CONFIG_DST) $(GHOSTTY_CONFIG_DST)
	@echo "Dotfiles are now linked."

# Homebrew 本体が無ければインストール（新マシン向け）
install-homebrew:
	@command -v brew >/dev/null 2>&1 || \
	  { echo "Installing Homebrew..."; \
	    /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; }

# Brewfile からパッケージを導入。Homebrew を PATH に通してから bundle する。
install-brew: install-homebrew
	@echo "Installing Homebrew packages from $(BREWFILE)..."
	@eval "$$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"; \
	  brew bundle --file=$(BREWFILE)

# mise 管理のランタイム（node/go/terraform 等）を導入。
# WHY: brew で mise を入れただけでは実体は入らず、config に基づく `mise install` が必要。
mise-install:
	@command -v mise >/dev/null 2>&1 && { echo "Installing mise-managed runtimes..."; mise install; } \
	  || echo "mise not found, skipping runtime install."

# npm グローバル（claude など）を導入。
# WHY: mise install は node を入れるが npm グローバルは再現しないため、mise の node 上で別途入れる。
npm-globals:
	@command -v mise >/dev/null 2>&1 || { echo "mise not found, skipping npm globals."; exit 0; }
	@echo "Installing npm global packages: $(NPM_GLOBALS)"
	@mise exec -- npm install -g $(NPM_GLOBALS)

# 機密・マシン固有の local ファイルを雛形から作成（既存は上書きしない）
local-files:
	@test -f "$(ZSHRC_LOCAL_DST)" || \
	  { cp "$(ZSHRC_LOCAL_SRC)" "$(ZSHRC_LOCAL_DST)"; echo "Created $(ZSHRC_LOCAL_DST) (要編集: 機密値を記入)"; }
	@test -f "$(GITCONFIG_LOCAL_DST)" || \
	  { cp "$(GITCONFIG_LOCAL_SRC)" "$(GITCONFIG_LOCAL_DST)"; echo "Created $(GITCONFIG_LOCAL_DST) (要編集)"; }

# zsh の設定をリロード
reload_zsh:
	@echo "Reloading zsh configuration..."
	@zsh -ic 'source ~/.zshrc'

# vim の設定をリロード
reload_vim:
	@echo "Reloading vim configuration..."
	@vim -c "source ~/.vimrc" -c "echom 'Vim configuration reloaded.'" || echo "Error reloading Vim configuration."

reload: reload_zsh reload_vim
	@echo "All configurations reloaded."

clean:
	@echo "Removing symbolic links..."
	@find $(HOME) -maxdepth 1 -type l \( -name ".zshrc" -o -name ".vimrc" -o -name ".gvimrc" -o -name ".gitconfig" \) -exec rm {} \;
	@rm -f "$(STARSHIP_CONFIG_DST)" "$(GHOSTTY_CONFIG_DST)"
	@echo "Cleaned."

brew:
	@echo "Installing/updating Homebrew packages from Brewfile..."
	@brew bundle --file=$(BREWFILE)
	@brew cleanup

apply-vscode-extensions:
	@echo "Applying VS Code extensions from $(VSCODE_EXTENSIONS_FILE)..."
	@command -v code >/dev/null 2>&1 || \
	{ echo "'code' コマンドが見つからないため拡張のインストールをスキップします（VS Code 起動後に Cmd+Shift+P > Install 'code' command でPATHを通すと適用可能）。"; exit 0; }
	@test -f $(VSCODE_EXTENSIONS_FILE) || \
	{ echo "$(VSCODE_EXTENSIONS_FILE) が存在しません。'make list-vscode-extensions' を実行して作成してください。"; exit 0; }
	@while IFS= read -r extension; do \
        echo "Applying VS Code extension: $$extension"; \
        code --install-extension "$$extension"; \
    done < $(VSCODE_EXTENSIONS_FILE)

apply-vscode-keybindings:
	@echo "Applying VS Code keybindings from $(VSCODE_KEYBINDINGS_DST) to $(VSCODE_KEYBINDINGS_LINK)..."
	mkdir -p "$(shell dirname "$(VSCODE_KEYBINDINGS_LINK)")"
	ln -sf "$(VSCODE_KEYBINDINGS_DST)" "$(VSCODE_KEYBINDINGS_LINK)"

apply-vscode-settings:
	@echo "Applying VS Code settings from $(VSCODE_SETTINGS_DST) to $(VSCODE_SETTINGS_LINK)..."
	mkdir -p "$(shell dirname "$(VSCODE_SETTINGS_LINK)")"
	ln -sf "$(VSCODE_SETTINGS_DST)" "$(VSCODE_SETTINGS_LINK)"

apply-vscode: apply-vscode-extensions apply-vscode-keybindings apply-vscode-settings
	@echo "VS Code settings and extensions applied."

list-vscode-extensions:
	@echo "Listing installed VS Code extensions to $(VSCODE_EXTENSIONS_FILE)..."
	command -v code >/dev/null 2>&1 || \
	{ echo "Visual Studio Codeの 'code' コマンドが見つかりません。"; exit 1; }
	code --list-extensions > $(VSCODE_EXTENSIONS_FILE)

vscode: apply-vscode
	@echo "VS Code setup complete."

# 新しいマシンでこれ一つを実行すれば一通り完了する
install: install-brew mise-install npm-globals all local-files vscode
	@echo ""
	@echo "セットアップ完了！"
	@echo "  1. ~/.zshrc.local と ~/.gitconfig-zerocolor に実際の値を記入してください。"
	@echo "  2. シェルを開き直すか 'make reload' で設定を反映してください。"

.PHONY: all install-homebrew install-brew mise-install npm-globals local-files reload_zsh reload_vim reload clean brew \
        apply-vscode-extensions apply-vscode-keybindings apply-vscode-settings apply-vscode list-vscode-extensions vscode install
