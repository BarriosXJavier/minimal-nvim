local util = require("util")

util.with_plugin("nvim-lspconfig", function()
    local map = vim.keymap.set

    local on_attach = function(client, bufnr)
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_hover) then
            map("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })
        end
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local blink_ok, blink = pcall(require, "blink.cmp")
    if blink_ok and type(blink.get_lsp_capabilities) == "function" then
        capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
    end

    local server_configs = {
        rust_analyzer = {},
        vtsls = {
            filetypes = {
                "typescript",
                "javascript",
                "typescriptreact",
                "javascriptreact",
            },
        },
        emmet_language_server = {},
        tailwindcss = {},
        html = {},
        cssls = {
            filetypes = { "css", "scss", "less" },
        },
        pyright = {},
        clang_formatter = { "c", "cpp", "objc", "objcpp" },
        clangd = {
            filetypes = { "c", "cpp", "objc", "objcpp" },
        },
        gopls = {
            filetypes = { "go", "gomod" },
        },
        zls = {},
        lua_ls = {
            cmd = { "lua-language-server" },
            filetypes = { "lua" },
        },
        bashls = {
            cmd = { "bash-language-server" },
            filetypes = { "sh", "zsh" },
        },
        marksman = {
            filetypes = { "markdown" },
        },
        sqls = {},
        prisma = {},
        taplo = {
            filetypes = { "toml" },
        },
        yamlls = {}
    }

    for server, config in pairs(server_configs) do
        vim.lsp.config[server] = vim.tbl_deep_extend("force", {
            on_attach = on_attach,
            capabilities = capabilities,
        }, config)
        vim.lsp.enable(server)
    end
end)
