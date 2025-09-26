# Dotfiles

Managed with [chezmoi](https://www.chezmoi.io/) so the same setup works on macOS and Linux hosts.

## Layout

- `dot_aerospace.toml` – writes to `~/.aerospace.toml`.
- `dot_tmux.conf` – writes to `~/.tmux.conf`.
- `dot_zshrc` – writes to `~/.zshrc`.
- `dot_zshenv` – writes to `~/.zshenv`.
- `dot_p10k.zsh` – writes to `~/.p10k.zsh`.
- `dot_config/btop/` – writes to `~/.config/btop/`.
- `dot_config/sketchybar/` – writes to `~/.config/sketchybar/`.
- `executable_dot_skhdrc` – writes to executable `~/.skhdrc`.
- `executable_dot_yabairc` – writes to executable `~/.yabairc`.
- `dot_config/lvim/` – writes to `~/.config/lvim/`.
- `dot_config/wezterm/` – writes to `~/.config/wezterm/`.
- `ubersicht/` – additional assets kept outside of chezmoi for now.

## Usage

```bash
# first-time setup on a new machine
brew install chezmoi                # or your package manager
chezmoi init --apply path/to/dotfiles

# day-to-day workflow
chezmoi edit ~/.aerospace.toml      # edit through chezmoi
chezmoi diff                        # review pending changes
chezmoi apply                       # push changes into $HOME
```

`chezmoi source-path` prints the repo location that chezmoi manages. Commit and push from there as usual.
