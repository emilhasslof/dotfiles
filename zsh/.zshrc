# ~/.zshrc - portable config (managed in ~/dotfiles, stow package: zsh)
[[ -o interactive ]] || return

export PATH="$HOME/.local/bin:$PATH"
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# History shared between interactive shells.
setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE="$HOME/.zsh_history"

bindkey -e

# Completion
autoload -Uz compinit
compinit

zstyle ':completion:*' special-dirs true
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
if command -v dircolors &>/dev/null; then
  eval "$(dircolors -b)"
fi
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Aliases
command -v eza &>/dev/null && alias ls='eza -al'
command -v bat &>/dev/null && alias cat='bat'
command -v nvim &>/dev/null && alias vim='nvim'

# Let yazi change the shell's working directory when it exits.
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

# Tool initialization
if [[ ${TERM:-} != dumb ]] && command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if command -v fzf &>/dev/null; then
  for _fzf_dir in /usr/share/fzf /usr/share/doc/fzf/examples \
                  /opt/homebrew/opt/fzf/shell /usr/local/opt/fzf/shell; do
    if [[ -f "$_fzf_dir/key-bindings.zsh" ]]; then
      source "$_fzf_dir/key-bindings.zsh"
      break
    fi
  done
  unset _fzf_dir
fi

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Optional local, untracked overrides for this machine only.
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
