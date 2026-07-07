local mason_path = vim.fn.expand("~/.local/share/nvim/mason/bin")
vim.env.PATH = string.format("%s:%s", mason_path, vim.env.PATH)

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.swapfile = false
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 15
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.mouse = "a"
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.textwidth = 0
opt.updatetime = 1000
opt.guicursor = "n:block-blinkon0,i:block-blinkwait100-blinkon300-blinkoff200,r:block-blinkon0"
opt.clipboard = "unnamedplus"

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
})

-- Safe-load colorscheme so a missing/updating plugin doesn't crash startup
local ok = pcall(vim.cmd.packadd, "gruber-darker.nvim")
if ok then
   vim.cmd("colorscheme gruber-darker")
end
