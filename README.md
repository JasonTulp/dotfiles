# My dotfiles

This dir contains my system dotfiles for max configuration

# Install git and stow

```
sudo apt install git
sudo apt install stow
```

## Installation

First, clone the repo to your $HOME directory using git

```
git clone https://github.com/JasonTulp/dotfiles.git
cd dotfiles
```

Then use GNU stow to create symlinks

```
stow .
```

Note, when adding a new folder, you can use the following command
to move existing folder to repo and create symlink automatically

```
stow --adopt .
```
