local map = vim.keymap.set

map("i", "<C-h>", "<Left>", { desc = "Cursor left" })
map("i", "<C-j>", "<Down>", { desc = "Cursor down" })
map("i", "<C-k>", "<Up>", { desc = "Cursor up" })
map("i", "<C-l>", "<Right>", { desc = "Cursor right" })
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

map("n", ";", ":", { desc = "Command mode" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })

map("n", "<leader>fm", function()
	require("conform").format({ stop_after_first = true, lsp_fallback = true })
end, { desc = "Format buffer" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble diagnostics" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Trouble buffer diagnostics" })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Trouble symbols" })
map("n", "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "Trouble LSP" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Trouble location list" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Trouble quickfix list" })

map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
map("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
map("n", "<leader>o", "<cmd>Oil<cr>", { desc = "Open oil explorer" })
map("n", "<leader>x", "<cmd>bd<cr>", { desc = "Close buffer" })

map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprev<cr>", { desc = "Prev buffer" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

map("n", "<C-Left>", "5<C-w><", { desc = "Decrease window width" })
map("n", "<C-Right>", "5<C-w>>", { desc = "Increase window width" })
map("n", "<C-Up>", "5<C-w>+", { desc = "Increase window height" })
map("n", "<C-Down>", "5<C-w>-", { desc = "Decrease window height" })

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

local Terminal = require("toggleterm.terminal").Terminal
local lazygit_term = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
local float_term = Terminal:new({ direction = "float", hidden = true })
local vert_term = Terminal:new({ direction = "vertical", hidden = true })
local horiz_term = Terminal:new({
	direction = "horizontal",
	size = math.max(8, math.floor(vim.o.lines * 0.25)),
	hidden = true,
})

local function close_terms(terms)
	for _, term in ipairs(terms) do
		term:close()
	end
end

local function toggle_exclusive(term, others)
	close_terms(others)
	term:toggle()
end

map("n", "<leader>lg", function()
	toggle_exclusive(lazygit_term, { float_term, vert_term, horiz_term })
end, { desc = "Toggle lazygit" })
map("n", "<A-i>", function()
	toggle_exclusive(float_term, { lazygit_term, vert_term, horiz_term })
end, { desc = "Toggle floating terminal" })
map("n", "<A-v>", function()
	toggle_exclusive(vert_term, { lazygit_term, float_term, horiz_term })
end, { desc = "Toggle vertical terminal" })
map("n", "<A-h>", function()
	toggle_exclusive(horiz_term, { lazygit_term, float_term, vert_term })
end, { desc = "Toggle horizontal terminal" })
map("t", "<A-i>", function()
	toggle_exclusive(float_term, { lazygit_term, vert_term, horiz_term })
end, { desc = "Toggle floating terminal" })
map("t", "<A-v>", function()
	toggle_exclusive(vert_term, { lazygit_term, float_term, horiz_term })
end, { desc = "Toggle vertical terminal" })
map("t", "<A-h>", function()
	toggle_exclusive(horiz_term, { lazygit_term, float_term, vert_term })
end, { desc = "Toggle horizontal terminal" })

local dap = require("dap")
local dapui = require("dapui")
map("n", "<F5>", function()
	dap.continue()
end, { desc = "Debug continue" })
map("n", "<F10>", function()
	dap.step_over()
end, { desc = "Debug step over" })
map("n", "<F11>", function()
	dap.step_into()
end, { desc = "Debug step into" })
map("n", "<F12>", function()
	dap.step_out()
end, { desc = "Debug step out" })
map("n", "<leader>b", function()
	dap.toggle_breakpoint()
end, { desc = "Toggle breakpoint" })
map("n", "<leader>B", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Set conditional breakpoint" })
map("n", "<leader>lp", function()
	dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "Set log point" })
map("n", "<leader>dr", function()
	dap.repl.open()
end, { desc = "Open debug REPL" })
map("n", "<leader>dl", function()
	dap.run_last()
end, { desc = "Run last debug config" })
map({ "n", "v" }, "<leader>dh", function()
	dapui.eval()
end, { desc = "Evaluate expression" })
