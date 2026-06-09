export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  fzf
  sudo
  extract
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
[[ -f "$HOME/.config/pda/startup-banner.sh" ]] && source "$HOME/.config/pda/startup-banner.sh"

export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"
export PATH="$HOME/.local/bin:$PATH"

alias ll="eza -la --icons --group-directories-first"
alias la="eza -a --icons --group-directories-first"
alias ls="eza --icons --group-directories-first"
alias cat="bat"
alias grep="rg"
#alias top="btop"
alias vim="nvim"
alias c="clear"
alias ..="cd .."
alias ...="cd ../.."
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"

setopt AUTO_CD
setopt CORRECT
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
