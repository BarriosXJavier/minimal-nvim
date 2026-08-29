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

## Debugging

Debugging is provided by `nvim-dap` and `nvim-dap-ui`. The configuration in
`lua/dap-config.lua` owns the adapters, launch configurations, and UI lifecycle;
`lua/mappings.lua` only defines the keymaps. The UI opens automatically when a
debug session starts and closes when it exits or is terminated.

### Supported filetypes

| Filetype | Adapter | Launch behavior |
| --- | --- | --- |
| C, C++, Rust, Zig | `codelldb` | Prompts for a compiled executable, then launches it |
| Go | `dlv` | Launches the package at `${workspaceFolder}` |
| Shell (`sh`, `zsh`) | `bash-debug-adapter` | Launches the current file |
| JavaScript, TypeScript (and React variants) | `js-debug-adapter` | Launches the current file with Node and source maps enabled |

The filetype must be set correctly for the matching configuration to appear.
There is intentionally no Python adapter/configuration yet; having `pyright`
installed does not provide Python debugging.

JavaScript and TypeScript use the `pwa-node` adapter. JavaScript runs directly
with Node. TypeScript must either be executable by the project’s Node setup or
be run through a loader such as `tsx`; otherwise launch the compiled JavaScript
file and keep source maps enabled.

### Keymaps

`<leader>` is the space bar in this configuration.

| Key | Action |
| --- | --- |
| `<F5>` | Start/continue the session; with one launch configuration this starts it directly |
| `<F6>` | Terminate the session |
| `<F10>` / `<F11>` / `<F12>` | Step over / into / out |
| `<leader>b` | Toggle a breakpoint on the current line |
| `<leader>B` | Add a conditional breakpoint |
| `<leader>lp` | Add a log point |
| `<leader>du` | Toggle the DAP UI manually |
| `<leader>dr` | Open the debug REPL |
| `<leader>dh` | Evaluate the cursor or visual selection in the debug context |
| `<leader>dl` | Run the last debug configuration again |

### Normal workflow

1. Open the project from its root (`cd project && nvim`), and open a source file.
2. Set one or more breakpoints with `<leader>b`.
3. Press `<F5>`. For C-family projects, enter the path to the already-built executable.
4. Inspect scopes, stack frames, watches, and breakpoints in the UI. Use the step keys to move through the program.
5. Press `<F6>` when finished. Use `<leader>du` if the UI was closed manually.

`${workspaceFolder}` is the Neovim working directory, not necessarily the
directory of the current buffer. Start Neovim in the project root when using
the Go configuration or when a C-family executable relies on relative paths.
The C-family prompt defaults to the current directory and accepts an
executable path, so build first (`cargo build`, `go build`, `make`, etc.).

### Adapter requirements

The adapters are external programs and are not installed by `nvim-dap`:

- `codelldb` for C, C++, Rust, and Zig
- `dlv` (Delve) for Go
- `bash-debug-adapter` for Shell
- `js-debug-adapter` for JavaScript and TypeScript

The config prepends Mason's `bin` directory to `PATH`, so Mason-installed
executables are found automatically. Alternatively install the tools with the
system/package manager and ensure `:echo executable('codelldb')` (and the
equivalent command for the adapter you need) returns `1`.

If `<F5>` reports that an adapter cannot be started, check the command first:
`:echo executable('codelldb')`, `:echo executable('dlv')`,
`:echo executable('bash-debug-adapter')`, or
`:echo executable('js-debug-adapter')`. If no configuration appears, check
`:set filetype?`, and confirm that Neovim was started in the intended project
directory with `:pwd`.
