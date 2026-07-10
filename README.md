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
| `bash` / `zsh` | Shell config, aliases, functions, history, completion         |
| `fzf-git`   | Shared fzf-powered git browser, used by both shells              |
| `kitty`     | Terminal emulator config (Rosé Pine theme + Monaspace Nerd Font) |
| `ohmyposh`  | Prompt theme                                                     |
| `fastfetch` | System-info banner with a custom ASCII logo                      |

## Structure

```
dotfiles/
├── bootstrap/install.sh     # entry point, run via curl
├── ansible/                 # playbook + role that installs packages and runs stow
└── dotfiles/                # stow packages
    ├── git/
    ├── editorconfig/
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

## Notes

- First run will take a while. It bootstraps `rustup`, then compiles nine Rust tools from
  source via `cargo install`, plus builds `bat-extras` from its own build script and downloads
  a handful of binary releases (`gh`, `yazi`, `zellij`, `onefetch`, `lazygit`). Subsequent runs
  are fast as every install task checks for the binary first and skips if it's already there.
- `EDITOR` is set to `micro`, falling back to `nano` if it's somehow missing, rather than a GUI
  editor, so tools like `git commit` and `crontab -e` don't hang waiting on a window that isn't
  there over SSH. Neither vim nor Neovim are used anywhere in this repo with my own separate IDE that handles
  all actual code editing; `micro`/`nano` cover quick terminal edits only. (Not a neovim user yet though lol)
- The `z` alias for `cd` (via `zoxide`) only activates if `zoxide` is actually installed.
- Background job count in the prompt comes from a small shell hook (`BG_JOBS`), not a native
  oh-my-posh segment where it runs as a separate process per prompt render and has no direct
  view into the shell's job table.
