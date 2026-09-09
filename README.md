# dotfiles

My personal Linux configuration, automated end-to-end with **shellscripts** and **chezmoi**.
Do note that its heavily opinionated and a work in progress still.

Supports **Debian/Ubuntu**, **Arch**, and **Fedora**.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/doubleddoge/dotfiles/main/install.sh | bash
```

## What's included

| Package     | What it configures                                               |
|-------------|--------------------------------------------------------------------|
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
├── bootstrap-install.sh
└── chezmoi-source/
    ├── .chezmoidata/packages.yaml       # package lists + tool URLs, per distro
    ├── .chezmoitemplates/               # shared partials (OS detection, etc.)
    ├── .chezmoiscripts/                 # provisioning, run once per machine
    ├── dot_config/
    │   ├── git/, kitty/, ohmyposh/, fastfetch/, fzf-git/, zsh/, shell/
    └── dot_bashrc, dot_profile, dot_gitconfig, ...
```

## Manual re-apply

If you edit a config and want to re-sync without rerunning provisioning:

```bash
chezmoi apply
```

To preview what would change first:

```bash
chezmoi diff
```

Provisioning steps only rerun when the corresponding script's content
changes (chezmoi's `run_once_` semantics) so editing a dotfile alone never
retriggers package installs.
