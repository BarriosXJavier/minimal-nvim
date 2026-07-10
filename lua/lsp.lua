local languages = require("languages")
local util = require("util")

local function on_attach(client, bufnr)
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_hover) then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })
    end
end

local function capabilities()
    local base = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")

    if ok and type(blink.get_lsp_capabilities) == "function" then
        return vim.tbl_deep_extend("force", base, blink.get_lsp_capabilities())
    end

    return base
end

util.with_plugin("nvim-lspconfig", function()
    local shared = {
        on_attach = on_attach,
        capabilities = capabilities(),
    }

    for server, config in pairs(languages.lsp_servers) do
        vim.lsp.config(server, vim.tbl_deep_extend("force", shared, config))
        vim.lsp.enable(server)
    end
end)
