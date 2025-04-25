# Makefile

.DEFAULT_GOAL := setup

SHELL := /bin/bash

.PHONY: setup
setup: brew

.PHONY: brew
brew:
	@echo "Setting up Brew packages..."
	@which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" # Homebrew インストール
	@brew bundle --file="$(HOME)/dotfiles/Brewfile"


IGNORE_PATTERN="^\.(git|travis)"

.PHONY: deploy
deploy:
    @echo "Create dotfile links."
    @for dotfile in .??*; do \
        if [[ $$dotfile =~ $(IGNORE_PATTERN) ]]; then continue; fi; \
        ln -snfv "$$(pwd)/$$dotfile" "$$HOME/$$dotfile"; \
    done
    @echo "Success"
