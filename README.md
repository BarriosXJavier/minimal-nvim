# Neovim config

A modular Neovim setup built mostly on native APIs:

- `vim.pack` for plugin management
- `vim.lsp.config()` / `vim.lsp.enable()` for LSP
- `vim.snippet` for snippets
- `vim.treesitter.start()` for Treesitter activation

The config is organized as small Lua modules instead of one large plugin file.

## Requirements

- Neovim `>= 0.12`
- A Nerd Font for icons
- `git`
- `cargo` if you want to build `blink.cmp`'s native fuzzy matcher locally

## Installation

This repo is meant to live at `~/.config/nvim`.

```sh
git clone <your-repo-url> ~/.config/nvim
```

On first start, plugins are installed automatically through `vim.pack.add()`.

## How startup works

`init.lua` loads modules in this order:

1. `options`
2. `plugins`
3. `lsp`
4. `dap-config`
5. `autocmds`
6. `mappings`

### Plugin bootstrap flow

`lua/plugins.lua` is the entrypoint for plugin setup. It:

1. loads `lua/plugins/bootstrap.lua`
2. prepends Mason's bin dir to `PATH`
3. registers plugin-related autocmds
4. installs plugin specs from `lua/plugins/specs.lua` via `vim.pack.add()`
5. runs grouped setup modules:
   - `plugins.tooling`
   - `plugins.editor`
   - `plugins.navigation`
   - `plugins.completion`
   - `plugins.terminal`
   - `plugins.ui`

### Lockfile

Plugin revisions are pinned in `nvim-pack-lock.json`.

## File structure

```text
~/.config/nvim/
├── init.lua
├── README.md
├── nvim-pack-lock.json
└── lua/
    ├── autocmds.lua
    ├── dap-config.lua
    ├── languages.lua
    ├── lsp.lua
    ├── mappings.lua
    ├── options.lua
    ├── plugins.lua
    ├── util.lua
    └── plugins/
        ├── bootstrap.lua
        ├── completion.lua
        ├── editor.lua
        ├── navigation.lua
        ├── specs.lua
        ├── terminal.lua
        ├── tooling.lua
        └── ui.lua
```

## Module overview

### Core modules

- `lua/options.lua`
  - editor options
  - diagnostic UI configuration
- `lua/autocmds.lua`
  - `:PackUpdate` command
  - Treesitter auto-start for selected filetypes
- `lua/languages.lua`
  - shared language metadata
  - LSP server definitions
  - formatter mappings
  - Treesitter filetype list
- `lua/lsp.lua`
  - LSP client capabilities
  - server registration and enablement
  - LSP hover binding on attach
- `lua/dap-config.lua`
  - DAP adapters and language-specific debug configurations
- `lua/mappings.lua`
  - core and plugin keymaps
- `lua/util.lua`
  - safe plugin/module helpers
  - augroup helper
  - shared terminal sizing helper

### Plugin modules

- `lua/plugins/specs.lua`
  - plugin source list for `vim.pack`
- `lua/plugins/bootstrap.lua`
  - plugin bootstrap helpers
  - Mason `PATH` setup
  - `blink.cmp` background native build scheduling
- `lua/plugins/tooling.lua`
  - `mason.nvim`
- `lua/plugins/editor.lua`
  - `which-key`, `autopairs`, `gitsigns`, `marks`, `conform`, `autosave`
- `lua/plugins/navigation.lua`
  - `telescope`, `trouble`, `oil`, `nvim-tree`
- `lua/plugins/completion.lua`
  - `blink.cmp`, `blink.lib`, `lspkind`
- `lua/plugins/terminal.lua`
  - `toggleterm`
- `lua/plugins/ui.lua`
  - colorscheme, `lualine`, `bufferline`, `ibl`, `render-markdown`, `tiny-glimmer`

## Plugins

### Core editing / UI

- `blazkowolf/gruber-darker.nvim`
- `nvim-tree/nvim-web-devicons`
- `lukas-reineke/indent-blankline.nvim`
- `akinsho/bufferline.nvim`
- `nvim-lualine/lualine.nvim`
- `rachartier/tiny-glimmer.nvim`
- `MeanderingProgrammer/render-markdown.nvim`
- `folke/zen-mode.nvim`

### Navigation / search

- `nvim-tree/nvim-tree.lua`
- `stevearc/oil.nvim`
- `nvim-telescope/telescope.nvim`
- `nvim-lua/plenary.nvim`
- `folke/trouble.nvim`

### LSP / completion / formatting

- `neovim/nvim-lspconfig`
- `saghen/blink.lib`
- `saghen/blink.cmp`
- `onsails/lspkind.nvim`
- `rafamadriz/friendly-snippets`
- `stevearc/conform.nvim`
- `williamboman/mason.nvim`

### Editing helpers

- `windwp/nvim-autopairs`
- `lewis6991/gitsigns.nvim`
- `chentoast/marks.nvim`
- `0x00-ketsu/autosave.nvim`

### Terminal / debug / database

- `akinsho/toggleterm.nvim`
- `mfussenegger/nvim-dap`
- `rcarriga/nvim-dap-ui`
- `nvim-neotest/nvim-nio`
- `tpope/vim-dadbod`
- `kristijanhusak/vim-dadbod-ui`
- `kristijanhusak/vim-dadbod-completion`

### Extras

- `folke/which-key.nvim`
- `nvim-treesitter/nvim-treesitter`
- `jtprogru/pack-ui.nvim`

## blink.cmp and native build behavior

This config does **not** use `lazy.nvim`.

Instead, `blink.cmp` is integrated with `vim.pack` like this:

- `blink.lib` and `blink.cmp` are installed by `vim.pack.add()` from `plugins/specs.lua`
- `plugins/completion.lua` sets up `blink.cmp`
- `plugins/bootstrap.lua` schedules native fuzzy builds in the background

### When the native build runs

- on `PackChanged` install/update events for `blink.cmp`
- once on `VimEnter` if the native library is missing

This avoids blocking startup while still allowing the Rust/native fuzzy matcher to be built when needed.

Current completion fuzzy mode:

```lua
fuzzy = {
    implementation = "prefer_rust",
}
```

So startup remains responsive, and the native matcher is used when available.

## LSP

LSP servers are defined centrally in `lua/languages.lua` and enabled in `lua/lsp.lua`.

Configured servers include:

- `rust_analyzer`
- `vtsls`
- `emmet_language_server`
- `tailwindcss`
- `html`
- `cssls`
- `pyright`
- `clangd`
- `gopls`
- `zls`
- `lua_ls`
- `bashls`
- `marksman`
- `sqls`
- `prisma`
- `taplo`
- `yamlls`

### LSP keymaps

Currently, the only LSP keymap set in `on_attach` is:

- `K` → hover documentation

## Formatting

Formatting is handled by `conform.nvim` using the shared formatter table in `lua/languages.lua`.

Examples:

- `lua` → `stylua`
- `rust` → `rustfmt`
- `go` → `gofmt`
- `python` → `black`
- `c`, `cpp` → `clang-format`
- JS/TS/HTML/CSS/JSON/YAML/Markdown/Vue → `prettierd`, fallback `prettier`

Manual format key:

- `<leader>fm`

## Treesitter

Treesitter is started through a `FileType` autocmd in `lua/autocmds.lua` for:

- `c`
- `cpp`
- `go`
- `javascript`
- `lua`
- `markdown`
- `python`
- `rust`
- `typescript`
- `zig`

Parsers are still managed separately from startup logic. Install missing parsers as needed.

## DAP

Configured adapters:

- `lldb` for `c`, `cpp`, `rust`, `zig`
- `go` via `dlv`
- `bash` for `sh`, `zsh`

DAP UI opens on session start and closes on termination/exit.

## Keymaps

Leader is set to `<Space>`.

### Insert mode

| Key | Action |
|---|---|
| `<C-h>` | Cursor left |
| `<C-j>` | Cursor down |
| `<C-k>` | Cursor up |
| `<C-l>` | Cursor right |
| `jk` | Exit insert mode |

### Normal mode

| Key | Action |
|---|---|
| `<Esc>` | Clear search highlight |
| `;` | Command mode |
| `<C-s>` | Save file |
| `<C-c>` | Copy whole file to clipboard |
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `<C-d>` | Scroll down and center |
| `<C-u>` | Scroll up and center |
| `<C-h/j/k/l>` | Move between windows |
| `<C-Left>` | Decrease window width |
| `<C-Right>` | Increase window width |
| `<C-Up>` | Increase window height |
| `<C-Down>` | Decrease window height |
| `<leader>e` | Show diagnostics float |
| `<leader>fm` | Format buffer |
| `<leader>z` | Toggle Zen mode |
| `<C-n>` | Toggle `nvim-tree` |
| `<leader>o` | Open `oil.nvim` |

### Telescope

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fr` | Find recent files |
| `<leader>fg` | Live grep |
| `<leader>fw` | Find word under cursor |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Find help tags |
| `<leader>fk` | Find keymaps |
| `<leader>fd` | Find diagnostics |
| `<leader>fc` | Find in current buffer |

### Trouble

| Key | Action |
|---|---|
| `<leader>xx` | Diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xs` | Symbols |
| `<leader>xl` | LSP list |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |

### Terminal

| Key | Action |
|---|---|
| `<leader>lg` | Toggle LazyGit |
| `<A-i>` | Toggle floating terminal |
| `<A-v>` | Toggle vertical terminal |
| `<A-h>` | Toggle horizontal terminal |
| terminal `<C-h/j/k/l>` | Move between windows |

### DAP

| Key | Action |
|---|---|
| `<F5>` | Continue |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<leader>lp` | Log point |
| `<leader>dr` | Open REPL |
| `<leader>dl` | Run last config |
| `<leader>dh` | Evaluate expression |

### blink.cmp

| Key | Action |
|---|---|
| `<CR>` | Accept selected completion |
| `<Tab>` | Snippet forward or next completion |
| `<S-Tab>` | Snippet backward or previous completion |

## Commands

| Command | Action |
|---|---|
| `:PackUpdate` | Update plugins managed by `vim.pack` |

## Notes

- Mason binaries are shared under `~/.local/share/nvim/mason`
- Mason's `bin` directory is prepended to `PATH` during plugin bootstrap
- plugin revisions are locked in `nvim-pack-lock.json`
- plugin-specific mappings are guarded so missing plugins fail more gracefully
