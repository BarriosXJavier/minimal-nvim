local util = require("util")

local M = {}

function M.setup()
  util.setup_module("toggleterm.nvim", "toggleterm", {
    open_mapping = false,
    direction = "float",
    shade_terminals = false,
    persist_size = false,
    size = function(term)
      return util.terminal_size(term.direction)
    end,
  })
end

return M
