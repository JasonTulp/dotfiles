# Fix terminal rendering for SSH sessions from Ghostty
if [[ "$SSH_CONNECTION" && "$TERM" == "xterm-ghostty" ]]; then
  export TERM="xterm-256color"
fi

# Set homebrew variables
if [[ "$(uname)" != "Linux" ]]; then
  export STARSHIP_CONFIG="$HOME/.config/starship-mac.toml"    
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  export STARSHIP_CONFIG="$HOME/.config/starship-linux.toml"    
fi

export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Add zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUPE=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias c='clear'
alias v='nvim'
alias x='exit'
alias crun='cargo run -- --dev --tmp --execution=native --pruning=archive -l=evm=debug'
alias yay='paru'

unalias gb 2>/dev/null
gb() {
  if [[ -z "$1" ]]; then
    echo "Usage: gb <branch-name>"
    return 1
  fi
  read "reply?Do you want to create a new branch called '$1'? [Y/n] "
  if [[ "$reply" =~ ^[Yy]$ || -z "$reply" ]]; then
    git fetch && git checkout main && git pull && git checkout -b "$1"
  else
    echo "Aborted."
  fi
}

# Open a tmux session called helical and start cloud, server and geno
# If the session already exists, stop services and restart them in place
hel() {
  local dir="/home/jason/github/hel/helical"
  if tmux has-session -t helical 2>/dev/null; then
    tmux send-keys -t helical:1.1 C-c Enter
    tmux send-keys -t helical:1.2 C-c Enter
    tmux send-keys -t helical:1.3 C-c Enter
    sleep 1
    tmux send-keys -t helical:1.1 "make cloud" Enter
    tmux send-keys -t helical:1.3 "make server" Enter
    tmux send-keys -t helical:1.2 "make geno" Enter
  else
    helical auth login -u http://localhost:3100
    tmux new-session -d -s helical -c "$dir"
    tmux send-keys -t helical "make cloud" Enter
    tmux split-window -v -t helical:1.1 -c "$dir"
    tmux send-keys -t helical "make server" Enter
    tmux split-window -h -t helical:1.1 -c "$dir"
    tmux send-keys -t helical "make geno" Enter
    tmux attach -t helical
  fi
}

# Shell Integrations
# Use FZF
# eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
