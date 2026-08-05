#!/usr/bin/env bash
# bootstrap.sh — set up this machine from the dotfiles repo.
#   1. install the CLI toolset (works on Arch/pacman and Ubuntu/apt)
#   2. stow the config packages into $HOME
#
# Safe to re-run. Installs are idempotent; stow won't clobber non-symlinks.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(bash tmux starship ghostty git bin nvim)

# --- detect package manager -------------------------------------------------
if   command -v pacman  >/dev/null; then PM=pacman
elif command -v apt-get >/dev/null; then PM=apt
else echo "Unsupported system: need pacman or apt." >&2; exit 1
fi
echo "==> Package manager: $PM"

pac()   { sudo pacman -S --needed --noconfirm "$@"; }
aptin() { sudo apt-get install -y "$@"; }
have()  { command -v "$1" >/dev/null 2>&1; }

mkdir -p "$HOME/.local/bin"

# ---------------------------------------------------------------------------
# 1. Packages available in both distros' repos under (mostly) the same name
# ---------------------------------------------------------------------------
echo "==> Installing base packages"
if [ "$PM" = pacman ]; then
  pac git tmux ripgrep fzf bash-completion stow wl-clipboard xclip \
      eza zoxide bat fd starship lazygit fastfetch neovim ghostty
else
  sudo apt-get update
  aptin git tmux ripgrep fzf bash-completion stow wl-clipboard xclip \
        zoxide bat fd-find fastfetch neovim
  # --- Ubuntu binary-name fixups ------------------------------------------
  # bat installs as `batcat`, fd as `fdfind`; add friendly names on PATH.
  have batcat && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  have fdfind && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  # --- eza: in newer Ubuntu 'universe'; fall back to cargo if missing -----
  aptin eza 2>/dev/null || echo "!! eza not in apt; install via 'cargo install eza' or the eza apt repo."
  # --- starship: not in apt → official installer --------------------------
  have starship || curl -sS https://starship.rs/install.sh | sh -s -- -y
  # --- lazygit: not in apt → GitHub release binary ------------------------
  if ! have lazygit; then
    ver="$(curl -sL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
           | grep -Po '"tag_name": *"v\K[^"]*')"
    curl -sL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${ver}_Linux_x86_64.tar.gz" \
      | tar -xz -C "$HOME/.local/bin" lazygit
  fi
  # --- ghostty: no official apt package -----------------------------------
  have ghostty || cat <<'EOF'
!! Ghostty has no official apt package. Options on Ubuntu:
     - community .deb / build: https://ghostty.org/docs/install/binary
     - or keep using kitty (already configured) as a fallback.
   Skipping ghostty install; everything else continues.
EOF
fi

# --- mise: same installer everywhere ---------------------------------------
have mise || curl -sSf https://mise.run | sh

# --- clipboard shims are executable ----------------------------------------
chmod +x "$DOTFILES"/bin/.local/bin/pbcopy "$DOTFILES"/bin/.local/bin/pbpaste

# ---------------------------------------------------------------------------
# 2. Stow the config packages
# ---------------------------------------------------------------------------
echo "==> Stowing packages into \$HOME"
cd "$DOTFILES"
for pkg in "${PACKAGES[@]}"; do
  [ -d "$pkg" ] || continue
  if stow -v -t "$HOME" "$pkg"; then
    echo "   linked: $pkg"
  else
    echo "!! stow conflict on '$pkg' — a real file already exists at the target."
    echo "   Resolve by moving it aside, or re-run:  stow --adopt -t \$HOME $pkg"
  fi
done

echo
echo "==> Done. Open a new shell (or: exec bash) to load everything."
echo "    Set a work git email in ~/.config/git/config.local if needed."
