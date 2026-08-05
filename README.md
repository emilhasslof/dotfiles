# dotfiles

Portable terminal/CLI environment, self-contained and OS-agnostic
(Arch/Omarchy, Ubuntu, and macOS). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's here

Each top-level folder is a **Stow package** whose inner tree mirrors `$HOME`:

| Package    | Links to                          | Contents |
|------------|-----------------------------------|----------|
| `bash`     | `~/.bashrc`                        | self-contained shell config (no Omarchy dependency) |
| `tmux`     | `~/.config/tmux/tmux.conf`         | prefix `C-j`, vi copy, portable clipboard |
| `starship` | `~/.config/starship.toml`          | prompt |
| `ghostty`  | `~/.config/ghostty/config`         | terminal (GruvboxDark base theme) |
| `git`      | `~/.config/git/{config,ignore}`    | aliases + identity (override email locally) |
| `bin`      | `~/.local/bin/{pbcopy,pbpaste}`    | clipboard shims (wl-copy/xclip/native) |
| `nvim`     | `~/.config/nvim/`                  | LazyVim config |
| `lazygit`  | `~/.config/lazygit/config.yml`     | tab keybindings (`h`/`l`) |
| `btop`     | `~/.config/btop/btop.conf`         | system monitor (nord theme) |

## Install on a new machine

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh          # installs tools (pacman / apt / brew) then stows everything
exec bash               # reload the shell
```

## How Stow works (quick reference)

Stow recreates a package's inner tree as **symlinks** under `$HOME`:

```bash
cd ~/dotfiles
stow tmux            # link this package
stow -D tmux         # unlink (remove its symlinks)
stow -R tmux         # restow (fix links after adding/removing files)
stow --adopt tmux    # pull an existing real file into the repo, then link
```

Add a new config by placing the file at its `$HOME`-relative path inside a
package (e.g. `btop/.config/btop/btop.conf`), then `stow btop`.

## Per-machine differences

- **Git email at work:** create `~/.config/git/config.local` (git-ignored):
  ```ini
  [user]
      email = you@company.com
  ```
- **Machine-only shell tweaks:** create `~/.bashrc.local` (git-ignored); it's
  sourced automatically at the end of `.bashrc`.

## Notes / caveats

- **Ghostty** has no official apt package; on Ubuntu use a community build or
  fall back to kitty. Everything else installs cleanly on both distros.
- On Ubuntu, `bat`→`batcat` and `fd`→`fdfind`; `bootstrap.sh` adds `~/.local/bin`
  shims so the normal names work. (brew keeps the normal names, so macOS is unaffected.)
- **macOS** needs a modern bash (`brew install bash`); the config uses bash 4+ features.
  Clipboard uses the native `pbcopy`/`pbpaste` (the shims `exec` them on Darwin), and
  the Linux-only `open()`/completion/fzf paths are OS-guarded so nothing clobbers native
  tools. Ghostty installs via `brew install --cask ghostty`.
