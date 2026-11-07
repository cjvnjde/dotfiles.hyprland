# Hyprland

Minimal Hyprland setup. Linked to `~/.config/hypr` by `setup.sh`.

| File | What it does |
|---|---|
| `hyprland.lua` | Monitors, autostart, look, input, key bindings |
| `hypridle.conf` | Lock after 5 min, screen off after 5.5 min, suspend after 30 min |
| `hyprlock.conf` | Lock screen: clock and password field |
| `local.lua` | Optional per-machine overrides (git-ignored) |

## Keys

| Key | Action |
|---|---|
| `Super+Return` | Terminal (ghostty) |
| `Super+Space` | App launcher (`qs ipc call launcher toggle`) |
| `Super+T` | Toggle floating |
| `Super+W` | Close window |
| `Super+M` | Toggle default microphone mute |
| `Super+H/J/K/L` | Focus left/down/up/right |
| `Super+Shift+H/J/K/L` | Move window |
| `Super+1..0` | Go to workspace 1-10 |
| `Super+Shift+1..0` | Move window to workspace 1-10 |
| `Super+F` | Toggle fullscreen |
| `Super+I` | Toggle split direction |
| `Super+D` | Toggle window group (tabs) |
| `Super+drag` | Move (left) / resize (right) |
| `Print` | Freeze, select a region, then silently save and copy; Escape cancels |
| `Shift+Print` | Freeze, select a region, then annotate in Satty; copying silently saves too |
| `Left Alt` held, then `Right Alt` | Next keyboard layout (`us,ru`) |
| `Right Alt` held, then `Left Alt` | Previous keyboard layout |

## Scratchpads

`Super+S` and `Super+N` toggle independent scratchpads. `Super+Alt+S/N` moves
the focused window into one without following it. Scratchpads start below the
24-pixel bar, with a 12-pixel margin on every side to show the workspace behind.

## Quake consoles

`Super+grave` toggles the terminal console; `Super+apostrophe` toggles the agent
console. Moving the pointer outside leaves them open. A left, right, or middle
click outside a console—including on another monitor—hides it without closing
the terminal or consuming the click. Scratchpads are unaffected.

## Screenshots

Requires `hyprshot`, `hyprpicker`, `grim`, `slurp`, `wl-clipboard`, and `satty`.

Both shortcuts use Hyprshot's `--freeze` mode: hyprpicker preserves the visible
screen before slurp takes focus, keeping browser popovers and hover states in
the capture. The wrapper drains the complete PNG stream before copying it or
opening Satty; Hyprshot itself can return while its capture process is still
writing.

`Print` silently saves the selected region to `~/Pictures/Screenshots` and copies
it to the clipboard. `Shift+Print` opens it in Satty fullscreen for drawing,
arrows, text, highlighting, and cropping. Press `Enter` or `Ctrl+C` to copy the
annotated result, automatically save it to the same folder, and close. No save
dialog or notification appears. `Ctrl+Shift+S` remains available for a manual
Save As.

The folder is created automatically; PNG filenames include the capture date
and time with nanoseconds to avoid overwrites. `Escape` cancels without saving
or changing the clipboard. Cancelling region selection does not open Satty.
Temporary captures are removed when the command finishes.

## Setup

```bash
bash hyprland/setup.sh enable
```
