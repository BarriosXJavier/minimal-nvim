local function notify_plugin_error(name, err)
	vim.schedule(function()
		vim.notify(("Plugin setup failed for %s: %s"):format(name, err), vim.log.levels.ERROR)
	end)
end

local function with_plugin(name, setup)
	local ok, err = pcall(setup)
	if not ok then
		notify_plugin_error(name, err)
	end
end

local function packadd(name)
	pcall(vim.cmd.packadd, name)
end

local function add_repo(src)
	local ok, err = pcall(vim.pack.add, { { src = src } })
	if not ok then
		notify_plugin_error(src, err)
	end
end

local function setup_module(package_name, module_name, opts)
	with_plugin(package_name, function()
		if package_name then
			packadd(package_name)
		end

		local ok, module = pcall(require, module_name)
		if not ok then
			error(module)
		end

		if type(module.setup) ~= "function" then
			error(("module %s has no setup()"):format(module_name))
		end

		module.setup(opts or {})
	end)
end

add_repo("https://github.com/nvim-tree/nvim-web-devicons")
add_repo("https://github.com/nvim-tree/nvim-tree.lua")
add_repo("https://github.com/nvim-treesitter/nvim-treesitter")
add_repo("https://github.com/neovim/nvim-lspconfig")
add_repo("https://github.com/folke/which-key.nvim")
add_repo("https://github.com/folke/trouble.nvim")
add_repo("https://github.com/chentoast/marks.nvim")
add_repo("https://github.com/nvim-telescope/telescope.nvim")
add_repo("https://github.com/nvim-lua/plenary.nvim")
add_repo("https://github.com/blazkowolf/gruber-darker.nvim")
add_repo("https://github.com/windwp/nvim-autopairs")
add_repo("https://github.com/lewis6991/gitsigns.nvim")
add_repo("https://github.com/saghen/blink.cmp")
add_repo("https://github.com/lukas-reineke/indent-blankline.nvim")
add_repo("https://github.com/akinsho/bufferline.nvim")
add_repo("https://github.com/nvim-lualine/lualine.nvim")
add_repo("https://github.com/akinsho/toggleterm.nvim")
add_repo("https://github.com/mfussenegger/nvim-dap")
add_repo("https://github.com/rcarriga/nvim-dap-ui")
add_repo("https://github.com/nvim-neotest/nvim-nio")
add_repo("https://github.com/rachartier/tiny-glimmer.nvim")
add_repo("https://github.com/williamboman/mason.nvim")
add_repo("https://github.com/stevearc/conform.nvim")
add_repo("https://github.com/stevearc/oil.nvim")
add_repo("https://github.com/0x00-ketsu/autosave.nvim")
add_repo("https://github.com/rafamadriz/friendly-snippets")
add_repo("https://github.com/MeanderingProgrammer/render-markdown.nvim")

setup_module("mason.nvim", "mason", {
	install_root_dir = vim.fn.expand("~/.local/share/nvim/mason"),
})

setup_module("which-key.nvim", "which-key")
setup_module("telescope.nvim", "telescope")
setup_module("nvim-autopairs", "nvim-autopairs")
setup_module("gitsigns.nvim", "gitsigns")
setup_module("trouble.nvim", "trouble")
setup_module("marks.nvim", "marks")

setup_module("conform.nvim", "conform", {
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

setup_module("tiny-glimmer.nvim", "tiny-glimmer")
setup_module("render-markdown.nvim", "render-markdown")
setup_module("autosave.nvim", "autosave", {
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

setup_module("oil.nvim", "oil")
packadd("nvim-treesitter")

setup_module("nvim-tree.lua", "nvim-tree", {
	filters = {
		custom = { "^\\.git$", ".*\\~$", ".*\\.swp$", ".*\\.swo$" },
		exclude = {},
	},
})

packadd("friendly-snippets")
setup_module("blink.cmp", "blink.cmp", {
	keymap = {
		preset = "default",

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

	cmdline = {
		enabled = true,
	},

	completion = {
		menu = {
			auto_show = true,
		},
	},

	sources = {
		default = {
			"lsp",
			"path",
			"snippets",
			"buffer",
		},
	},

	snippets = {
		preset = "default",
	},

	signature = {
		enabled = true,
		window = {
			show_documentation = false,
		},
	},
})

setup_module("indent-blankline.nvim", "ibl", {
	indent = {
		char = "│",
	},
	scope = {
		enabled = true,
		show_start = false,
		show_end = false,
	},
	exclude = {
		filetypes = {
			"help",
			"dashboard",
			"neo-tree",
			"NvimTree",
			"Trouble",
			"lazy",
			"toggleterm",
		},
	},
})

setup_module("toggleterm.nvim", "toggleterm", {
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

setup_module("bufferline.nvim", "bufferline", {
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

setup_module("lualine.nvim", "lualine", {
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
				"oil",
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
