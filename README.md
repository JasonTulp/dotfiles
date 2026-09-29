# My dotfiles

Managed with [chezmoi](https://chezmoi.io). Config directories live as plain
files in this repo and chezmoi symlinks them into `~`, so editing
`~/.config/hypr/...` edits the repo directly (same as the old stow setup).

## Layout

```
home/        chezmoi source state (.chezmoiroot points here)
  .chezmoi.toml.tmpl    asks "desktop" or "server" once on init
  .chezmoiignore        which configs each machine type/OS gets
  .chezmoiscripts/      bootstrap: install CLI tools, tmux plugins
  dot_config/symlink_*  ~/.config/<name> -> config/<name>
config/      the actual ~/.config contents
zsh/zshrc    ~/.zshrc
local/share  ~/.local/share contents
wallpapers/  not deployed
```

What each machine gets:

- **server**: zsh, tmux, herdr, nvim, starship
- **Linux desktop**: everything above, plus Hyprland, DMS, mango, waybar, rofi, KDE/Qt/GTK theming, ghostty, zed
- **macOS desktop**: shared configs, plus aerospace, sketchybar, ghostty, zed

## New machine

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply JasonTulp/dotfiles
```

This clones to `~/.local/share/chezmoi`, asks for the machine type, installs
missing tools (zsh, tmux, neovim, fzf, zoxide, starship) and links configs.
To keep the clone at `~/dotfiles` instead:

```
git clone https://github.com/JasonTulp/dotfiles.git ~/dotfiles
~/.local/bin/chezmoi init --source ~/dotfiles --apply
```

## Day to day

- Edit files under `~/.config/...` as normal; commit from the repo.
- `chezmoi cd` to jump to the repo, `chezmoi update` to pull and re-apply.
- New config dir: move it into `config/<name>`, then add
  `home/dot_config/symlink_<name>.tmpl` containing
  `{{ .chezmoi.workingTree }}/config/<name>`, and optionally a line in
  `home/.chezmoiignore`. Run `chezmoi apply`.
- Change the machine type: edit `~/.config/chezmoi/chezmoi.toml`.
