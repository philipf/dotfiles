-- File: ~/.config/nvim/lua/plugins/formatting.lua

return {
  -- 1. Modify the conform.nvim plugin specification
  {
    "stevearc/conform.nvim",
    -- The 'opts' table is what LazyVim merges with the default config.
    -- You do NOT need the opts = function() wrapper shown in the documentation.
    opts = {
      -- Add 'yamlfix' to the list of formatters for the 'yaml' filetype.
      -- LazyVim's defaults will still be applied to other filetypes (like lua, sh, etc.).
      formatters_by_ft = {
        yaml = { "yamlfix" },
      },
    },
  },

  -- 2. Add mason-conform.nvim to automatically install the formatter
  {
    "zapling/mason-conform.nvim",
    -- This ensures it loads after the dependencies it needs
    dependencies = { "mason-org/mason.nvim", "stevearc/conform.nvim" },
    config = function()
      -- This tells mason-conform to look at the formatters defined in conform.nvim's setup
      require("mason-conform").setup()
    end,
  },
}
