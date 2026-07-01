vim.pack.add({
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-tree/nvim-tree.lua" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/chentoast/marks.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/blazkowolf/gruber-darker.nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/akinsho/bufferline.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/akinsho/toggleterm.nvim" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/rachartier/tiny-glimmer.nvim" },
	{ src = "https://github.com/williamboman/mason.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/0x00-ketsu/autosave.nvim" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

vim.cmd.packadd("mason.nvim")
require("mason").setup({
	install_root_dir = vim.fn.expand("~/.local/share/nvim/mason"),
})

require("which-key").setup()
require("telescope").setup()
require("nvim-autopairs").setup()
require("gitsigns").setup()

vim.cmd.packadd("trouble.nvim")
require("trouble").setup()

vim.cmd.packadd("marks.nvim")
require("marks").setup()

vim.cmd.packadd("conform.nvim")
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt" },
		go = { "gofmt" },
		python = { "black" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		vue = { "prettierd", "prettier" },
		javascript = { "prettierd", "prettier" },
		typescript = { "prettierd", "prettier" },
		markdown = { "prettierd", "prettier" },
	},
})

vim.cmd.packadd("tiny-glimmer.nvim")
require("tiny-glimmer").setup()

vim.cmd.packadd("render-markdown.nvim")
require("render-markdown").setup()

vim.cmd.packadd("autosave.nvim")
require("autosave").setup({
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

vim.cmd.packadd("oil.nvim")
require("oil").setup()

vim.cmd.packadd("nvim-treesitter")

vim.cmd.packadd("nvim-tree.lua")
require("nvim-tree").setup({
	filters = {
		custom = { "^\\.git$", ".*\\~$", ".*\\.swp$", ".*\\.swo$" },
		exclude = {},
	},
})

vim.cmd.packadd("friendly-snippets")
vim.cmd.packadd("blink.cmp")
require("blink.cmp").setup({
	keymap = {
		preset = "enter",
		["<Tab>"] = {
			function(cmp)
				if cmp.snippet_active({ direction = 1 }) then
					cmp.snippet_forward()
					return true
				end
			end,
			"select_next",
			"fallback",
		},
		["<S-Tab>"] = {
			function(cmp)
				if cmp.snippet_active({ direction = -1 }) then
					cmp.snippet_backward()
					return true
				end
			end,
			"select_prev",
			"fallback",
		},
	},
	snippets = { preset = "default" },
})

vim.cmd.packadd("toggleterm.nvim")
require("toggleterm").setup({
	open_mapping = false,
	direction = "float",
	shade_terminals = false,
	persist_size = false,
	size = function(term)
		if term.direction == "vertical" then
			return math.floor(vim.o.columns * 0.3)
		end
		return math.max(8, math.floor(vim.o.lines * 0.25))
	end,
})

require("bufferline").setup({
	options = {
		offsets = {
			{
				filetype = "NvimTree",
				text = "",
				highlight = "Directory",
				separator = true,
			},
		},
	},
})

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "│", right = "│" },
		section_separators = { left = "", right = "" },
		globalstatus = true,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
		disabled_filetypes = {
			statusline = {
				"alpha",
				"dashboard",
				"neo-tree",
				"NvimTree",
				"toggleterm",
				"terminal",
				"Trouble",
				"lazy",
			},
		},
	},
	extensions = { "nvim-tree" },
	sections = {
		lualine_a = {
			{
				"mode",
				padding = { left = 1, right = 1 },
				color = { gui = "bold" },
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
		lualine_y = {
			{
				"progress",
				padding = { left = 1, right = 1 },
			},
		},
		lualine_x = {
			{
				function()
					local clients = vim.lsp.get_clients({ bufnr = 0 })
					if #clients == 0 then
						return ""
					end
					local names = {}
					for _, client in ipairs(clients) do
						names[#names + 1] = client.name
					end
					local label = table.concat(names, ",")
					if #label > 16 then
						label = label:sub(1, 14) .. ".."
					end
					return label
				end,
				color = { gui = "bold" },
			},
			"filetype",
			"encoding",
			"fileformat",
		},
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "go", "javascript", "lua", "python", "rust", "typescript", "zig", "markdown" },
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
