-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.swapfile = false

-- For Oil
vim.keymap.set("n", "<C-`>", function()
  -- vim.keymap.set("n", "<space>st", function()
  vim.cmd.new()
  vim.cmd.term()
  -- vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 15)

  -- Check if the current buffer is a terminal before switching modes
  if vim.bo.buftype == "terminal" then
    vim.cmd.startinsert()
  end
end)

require("mason").setup({
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry",
  },

  ensure_installed = {
    "roslyn",
    "rzls",

    -- "html-lsp",
    -- "css-lsp",
    -- "typescript-language-server",
    -- "json-lsp",
    --
    -- "xmlformatter",
    -- "csharpier",
    -- "prettier",
  },
})

require("neotest").setup({
  adapters = {
    require("neotest-dotnet"),
  },
})
