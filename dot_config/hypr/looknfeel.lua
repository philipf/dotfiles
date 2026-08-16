-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- Tight gaps between windows, none against the screen edge.
    gaps_in = 3,
    gaps_out = 0,

    -- Use master layout instead of dwindle.
    layout = "master",
  },

  -- https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
  master = {
    -- Keep the master window centered with slaves on either side.
    orientation = "center",
    slave_count_for_center_master = 0,
    mfact = 0.44,
  },
})
