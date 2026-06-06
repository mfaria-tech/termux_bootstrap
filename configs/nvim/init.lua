vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.wrap = false
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 400

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Salvar arquivo" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Fechar janela" })
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Limpar busca" })
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Abrir explorador" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Destaca texto copiado",
  callback = function()
    vim.highlight.on_yank()
  end,
})
