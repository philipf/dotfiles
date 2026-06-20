-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.diagnostic.enable(false, { bufnr = args.buf })
  end,
})

-- In the gitsigns blame panel (<leader>ghB), jump between commit blocks.
-- Block-start lines begin with ┍ (multi-line commit) or ╺ (single-line commit).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitsigns-blame",
  callback = function(args)
    local pat = [[\v^(┍|╺)]]
    vim.keymap.set("n", "]c", function()
      vim.fn.search(pat, "W")
    end, { buffer = args.buf, desc = "Next commit block" })
    vim.keymap.set("n", "[c", function()
      vim.fn.search(pat, "bW")
    end, { buffer = args.buf, desc = "Prev commit block" })
  end,
})
