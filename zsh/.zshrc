# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
# Q pre block. Keep at the top of this file.
eval "$(anyenv init -)"
alias -g dc='docker-compose'
alias -g la='ls -a'
alias -g ll='ls -l'

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

export PATH=${HOME}/go/bin:${PATH}

# 直前のコマンドの重複を削除
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# 同時に起動したzshの間でヒストリを共有
setopt share_history

# 補完機能を有効にする
autoload -Uz compinit
compinit -u
if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完候補を詰めて表示
setopt list_packed

# 補完候補一覧をカラー表示
autoload colors
zstyle ':completion:*' list-colors ''

# コマンドのスペルを訂正
setopt correct
# ビープ音を鳴らさない
setopt no_beep

# ディレクトリスタック
DIRSTACKSIZE=100
setopt AUTO_PUSHD

# git
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{magenta}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{yellow}+"
zstyle ':vcs_info:*' formats "%F{cyan}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }

alias g='git'
alias gs='git status'
alias gb='git branch'
alias gc='git checkout'
alias gct='git commit'
alias gg='git grep'
alias ga='git add'
alias gd='git diff'
alias glog='git log --graph --all --format="%x09%C(cyan bold)%an%Creset%x09%C(yellow)%h%Creset %C(magenta reverse)%d%Creset %s"'
alias gcom='git checkout main'
alias gcd='git checkout develop'
alias gfu='git fetch upstream'
alias gfo='git fetch origin'
alias gmod='git merge origin/develop'
alias gmud='git merge upstream/develop'
alias gmom='git merge origin/master'
alias gcm='git commit -m'
alias gac="git add . && git commit -m" # + commit message
alias gpo='git push origin'
alias gpom='git push origin master'
alias gst='git stash'
alias gsl='git stash list'
alias gsap='git stash apply'
alias gca='git commit --amend --no-edit'
alias gpo='git push --set-upstream origin "$(git branch --show-current)"'

# プロンプトカスタマイズ
PROMPT='
[%B%F{red}%n@%m%f%b:%F{green}%~%f]%F{cyan}$vcs_info_msg_0_%f
%F{yellow}$%f '


# # vscode code コマンド適用
# function code {
#     if [[ $# = 0 ]]
#     then
#         open -a "Visual Studio Code"
#     else
#         local argPath="$1"
#         [[ $1 = /* ]] && argPath="$1" || argPath="$PWD/${1#./}"
#         open -a "Visual Studio Code" "$argPath"
#     fi
# }

eval "$(starship init zsh)"


# bun completions
[ -s "/Users/watanabesota/.bun/_bun" ] && source "/Users/watanabesota/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"



[[ -f "$HOME/fig-export/dotfiles/dotfile.zsh" ]] && builtin source "$HOME/fig-export/dotfiles/dotfile.zsh"

# Q post block. Keep at the bottom of this file.
export PATH=$PATH:/Users/sota.watanabe/Library/Python/3.12/bin


delete_by_extension() {
    if [[ -z "$1" ]]; then
        echo "使い方: delete_by_extension <拡張子>"
        echo "例: delete_by_extension txt"
        return 1
    fi

    local ext="$1"
    local files=(*."$ext")

    if [[ -z "${files[@]}" || "${files[@]}" == "*.$ext" ]]; then
        echo "拡張子 .$ext のファイルは見つかりませんでした。"
        return 0
    fi

    echo "以下のファイルが削除されます:"
    for file in "${files[@]}"; do
        echo "$file"
    done

    echo "これらのファイルを削除してもよろしいですか？ (y/n)"
    read -r confirmation
    if [[ "$confirmation" == "y" ]]; then
        rm -- "${files[@]}"
        echo "拡張子 .$ext のファイルを削除しました。"
    else
        echo "削除をキャンセルしました。"
    fi
}

alias del-ext=delete_by_extension

eval "$(~/.local/bin/mise activate zsh)"
export JQ_COLORS='1;34:1;31:1;32:0;35:0;36:1;33:1;33'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sota.watanabe/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sota.watanabe/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sota.watanabe/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sota.watanabe/google-cloud-sdk/completion.zsh.inc'; fi

# ローカル設定（機密情報など）
[ -f ~/.zshrc.local ] && source ~/.zshrc.local


alias yolo="claude --dangerously-skip-permissions"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
