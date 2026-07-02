local function safe_require(module_name)
	local ok, err = pcall(require, module_name)
	if not ok then
		vim.schedule(function()
			vim.notify(("Failed to load %s: %s"):format(module_name, err), vim.log.levels.ERROR)
		end)
	end
end

safe_require("options")
safe_require("plugins")
safe_require("lsp")
safe_require("dap-config")
safe_require("mappings")
safe_require("autocmds")
