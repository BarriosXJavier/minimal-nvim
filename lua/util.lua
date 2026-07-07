local M = {}

function M.notify_plugin_error(name, err)
	vim.schedule(function()
		vim.notify(("Plugin setup failed for %s: %s"):format(name, err), vim.log.levels.ERROR)
	end)
end

function M.with_plugin(name, fn)
	local ok, err = pcall(fn)
	if not ok then
		M.notify_plugin_error(name, err)
	end
end

function M.packadd(name)
	pcall(vim.cmd.packadd, name)
end

function M.setup_module(package_name, module_name, opts)
	M.with_plugin(package_name, function()
		if package_name then
			M.packadd(package_name)
		end
		require(module_name).setup(opts or {})
	end)
end

return M
