local languages = require("languages")
local util = require("util")

local M = {}

function M.setup()
  util.setup_module("which-key.nvim", "which-key")
  util.setup_module("nvim-autopairs", "nvim-autopairs")
  util.setup_module("gitsigns.nvim", "gitsigns")
  util.setup_module("marks.nvim", "marks")
  util.setup_module("conform.nvim", "conform", {
    formatters_by_ft = languages.formatters_by_ft,
  })
  util.setup_module("autosave.nvim", "autosave", {
    enabled = true,
    execution_message = "",
    events = { "InsertLeave", "TextChanged" },
    conditions = {
      exists = true,
      filename_is_not = {},
      filetype_is_not = {},
      modifiable = true,
    },
  })

  util.packadd("nvim-treesitter")
  util.packadd("friendly-snippets")
end

return M
