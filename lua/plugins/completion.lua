local util = require("util")

local M = {}

local function blink_kind_icon(ctx)
    if ctx.source_name == "Path" then
        local ok, devicons = pcall(require, "nvim-web-devicons")
        if ok then
            local icon, hl = devicons.get_icon(ctx.label, nil, { default = true })
            if icon then
                return icon .. ctx.icon_gap, hl
            end
        end
    end

    local ok, lspkind = pcall(require, "lspkind")
    if ok then
        return (lspkind.symbol_map[ctx.kind] or ctx.kind_icon) .. ctx.icon_gap, ctx.kind_hl
    end

    return ctx.kind_icon .. ctx.icon_gap, ctx.kind_hl
end

function M.setup()
    util.packadd("blink.lib")
    util.packadd("blink.cmp")

    local ok, blink = pcall(require, "blink.cmp")
    if not ok then
        util.notify_plugin_error("blink.cmp", blink)
        return
    end

    blink.setup({
        keymap = {
            preset = "enter",
            ["<C-k>"] = false,
            ["<CR>"] = {
                "select_and_accept",
                "fallback",
            },
            ["<Tab>"] = {
                function(cmp)
                    if cmp.snippet_active({ direction = 1 }) then
                        cmp.snippet_forward()
                        return true
                    end
                end,
                "select_next",
                "fallback",
            },
            ["<S-Tab>"] = {
                function(cmp)
                    if cmp.snippet_active({ direction = -1 }) then
                        cmp.snippet_backward()
                        return true
                    end
                end,
                "select_prev",
                "fallback",
            },
        },
        cmdline = {
            enabled = true,
        },
        completion = {
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
                window = {
                    border = "none",
                    direction_priority = {
                        menu_north = { "e", "w" },
                        menu_south = { "e", "w" },
                    },
                },
            },
            list = {
                selection = {
                    auto_insert = true,
                },
            },
            menu = {
                auto_show = true,
                border = "none",
                direction_priority = { "s", "n" },
                draw = {
                    columns = {
                        { "kind_icon" },
                        { "label", "label_description", gap = 1 },
                    },
                    components = {
                        kind_icon = {
                            ellipsis = false,
                            text = function(ctx)
                                local icon = blink_kind_icon(ctx)
                                return icon
                            end,
                            highlight = function(ctx)
                                local _, hl = blink_kind_icon(ctx)
                                return hl
                            end,
                        },
                    },
                },
            },
        },
        sources = {
            default = {
                "lsp",
                "path",
                "snippets",
                "buffer",
            },
        },
        fuzzy = {
            implementation = "prefer_rust",
        },
        snippets = {
            preset = "default",
            expand = function(snippet)
                vim.snippet.expand(snippet)
            end,
        },
        signature = {
            enabled = true,
            window = {
                show_documentation = true,
                border = "none",
            },
        },
    })
end

return M
