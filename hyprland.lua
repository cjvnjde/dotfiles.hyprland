local modules = {
    "monitor",
    "environment",
    "autostart",
    "appearance",
    "input",
    "animations",
    "bindings",
    "window_rules",
}

for _, module in ipairs(modules) do
    require("modules." .. module)
end
