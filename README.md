# dotfiles

My personal Linux configuration, automated end-to-end with **Ansible** and **GNU Stow**.
Do note that its heavily opinionated and a work in progress still.

Supports **Debian/Ubuntu**, **Arch**, and **Fedora**.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/doubleddoge/dotfiles/main/bootstrap/install.sh | bash
```

## What's included

| Package     | What it configures                                               |
|-------------|------------------------------------------------------------------|
| `git`       | `.gitconfig`, global gitignore, commit message template          |
| `editorconfig` | Universal indent/whitespace rules for any editor              |
| `shell-common` | Env vars, aliases, and functions shared by bash and zsh, plus login-shell env setup |
| `bash` / `zsh` | Shell-specific config: history, completion, keybindings, plugin managers |
| `fzf-git`   | Shared fzf-powered git browser, used by both shells              |
| `kitty`     | Terminal emulator config (Rosé Pine theme + Monaspace Nerd Font) |
| `ohmyposh`  | Prompt theme                                                     |
| `fastfetch` | System-info banner with a custom ASCII logo                      |

## Structure

```
dotfiles/
├── bootstrap/install.sh
├── ansible/
│   └── roles/linux/
│       ├── tasks/
│       │
│       └── vars/
└── dotfiles/
    ├── git/
    ├── editorconfig/
    ├── shell-common/
    │
    ├── bash/
    ├── zsh/
    ├── kitty/
    ├── fzf-git/
    ├── ohmyposh/
    └── fastfetch/
```

## Manual re-stow

If you edit a config and want to re-link without rerunning all of Ansible:

```bash
cd ~/dotfiles/dotfiles
stow -v -R -t "$HOME" --no-folding <package>
```
