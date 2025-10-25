return {
  -- Harpoon 2 Installation
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  -- Harpoon Configuration and Keymaps
  config = function()
    local harpoon = require("harpoon")
    local harpoon_extensions = require("harpoon.extensions")

    -- REQUIRED: Setup Harpoon
    harpoon:setup({
      -- Optional: Configure settings if needed. Here are the defaults:
      settings = {
        --   save_on_toggle = false,
        --   sync_on_ui_close = false,
        --   save_on_change = true,
      },
    })

    -- Builtin Extension: Highlight the currently active file in the quick menu
    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

    -- Define Keymaps

    -- The keymaps use a `<leader>m` (for 'mark') prefix instead of the default
    -- `<leader>a` and control keys to better integrate with LazyVim conventions.

    -- Add the current file to the harpoon list
    vim.keymap.set("n", "hg", function()
      harpoon:list():add()
    end, { desc = "Harpoon: Add File" })

    -- Toggle the quick menu/UI
    -- Using `<leader>me` (for 'menu') instead of `<C-e>` to avoid conflicts
    vim.keymap.set("n", "he", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon: Toggle Quick Menu" })

    -- Navigate to the first 4 files
    -- Using `<leader>m1`, `<leader>m2`, etc. as a common convention for numbered jumps
    vim.keymap.set("n", "ha", function()
      harpoon:list():select(1)
    end, { desc = "Harpoon: Go to File 1" })
    vim.keymap.set("n", "hs", function()
      harpoon:list():select(2)
    end, { desc = "Harpoon: Go to File 2" })
    vim.keymap.set("n", "hd", function()
      harpoon:list():select(3)
    end, { desc = "Harpoon: Go to File 3" })
    vim.keymap.set("n", "hf", function()
      harpoon:list():select(4)
    end, { desc = "Harpoon: Go to File 4" })

    -- Toggle previous & next buffers
    -- Using `<leader>mp` and `<leader>mn`
    --   vim.keymap.set("n", "<leader>mp", function()
    --     harpoon:list():prev()
    --   end, { desc = "Harpoon: Previous File" })
    --   vim.keymap.set("n", "<leader>hn", function()
    --     harpoon:list():next()
    --   end, { desc = "Harpoon: Next File" })
  end,
}
