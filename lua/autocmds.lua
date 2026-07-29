local languages = require("plugins")
local augroup = vim.api.nvim_create_augroup("core-autocmds", { clear = true })

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update plugins managed by vim.pack" })

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = languages.treesitter_filetypes,
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
