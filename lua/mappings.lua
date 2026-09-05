local map = vim.keymap.set

local function with_plugin(name, fn)
  local ok, err = pcall(function()
    pcall(vim.cmd.packadd, name)
    fn()
  end)
  if not ok then
    vim.schedule(function()
      vim.notify(("Plugin setup failed for %s: %s"):format(name, err), vim.log.levels.ERROR)
    end)
  end
end

local function terminal_size(direction)
  if direction == "vertical" then
    return math.floor(vim.o.columns * 0.3)
  end
  return math.max(8, math.floor(vim.o.lines * 0.25))
end

local function nmap(lhs, rhs, desc, opts)
  map("n", lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
end

local function imap(lhs, rhs, desc, opts)
  map("i", lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
end

local function tmap(lhs, rhs, desc, opts)
  map("t", lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
end

local function close_current_buffer()
  local current = vim.api.nvim_get_current_buf()
  local last = vim.fn.bufnr("$")
  local next_buf

  for offset = 1, last do
    local candidate = ((current + offset - 1) % last) + 1
    if candidate ~= current and vim.api.nvim_buf_is_valid(candidate) then
      local buffer = vim.bo[candidate]
      if buffer.buflisted and buffer.buftype == "" and buffer.filetype ~= "NvimTree" then
        next_buf = candidate
        break
      end
    end
  end

  if next_buf then
    vim.api.nvim_win_set_buf(0, next_buf)
    vim.cmd({ cmd = "bdelete", args = { tostring(current) } })
  else
    vim.cmd.bdelete()
  end
end

imap("<C-h>", "<Left>", "Cursor left")
imap("<C-j>", "<Down>", "Cursor down")
imap("<C-k>", "<Up>", "Cursor up")
imap("<C-l>", "<Right>", "Cursor right")
imap("jk", "<Esc>", "Exit insert mode")


nmap("<Esc>", "<cmd>nohlsearch<CR>", "Clear highlights")
nmap(";", ":", "Command mode")
nmap("<C-s>", "<cmd>w<CR>", "Save file")
nmap("<Tab>", "<cmd>bnext<cr>", "Next buffer")
nmap("<S-Tab>", "<cmd>bprev<cr>", "Prev buffer")
nmap("<leader>bd", close_current_buffer, "Close current buffer")
nmap("<C-d>", "<C-d>zz", "Scroll down and center")
nmap("<C-u>", "<C-u>zz", "Scroll up and center")
nmap("<C-Left>", "5<C-w><", "Decrease window width")
nmap("<C-Right>", "5<C-w>>", "Increase window width")
nmap("<C-Up>", "5<C-w>+", "Increase window height")
nmap("<C-Down>", "5<C-w>-", "Decrease window height")

nmap("<C-c>", function()
  vim.cmd("%y")
  print("File copied to +register")
end, "Copy whole file to clipboard")

-- Open URLs in the Hyprland dropdown browser; keep normal system handling for files.
local function open_popup_browser()
  local target = vim.fn.expand("<cfile>")

  -- Go imports are documentation targets rather than filesystem paths.
  if vim.bo.filetype == "go" then
    target = target:gsub('^[%[%(\"`]+', ""):gsub('[%]%)\"`;:,]+$', "")
    if target:match("^[%w][%w%._-]*/") then
      target = "https://pkg.go.dev/" .. target
    end
  end

  if not target:match("^https?://") then
    vim.ui.open(target)
    return
  end

  vim.fn.jobstart({ "bash", vim.fn.expand("~/.config/hypr/scripts/PopupBrowser.sh"), target }, { detach = true })
end

local function open_hover_link()
  local line = vim.api.nvim_get_current_line()
  local target = line:match("%]%((https?://[^)%s]+)%)")
  if not target then
    target = vim.fn.expand("<cfile>")
  end
  if not target:match("^https?://") then
    return
  end

  target = target:gsub("[.,;:!?]+$", "")
  vim.fn.jobstart({ "bash", vim.fn.expand("~/.config/hypr/scripts/PopupBrowser.sh"), target }, { detach = true })
end

nmap("gx", open_popup_browser, "Open URL in dropdown browser")
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("hover-link-mapping", { clear = true }),
  callback = function(args)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        local buffer = vim.bo[args.buf]
        if buffer.buftype == "nofile" and buffer.filetype == "markdown" then
          vim.keymap.set("n", "gx", open_hover_link, { buffer = args.buf, desc = "Open hover documentation link" })
        end
      end
    end)
  end,
})
nmap("<A-b>", function()
  vim.fn.jobstart({ "bash", vim.fn.expand("~/.config/hypr/scripts/PopupBrowser.sh") }, { detach = true })
end, "Toggle dropdown browser")

nmap("<leader>fm", function()
  require("conform").format({ stop_after_first = true, lsp_format = "fallback" })
end, "Format buffer")

nmap("<C-h>", "<C-w>h", "Move to left window")
nmap("<C-j>", "<C-w>j", "Move to bottom window")
nmap("<C-k>", "<C-w>k", "Move to top window")
nmap("<C-l>", "<C-w>l", "Move to right window")

tmap("<C-h>", "<C-\\><C-n><C-w>h", "Move to left window")
tmap("<C-j>", "<C-\\><C-n><C-w>j", "Move to bottom window")
tmap("<C-k>", "<C-\\><C-n><C-w>k", "Move to top window")
tmap("<C-l>", "<C-\\><C-n><C-w>l", "Move to right window")

with_plugin("zen-mode.nvim", function()
  nmap("<leader>z", "<cmd>ZenMode<cr>", "Toggle zen mode")
end)

with_plugin("trouble.nvim", function()
  nmap("<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Trouble diagnostics")
  nmap("<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Trouble buffer diagnostics")
  nmap("<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", "Trouble symbols")
  nmap("<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "Trouble LSP")
  nmap("<leader>xL", "<cmd>Trouble loclist toggle<cr>", "Trouble location list")
  nmap("<leader>xQ", "<cmd>Trouble qflist toggle<cr>", "Trouble quickfix list")
end)

with_plugin("nvim-tree.lua", function()
  nmap("<C-n>", "<cmd>NvimTreeToggle<cr>", "Toggle file tree")
end)

with_plugin("supermaven-nvim", function()
  local api = require("supermaven-nvim.api")
  local function safe_nmap(lhs, rhs, desc)
    if vim.fn.maparg(lhs, "n") == "" then
      nmap(lhs, rhs, desc)
    end
  end
  local function safe_imap(lhs, rhs, desc)
    if vim.fn.maparg(lhs, "i") == "" then
      imap(lhs, rhs, desc)
    end
  end

  safe_nmap("<leader>sm", api.toggle, "Toggle Supermaven")
  safe_nmap("<leader>sM", api.restart, "Restart Supermaven")
  safe_nmap("<leader>ss", function()
    vim.notify("Supermaven is " .. (api.is_running() and "running" or "stopped"))
  end, "Supermaven status")

  local completion_preview = require("supermaven-nvim.completion_preview")
  safe_imap("<A-l>", completion_preview.on_accept_suggestion, "Accept Supermaven suggestion")
  safe_imap("<A-j>", completion_preview.on_accept_suggestion_word, "Accept Supermaven word")
  safe_imap("<A-h>", completion_preview.on_dispose_inlay, "Clear Supermaven suggestion")
  safe_imap("<A-k>", completion_preview.on_dispose_inlay, "Reroll Supermaven suggestion")
end)


with_plugin("oil.nvim", function()
  nmap("<leader>o", "<cmd>Oil<cr>", "Open oil explorer")
end)

with_plugin("telescope.nvim", function()
  local builtin = require("telescope.builtin")

  nmap("<leader>ff", builtin.find_files, "Find files")
  nmap("<leader>fr", builtin.oldfiles, "Find recent files")
  nmap("<leader>fg", builtin.live_grep, "Live grep")
  nmap("<leader>fw", builtin.grep_string, "Find word under cursor")
  nmap("<leader>fb", builtin.buffers, "Find buffers")
  nmap("<leader>fh", builtin.help_tags, "Find help tags")
  nmap("<leader>fk", builtin.keymaps, "Find keymaps")
  nmap("<leader>fd", builtin.diagnostics, "Find diagnostics")
  nmap("<leader>fc", builtin.current_buffer_fuzzy_find, "Find in current buffer")
  nmap("gd", vim.lsp.buf.definition, "Goto definition")
  nmap("gD", vim.lsp.buf.declaration, "Goto declaration")

  nmap("<leader>gc", builtin.git_commits, "Git commits")
  nmap("<leader>gC", builtin.git_bcommits, "Buffer commits")
  nmap("<leader>gs", builtin.git_status, "Git status")
  nmap("<leader>gb", builtin.git_branches, "Git branches")
end)

with_plugin("lspsaga.nvim", function()
  nmap("<leader>lh", "<cmd>Lspsaga hover_doc<cr>", "Hover documentation")
  nmap("<leader>lf", "<cmd>Lspsaga finder<cr>", "LSP finder")
  nmap("<leader>lD", "<cmd>Lspsaga peek_definition<cr>", "Peek definition")
  nmap("<leader>ld", "<cmd>Lspsaga goto_definition<cr>", "Lspsaga definition")
  nmap("<leader>lP", "<cmd>Lspsaga peek_type_definition<cr>", "Peek type definition")
  nmap("<leader>lt", "<cmd>Lspsaga goto_type_definition<cr>", "Goto type definition")
  nmap("<leader>ca", "<cmd>Lspsaga code_action<cr>", "LSP code action")
  nmap("<leader>cr", "<cmd>Lspsaga rename<cr>", "LSP rename")
  nmap("<leader>cR", "<cmd>Lspsaga project_replace<cr>", "Project-wide rename")
  nmap("<leader>cd", "<cmd>Lspsaga show_line_diagnostics<cr>", "Show line diagnostics")
  nmap("<leader>lW", "<cmd>Lspsaga show_workspace_diagnostics<cr>", "Workspace diagnostics")
  nmap("<leader>lB", "<cmd>Lspsaga show_buf_diagnostics<cr>", "Buffer diagnostics")
  nmap("<leader>lC", "<cmd>Lspsaga show_cursor_diagnostics<cr>", "Cursor diagnostics")
  nmap("[e", "<cmd>Lspsaga diagnostic_jump_prev<cr>", "Previous diagnostic")
  nmap("]e", "<cmd>Lspsaga diagnostic_jump_next<cr>", "Next diagnostic")
  nmap("<leader>ci", "<cmd>Lspsaga incoming_calls<cr>", "Incoming calls")
  nmap("<leader>co", "<cmd>Lspsaga outgoing_calls<cr>", "Outgoing calls")
  nmap("<leader>lS", "<cmd>Lspsaga supertypes<cr>", "Supertypes")
  nmap("<leader>lU", "<cmd>Lspsaga subtypes<cr>", "Subtypes")
  nmap("<leader>so", "<cmd>Lspsaga outline<cr>", "LSP outline")
  nmap("<leader>lz", "<cmd>Lspsaga term_toggle<cr>", "Toggle Lspsaga terminal")
  nmap("<leader>ll", "<cmd>Lspsaga open_log<cr>", "Open Lspsaga log")
  nmap("<leader>lw", "<cmd>Lspsaga winbar_toggle<cr>", "Toggle Lspsaga winbar")
end)

with_plugin("toggleterm.nvim", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local terms = {
    lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true }),
    float = Terminal:new({ direction = "float", hidden = true }),
    vert = Terminal:new({ direction = "vertical", hidden = true }),
    horiz = Terminal:new({
      direction = "horizontal",
      size = terminal_size("horizontal"),
      hidden = true,
    }),
  }

  local function toggle_exclusive(target)
    for key, term in pairs(terms) do
      if key ~= target then
        term:close()
      end
    end

    terms[target]:toggle()
  end

  nmap("<leader>lg", function()
    toggle_exclusive("lazygit")
  end, "Toggle lazygit")
  map({ "n", "t" }, "<A-i>", function()
    toggle_exclusive("float")
  end, { desc = "Toggle floating terminal" })
  map({ "n", "t" }, "<A-v>", function()
    toggle_exclusive("vert")
  end, { desc = "Toggle vertical terminal" })
  map({ "n", "t" }, "<A-h>", function()
    toggle_exclusive("horiz")
  end, { desc = "Toggle horizontal terminal" })
end)

with_plugin("nvim-dap", function()
  local dap = require("dap")
  local dapui = require("dapui")

  nmap("<F5>", dap.continue, "Debug continue")
  nmap("<F6>", dap.terminate, "Debug terminate")
  nmap("<F10>", dap.step_over, "Debug step over")
  nmap("<F11>", dap.step_into, "Debug step into")
  nmap("<F12>", dap.step_out, "Debug step out")
  nmap("<leader>b", dap.toggle_breakpoint, "Toggle breakpoint")
  nmap("<leader>du", dapui.toggle, "Toggle debug UI")
  nmap("<leader>dr", dap.repl.open, "Open debug REPL")
  nmap("<leader>dl", dap.run_last, "Run last debug config")
  map({ "n", "v" }, "<leader>dh", dapui.eval, { desc = "Evaluate expression" })
  nmap("<leader>B", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, "Set conditional breakpoint")
  nmap("<leader>lp", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
  end, "Set log point")
end)
