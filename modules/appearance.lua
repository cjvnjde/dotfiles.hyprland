hl.config({
    general = {
        layout = "dwindle",
        gaps_in = 2,
        gaps_out = 2,
        border_size = 2,
        col = {
            active_border = {
                colors = { "rgba(b4befeff)", "rgba(89b4faff)" },
                angle = 45,
            },
            inactive_border = "rgba(45475aff)",
        },
        resize_on_border = false,
        allow_tearing = false,
    },
    decoration = {
        rounding = 8,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee181825,
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
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
})
