hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

	hl.exec_cmd("qs -c main")
end)
