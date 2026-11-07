-- Minimal Hyprland config. Machine-specific overrides go in local.lua (git-ignored).

local mod = "SUPER"
local terminal = "ghostty"
local agent = "pi"
local launcher = "qs ipc call launcher toggle"

-- Monitors: every output at its preferred mode
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Autostart. Hyprland exports its environment to systemd/D-Bus itself,
-- and gnome-keyring starts on demand from its systemd user socket.
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("qs")
end)

-- Look and input
hl.config({
    general = {
        layout = "dwindle", gaps_in = 0, border_size = 0,
        -- Fixed room for the 24px bar. Special workspaces override these gaps.
        gaps_out = { top = 24, right = 0, bottom = 0, left = 0 },
        -- Catppuccin Mocha fallback colors; borders remain disabled.
        col = {
            active_border = "rgb(b4befe)",
            inactive_border = "rgb(313244)",
        },
    },
    decoration = { rounding = 0 },
    animations = { enabled = false },
    misc = { force_default_wallpaper = 0, disable_hyprland_logo = true }, -- wallpaper comes from Quickshell
    dwindle = { preserve_split = true },
    input = {
        kb_layout = "us,ru",
        -- Hold Left Alt + press Right Alt: next; reverse order: previous.
        kb_options = "grp:alts_toggle",
        follow_mouse = 1,
    },
})

-- Apps and session
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + SHIFT + F", hl.dsp.exec_cmd("nautilus"))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("xdg-open about:blank"))
hl.bind(mod .. " + W", hl.dsp.window.close())

-- Universal clipboard: keep Ctrl+C as SIGINT in terminals.
-- Add custom terminal app IDs here if needed (matched case-insensitively).
local terminal_classes = {
    ["com.mitchellh.ghostty"] = true,
    ["kitty"] = true,
    ["alacritty"] = true,
    ["foot"] = true,
    ["footclient"] = true,
    ["org.wezfurlong.wezterm"] = true,
    ["org.kde.konsole"] = true,
    ["org.gnome.terminal"] = true,
}
for _, key in ipairs({ "C", "V" }) do
    hl.bind(mod .. " + " .. key, function()
        local window = hl.get_active_window()
        local is_terminal = window and terminal_classes[window.class:lower()]
        local mods = is_terminal and "CTRL SHIFT" or "CTRL"
        -- Explicit down/up avoids send_shortcut leaving synthetic keys stuck.
        -- No window target: also send to focused layer-shell panels.
        hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
        hl.timer(function()
            hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
        end, { timeout = 50, type = "oneshot" })
    end)
end

-- Windows
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + I", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + D", hl.dsp.group.toggle())

for key, direction in pairs({ H = "left", J = "down", K = "up", L = "right" }) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces 1-10 (key 0 = workspace 10)
for ws = 1, 10 do
    local key = ws % 10
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = ws }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
    hl.bind(mod .. " + SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = ws, follow = false }))
end

-- Special workspaces use screen-edge geometry, not the normal bar inset.
-- The bar stays visible and normal workspaces never change size when toggling.
-- With a command: centered, half-height Quake console; otherwise: full scratchpad.
local function special_workspace(name, key, command)
    local workspace = "special:" .. name
    local last_geometry

    local function cover(top, right, bottom, left)
        local geometry = table.concat({ top, right, bottom, left }, ",")
        if geometry == last_geometry then
            return false
        end
        last_geometry = geometry
        hl.workspace_rule({
            workspace = workspace,
            gaps_in = 0,
            gaps_out = { top = top, right = right, bottom = bottom, left = left },
            no_border = true,
            on_created_empty = command and ("[workspace " .. workspace .. " silent] " .. command) or nil,
        })
        return true
    end

    local function refit(monitor)
        local ws = hl.get_workspace(workspace)
        monitor = monitor or (ws and ws.visible and ws.monitor) or hl.get_active_monitor()
        if not monitor or not monitor.scale or monitor.scale <= 0 then
            return
        end
        local width, height = monitor.width, monitor.height
        if monitor.transform % 2 == 1 then
            width, height = height, width
        end
        width = width / monitor.scale
        height = height / monitor.scale
        local reserved = monitor.reserved
        local tall = command and math.floor(height * 0.5) or height
        local wide = command and math.min(width, tall * 2) or width
        local side = math.floor((width - wide) / 2)
        if cover(0, math.max(0, side - reserved.right),
            math.max(0, math.floor(height - tall) - reserved.bottom), math.max(0, side - reserved.left)) then
            hl.exec_scheduled_prop_refresh_immediately()
        end
    end

    cover(0, 0, 0, 0)
    refit()
    hl.bind(mod .. " + " .. key, hl.dsp.workspace.toggle_special(name))
    hl.on("monitor.layout_changed", function() refit() end)
    hl.on("monitor.focused", function() refit() end)
    hl.on("workspace.special_active", function(ws, monitor)
        if ws and ws.name == workspace then
            refit(monitor)
        end
    end)
    hl.on("workspace.move_to_monitor", function(ws, monitor)
        if ws and ws.name == workspace then
            refit(monitor)
        end
    end)
end

-- Two independent, full-size scratchpads.
for _, key in ipairs({ "S", "N" }) do
    local name = "scratchpad-" .. key:lower()
    special_workspace(name, key)
    hl.bind(mod .. " + ALT + " .. key,
        hl.dsp.window.move({ workspace = "special:" .. name, follow = false }))
end

special_workspace("console-terminal", "grave", terminal)
-- An interactive shell loads your mise environment so the agent is on PATH.
local quoted_agent = "'" .. agent:gsub("'", "'\\''") .. "'"
special_workspace("console-agent", "apostrophe", terminal .. " -e zsh -ic " .. quoted_agent)

-- Hide only the Quake consoles on an outside click, not on mouse movement.
-- Keep the terminal running in its special workspace and pass the click through.
local function dismiss_console_outside()
    local cursor = hl.get_cursor_pos()
    if not cursor then return end
    for _, monitor in ipairs(hl.get_monitors()) do
        local ws = monitor.active_special_workspace
        if ws and (ws.name == "special:console-terminal" or ws.name == "special:console-agent") then
            local inside = false
            for _, window in ipairs(ws:get_windows()) do
                if window.mapped and not window.hidden then
                    local at, size = window.at, window.size
                    local x, y = at.x or at[1], at.y or at[2]
                    local width, height = size.x or size[1], size.y or size[2]
                    if cursor.x >= x and cursor.x < x + width
                        and cursor.y >= y and cursor.y < y + height then
                        inside = true
                        break
                    end
                end
            end
            if not inside then
                monitor:set_special_workspace(nil)
            end
        end
    end
end
for _, button in ipairs({ "mouse:272", "mouse:273", "mouse:274" }) do
    hl.bind(button, dismiss_console_outside, { non_consuming = true, ignore_mods = true })
end

-- Screenshot of a region to the clipboard
hl.bind("Print", hl.dsp.exec_cmd([[sh -c 'geometry=$(slurp) && grim -g "$geometry" - | wl-copy']]))

-- Volume and media keys (work on the lock screen too)
local sink = "@DEFAULT_AUDIO_SINK@"
hl.bind(mod .. " + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 " .. sink .. " 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume " .. sink .. " 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute " .. sink .. " toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Optional per-machine overrides
if package.searchpath("local", package.path) then
    require("local")
end
