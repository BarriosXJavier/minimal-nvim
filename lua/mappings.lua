local util = require("util")
local map = vim.keymap.set

map("i", "<C-h>", "<Left>", { desc = "Cursor left" })
map("i", "<C-j>", "<Down>", { desc = "Cursor down" })
map("i", "<C-k>", "<Up>", { desc = "Cursor up" })
map("i", "<C-l>", "<Right>", { desc = "Cursor right" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

map("n", "<C-c>", function()
    vim.cmd("%y")
    print("File copied to +register")
end, { desc = "Copy whole file to clipboard" })

map("n", ";", ":", { desc = "Command mode" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Toggle Mode" })

map("n", "<leader>fm", function()
    require("conform").format({ stop_after_first = true, lsp_fallback = true })
end, { desc = "Format buffer" })

map("n", "<leader>e", vim.diagnostic.open_float, {
    desc = "Show diagnostics",
})
-- Trouble
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble diagnostics" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Trouble buffer diagnostics" })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Trouble symbols" })
map("n", "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "Trouble LSP" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Trouble location list" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Trouble quickfix list" })


map("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
map("n", "<leader>o", "<cmd>Oil<cr>", { desc = "Open oil explorer" })

map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprev<cr>", { desc = "Prev buffer" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Window Movements (Normal & Terminal Mode)
map({ "n", "t" }, "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
map({ "n", "t" }, "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to bottom window" })
map({ "n", "t" }, "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to top window" })
map({ "n", "t" }, "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })

map("n", "<C-Left>", "5<C-w><", { desc = "Decrease window width" })
map("n", "<C-Right>", "5<C-w>>", { desc = "Increase window width" })
map("n", "<C-Up>", "5<C-w>+", { desc = "Increase window height" })
map("n", "<C-Down>", "5<C-w>-", { desc = "Decrease window height" })

-- Telescope
util.with_plugin("telescope.nvim", function()
    local telescope = require("telescope.builtin")
    map("n", "<leader>ff", telescope.find_files, { desc = "Find files" })
    map("n", "<leader>fr", telescope.oldfiles, { desc = "Find recent files" })
    map("n", "<leader>fg", telescope.live_grep, { desc = "Live grep" })
    map("n", "<leader>fw", telescope.grep_string, { desc = "Find word under cursor" })
    map("n", "<leader>fb", telescope.buffers, { desc = "Find buffers" })
    map("n", "<leader>fh", telescope.help_tags, { desc = "Find help tags" })
    map("n", "<leader>fk", telescope.keymaps, { desc = "Find keymaps" })
    map("n", "<leader>fd", telescope.diagnostics, { desc = "Find diagnostics" })
    map("n", "<leader>fc", telescope.current_buffer_fuzzy_find, { desc = "Find in current buffer" })
end)

-- Toggleterm
util.with_plugin("toggleterm.nvim", function()
    local Terminal = require("toggleterm.terminal").Terminal
    local terms = {
        lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true }),
        float = Terminal:new({ direction = "float", hidden = true }),
        vert = Terminal:new({ direction = "vertical", hidden = true }),
        horiz = Terminal:new({
            direction = "horizontal",
            size = math.max(8, math.floor(vim.o.lines * 0.25)),
            hidden = true,
        }),
    }

    local function toggle_exclusive(target_key)
        for k, term in pairs(terms) do
            if k ~= target_key then
                term:close()
            end
        end
        terms[target_key]:toggle()
    end

    map("n", "<leader>lg", function()
        toggle_exclusive("lazygit")
    end, { desc = "Toggle lazygit" })
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

-- DAP
util.with_plugin("nvim-dap", function()
    local dap = require("dap")
    local dapui = require("dapui")

    map("n", "<F5>", dap.continue, { desc = "Debug continue" })
    map("n", "<F10>", dap.step_over, { desc = "Debug step over" })
    map("n", "<F11>", dap.step_into, { desc = "Debug step into" })
    map("n", "<F12>", dap.step_out, { desc = "Debug step out" })
    map("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
    map("n", "<leader>dr", dap.repl.open, { desc = "Open debug REPL" })
    map("n", "<leader>dl", dap.run_last, { desc = "Run last debug config" })
    map({ "n", "v" }, "<leader>dh", dapui.eval, { desc = "Evaluate expression" })

    map("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Set conditional breakpoint" })

    map("n", "<leader>lp", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end, { desc = "Set log point" })
end)
