local M = {}

function M.notify_plugin_error(name, err, level)
    vim.schedule(function()
        vim.notify(("Plugin setup failed for %s: %s"):format(name, err), level or vim.log.levels.ERROR)
    end)
end

function M.safe_call(name, fn, level)
    local ok, result = pcall(fn)
    if not ok then
        M.notify_plugin_error(name, result, level)
        return nil
    end

    return result
end

function M.packadd(name)
    pcall(vim.cmd.packadd, name)
end

function M.with_plugin(name, fn)
    return M.safe_call(name, function()
        if name then
            M.packadd(name)
        end

        return fn()
    end)
end

function M.with_module(package_name, module_name, fn)
    return M.with_plugin(package_name, function()
        return fn(require(module_name))
    end)
end

function M.setup_module(package_name, module_name, opts)
    return M.with_module(package_name, module_name, function(module)
        module.setup(opts or {})
        return module
    end)
end

function M.augroup(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

function M.terminal_size(direction)
    if direction == "vertical" then
        return math.floor(vim.o.columns * 0.3)
    end

    return math.max(8, math.floor(vim.o.lines * 0.25))
end

return M
