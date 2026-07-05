local function notify_plugin_error(name, err)
	vim.schedule(function()
		vim.notify(("Plugin setup failed for %s: %s"):format(name, err), vim.log.levels.ERROR)
	end)
end

local function with_plugin(name, fn)
	local ok, err = pcall(fn)
	if not ok then
		notify_plugin_error(name, err)
	end
end

local function packadd(name)
	pcall(vim.cmd.packadd, name)
end

local function add_repo(src)
	with_plugin(src, function()
		vim.pack.add({
			{ src = src },
		})
	end)
end

local function setup_module(package_name, module_name, opts)
	with_plugin(package_name, function()
		if package_name then
			packadd(package_name)
		end

		require(module_name).setup(opts or {})
	end)
end

--------------------------------------------------------------------------------
-- Plugin repositories
--------------------------------------------------------------------------------

local repos = {
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/chentoast/marks.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/blazkowolf/gruber-darker.nvim",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/saghen/blink.cmp",
	"https://github.com/onsails/lspkind.nvim",
	"https://github.com/lukas-reineke/indent-blankline.nvim",
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/akinsho/toggleterm.nvim",
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/nvim-neotest/nvim-nio",
	"https://github.com/rachartier/tiny-glimmer.nvim",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/0x00-ketsu/autosave.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	"https://github.com/folke/zen-mode.nvim",
}

for _, repo in ipairs(repos) do
	add_repo(repo)
end

--------------------------------------------------------------------------------
-- Plugin setup
--------------------------------------------------------------------------------

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

	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
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
		custom = {
			"^\\.git$",
			".*\\~$",
			".*\\.swp$",
			".*\\.swo$",
		},
		exclude = {},
	},
})

packadd("friendly-snippets")

--------------------------------------------------------------------------------
-- blink.cmp helpers
--------------------------------------------------------------------------------

local function blink_kind_icon(ctx)
	if ctx.source_name == "Path" then
		local ok, devicons = pcall(require, "nvim-web-devicons")
		if ok then
			local icon, hl = devicons.get_icon(ctx.label, nil, { default = true })

			if icon then
				return icon .. ctx.icon_gap, hl
			end
		end
	end

	local ok, lspkind = pcall(require, "lspkind")
	if ok then
		return (lspkind.symbol_map[ctx.kind] or ctx.kind_icon) .. ctx.icon_gap, ctx.kind_hl
	end

	return ctx.kind_icon .. ctx.icon_gap, ctx.kind_hl
end

--------------------------------------------------------------------------------
-- blink.cmp
--------------------------------------------------------------------------------

setup_module("blink.cmp", "blink.cmp", {
	keymap = {
		preset = "enter",

		["<CR>"] = {
			"select_and_accept",
			"fallback",
		},

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
		list = {
			selection = {
				auto_insert = true,
			},
		},

		menu = {
			auto_show = true,
			border = "rounded",

			draw = {
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
				},

				components = {
					kind_icon = {
						ellipsis = false,

						text = function(ctx)
							local icon = blink_kind_icon(ctx)
							return icon
						end,

						highlight = function(ctx)
							local _, hl = blink_kind_icon(ctx)
							return hl
						end,
					},
				},
			},
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

		expand = function(snippet)
			vim.snippet.expand(snippet)
		end,
	},

	signature = {
		enabled = true,

		window = {
			show_documentation = true,
			border = "rounded",
		},
	},
})

--------------------------------------------------------------------------------
-- indent-blankline
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- toggleterm
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- bufferline
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- lualine
--------------------------------------------------------------------------------

setup_module("lualine.nvim", "lualine", {
	options = {
		icons_enabled = true,
		theme = "auto",

		component_separators = {
			left = "│",
			right = "│",
		},

		section_separators = {
			left = "",
			right = "",
		},

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

				function()
					local clients = vim.lsp.get_clients({ bufnr = 0 })

					if #clients == 0 then
						return ""
					end

					if #clients == 1 then
						return clients[1].name
					end

					return ("%s +%d"):format(clients[1].name, #clients - 1)
				end,

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

--------------------------------------------------------------------------------
-- Treesitter
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"c",
		"cpp",
		"go",
		"javascript",
		"lua",
		"markdown",
		"python",
		"rust",
		"typescript",
		"zig",
	},

	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
