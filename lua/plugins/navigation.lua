local util = require("util")

local M = {}

function M.setup()
  util.setup_module("telescope.nvim", "telescope")
  util.setup_module("trouble.nvim", "trouble", { focus = true })
  util.setup_module("oil.nvim", "oil")
  util.setup_module("nvim-tree.lua", "nvim-tree", {
    filters = {
      custom = {
        "^\\.git$",
        ".*\\~$",
        ".*\\.swp$",
        ".*\\.swo$",
      },
      exclude = {},
    },
    update_focused_file = {
      enable = true,
      update_root = false,
    },

  })
end

return M
