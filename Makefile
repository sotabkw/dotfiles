DOTFILES_DIR := $(HOME)/.dotfiles
BACKUP_DIR := $(HOME)/.dotfiles_backup_$(shell date +%Y%m%d%H%M%S)

# Homebrew のインストールと Brewfile の適用
brew:
	@echo "Homebrew がインストールされているか確認します..."
	@if ! command -v brew >/dev/null 2>&1; then
		@echo "Homebrew がインストールされていません。インストールを開始します..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	else
		@echo "Homebrew は既にインストールされています。"
	fi
	@echo "Brewfile を適用します..."
	@brew bundle --file="$(DOTFILES_DIR)/Brewfile"
	@echo "Brewfile の適用が完了しました。"

# バックアップ処理
backup:
	@echo "既存のDotfileをバックアップします..."
	@mkdir -p "$(BACKUP_DIR)"
	@find $(HOME) -maxdepth 1 -name ".*" -not -name ".git" -not -name "." -not -name ".." -exec mv {} "$(BACKUP_DIR)" \;
	@echo "バックアップ完了: $(BACKUP_DIR)"

# git の設定
git:
	@echo "Gitの設定を適用します..."
	@mkdir -p "$(HOME)/git"
	@ln -sf "$(DOTFILES_DIR)/git/.gitconfig" "$(HOME)/.gitconfig"
	@echo "Gitの設定完了"

# zsh の設定
zsh:
	@echo "Zshの設定を適用します..."
	@ln -sf "$(DOTFILES_DIR)/zsh/.zshrc" "$(HOME)/.zshrc"
	@echo "Zshの設定完了"

# VSCode の設定
vscode:
	@echo "VSCodeの設定を適用します..."
	@mkdir -p "$(HOME)/Library/Application Support/Code/User"
	@ln -sf "$(DOTFILES_DIR)/vscode/settings.json" "$(HOME)/Library/Application Support/Code/User/settings.json"
	@echo "VSCodeの設定完了"

# iTerm2 の設定
iterm2:
	@echo "iTerm2の設定を適用します..."
	@ln -sf "$(DOTFILES_DIR)/iterm2/com.googlecode.iterm2.plist" "$(HOME)/Library/Preferences/com.googlecode.iterm2.plist"
	@echo "iTerm2の設定完了"

# Vim の設定
vim:
	@echo "Vimの設定を適用します..."
	@ln -sf "$(DOTFILES_DIR)/vim/.vimrc" "$(HOME)/.vimrc"
	@ln -sf "$(DOTFILES_DIR)/vim/.gvimrc" "$(HOME)/.gvimrc"
	@mkdir -p "$(HOME)/.vim"
	@echo "Vimの設定完了"

# Starship の設定
starship:
	@echo "Starshipの設定を適用します..."
	@ln -sf "$(DOTFILES_DIR)/starship/starship.toml" "$(HOME)/.config/starship.toml"
	@echo "Starshipの設定完了"

# 一括適用 (brew を先頭に追加)
all: backup brew git zsh vscode iterm2 vim starship
	@echo "すべての設定が適用されました！"

# クリーンアップ (Brewfile 関連の処理は通常不要)
clean:
	@echo "シンボリックリンクを削除します..."
	@find $(HOME) -maxdepth 1 -name ".gitconfig" -delete
	@find $(HOME) -maxdepth 1 -name ".zshrc" -delete
	@find $(HOME)/Library/Application\ Support/Code/User -name "settings.json" -delete
	@find $(HOME)/Library/Preferences -name "com.googlecode.iterm2.plist" -delete
	@find $(HOME) -maxdepth 1 -name ".vimrc" -delete
	@find $(HOME) -maxdepth 1 -name ".gvimrc" -delete
	@find $(HOME)/.config -name "starship.toml" -delete
	@echo "クリーンアップ完了"