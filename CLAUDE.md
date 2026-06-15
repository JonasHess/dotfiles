# dotfiles

Personal dotfiles, symlinked into `$HOME` with GNU Stow.
Repo: github.com/JonasHess/dotfiles.

## Editing semantics
- Files in this repo are symlinked into `$HOME` (e.g. `~/.zshrc -> ~/repos/dotfiles/.zshrc`),
  so editing a file here changes the live config immediately — no copy step.
- A *new* file needs to be stowed once to create its symlink:
  `stow -Sv -d ~/repos/dotfiles -t ~ .`  (add `-n` for a dry run; `-D` to unstow).
- `.stow-local-ignore` controls what stow skips (`.git`, `.idea`, `README*`, etc.).

## Layout
- Shell: `.zshrc`, `.oh-my-zsh/`, `.p10k.zsh`, `.tmux.conf` (+ `.tmux.conf.local`).
- Editors: `.nvimrc` + `.config/nvim` (AstroNvim), `.ideavimrc`.
- macOS window mgmt: `.config/{yabai,skhd,sketchybar,rectangle}`.
- Other tools: `.config/{k9s,lazygit,gh,ranger,alacritty,htop}`, `.osx` (macOS `defaults`).
- Claude Code global config: `.claude/CLAUDE.md`, stowed to `~/.claude/CLAUDE.md`.

## Submodules
Third-party zsh plugins and Powerlevel10k are git submodules:
`git submodule update --init --recursive`.

## Gitignore note
Most `.claude/` runtime data is gitignored; only `.claude/CLAUDE.md` is tracked,
via a `!.claude/CLAUDE.md` exception. Keep that exception when editing `.gitignore`.
