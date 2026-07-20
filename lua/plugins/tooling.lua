local util = require("util")

local M = {}

function M.setup()
  util.setup_module("mason.nvim", "mason", {
    install_root_dir = vim.fn.expand("~/.local/share/nvim/mason"),
  })
end

return M
