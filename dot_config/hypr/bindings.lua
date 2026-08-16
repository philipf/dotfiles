-- Personal keybinding overrides.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print
--
-- Bindings that Omarchy's defaults already cover identically are not repeated
-- here: SUPER+RETURN (terminal in cwd), SUPER+SHIFT+F (Files), SUPER+SHIFT+B /
-- SUPER+SHIFT+ALT+B (browser), SUPER+SHIFT+M (Spotify), SUPER+SHIFT+N (editor),
-- SUPER+SHIFT+D (lazydocker), SUPER+SHIFT+ALT+A (Grok), SUPER+SHIFT+Y (YouTube),
-- SUPER+SHIFT+ALT+G (WhatsApp), SUPER+SHIFT+P (Google Photos).

-- ==============================================================================
-- Applications
-- ==============================================================================

o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })
o.bind("SUPER + SHIFT + R", "Retrain DP-2 link (fix blocky red text)", os.getenv("HOME") .. "/.local/bin/dp-retrain")

-- Obsidian needs the GPU disabled and Wayland IME enabled.
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian -disable-gpu --enable-wayland-ime", focus = "^obsidian$" })

-- Typora instead of Omawrite.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })

-- Bitwarden instead of 1Password.
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden" })

-- ==============================================================================
-- Web apps
-- ==============================================================================

-- Claude instead of ChatGPT.
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "Claude", { webapp = "https://claude.ai" })

-- Google Calendar / Gmail instead of HEY.
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Calendar", { webapp = "https://calendar.google.com" })

hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://gmail.google.com" })

-- Gemini instead of Signal.
hl.unbind("SUPER + SHIFT + G")
o.bind("SUPER + SHIFT + G", "Gemini", { webapp = "https://gemini.google.com" })

-- ==============================================================================
-- Tiling
-- ==============================================================================

-- Promote the focused slave to master (SUPER+SHIFT+RETURN defaults to Browser,
-- which is already on SUPER+SHIFT+B).
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + RETURN", "Promote Slave", hl.dsp.layout("swapwithmaster"))

-- Cycle workspace layout through master (default) -> dwindle -> scrolling.
-- Overrides the stock toggle, which only flips dwindle <-> scrolling and can
-- never return to master.
hl.unbind("SUPER + L")
o.bind("SUPER + L", "Cycle workspace layout", os.getenv("HOME") .. "/.local/bin/hypr-workspace-layout-cycle")

-- ==============================================================================
-- Numpad workspaces 1-9 (by keycode, so numlock state doesn't matter)
-- ==============================================================================

local numpad_keycodes = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }

for workspace, keycode in ipairs(numpad_keycodes) do
  local key = "code:" .. tostring(keycode)
  o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
end
