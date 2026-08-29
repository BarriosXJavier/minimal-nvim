local function executable_path_prompt()
  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
end

local function c_family_configuration()
  return {
    {
      name = "Launch",
      type = "lldb",
      request = "launch",
      program = executable_path_prompt,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      args = {},
    },
  }
end

local ok, err = pcall(function()
  pcall(vim.cmd.packadd, "nvim-dap")
  -- dap-ui uses nvim-nio but does not load it for us in this native pack setup.
  pcall(vim.cmd.packadd, "nvim-nio")
  pcall(vim.cmd.packadd, "nvim-dap-ui")

  local dap = require("dap")
  local dapui = require("dapui")

  dapui.setup()

  local function close_dapui()
    dapui.close()
  end

  dap.listeners.after.event_initialized.dapui_config = function()
    dapui.open()
  end
  dap.listeners.after.event_terminated.dapui_config = close_dapui
  dap.listeners.after.event_exited.dapui_config = close_dapui

  dap.adapters.lldb = {
    type = "server",
    port = "${port}",
    executable = {
      command = "codelldb",
      args = { "--port", "${port}" },
    },
  }

  dap.adapters.go = {
    type = "server",
    port = "${port}",
    executable = {
      command = "dlv",
      args = { "dap", "--listen", "127.0.0.1:${port}" },
    },
  }

  dap.adapters.bash = {
    type = "executable",
    command = "bash-debug-adapter",
    args = {},
  }

  dap.adapters["pwa-node"] = {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
      command = "js-debug-adapter",
      args = { "${port}" },
    },
  }

  local c_family = c_family_configuration()
  dap.configurations.c = c_family
  dap.configurations.cpp = c_family
  dap.configurations.rust = c_family
  dap.configurations.zig = c_family

  dap.configurations.go = {
    {
      name = "Launch",
      type = "go",
      request = "launch",
      program = "${workspaceFolder}",
    },
  }

  dap.configurations.sh = {
    {
      name = "Launch",
      type = "bash",
      request = "launch",
      program = "${file}",
    },
  }
  dap.configurations.zsh = dap.configurations.sh

  local javascript = {
    {
      name = "Launch file",
      type = "pwa-node",
      request = "launch",
      program = "${file}",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
    },
  }
  dap.configurations.javascript = javascript
  dap.configurations.javascriptreact = javascript
  dap.configurations.typescript = javascript
  dap.configurations.typescriptreact = javascript
end)
if not ok then
  vim.schedule(function() vim.notify(("Plugin setup failed for nvim-dap: %s"):format(err), vim.log.levels.ERROR) end)
end
