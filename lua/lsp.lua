vim.cmd.packadd("nvim-lspconfig")

local map = vim.keymap.set
local uv = vim.uv or vim.loop

local signature_delay_ms = 500

local on_attach = function(client, bufnr)
	local signature_group = vim.api.nvim_create_augroup("mvim_lsp_signature_" .. bufnr, { clear = true })
	local signature_timer = uv.new_timer()

	local function stop_signature_timer()
		if signature_timer then
			signature_timer:stop()
		end
	end

	local function schedule_signature_help()
		stop_signature_timer()

		signature_timer:start(
			signature_delay_ms,
			0,
			vim.schedule_wrap(function()
				if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
					vim.lsp.buf.signature_help()
				end
			end)
		)
	end

	-- Hover documentation on demand (like VS Code)
	if client:supports_method(vim.lsp.protocol.Methods.textDocument_hover) then
		map("n", "K", vim.lsp.buf.hover, {
			buffer = bufnr,
			desc = "Hover documentation",
		})
	end

	-- Automatic signature help while typing
	if client:supports_method(vim.lsp.protocol.Methods.textDocument_signatureHelp) then
		vim.api.nvim_create_autocmd("CursorHoldI", {
			group = signature_group,
			buffer = bufnr,
			callback = schedule_signature_help,
		})
	end

	vim.api.nvim_create_autocmd({ "CursorMovedI", "InsertLeave", "BufLeave", "WinLeave" }, {
		group = signature_group,
		buffer = bufnr,
		callback = stop_signature_timer,
	})

	vim.api.nvim_create_autocmd("BufWipeout", {
		group = signature_group,
		buffer = bufnr,
		callback = function()
			stop_signature_timer()

			if signature_timer and not signature_timer:is_closing() then
				signature_timer:close()
			end
		end,
	})
end

local capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("blink.cmp").get_lsp_capabilities()
)

local server_configs = {
	rust_analyzer = { filetypes = { "rust" } },
	vtsls = { filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" } },
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
