vim.cmd.packadd("nvim-lspconfig")

local map = vim.keymap.set
local uv = vim.uv or vim.loop
local popup_delay_ms = 150

local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    local popup_group = vim.api.nvim_create_augroup("mvim_lsp_popups_" .. bufnr, { clear = true })
    local popup_timer = uv.new_timer()

    local function stop_popup_timer()
        if popup_timer then
            popup_timer:stop()
        end
    end

    local function schedule_popup(callback)
        stop_popup_timer()
        popup_timer:start(popup_delay_ms, 0, vim.schedule_wrap(function()
            if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
                callback()
            end
        end))
    end

    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
    map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
    map("n", "<leader>d", vim.diagnostic.open_float, opts)
    map("n", "<leader>q", vim.diagnostic.setloclist, opts)

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_hover, bufnr) then
        vim.api.nvim_create_autocmd("CursorHold", {
            group = popup_group,
            buffer = bufnr,
            callback = function()
                schedule_popup(vim.lsp.buf.hover)
            end,
        })
    end

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_signatureHelp, bufnr) then
        vim.api.nvim_create_autocmd("CursorHoldI", {
            group = popup_group,
            buffer = bufnr,
            callback = function()
                schedule_popup(vim.lsp.buf.signature_help)
            end,
        })
    end

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertLeave", "BufLeave", "WinLeave" }, {
        group = popup_group,
        buffer = bufnr,
        callback = stop_popup_timer,
    })

    vim.api.nvim_create_autocmd("BufWipeout", {
        group = popup_group,
        buffer = bufnr,
        callback = function()
            stop_popup_timer()
            if popup_timer and not popup_timer:is_closing() then
                popup_timer:close()
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
