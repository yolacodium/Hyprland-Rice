------------------
---- PROGRAMME ----
------------------
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show drun"
local openai     = "claude-desktop"
local mainMod     = "SUPER"

------------------
---- STANDARD ----
------------------
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(openai))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("ags toggle notification-center"))

-- Firefox schwebend
hl.window_rule({ match = { class = "^(firefox)$" }, float = true, size = "1100 700" })
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("firefox"))

-- Spotify schwebend
hl.window_rule({ match = { class = "^(spotify)$" }, float = true, size = "1000 650" })
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("spotify"))

-- Kitty schwebend
hl.window_rule({ match = { class = "^(kitty-float)$" }, float = true, size = "900 550" })
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty --class kitty-float"))

-- TeamSpeak schwebend
hl.window_rule({ match = { class = "^(TeamSpeak 3)$" }, float = true, size = "800 500" })
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("teamspeak3"))
-- Claude Desktop schwebend
hl.window_rule({ match = { class = "^(com.anthropic.Claude)$" }, float = true, size = "1000 700" })

-- Dolphin schwebend
hl.window_rule({ match = { class = "^(org.kde.dolphin)$" }, float = true, size = "1000 650" })

-- VSCodium schwebend
hl.window_rule({ match = { class = "^(codium)$" }, float = true, size = "1200 800" })
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("codium"))



--Wallpaper && Scrolloverview
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.local/bin/pickwall"))
hl.bind(mainMod .. " + g", function()
    hl.plugin.scrolloverview.overview("toggle")
end)

-- Fokus mit Pfeiltasten
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Lautstärke und Medien
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

----------------------------
---- INFINITE DESKTOP ----
----------------------------
hl.bind("SUPER + Z", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + X", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + SHIFT + Z", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + SHIFT + X", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("SUPER + D", hl.dsp.exec_cmd("python3 ~/scripts/floating_tile_toggle.py"))
hl.bind("SUPER + H", hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py left"))
hl.bind("SUPER + ALT + left", hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py left"))
hl.bind("SUPER + SHIFT + left", hl.dsp.exec_cmd("python3 ~/scripts/move_window.py left"), { repeating = true })
hl.bind("SUPER + CTRL + left", hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py left"), { repeating = true })
hl.bind("SUPER + L", hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py right"))
hl.bind("SUPER + ALT + right", hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py right"))
hl.bind("SUPER + SHIFT + right", hl.dsp.exec_cmd("python3 ~/scripts/move_window.py right"), { repeating = true })
hl.bind("SUPER + CTRL + right", hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py right"), { repeating = true })
hl.bind("SUPER + K", hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py up"))
hl.bind("SUPER + ALT + up", hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py up"))
hl.bind("SUPER + SHIFT + up", hl.dsp.exec_cmd("python3 ~/scripts/move_window.py up"), { repeating = true })
hl.bind("SUPER + CTRL + up", hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py up"), { repeating = true })
hl.bind("SUPER + down", hl.dsp.exec_cmd("python3 ~/scripts/navigate_windows.py down"))
hl.bind("SUPER + ALT + down", hl.dsp.exec_cmd("python3 ~/scripts/move_window_tiled.py down"))
hl.bind("SUPER + SHIFT + down", hl.dsp.exec_cmd("python3 ~/scripts/move_window.py down"), { repeating = true })
hl.bind("SUPER + CTRL + down", hl.dsp.exec_cmd("python3 ~/scripts/resize_window.py down"), { repeating = true })

hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
