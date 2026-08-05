# ~/.bashrc — portable, self-contained (managed in ~/dotfiles, stow package: bash)
# No dependency on Omarchy internals. Every tool is guarded so a missing
# binary degrades gracefully instead of erroring.

# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export EDITOR=nvim            # Omarchy set this in a Wayland session file; we own it here.
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"   # colorized man pages via bat
export PATH="$HOME/.local/bin:$PATH"

# Homebrew on Apple Silicon: put brew tools on PATH for non-login shells (tmux panes, etc.)
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

set +h   # disable command hashing (recommended for mise)

# ---------------------------------------------------------------------------
# Bash completion
# ---------------------------------------------------------------------------
# Path differs by OS: Linux = /usr/share, macOS/brew = $(brew --prefix)/etc/profile.d
for _bc in /usr/share/bash-completion/bash_completion \
           /opt/homebrew/etc/profile.d/bash_completion.sh \
           /usr/local/etc/profile.d/bash_completion.sh; do
  if [[ ! -v BASH_COMPLETION_VERSINFO && -f "$_bc" ]]; then
    source "$_bc"; break
  fi
done; unset _bc

# ---------------------------------------------------------------------------
# Aliases (curated from Omarchy defaults + personal)
# ---------------------------------------------------------------------------
# Listing (eza)
if command -v eza &>/dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

# bat as cat
command -v bat &>/dev/null && alias cat='bat'

# fzf finder with preview
if command -v fzf &>/dev/null; then
  alias ff="fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"
  alias eff='$EDITOR "$(ff)"'
fi

# Directory hops
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Editors
alias vim='nvim'
n() { if [ "$#" -eq 0 ]; then command nvim .; else command nvim "$@"; fi; }

# Git
alias g='git'
alias gs='git status'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# tmux
alias t='tmux attach || tmux new -s Work'

# open (detached xdg-open) — Linux only; never shadow macOS's native `open`
if command -v xdg-open &>/dev/null; then
  open() ( xdg-open "$@" >/dev/null 2>&1 & )
fi

# ---------------------------------------------------------------------------
# Tool initialisation
# ---------------------------------------------------------------------------
# zoxide — smart cd; `cd` falls back to plain cd for real paths, else jumps.
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
  zd() {
    if   (( $# == 0 ));   then builtin cd ~ || return
    elif [[ -d $1 ]];     then builtin cd "$1" || return
    else z "$@" || { echo "Error: directory not found" >&2; return 1; }
    fi
  }
  alias cd='zd'
fi

# mise — runtime version manager
command -v mise &>/dev/null && eval "$(mise activate bash)"

# starship prompt
if [[ ${TERM:-} != dumb ]] && command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi

# fzf keybindings/completion — path differs per platform:
#   Arch = /usr/share/fzf | Debian/Ubuntu = /usr/share/doc/fzf/examples | brew = $(brew --prefix)/opt/fzf/shell
if command -v fzf &>/dev/null; then
  for d in /usr/share/fzf /usr/share/doc/fzf/examples \
           /opt/homebrew/opt/fzf/shell /usr/local/opt/fzf/shell; do
    [[ -f "$d/key-bindings.bash" ]] && source "$d/key-bindings.bash"
    [[ -f "$d/completion.bash"   ]] && source "$d/completion.bash"
  done
fi

# ---------------------------------------------------------------------------
# Auto-attach to tmux (set DOTFILES_NO_TMUX=1 to skip, e.g. when testing)
# ---------------------------------------------------------------------------
if [[ -z "${DOTFILES_NO_TMUX:-}" ]] && command -v tmux >/dev/null && [ -z "${TMUX:-}" ]; then
  if [ "$(tmux ls 2>/dev/null | wc -l)" -eq 0 ]; then
    tmux new
  else
    tmux ls -F '#{?session_attached,yes,no}' 2>/dev/null | grep -q yes || \
      tmux attach -t "$(tmux ls -F '#{session_name}' | head -n1)"
  fi
fi

# ---------------------------------------------------------------------------
# Personal / machine-specific extras — uncomment per machine as needed
# ---------------------------------------------------------------------------
# alias d='docker'
# alias c='opencode'
# alias eq='flatpak run com.github.wwmm.easyeffects'

# Optional local, untracked overrides for this machine only:
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
