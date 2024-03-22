```
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

Configurations for various tools and applications that I use on a daily basis. Feel free to explore and copy.

### Download git submodules
``` bash
git submodule update --init --recursive
```


## Symlink
### Stow Apply
Remove parameter `n` to actually apply changes
``` bash
stow -Svn .
```

### Stow Delete
Remove parameter `n` to actually apply changes

``` bash
stow -Dvn .
```

### Install git-delta and symlink lazygit config
``` bash
cargo install git-deltaa
ln -s /Users/jonas/.config/lazygit/config.yml ~/Library/Application\ Support/lazygit/config.yml
```
