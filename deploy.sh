#!/bin/bash

dotfiles=(.zshrc .tmux.conf)

for file in "${dotfiles[@]}"; do
        ln -svf $file ~/
done
