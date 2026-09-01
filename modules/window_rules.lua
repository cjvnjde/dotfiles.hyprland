hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "browser-picture-in-picture",
    match = {
        class = "^(firefox|firefoxdeveloperedition|app[.]zen_browser[.]zen)$",
        title = "^Picture-in-Picture$",
    },
    float = true,
    pin = true,
})

hl.window_rule({
    name = "quickshell-pinned-note",
    match = { title = "^Quickshell Note .+$" },
    float = true,
    pin = true,
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})
