return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" }, -- if you use standalone mini plugins
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      heading = {
        width = "block",
        left_pad = 2,
        right_pad = 4,
      },
    },
    config = function()
      require("render-markdown").setup({
        completions = { lsp = { enabled = true } },
      })
    end,
  },
}
