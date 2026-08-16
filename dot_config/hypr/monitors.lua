-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Both panels run unscaled, so GTK apps should not be scaled either.
hl.env("GDK_SCALE", "1")

-- Samsung G9 ultrawide (via Lenovo hub) on the left, laptop panel to its right.
hl.monitor({ output = "DP-2", mode = "5120x1440@120", position = "0x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "5120x0", scale = 1 })

-- Workspaces 1-8 live on the ultrawide, 9 is dedicated to the laptop panel.
-- persistent keeps them all present (and visible in the bar) while empty.
for workspace = 1, 8 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-2", persistent = true })
end

hl.workspace_rule({
  workspace = "9",
  monitor = "eDP-1",
  persistent = true,
  layout_opts = { orientation = "left" },
})
