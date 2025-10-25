return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    image = {
      -- This is the new 'resolve' function you want to add
      resolve = function(path, src)
        if require("obsidian.api").path_is_note(path) then
          return require("obsidian.api").resolve_image_path(src)
        end
        -- It's often good practice to return nil or the original src
        -- if your custom logic doesn't apply, although the plugin might handle this.
        -- For this specific obsidian integration, the provided function is usually sufficient.
      end,
    },
  },
}
