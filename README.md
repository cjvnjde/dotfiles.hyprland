# Hyprland configuration

This is a modular Lua configuration for Hyprland. Hyprland loads
`hyprland.lua`, which then loads the files in `modules/` with `require()`.
Saving any loaded file causes Hyprland to reload the configuration
automatically; it can also be reloaded manually with:

```bash
hyprctl reload
```

## Modules

| Module | Responsibility |
| --- | --- |
| `hyprland.lua` | Entrypoint and module load order |
| `modules/programs.lua` | Terminal, browser, and launcher commands |
| `modules/monitor.lua` | Default monitor mode, position, and scale |
| `modules/environment.lua` | Cursor environment variables |
| `modules/autostart.lua` | Quickshell startup |
| `modules/appearance.lua` | Layout, gaps, borders, decoration, blur, shadows, and disabled animations |
| `modules/input.lua` | Keyboard layouts, layout switching, mouse, and touchpad |
| `modules/bindings.lua` | Keyboard, mouse, media, and screenshot bindings |
| `modules/window_rules.lua` | Application and XWayland rules |
| `hyprtoolkit.conf` | Catppuccin Mocha colors, typography, and rounding |
| `hyprpaper.conf` | Wallpaper image and display mode |

The module loader honors `XDG_CONFIG_HOME`. If it is unset, it loads modules
from `~/.config/hypr/modules/`.

## Keybindings

The main convention mirrors browser shortcuts: `Ctrl` operates within an
application, while `Super` performs the analogous desktop-level action. For
example, `Ctrl+T` opens a browser tab and `Super+T` opens the application
picker; `Ctrl+W` closes a browser tab and `Super+W` closes a window.

### Applications and session

| Binding | Action |
| --- | --- |
| `Super+T` | Open the Quickshell application picker |
| `Super+W` | Close active window |
| `Super+Return` | Open Ghostty |
| `Super+B` | Open Zen Browser |
| `Super+Shift+E` | Exit Hyprland |
| `Print` | Select a region and copy its screenshot to the clipboard |
| `Shift+Print` | Select a region, save the original, and annotate it with Satty |

### Windows and layout

| Binding | Action |
| --- | --- |
| `Super+F` | Toggle fullscreen |
| `Super+Shift+F` | Toggle floating |
| `Super+P` | Toggle pseudotiling |
| `Super+E` | Toggle the dwindle split direction |
| `Super+D` | Toggle window grouping |
| `Super+H/J/K/L` | Focus the window left/down/up/right |
| `Super+Shift+H/J/K/L` | Move the window left/down/up/right |
| `Super+Alt+H` | Select previous window in the group |
| `Super+Alt+L` | Select next window in the group |
| `Super+left mouse button` | Drag a window |
| `Super+right mouse button` | Resize a window |

### Workspaces

| Binding | Action |
| --- | --- |
| `Super+1` ... `Super+9` | Switch to workspace 1 ... 9 |
| `Super+0` | Switch to workspace 10 |
| `Super+Shift+1` ... `Super+Shift+9` | Move active window to workspace 1 ... 9 |
| `Super+Shift+0` | Move active window to workspace 10 |
| `Super+S` | Toggle the `magic` special workspace |
| `Super+Shift+S` | Move active window to the `magic` special workspace |

### Audio and media

| Binding | Action |
| --- | --- |
| `Volume Up` | Raise output volume by 5%, capped at 100% |
| `Volume Down` | Lower output volume by 5% |
| `Audio Mute` | Toggle output mute |
| `Microphone Mute` | Toggle microphone mute |
| `Media Next` | Next track |
| `Media Play` | Toggle play/pause |
| `Media Pause` | Toggle play/pause |
| `Media Previous` | Previous track |

### Input

| Binding | Action |
| --- | --- |
| `Super+Space` | Switch between US and Russian keyboard layouts |
| `Caps Lock` | Escape |

## Dependencies

The package names below are for Arch Linux.

### Core and configured applications

| Package/component | Used for |
| --- | --- |
| `hyprland` | Compositor and Lua configuration runtime |
| `ghostty` | Terminal opened by `Super+Return` |
| `hyprpaper` | Displays the configured desktop wallpaper |
| `quickshell` | Provides `qs`, started as the `main` shell configuration |
| `wireplumber` | Provides `wpctl` for volume and microphone bindings |
| `playerctl` | MPRIS media controls |
| `flatpak` | Launches the configured Zen Browser Flatpak |

Install the repository packages with:

```bash
sudo pacman -S hyprland ghostty hyprpaper quickshell wireplumber playerctl flatpak
```

Zen Browser must be installed with the Flatpak application ID used by
`modules/programs.lua`:

```bash
flatpak install flathub app.zen_browser.zen
```

The autostart command is `qs -c main`, so a working Quickshell configuration
named `main` must also exist in Quickshell's configuration search path. The
Hyprland files in this directory do not provide that shell configuration.

### Screenshots

The `Print` binding tries the following backends in order. Only one complete
backend is required:

1. `grimshot`
2. `hyprshot`
3. `grim`, `slurp`, and `wl-copy`

The fully repository-based fallback can be installed with:

```bash
sudo pacman -S grim slurp wl-clipboard libnotify
```

`wl-clipboard` provides `wl-copy`. `libnotify` provides `notify-send`, which is
used to report that no screenshot backend is available. A notification daemon
or a Quickshell notification service must be running for that message to be
visible.

`Shift+Print` uses `grim`, `slurp`, `satty`, and `wl-copy`. It saves the original
capture to `~/Pictures/Screenshots` (or the configured XDG Pictures directory)
with a `-raw.png` suffix. In Satty, press `Enter` or `Ctrl+C` to copy the
annotated image to the clipboard, save it beside the original, and close Satty.

### Runtime configuration modules

No third-party Lua modules are required. All Lua files used by this config live
under `modules/` and are loaded with Hyprland's configuration-aware `require()`.

## Customization

Change application commands in `modules/programs.lua`. Keep machine-specific
display changes in `modules/monitor.lua`, input changes in `modules/input.lua`,
and personal shortcuts in `modules/bindings.lua`.
