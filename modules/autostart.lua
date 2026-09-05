hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && systemctl --user daemon-reload && systemctl --user start hyprland-session.target")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("qs -c main")
end)

hl.on("hyprland.shutdown", function()
	hl.exec_cmd("systemctl --user stop hyprland-session.target")
end)
