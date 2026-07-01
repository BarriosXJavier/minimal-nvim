local mason_path = vim.fn.expand("~/.local/share/nvim/mason/bin")
vim.env.PATH = mason_path .. ":" .. vim.env.PATH

local opt = vim.opt

vim.g.mapleader = " "
opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.swapfile = false
opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true

opt.splitbelow = true
opt.splitright = true

opt.mouse = "a"

opt.guicursor = "n:block-blinkon0,i:block-blinkwait100-blinkon300-blinkoff200,r:block-blinkon0"
opt.clipboard = "unnamedplus"

opt.updatetime = 250

opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.textwidth = 0

vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
}

vim.cmd.packadd("gruber-darker.nvim")
vim.cmd("colorscheme gruber-darker")
