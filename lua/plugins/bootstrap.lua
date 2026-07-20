local util = require("util")

local M = {}

local blink_build_task
local augroup = util.augroup("plugin-bootstrap")

local function prepend_path(path)
  local current = vim.env.PATH or ""

  for _, segment in ipairs(vim.split(current, ":", { trimempty = true })) do
    if segment == path then
      return
    end
  end

  vim.env.PATH = path .. (current ~= "" and (":" .. current) or "")
end

function M.setup_environment()
  prepend_path(vim.fn.stdpath("data") .. "/mason/bin")
end

function M.queue_blink_build(force)
  if blink_build_task then
    return
  end

  util.packadd("blink.lib")
  util.packadd("blink.cmp")

  local ok, cmp = pcall(require, "blink.cmp")
  if not ok or (not force and cmp.library_available()) then
    return
  end

  local ok_task, task = pcall(function()
    return cmp.build({ force = force })
  end)

  if not ok_task then
    util.notify_plugin_error("blink.cmp", task, vim.log.levels.WARN)
    return
  end

  blink_build_task = task
  task:on_resolve(function()
    blink_build_task = nil
  end)
  task:on_reject(function(err)
    blink_build_task = nil
    util.notify_plugin_error("blink.cmp background build", err, vim.log.levels.WARN)
  end)
  task:on_cancel(function()
    blink_build_task = nil
  end)
end

function M.register_autocmds()
  vim.api.nvim_create_autocmd("PackChanged", {
    group = augroup,
    callback = function(ev)
      local data = ev.data
      local name = data.spec.name or vim.fs.basename(data.path)
      local kind = data.kind

      if name == "blink.cmp" and (kind == "install" or kind == "update") then
        vim.schedule(function()
          M.queue_blink_build(true)
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    once = true,
    callback = function()
      vim.schedule(function()
        M.queue_blink_build(false)
      end)
    end,
  })
end

function M.install(specs)
  vim.pack.add(specs)
end

return M
