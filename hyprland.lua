local modules = {
    "monitor",
    "workspaces",
    "environment",
    "autostart",
    "appearance",
    "input",
    "bindings",
    "window_rules",
}

for _, module in ipairs(modules) do
    require("modules." .. module)
end

local local_module = "modules.local"

if package.searchpath(local_module, package.path) then
    require(local_module)
end
