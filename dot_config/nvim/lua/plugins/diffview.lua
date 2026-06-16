return {
  {
    "sindrets/diffview.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },

    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    opts = {
      view = {
        merge_tool = {
          layout = "diff3_horizontal",
        },
      },
    },

    keys = {
      {
        "<leader>gd",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Toggle Diffview window",
      },
    },
  },
}
