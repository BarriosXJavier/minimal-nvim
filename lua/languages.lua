local prettier = { "prettierd", "prettier" }

return {
    treesitter_filetypes = {
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

    formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt" },
        go = { "gofmt" },
        python = { "black" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        sql = { "sleek" },

        javascript = prettier,
        typescript = prettier,
        javascriptreact = prettier,
        typescriptreact = prettier,
        html = prettier,
        css = prettier,
        scss = prettier,
        json = prettier,
        yaml = prettier,
        markdown = prettier,
        vue = prettier,
    },

    lsp_servers = {
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
        yamlls = {},
    },
}
