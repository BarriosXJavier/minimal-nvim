local languages = require("plugins")

local function on_attach(client, bufnr)
  if client:supports_method(vim.lsp.protocol.Methods.textDocument_hover) then
    vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", { buffer = bufnr, desc = "Hover documentation" })
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

local ok, err = pcall(function()
  pcall(vim.cmd.packadd, "nvim-lspconfig")
  local shared = {
    on_attach = on_attach,
    capabilities = capabilities(),
  }

  for server, config in pairs(languages.lsp_servers) do
    vim.lsp.config(server, vim.tbl_deep_extend("force", shared, config))
    vim.lsp.enable(server)
  end
end)
if not ok then
  vim.schedule(function() vim.notify(("Plugin setup failed for nvim-lspconfig: %s"):format(err), vim.log.levels.ERROR) end)
end

local vault = vim.fn.expand("~/Documents/Obsidian")
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "marksman" then
      local bufname = vim.api.nvim_buf_get_name(args.buf)
      if vim.startswith(bufname, vault) then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) then
            vim.lsp.buf_detach_client(args.buf, client.id)
          end
        end)
      end
    end
  end,
})
