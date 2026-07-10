local util = require("util")
local map = vim.keymap.set

local function nmap(lhs, rhs, desc, opts)
    map("n", lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
end

local function imap(lhs, rhs, desc, opts)
    map("i", lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
end

local function tmap(lhs, rhs, desc, opts)
    map("t", lhs, rhs, vim.tbl_extend("force", { desc = desc }, opts or {}))
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
nmap("<C-d>", "<C-d>zz", "Scroll down and center")
nmap("<C-u>", "<C-u>zz", "Scroll up and center")
nmap("<C-Left>", "5<C-w><", "Decrease window width")
nmap("<C-Right>", "5<C-w>>", "Increase window width")
nmap("<C-Up>", "5<C-w>+", "Increase window height")
nmap("<C-Down>", "5<C-w>-", "Decrease window height")
nmap("<leader>e", vim.diagnostic.open_float, "Show diagnostics")

nmap("<C-c>", function()
    vim.cmd("%y")
    print("File copied to +register")
end, "Copy whole file to clipboard")

nmap("<leader>fm", function()
    require("conform").format({ stop_after_first = true, lsp_fallback = true })
end, "Format buffer")

nmap("<C-h>", "<C-w>h", "Move to left window")
nmap("<C-j>", "<C-w>j", "Move to bottom window")
nmap("<C-k>", "<C-w>k", "Move to top window")
nmap("<C-l>", "<C-w>l", "Move to right window")

tmap("<C-h>", "<C-\\><C-n><C-w>h", "Move to left window")
tmap("<C-j>", "<C-\\><C-n><C-w>j", "Move to bottom window")
tmap("<C-k>", "<C-\\><C-n><C-w>k", "Move to top window")
tmap("<C-l>", "<C-\\><C-n><C-w>l", "Move to right window")

util.with_plugin("zen-mode.nvim", function()
    nmap("<leader>z", "<cmd>ZenMode<cr>", "Toggle zen mode")
end)

util.with_plugin("trouble.nvim", function()
    nmap("<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Trouble diagnostics")
    nmap("<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Trouble buffer diagnostics")
    nmap("<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", "Trouble symbols")
    nmap("<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "Trouble LSP")
    nmap("<leader>xL", "<cmd>Trouble loclist toggle<cr>", "Trouble location list")
    nmap("<leader>xQ", "<cmd>Trouble qflist toggle<cr>", "Trouble quickfix list")
end)

util.with_plugin("nvim-tree.lua", function()
    nmap("<C-n>", "<cmd>NvimTreeToggle<cr>", "Toggle file tree")
end)

util.with_plugin("oil.nvim", function()
    nmap("<leader>o", "<cmd>Oil<cr>", "Open oil explorer")
end)

util.with_plugin("telescope.nvim", function()
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
end)

util.with_plugin("toggleterm.nvim", function()
    local Terminal = require("toggleterm.terminal").Terminal
    local terms = {
        lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true }),
        float = Terminal:new({ direction = "float", hidden = true }),
        vert = Terminal:new({ direction = "vertical", hidden = true }),
        horiz = Terminal:new({
            direction = "horizontal",
            size = util.terminal_size("horizontal"),
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

util.with_plugin("nvim-dap", function()
    util.packadd("nvim-dap-ui")

    local dap = require("dap")
    local dapui = require("dapui")

    nmap("<F5>", dap.continue, "Debug continue")
    nmap("<F10>", dap.step_over, "Debug step over")
    nmap("<F11>", dap.step_into, "Debug step into")
    nmap("<F12>", dap.step_out, "Debug step out")
    nmap("<leader>b", dap.toggle_breakpoint, "Toggle breakpoint")
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
