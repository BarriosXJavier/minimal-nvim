local function notify(name, err, level)
  vim.schedule(function()
    vim.notify(("Plugin setup failed for %s: %s"):format(name, err), level or vim.log.levels.ERROR)
  end)
end

local function packadd(name)
  pcall(vim.cmd.packadd, name)
end

local function with_plugin(name, fn)
  local ok, result = pcall(function()
    packadd(name)
    return fn()
  end)
  if not ok then
    notify(name, result)
  end
  return result
end

local function setup(name, module, opts)
  with_plugin(name, function()
    require(module).setup(opts or {})
  end)
end

local function terminal_size(direction)
  if direction == "vertical" then
    return math.floor(vim.o.columns * 0.3)
  end
  return math.max(8, math.floor(vim.o.lines * 0.25))
end

local prettier = { "prettierd", "prettier" }
local formatters_by_ft = {
  lua = { "stylua" },
  rust = { "rustfmt" },
  go = { "gofmt" },
  python = { "black" },
  c = { "clang-format" },
  cpp = { "clang-format" },
  sql = { "sleek" },
  javascript = prettier,
  typescript = prettier,
  javascriptreact = prettier,
  typescriptreact = prettier,
  html = prettier,
  css = prettier,
  scss = prettier,
  json = prettier,
  yaml = prettier,
  markdown = prettier,
  vue = prettier,
}

local languages = {
  treesitter_filetypes = {
    "c", "cpp", "go", "javascript", "lua", "markdown", "python", "rust", "typescript",
    "zig", "odin", "php",
  },
  formatters_by_ft = formatters_by_ft,
  lsp_servers = {
    rust_analyzer = {},
    vtsls = { filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" } },
    emmet_language_server = {},
    tailwindcss = {},
    html = {},
    cssls = { filetypes = { "css", "scss", "less" } },
    pyright = {},
    clangd = { filetypes = { "c", "cpp", "objc", "objcpp" } },
    gopls = { filetypes = { "go", "gomod" } },
    zls = {},
    lua_ls = { cmd = { "lua-language-server" }, filetypes = { "lua" } },
    bashls = { cmd = { "bash-language-server" }, filetypes = { "sh", "zsh" } },
    marksman = { filetypes = { "markdown" } },
    sqls = { cmd = { "sqls" } },
    prisma = {},
    taplo = { filetypes = { "toml" } },
    yamlls = {},
    ols = {},
    laravel_ls = {},
    intelephense = {},
    vue_language_server = {},
  },
}

local specs = {}
for _, src in ipairs({
  "nvim-tree/nvim-web-devicons", "nvim-tree/nvim-tree.lua", "nvim-treesitter/nvim-treesitter",
  "neovim/nvim-lspconfig", "folke/which-key.nvim", "folke/trouble.nvim", "chentoast/marks.nvim",
  "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "blazkowolf/gruber-darker.nvim",
  "windwp/nvim-autopairs", "lewis6991/gitsigns.nvim", "saghen/blink.lib", "saghen/blink.cmp",
  "onsails/lspkind.nvim", "lukas-reineke/indent-blankline.nvim", "akinsho/bufferline.nvim",
  "nvim-lualine/lualine.nvim", "akinsho/toggleterm.nvim", "mfussenegger/nvim-dap",
  "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio", "rachartier/tiny-glimmer.nvim",
  "williamboman/mason.nvim", "stevearc/conform.nvim", "stevearc/oil.nvim", "0x00-ketsu/autosave.nvim",
  "rafamadriz/friendly-snippets", "MeanderingProgrammer/render-markdown.nvim", "folke/zen-mode.nvim",
  "tpope/vim-dadbod", "kristijanhusak/vim-dadbod-ui", "kristijanhusak/vim-dadbod-completion",
  "jtprogru/pack-ui.nvim", "xiyaowong/transparent.nvim.git", "supermaven-inc/supermaven-nvim.git", "obsidian-nvim/obsidian.nvim.git"
}) do
  specs[#specs + 1] = { src = "https://github.com/" .. src }
end

local bootstrap_group = vim.api.nvim_create_augroup("plugin-bootstrap", { clear = true })
local blink_build_task
local function queue_blink_build(force)
  if blink_build_task then return end
  packadd("blink.lib")
  packadd("blink.cmp")
  local ok, cmp = pcall(require, "blink.cmp")
  if not ok or (not force and cmp.library_available()) then return end
  local ok_task, task = pcall(function() return cmp.build({ force = force }) end)
  if not ok_task then
    notify("blink.cmp", task, vim.log.levels.WARN)
    return
  end
  blink_build_task = task
  task:on_resolve(function() blink_build_task = nil end)
  task:on_reject(function(err)
    blink_build_task = nil
    notify("blink.cmp background build", err, vim.log.levels.WARN)
  end)
  task:on_cancel(function() blink_build_task = nil end)
end

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local path = vim.env.PATH or ""
local found = false
for _, segment in ipairs(vim.split(path, ":", { trimempty = true })) do
  found = found or segment == mason_bin
end
if not found then vim.env.PATH = mason_bin .. (path ~= "" and ":" .. path or "") end

vim.api.nvim_create_autocmd("PackChanged", {
  group = bootstrap_group,
  callback = function(ev)
    local data = ev.data
    local name = data.spec.name or vim.fs.basename(data.path)
    if name == "blink.cmp" and (data.kind == "install" or data.kind == "update") then
      vim.schedule(function() queue_blink_build(true) end)
    end
  end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  group = bootstrap_group,
  once = true,
  callback = function() vim.schedule(function() queue_blink_build(false) end) end,
})
vim.pack.add(specs)

setup("mason.nvim", "mason", { install_root_dir = vim.fn.expand("~/.local/share/nvim/mason") })
setup("which-key.nvim", "which-key")
setup("nvim-autopairs", "nvim-autopairs")
setup("gitsigns.nvim", "gitsigns")
setup("marks.nvim", "marks")
setup("conform.nvim", "conform", { formatters_by_ft = formatters_by_ft })
setup("autosave.nvim", "autosave", {
  enabled = true,
  execution_message = "",
  events = { "InsertLeave", "TextChanged" },
  conditions = { exists = true, filename_is_not = {}, filetype_is_not = {}, modifiable = true },
})
packadd("nvim-treesitter")
packadd("friendly-snippets")
with_plugin("supermaven-nvim", function()
  require("supermaven-nvim").setup({ disable_keymaps = true })
end)
setup("obsidian-nvim", "obsidian")
setup("telescope.nvim", "telescope")
setup("trouble.nvim", "trouble", { focus = true })
setup("oil.nvim", "oil")
setup("nvim-tree.lua", "nvim-tree", {
  filters = { custom = { "^\\.git$", ".*\\~$", ".*\\.swp$", ".*\\.swo$" }, exclude = {} },
  update_focused_file = { enable = true, update_root = false },
})

local function blink_kind_icon(ctx)
  if ctx.source_name == "Path" then
    local ok, devicons = pcall(require, "nvim-web-devicons")
    if ok then
      local icon, hl = devicons.get_icon(ctx.label, nil, { default = true })
      if icon then return icon .. ctx.icon_gap, hl end
    end
  end
  local ok, lspkind = pcall(require, "lspkind")
  if ok then return (lspkind.symbol_map[ctx.kind] or ctx.kind_icon) .. ctx.icon_gap, ctx.kind_hl end
  return ctx.kind_icon .. ctx.icon_gap, ctx.kind_hl
end

with_plugin("blink.cmp", function()
  local blink = require("blink.cmp")
  blink.setup({
    keymap = {
      preset = "enter",
      ["<C-k>"] = false,
      ["<CR>"] = { "select_and_accept", "fallback" },
      ["<Tab>"] = { function(cmp)
        if cmp.snippet_active({ direction = 1 }) then
          cmp.snippet_forward(); return true
        end
      end, "select_next", "fallback" },
      ["<S-Tab>"] = { function(cmp)
        if cmp.snippet_active({ direction = -1 }) then
          cmp.snippet_backward(); return true
        end
      end, "select_prev", "fallback" }
    },
    cmdline = { enabled = true },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "none", direction_priority = { menu_north = { "e", "w" }, menu_south = { "e", "w" } } } },
      list = { selection = { auto_insert = true } },
      menu = {
        auto_show = true,
        border = "none",
        direction_priority = { "s", "n" },
        draw = {
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(
                  ctx)
                return blink_kind_icon(ctx)
              end,
              highlight = function(ctx)
                local _, hl = blink_kind_icon(ctx); return hl
              end
            }
          }
        }
      }
    },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    fuzzy = { implementation = "prefer_rust" },
    snippets = { preset = "default", expand = function(snippet) vim.snippet.expand(snippet) end },
    signature = { enabled = true, window = { show_documentation = true, border = "none" } },
  })
end)

setup("toggleterm.nvim", "toggleterm",
  {
    open_mapping = false,
    direction = "float",
    shade_terminals = false,
    persist_size = false,
    size = function(term)
      return
          terminal_size(term.direction)
    end
  })
setup("tiny-glimmer.nvim", "tiny-glimmer")
setup("render-markdown.nvim", "render-markdown")
setup("indent-blankline.nvim", "ibl",
  { indent = { char = "│" }, scope = { enabled = true, show_start = false, show_end = false }, exclude = { filetypes = { "help", "dashboard", "neo-tree", "NvimTree", "Trouble", "lazy", "toggleterm" } } })
setup("bufferline.nvim", "bufferline",
  { options = { offsets = { { filetype = "NvimTree", text = "NvimTree", highlight = "Directory", separator = true } } } })
setup("lualine.nvim", "lualine", {
  options = { icons_enabled = true, theme = "auto", component_separators = { left = "│", right = "│" }, section_separators = { left = "", right = "" }, globalstatus = true, refresh = { statusline = 1000, tabline = 1000, winbar = 1000 }, disabled_filetypes = { statusline = { "alpha", "dashboard", "oil", "neo-tree", "NvimTree", "toggleterm", "terminal", "Trouble", "lazy" } } },
  extensions = { "nvim-tree" },
  sections = {
    lualine_a = { { "mode", padding = { left = 1, right = 1 }, color = { gui = "bold" } } },
    lualine_b = { { "branch", icon = "󰘬" }, "diff", "diagnostics" },
    lualine_c = { { "filename", path = 1, symbols = { modified = " [+]", readonly = " [RO]", unnamed = "[No Name]", newfile = "[New]" } } },
    lualine_x = { {
      function()
        local clients = vim.lsp.get_clients({ bufnr = 0 }); if #clients == 0 then return "" end; if #clients == 1 then
          return
              clients[1].name
        end; return ("%s +%d"):format(clients[1].name, #clients - 1)
      end,
      color = { gui = "bold" }
    }, "filetype", "encoding", "fileformat" },
    lualine_y = { { "progress", padding = { left = 1, right = 1 } } }
  },
})
packadd("gruber-darker.nvim")
pcall(vim.cmd.colorscheme, "gruber-darker")
setup("transparent.nvim", "transparent",
  { extra_groups = { "BlinkCmpMenu", "BlinkCmpMenuBorder", "BlinkCmpDoc", "BlinkCmpDocBorder", "BlinkCmpSignatureHelp", "BlinkCmpSignatureHelpBorder", "WhichKey", "WhichKeyBorder", "WhichKeyNormal", "WhichKeyFloat" } })

return languages
