hl.config({
    general = {
        layout = "dwindle",
        gaps_in = 2,
        gaps_out = 2,
        border_size = 2,
        resize_on_border = false,
        allow_tearing = false,
    },
    animations = {
        enabled = false,
    },
    decoration = {
        rounding = 4,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
    dwindle = {
        preserve_split = true,
        force_split = 2,
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
})

local palettes = {
    dark = {
        base = 0xff1e1e2e,
        text = 0xffcdd6f4,
        surface = "rgba(313244ff)",
        inactive = "rgba(45475aff)",
        active = { colors = { "rgba(b4befeff)", "rgba(89b4faff)" }, angle = 45 },
        locked = "rgba(cba6f7ff)",
        shadow = 0xee181825,
    },
    light = {
        base = 0xffeff1f5,
        text = 0xff4c4f69,
        surface = "rgba(ccd0daff)",
        inactive = "rgba(bcc0ccff)",
        active = { colors = { "rgba(7287fdff)", "rgba(1e66f5ff)" }, angle = 45 },
        locked = "rgba(8839efff)",
        shadow = 0x669ca0b0,
    },
}

local function set_mode(mode)
    local palette = assert(palettes[mode], "Unknown appearance mode: " .. tostring(mode))
    hl.config({
        general = {
            col = {
                active_border = palette.active,
                inactive_border = palette.inactive,
            },
        },
        decoration = {
            shadow = {
                color = palette.shadow,
                color_inactive = palette.shadow,
            },
        },
        group = {
            col = {
                border_active = palette.active,
                border_inactive = palette.inactive,
                border_locked_active = palette.locked,
                border_locked_inactive = palette.inactive,
            },
            groupbar = {
                text_color = palette.text,
                text_color_inactive = palette.text,
                text_color_locked_active = palette.text,
                text_color_locked_inactive = palette.text,
                col = {
                    active = palette.surface,
                    inactive = palette.inactive,
                    locked_active = palette.surface,
                    locked_inactive = palette.inactive,
                },
            },
        },
        misc = {
            background_color = palette.base,
            col = { splash = palette.text },
        },
    })
end

set_mode("dark")

return { set_mode = set_mode }
