vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
end, {})

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
