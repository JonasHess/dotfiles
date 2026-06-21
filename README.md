```
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

Configurations for various tools and applications that I use on a daily basis. Feel free to explore and copy.

These dotfiles are intended to work on both **macOS** and **Windows (WSL / Ubuntu)**.

## Prerequisites

Install [GNU Stow](https://www.gnu.org/software/stow/) (symlink farm manager) and
Zsh, then make Zsh your default shell.

### macOS (Homebrew)

``` bash
brew install stow zsh
chsh -s $(which zsh)
```

### Debian / Ubuntu / WSL

``` bash
sudo apt-get update && sudo apt-get install -y stow zsh
chsh -s "$(which zsh)"
```

After changing your shell, log out and back in (or restart the WSL session), then
confirm with `echo $SHELL`.

## Local configuration (required)

Personal identity and machine-specific settings are kept out of the repo in
git-ignored `*.local` files. Create them from the provided templates before you
start using these dotfiles:

``` bash
cp .gitconfig.local.example ~/.gitconfig.local   # set your git name/email + credential helper
# Optional: ~/.zshrc.local is sourced at the end of .zshrc for per-machine tweaks
```

### Download git submodules
``` bash
git submodule update --init --recursive
```


## Symlink

### What is GNU Stow?
GNU Stow is a symlink manager that makes it easy to manage dotfiles. It creates symbolic links from your dotfiles repository to your home directory, allowing you to:
- Keep all configurations in a single git repository
- Easily install/uninstall configurations
- Share configurations across multiple machines

### How Stow Works
- `-S` (stow): Creates symlinks from the source directory to the target directory
- `-D` (delete): Removes symlinks created by stow
- `-v` (verbose): Shows what stow is doing
- `-n` (no/dry-run): Simulates the operation without making changes
- `-d` (directory): Specifies the source directory containing dotfiles
- `-t` (target): Specifies where symlinks should be created (usually your home directory)

The `.` at the end refers to the "package" to stow/unstow within the source directory. It means "process everything in the dotfiles directory". Since we're using `-d /Users/jonas/repos/dotfiles`, the `.` is interpreted relative to that source directory, effectively meaning "all contents of /Users/jonas/repos/dotfiles". You could also specify individual subdirectories instead of `.` if you only wanted to stow/unstow specific configurations.

### Stow Apply
Remove parameter `n` to actually apply changes
``` bash
stow -Svn -d /Users/jonas/repos/dotfiles -t /Users/jonas .
```

### Stow Delete
Remove parameter `n` to actually apply changes

``` bash
stow -Dvn -d /Users/jonas/repos/dotfiles -t /Users/jonas .
```

### Install git-delta and symlink lazygit config
``` bash
cargo install git-deltaa
ln -s /Users/jonas/.config/lazygit/config.yml ~/Library/Application\ Support/lazygit/config.yml
```
