# dotfiles

Personal shell configuration for Zsh on Linux/WSL.

## What's included

| File | Purpose |
|------|---------|
| `.zshrc` | Zsh config — oh-my-zsh, oh-my-posh, zoxide, fzf, history |
| `oh-my-posh/config.json` | Prompt theme — path, git status, execution time, memory, Node, .NET, Docker, kubectl |
| `install.sh` | Bootstrap script — installs dependencies and symlinks dotfiles |

## Prerequisites

- Debian/Ubuntu-based Linux or WSL
- `curl`, `git` (the install script will install these if missing)
- A [Nerd Font](https://www.nerdfonts.com/) set in your terminal for prompt icons

## Quick start

```bash
git clone https://github.com/jroque/dotfiles ~/dotfiles
cd ~/dotfiles
bash install.sh
```

Then restart your shell or run `source ~/.zshrc`.

## What `install.sh` does

1. Installs `fzf`, `zsh`, `curl`, `git` via apt
2. Installs [oh-my-zsh](https://ohmyz.sh/) (if not already present)
3. Installs [oh-my-posh](https://ohmyposh.dev/) to `~/.local/bin`
4. Installs [zoxide](https://github.com/ajeetdsouza/zoxide) (smart `cd`)
5. Backs up any existing `~/.zshrc` to `~/.zshrc.bak` and symlinks this repo's `.zshrc`

## Shell features

- **oh-my-posh** prompt with git status, execution time, memory usage, and context segments for Node, .NET, Docker, and kubectl
- **zoxide** — jump to frequently visited directories with `z <name>`
- **fzf** — fuzzy history search with `Ctrl+R`
- **Arrow key history search** — prefix-aware up/down navigation through history
- **Tab completion menu** — interactive selection via `zstyle`
- **oh-my-zsh plugins** — `git`, `docker`, `dotnet`
- Shared history across sessions, 10,000 entries, deduplication enabled
