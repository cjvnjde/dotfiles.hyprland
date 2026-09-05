local main_mod = "SUPER"
local programs = require("modules.programs")
local hypr_config_dir = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")

local screenshot = [[sh -c '
    if command -v grimshot >/dev/null 2>&1; then
        exec grimshot copy area
    elif command -v hyprshot >/dev/null 2>&1; then
        exec hyprshot -m region --clipboard-only
    elif command -v grim >/dev/null 2>&1 && command -v slurp >/dev/null 2>&1 && command -v wl-copy >/dev/null 2>&1; then
        grim -g "$(slurp)" - | wl-copy --type image/png
    else
        notify-send "Screenshot failed" "Install grimshot, hyprshot, or grim, slurp, and wl-clipboard"
    fi
']]

-- Browser-like hierarchy: Ctrl acts within an app; Super acts across apps.
hl.bind(main_mod .. " + T", hl.dsp.exec_cmd(programs.launcher))
hl.bind(main_mod .. " + A", hl.dsp.exec_cmd("qs -c main ipc call ai open"))
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd("qs -c main ipc call ai openProject general"))
hl.bind(main_mod .. " + O", hl.dsp.exec_cmd("qs -c main ipc call ai openProject english"))
hl.bind(main_mod .. " + SHIFT + A", hl.dsp.exec_cmd("qs -c main ipc call ai screenshot"))
hl.bind(main_mod .. " + SHIFT + E", hl.dsp.exec_cmd("qs -c main ipc call ai screenshotProject general"))
hl.bind(main_mod .. " + SHIFT + O", hl.dsp.exec_cmd("qs -c main ipc call ai screenshotProject english"))
hl.bind(main_mod .. " + W", hl.dsp.window.close())

hl.bind(main_mod .. " + Return", hl.dsp.exec_cmd(programs.terminal))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(main_mod .. " + CTRL + SHIFT + E", hl.dsp.exit())
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(main_mod .. " + SHIFT + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(main_mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind(main_mod .. " + I", hl.dsp.layout("togglesplit"))
hl.bind(main_mod .. " + D", hl.dsp.group.toggle())
hl.bind("Print", hl.dsp.exec_cmd(screenshot))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(hypr_config_dir .. "/hypr/scripts/screenshot-annotate.sh"))

local directions = {
    H = "left",
    J = "down",
    K = "up",
    L = "right",
}

for key, direction in pairs(directions) do
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
    hl.bind(main_mod .. " + CTRL + " .. key, hl.dsp.window.move({ into_group = direction }))
end

hl.bind(main_mod .. " + ALT + H", hl.dsp.group.prev())
hl.bind(main_mod .. " + ALT + L", hl.dsp.group.next())

for workspace = 1, 10 do
    local key = workspace % 10

    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
    locked = true,
    repeating = true,
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    locked = true,
    repeating = true,
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind(main_mod .. " + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
