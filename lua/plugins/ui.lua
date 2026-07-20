local util = require("util")

local M = {}

local statusline_ignored_filetypes = {
  "alpha",
  "dashboard",
  "oil",
  "neo-tree",
  "NvimTree",
  "toggleterm",
  "terminal",
  "Trouble",
  "lazy",
}

local sidebar_filetypes = {
  "help",
  "dashboard",
  "neo-tree",
  "NvimTree",
  "Trouble",
  "lazy",
  "toggleterm",
}

local function active_lsp_name()
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  if #clients == 0 then
    return ""
  end

  if #clients == 1 then
    return clients[1].name
  end

  return ("%s +%d"):format(clients[1].name, #clients - 1)
end

function M.setup()
  util.setup_module("tiny-glimmer.nvim", "tiny-glimmer")
  util.setup_module("render-markdown.nvim", "render-markdown")
  util.setup_module("indent-blankline.nvim", "ibl", {
    indent = {
      char = "│",
    },
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
    },
    exclude = {
      filetypes = sidebar_filetypes,
    },
  })
  util.setup_module("bufferline.nvim", "bufferline", {
    options = {
      offsets = {
        {
          filetype = "NvimTree",
          text = "NvimTree",
          highlight = "Directory",
          separator = true,
        },
      },
    },
  })
  util.setup_module("lualine.nvim", "lualine", {
    options = {
      icons_enabled = true,
      theme = "auto",
      component_separators = {
        left = "│",
        right = "│",
      },
      section_separators = {
        left = "",
        right = "",
      },
      globalstatus = true,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      },
      disabled_filetypes = {
        statusline = statusline_ignored_filetypes,
      },
    },
    extensions = {
      "nvim-tree",
    },
    sections = {
      lualine_a = {
        {
          "mode",
          padding = {
            left = 1,
            right = 1,
          },
          color = {
            gui = "bold",
          },
        },
      },
      lualine_b = {
        {
          "branch",
          icon = "󰘬",
        },
        "diff",
        "diagnostics",
      },
      lualine_c = {
        {
          "filename",
          path = 1,
          symbols = {
            modified = " [+]",
            readonly = " [RO]",
            unnamed = "[No Name]",
            newfile = "[New]",
          },
        },
      },
      lualine_x = {
        {
          active_lsp_name,
          color = {
            gui = "bold",
          },
        },
        "filetype",
        "encoding",
        "fileformat",
      },
      lualine_y = {
        {
          "progress",
          padding = {
            left = 1,
            right = 1,
          },
        },
      },
    },
  })

  util.packadd("gruber-darker.nvim")
  pcall(vim.cmd.colorscheme, "gruber-darker")

  util.setup_module("transparent.nvim", "transparent", {
    extra_groups = {
      -- blink.cmp
      "BlinkCmpMenu",
      "BlinkCmpMenuBorder",
      "BlinkCmpDoc",
      "BlinkCmpDocBorder",
      "BlinkCmpSignatureHelp",
      "BlinkCmpSignatureHelpBorder",

      -- which-key
      "WhichKey",
      "WhichKeyBorder",
      "WhichKeyNormal",
      "WhichKeyFloat",
    }
  })
end

return M
