return {
  "catppuccin/nvim",
  --   name = "catppuccin",
  priority = 1000,
  --   opt = {
  --     auto_integrations = true,
  --   },
  --   config = function()
  --     -- Possible values incude: catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
  --     vim.cmd.colorscheme("catppuccin")
  --   end,

  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
