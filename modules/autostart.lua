hl.on("hyprland.start", function()
	hl.exec_cmd(
		"dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
	)
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("qs -c main")
end)
