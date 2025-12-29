DOTFILES_DIR := $(HOME)/dotfiles
BREWFILE := $(DOTFILES_DIR)/brew/Brewfile

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
	@find $(HOME) -maxdepth 1 -type l -name ".zshrc" -o -name ".vimrc" -o -name ".gvimrc" -exec rm {} \;
	@echo "Cleaned."

brew:
	@echo "Installing/updating Homebrew packages from Brewfile..."
	@brew bundle --file=$(BREWFILE)
	@brew cleanup

install-brew:
	command -v brew >/dev/null 2>&1 || \
	( echo "Homebrew is not installed. Please install it from https://brew.sh/"; exit 1; )
	@echo "Installing Homebrew packages and casks from $(BREWFILE)..."
	@brew bundle --file=$(BREWFILE)

apply-vscode-extensions:
	@echo "Applying VS Code extensions from $(VSCODE_EXTENSIONS_FILE)..."
	command -v code >/dev/null 2>&1 || \
	{ echo "Visual Studio Codeの 'code' コマンドが見つかりません。"; exit 1; }
	test -f $(VSCODE_EXTENSIONS_FILE) || \
	{ echo "$(VSCODE_EXTENSIONS_FILE) が存在しません。'make list-vscode-extensions' を実行して作成してください。"; exit 1; }
	while IFS= read -r extension; do \
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

vscode: list-vscode-extensions apply-vscode
	@echo "VS Code setup complete."

install: install-brew all vscode
	@echo "Dotfiles and Homebrew packages installation complete!"

.PHONY: all reload_zsh reload_vim reload clean install install-brew brew
