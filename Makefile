DOTFILES_DIR := $(HOME)/dotfiles
BREWFILE := $(DOTFILES_DIR)/brew/Brewfile

# 反映させたい設定ファイルのリスト (ホームディレクトリのファイル名)
FILES := .zshrc .vimrc .gvimrc .gitconfig

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

all: $(addprefix $(HOME)/, $(FILES))
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

install: install-brew all
	@echo "Dotfiles and Homebrew packages installation complete!"

.PHONY: all reload_zsh reload_vim reload clean install install-brew brew