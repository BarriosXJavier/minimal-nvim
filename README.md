# Neovim config

A compact Neovim `>= 0.12` configuration using native `vim.pack`, the native
LSP API, `vim.snippet`, and `vim.treesitter.start()`.

## Startup

`init.lua` sets the leaders and loads options, plugins, LSP, DAP, Treesitter
autocommands, and mappings in that order. `lua/plugins.lua` contains the full
plugin source list, bootstrap logic, language metadata, and plugin setup.

Plugins are installed and updated with `vim.pack.add()` and pinned in
`nvim-pack-lock.json`. `:PackUpdate` runs `vim.pack.update()`.

Mason's bin directory is prepended to `PATH` during startup. `blink.cmp`'s
native matcher is built in the background after install/update and once on
`VimEnter` when unavailable. Completion uses `prefer_rust` and falls back
normally if the native library is not built.

## File structure

```text
~/.config/nvim/
├── init.lua
├── README.md
├── nvim-pack-lock.json
└── lua/
    ├── autocmds.lua
    ├── dap-config.lua
    ├── lsp.lua
    ├── mappings.lua
    ├── options.lua
    └── plugins.lua
```

`plugins.lua` preserves all plugin specs and setup previously spread across
`lua/plugins/*.lua`; it also contains the shared formatter, LSP, and
Treesitter language tables. The other files contain the corresponding core
settings, LSP setup, DAP setup, keymaps, options, and Treesitter autostart.

## Requirements

- Git
- A Nerd Font for icons
- Cargo if building `blink.cmp`'s native matcher locally

The configuration includes the same editing, UI, navigation, completion, LSP,
formatting, terminal, DAP, database, and utility plugins as the original
configuration. No plugin or feature is intentionally omitted.
