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
    general = { layout = "dwindle", gaps_in = 2, gaps_out = 4, border_size = 2 },
    decoration = { rounding = 0 },
    animations = { enabled = false },
    misc = { force_default_wallpaper = 0, disable_hyprland_logo = true }, -- wallpaper comes from Quickshell
    dwindle = { preserve_split = true },
    input = { kb_layout = "us,ru", follow_mouse = 1 },
})

-- Apps and session
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + SHIFT + F", hl.dsp.exec_cmd("nautilus"))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("xdg-open about:blank"))
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("loginctl lock-session"))

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

-- Two independent, full-size scratchpads.
for _, key in ipairs({ "S", "N" }) do
    local name = "scratchpad-" .. key:lower()
    hl.bind(mod .. " + " .. key, hl.dsp.workspace.toggle_special(name))
    hl.bind(mod .. " + ALT + " .. key,
        hl.dsp.window.move({ workspace = "special:" .. name, follow = false }))
end

-- Quake-style consoles, adapted from Omarchy's release candidate.
-- Each starts its command only when its workspace is first created.
local function console(name, key, command)
    local workspace = "special:" .. name
    local last_side, last_bottom

    local function cover(side, bottom)
        if side == last_side and bottom == last_bottom then
            return false
        end
        last_side, last_bottom = side, bottom
        hl.workspace_rule({
            workspace = workspace,
            gaps_in = 0,
            gaps_out = { top = 0, right = side, bottom = bottom, left = side },
            no_border = true,
            on_created_empty = "[workspace " .. workspace .. " silent] " .. command,
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
        local reserved = monitor.reserved
        width = width / monitor.scale - reserved.left - reserved.right
        height = height / monitor.scale - reserved.top - reserved.bottom
        local tall = math.floor(height * 0.5)
        local wide = math.min(width, tall * 2)
        if cover(math.floor((width - wide) / 2), math.floor(height - tall)) then
            hl.exec_scheduled_prop_refresh_immediately()
        end
    end

    cover(0, 0)
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

console("console-terminal", "grave", terminal)
-- An interactive shell loads your mise environment so the agent is on PATH.
local quoted_agent = "'" .. agent:gsub("'", "'\\''") .. "'"
console("console-agent", "apostrophe", terminal .. " -e zsh -ic " .. quoted_agent)

-- Screenshot of a region to the clipboard
hl.bind("Print", hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" - | wl-copy']]))

-- Volume and media keys (work on the lock screen too)
local sink = "@DEFAULT_AUDIO_SINK@"
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
