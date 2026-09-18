# dotfiles

My Neovim (LazyVim-based) and tmux config. Origin machine is Arch + Omarchy;
target machine is a company Mac. Only nvim + tmux are ported — Omarchy itself
(Hyprland, waybar, etc.) is Linux-only and does not apply to macOS.

## What's in here

```
dotfiles/
├── nvim/               a plain COPY of ~/.config/nvim
└── tmux/
    └── tmux.conf       a plain COPY of ~/.config/tmux/tmux.conf
```

These are real, independent copies — no symlinks. That means git here only
ever sees what you last copied in; it does **not** auto-update when you edit
your live config. You are responsible for syncing (see "Syncing" below).
This was a deliberate choice: fewer moving parts to reason about, at the
cost of a manual copy step.

## Install on a new machine (the Mac)

```bash
# 1. clone the repo somewhere permanent, e.g. your home directory
git clone git@github.com:<you>/dotfiles.git ~/dotfiles

# 2. make sure the target folders don't already have real configs in the way
#    (macOS Neovim/tmux installed fresh won't have these yet, but check)
ls -la ~/.config/nvim ~/.config/tmux 2>/dev/null

# 3. if anything real exists there, move it aside instead of deleting it
[ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak
[ -e ~/.config/tmux ] && mv ~/.config/tmux ~/.config/tmux.bak

# 4. copy this repo's configs into place (real copies, not links)
mkdir -p ~/.config/tmux
cp -r ~/dotfiles/nvim ~/.config/nvim
cp ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf

# 5. install neovim + tmux if not already there
brew install neovim tmux

# 6. open nvim once — LazyVim will auto-install all plugins from lazy-lock.json
nvim
# just let it sit for a minute while plugins install, then :q and reopen

# 7. start tmux and reload config to sanity check
tmux
# inside tmux: prefix (Ctrl-Space) then q   -> reloads config, should show no errors
```

That's the whole transition. Everything else below is for when something
breaks and you need to know where to look.

## Things that WILL need fixing on the Mac

- **tmux.conf line 8** (`?` keybinding) calls `omarchy-menu-tmux-keybindings`,
  an Omarchy-only helper script. It won't exist on Mac — that one keybind
  will error, nothing else breaks. Either delete the line or point it at
  something else (e.g. `tmux list-keys`).
- **`lua/plugins/omarchy-theme-hotreload.lua`** listens for an Omarchy theme
  event that will simply never fire on Mac. It's inert there — safe to leave,
  not worth deleting unless you want the repo Omarchy-free.
- **`lua/plugins/theme.lua`** — on the Linux/Omarchy machine this file is a
  *symlink* Omarchy manages, pointing at whichever theme you last picked with
  `omarchy-theme-set` (`~/.local/state/omarchy/current/theme/neovim.lua`).
  There's no Omarchy on Mac to manage that, so the version committed to this
  repo is a plain static snapshot (currently `tokyonight-night`) instead.
  Changing themes on Mac means editing this file directly — it won't
  hot-swap the way it does on the Linux box.
- **Keybindings that assume a Linux/Hyprland modifier layout** (e.g. `M-`
  = Alt in some setups) — check `lua/config/keymaps.lua` and the top of
  `tmux.conf` if a shortcut feels off; macOS terminals often map Option/Cmd
  differently than Linux terminals map Super/Alt.

## How to read/edit these files (just enough to not be lost)

**nvim** is [LazyVim](https://www.lazyvim.org/) — a pre-built config framework,
not a from-scratch one. You are not looking at "all of Neovim's config" here,
just the small bits that customize LazyVim's defaults:

| File | What it's for | Edit this when... |
|---|---|---|
| `init.lua` | One line, just boots everything below. | Never. |
| `lua/config/options.lua` | Editor settings (tabs, line numbers, etc). | You want a setting changed vim-wide. |
| `lua/config/keymaps.lua` | Your custom keybindings. | You want to add/change a shortcut. |
| `lua/config/autocmds.lua` | "When X happens, do Y" automation. | Rare. |
| `lua/config/lazy.lua` | Bootstraps the plugin manager itself. | Basically never. |
| `lua/plugins/*.lua` | **One file per plugin (or plugin group).** Each file returns a table describing a plugin to install/configure. | You want to add, remove, or reconfigure a plugin. |
| `lazy-lock.json` | Exact pinned plugin versions (auto-generated). | Never by hand — `:Lazy` manages it. |

Rule of thumb: if you want to change *behavior*, look in `lua/config/`. If
you want to add/remove a *plugin*, add a new file in `lua/plugins/` (copy
`lua/plugins/example.lua` as a template) or edit an existing one there.
Inside Neovim, `:Lazy` opens the plugin manager UI (install/update/check
status), `:LazyHealth` / `:checkhealth` diagnoses problems.

**tmux.conf** is one flat file, organized top-to-bottom by section (see the
`# Comment` headers inside it: prefix key, copy mode, pane controls, resize,
status bar, etc). It's plain text — no plugin manager involved, so there's
nothing to install beyond tmux itself. After any edit, reload with prefix
`Ctrl-Space` then `q` (that binding is defined in the file itself), or
`tmux source-file ~/.config/tmux/tmux.conf`.

## Syncing (the part you have to remember, since these are copies)

There are always **two separate copies** of each config: the live one
(`~/.config/nvim`, `~/.config/tmux/tmux.conf`) that the apps actually read,
and the repo one (`~/dotfiles/...`) that git tracks and pushes. Editing one
does not touch the other. Before you push, copy live → repo. After you pull
on the other machine, copy repo → live.

```bash
# LIVE -> REPO   (run this before committing, after you've edited your live config)
cp -r ~/.config/nvim/. ~/dotfiles/nvim/
cp ~/.config/tmux/tmux.conf ~/dotfiles/tmux/tmux.conf

# REPO -> LIVE   (run this after `git pull`, to apply changes you pulled)
cp -r ~/dotfiles/nvim/. ~/.config/nvim/
cp ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

Easy way to check if they've drifted apart before you assume which way to
copy:

```bash
diff -rq ~/.config/nvim ~/dotfiles/nvim
diff -q ~/.config/tmux/tmux.conf ~/dotfiles/tmux/tmux.conf
```

No output = identical. Any output = they've diverged, go read it before
blindly copying over something you meant to keep.

## Day-to-day workflow (keeping both machines in sync)

```bash
# after editing your LIVE config, and you're ready to push:
cp -r ~/.config/nvim/. ~/dotfiles/nvim/
cp ~/.config/tmux/tmux.conf ~/dotfiles/tmux/tmux.conf
cd ~/dotfiles
git add -A
git commit -m "describe what changed"
git push

# on the OTHER machine, to pull AND apply those changes:
cd ~/dotfiles
git pull
cp -r ~/dotfiles/nvim/. ~/.config/nvim/
cp ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

## First-time push (only needs doing once, from the Linux machine)

```bash
cd ~/dotfiles
gh repo create dotfiles --private --source=. --remote=origin --push
```

This creates the GitHub repo, wires up the remote, and pushes in one step
(requires `gh auth login` to already be done — it is, on this machine).
