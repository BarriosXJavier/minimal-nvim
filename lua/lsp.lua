vim.cmd.packadd("nvim-lspconfig")

local map = vim.keymap.set

local on_attach = function(client, bufnr)
	if client:supports_method(vim.lsp.protocol.Methods.textDocument_hover) then
		map("n", "K", vim.lsp.buf.hover, {
			buffer = bufnr,
			desc = "hover documentation",
		})
	end
end

local blink_ok, blink = pcall(require, "blink.cmp")
local blink_capabilities = {}

if blink_ok and type(blink.get_lsp_capabilities) == "function" then
	blink_capabilities = blink.get_lsp_capabilities()
end

local capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	blink_capabilities
)

local server_configs = {
	rust_analyzer = { filetypes = { "rust" } },
	vtsls = {
		filetypes = {
			"typescript",
			"javascript",
			"typescriptreact",
			"javascriptreact",
		},
	},
	pyright = { filetypes = { "python" } },
	clangd = { filetypes = { "c", "cpp", "objc", "objcpp" } },
	gopls = { filetypes = { "go", "gomod" } },
	zls = { filetypes = { "zig" } },
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
	},
	bashls = {
		cmd = { "bash-language-server" },
		filetypes = { "sh", "zsh" },
	},
	marksman = { filetypes = { "markdown" } },
}

for server, config in pairs(server_configs) do
	vim.lsp.config[server] = {
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = config.filetypes,
	}

	if config.cmd then
		vim.lsp.config[server].cmd = config.cmd
	end

	vim.lsp.enable(server)
end
