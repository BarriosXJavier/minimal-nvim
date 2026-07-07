local util = require("util")

util.with_plugin("nvim-dap", function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.after.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.after.event_exited["dapui_config"] = function()
        dapui.close()
    end

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

    dap.configurations.c = {
        {
            name = "Launch",
            type = "lldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
        },
    }
    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = dap.configurations.c
    dap.configurations.zig = dap.configurations.c

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
end)
