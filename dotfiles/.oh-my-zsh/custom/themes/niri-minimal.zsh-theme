# Quiet two-line prompt for the dark Niri palette.
function niri_git_segment() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  local branch dirty
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) || branch=$(command git rev-parse --short HEAD 2>/dev/null) || return
  command git diff --quiet --ignore-submodules HEAD 2>/dev/null || dirty=' *'
  print -n "%F{245}   ${branch}${dirty}%f"
}

setopt prompt_subst
PROMPT='%F{cyan}%~%f%{$(niri_git_segment)%}\n%(?..%F{red}%?%f )%F{blue}❯%f '
RPROMPT='%F{245}%*%f'
