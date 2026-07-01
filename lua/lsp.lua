vim.cmd.packadd("nvim-lspconfig")

local map = vim.keymap.set

local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
    map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
    map("n", "<leader>d", vim.diagnostic.open_float, opts)
    map("n", "<leader>q", vim.diagnostic.setloclist, opts)
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
    lua_ls = { cmd = { "lua-language-server" }, filetypes = { "lua" } },
    bashls = { cmd = { "bash-language-server" }, filetypes = { "sh", "zsh" } },
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
