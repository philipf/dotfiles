return {
  {
    "sindrets/diffview.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },

    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
      "DiffviewRefresh",
    },
    opts = {
      view = {
        merge_tool = {
          layout = "diff3_horizontal",
        },
      },
    },

    keys = {
      {
        "<leader>dd",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Toggle Diffview",
      },
      { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
      {
        "<leader>dh",
        function()
          local path
          -- If a Diffview is open, use the file under the cursor (panel or diff window).
          local ok, lib = pcall(require, "diffview.lib")
          if ok then
            local view = lib.get_current_view()
            if view and view.infer_cur_file then
              local entry = view:infer_cur_file()
              if entry and entry.absolute_path then
                path = entry.absolute_path
              end
            end
          end
          -- Otherwise fall back to the current buffer, if it's a real file.
          if not path then
            local file = vim.fn.expand("%:p")
            if file ~= "" and vim.bo.buftype == "" and not file:match("^%a+://") then
              path = file
            end
          end
          if not path then
            vim.notify("No file selected for history", vim.log.levels.WARN)
            return
          end
          vim.cmd("DiffviewFileHistory " .. vim.fn.fnameescape(path))
        end,
        desc = "File History (current/selected file)",
      },
      { "<leader>dH", "<cmd>DiffviewFileHistory<cr>", desc = "File History (repo)" },
      { "<leader>df", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle Files panel" },
      { "<leader>dF", "<cmd>DiffviewFocusFiles<cr>", desc = "Focus Files panel" },
      { "<leader>dr", "<cmd>DiffviewRefresh<cr>", desc = "Refresh Diffview" },
      -- Toggle source highlighting (Treesitter + render-markdown) in the current buffer,
      -- so diff colours stand out without the syntax noise.
      {
        "<leader>uH",
        function()
          local buf = vim.api.nvim_get_current_buf()
          local active = vim.treesitter.highlighter.active[buf] ~= nil
          if active then
            vim.treesitter.stop(buf)
          else
            vim.treesitter.start(buf)
          end
          if vim.bo[buf].filetype == "markdown" then
            pcall(function()
              require("render-markdown").buf_toggle(buf)
            end)
          end
          vim.notify("Treesitter highlight: " .. (active and "off" or "on"))
        end,
        desc = "Toggle source highlighting",
      },
      -- Diff this branch vs the repo's default branch merge-base (PR review).
      {
        "<leader>dm",
        function()
          -- Prefer origin/HEAD; fall back to a local main/master.
          local base = vim.fn.systemlist("git symbolic-ref --short refs/remotes/origin/HEAD")[1]
          if vim.v.shell_error ~= 0 or not base or base == "" then
            base = nil
            for _, b in ipairs({ "main", "master" }) do
              vim.fn.system("git rev-parse --verify " .. b)
              if vim.v.shell_error == 0 then
                base = b
                break
              end
            end
          else
            base = base:gsub("^origin/", "")
          end
          base = base or "main"
          vim.cmd("DiffviewOpen " .. base .. "...HEAD")
        end,
        desc = "Diff branch vs default",
      },
    },
  },

  -- Rename the <leader>d which-key group (was "debug")
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>d", group = "diffview" },
      },
    },
  },
}
