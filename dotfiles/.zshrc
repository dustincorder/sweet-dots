# Niri colors, fast startup, and a compact Oh My Zsh prompt.
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="niri-minimal"
export ZSH_CUSTOM="$ZSH/custom"
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="$EDITOR"
export LANG="${LANG:-en_US.UTF-8}"
export LESS="-FRX"

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history inc_append_history share_history hist_ignore_dups autocd

plugins=(git colored-man-pages command-not-found)
source "$ZSH/oh-my-zsh.sh"

alias ll='ls -lah --color=auto'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias zconf='${EDITOR:-nvim} ~/.zshrc'
alias nconf='${EDITOR:-nvim} ~/.config/niri/config.kdl'

if [[ -o interactive ]] && command -v fastfetch >/dev/null 2>&1; then
  fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
fi
