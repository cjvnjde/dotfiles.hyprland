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
| `Super+Escape` | Lock |
| `Super+M` | Toggle default microphone mute |
| `Super+H/J/K/L` | Focus left/down/up/right |
| `Super+Shift+H/J/K/L` | Move window |
| `Super+1..0` | Go to workspace 1-10 |
| `Super+Shift+1..0` | Move window to workspace 1-10 |
| `Super+F` | Toggle fullscreen |
| `Super+I` | Toggle split direction |
| `Super+D` | Toggle window group (tabs) |
| `Super+drag` | Move (left) / resize (right) |
| `Print` | Screenshot a region to the clipboard; Escape cancels without changing it |
| `Left Alt` held, then `Right Alt` | Next keyboard layout (`us,ru`) |
| `Right Alt` held, then `Left Alt` | Previous keyboard layout |

## Quake consoles

`Super+grave` toggles the terminal console; `Super+apostrophe` toggles the agent
console. Moving the pointer outside leaves them open. A left, right, or middle
click outside a console—including on another monitor—hides it without closing
the terminal or consuming the click. Full-size scratchpads are unaffected.

## Setup

```bash
bash hyprland/setup.sh enable
```
