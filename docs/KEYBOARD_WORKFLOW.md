# Keyboard Workflow

This setup uses one spatial language across Ghostty, tmux, Zsh, and Neovim. Run `workflow-help` anywhere, or press `Ctrl+a ?` inside tmux, to search the shortcut list.

## Mental model

| Layer | Job |
|---|---|
| Ghostty | Terminal window, clipboard, colors, font |
| tmux | Persistent sessions, windows, and panes |
| Sesh | Find, create, and switch project sessions |
| Zsh | Commands, completion, history, directory jumps |
| Neovim | Editing, code navigation, file search |
| Harpoon | Direct jumps among a small active set of files |

`Ctrl+a` is the tmux prefix. Press and release it, then press the next key. `Space` is the Neovim leader and works the same way.

## tmux

| Shortcut | Action |
|---|---|
| `Ctrl+a ?` | Search all workflow shortcuts |
| `Ctrl+h/j/k/l` | Move left/down/up/right across tmux and Neovim |
| `Alt+Arrow` | Move between tmux panes |
| `Shift+Arrow` | Resize the active pane |
| `Ctrl+a h` / `Ctrl+a v` | Split horizontally / vertically |
| `Ctrl+a f` | Open the Sesh project/session picker |
| `Ctrl+a c` | Create a window |
| `Ctrl+a n` / `Ctrl+a p` | Next / previous window |
| `Ctrl+a 1..9` | Jump to a numbered window |
| `Ctrl+a ,` | Rename the current window |
| `Ctrl+a z` | Zoom or unzoom a pane |
| `Ctrl+a d` | Detach; work keeps running |
| `Ctrl+a S` / `Ctrl+a X` | Create / confirm-kill a session |
| `Ctrl+a r` | Reload tmux configuration |

Sesh replaces the former custom `tmux-project` script. It combines active tmux sessions with directories learned by zoxide. Visit a project once with `cd` or `zoxide add PATH` to make it discoverable; selecting it with `Ctrl+a f` creates the session when necessary.

## Copy, URLs, and persistence

| Shortcut | Action |
|---|---|
| `Ctrl+a Space` | Show tmux-thumbs hints for paths, hashes, IPs, URLs, and IDs |
| lowercase hint | Copy the selected text |
| uppercase hint | Copy and paste the selected text |
| `Ctrl+a u` | Find and open a URL from visible terminal output |
| `Ctrl+a [` | Enter vi-style copy mode |
| `v`, then `y` | Select and copy in copy mode |
| `Ctrl+a Ctrl+s` | Save tmux layout with Resurrect |
| `Ctrl+a Ctrl+r` | Restore the saved layout |

Continuum saves every 15 minutes and restores automatically. It restores sessions, directories, windows, panes, and layouts; it does not resurrect arbitrary process state.

## Shell

| Shortcut / command | Action |
|---|---|
| `Tab` | Fuzzy command, option, Git ref, container, and path completion |
| `Ctrl+r` | Search deduplicated command history |
| `Ctrl+t` | Find a file and insert its path |
| `Alt+c` | Find and enter a directory |
| `Ctrl+Left/Right` | Move by one word |
| `Ctrl+Enter` | Add a newline without executing |
| `cd QUERY` | Jump to a frecent zoxide directory |
| `zi` | Pick a zoxide directory interactively |
| `br` | Browse an unfamiliar tree; `Alt+Enter` enters a directory |

## Neovim

| Shortcut | Action |
|---|---|
| `Space` | Show available LazyVim command groups |
| `Ctrl+h/j/k/l` | Move across Neovim splits and tmux panes |
| `Space Space` | Find project files |
| `Space /` | Search project text |
| `Space e` | Toggle Snacks Explorer |
| `Space w` | Save the current file |
| `Space H` | Add the current file to Harpoon |
| `Space h` | Open the Harpoon menu |
| `Space 1..9` | Jump directly to a Harpoon file |
| `Space m p` / `Space m P` | Start / stop browser document preview |

Harpoon is a short working set, not another file finder. Add the few files repeatedly used for the current task, then jump to them by number. Use `Space Space` when the file is not in that set.

Live Preview renders Markdown, KaTeX math, Mermaid diagrams, HTML, SVG, and AsciiDoc in the browser with synchronized scrolling. Full LaTeX/PDF compilation is not installed.

## Status and prompt

`tmux-cpu` shows CPU and NVIDIA GPU utilization in the tmux status bar. The Starship prompt uses a compact Tokyo Night palette; green `❯` means the previous command succeeded and red `❯` means it failed.

## Ghostty

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+c` / `Ctrl+Shift+v` | Copy / paste |
| `Ctrl+Insert` / `Shift+Insert` | Copy / paste alternatives |

Right-click opens the context menu. Vertical padding is disabled so tmux and non-tmux shells align at the top.
