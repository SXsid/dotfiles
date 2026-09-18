# dotfiles

My Neovim (LazyVim-based) and tmux config. Origin machine is Arch + Omarchy;
target machine is a company Mac. Only nvim + tmux are ported — Omarchy itself
(Hyprland, waybar, etc.) is Linux-only and does not apply to macOS.

## What's in here

```
dotfiles/
├── nvim/     -> symlinked to ~/.config/nvim on the source machine
└── tmux/
    └── tmux.conf  -> symlinked to ~/.config/tmux/tmux.conf on the source machine
```

On the Linux box, `~/.config/nvim` and `~/.config/tmux/tmux.conf` are now
**symlinks** pointing into this repo. That's on purpose — see "What's a
symlink" below. Editing the files under `~/.config/...` and editing the files
here are the same thing; there's only one real copy.

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

# 4. symlink this repo's configs into place
mkdir -p ~/.config/tmux
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf

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

## What's a symlink (since this is the part that's easy to get lost on)

A symlink (`ln -s target linkname`) is a pointer, not a copy. When you type
`ln -s ~/dotfiles/nvim ~/.config/nvim`, you're saying "whenever anything
opens `~/.config/nvim`, actually go read `~/dotfiles/nvim` instead." Neovim
has no idea it's a symlink — it just sees a normal folder. That's why this
setup works: **there is exactly one real copy of each file**, living in the
git repo, and both the "config location" and the "repo location" are just
two doors into the same room. Edit through either door, git only ever sees
the real file in `~/dotfiles`.

Why bother instead of just copying files into `~/.config`? Because a copy
goes stale the moment you edit it in one place and forget the other. A
symlink can't go stale — there's only one file.

Two commands worth knowing:
- `ls -la ~/.config/nvim` — the `->` in the output shows you it's a link and
  where it points.
- `readlink ~/.config/nvim` — prints just the target path.
- If a symlink is broken (target moved/deleted), `ls` usually shows it in
  red, and opening it errors "No such file or directory."

## Day-to-day workflow (keeping both machines in sync)

```bash
# after editing configs on either machine
cd ~/dotfiles
git add -A
git commit -m "describe what changed"
git push

# on the OTHER machine, to pull those changes
cd ~/dotfiles
git pull
```

Nothing needs re-linking after a `git pull` — the symlinks still point at
the same repo folder, which now just has newer content in it.

## First-time push (only needs doing once, from the Linux machine)

```bash
cd ~/dotfiles
gh repo create dotfiles --private --source=. --remote=origin --push
```

This creates the GitHub repo, wires up the remote, and pushes in one step
(requires `gh auth login` to already be done — it is, on this machine).
