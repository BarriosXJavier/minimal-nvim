# nvim-minimal

A minimal Neovim config using **native Neovim APIs** (`vim.pack`, `vim.lsp.config`, `vim.snippet`, `vim.treesitter`)

## Requirements

- Neovim >= 0.12
- [Nerd Font](https://www.nerdfonts.com/) (for icons)

## Installation

```sh
git clone https://github.com/BarriosXJavier/nvim-minimal ~/.config/nvim-minimal
```

Add an alias to your shell config:

```sh
alias mvim='NVIM_APPNAME=nvim-minimal nvim'
```

On first launch, plugins are auto-installed via `vim.pack.add`. LSP and DAP binaries are installed on demand via Mason (shared with NvChad at `~/.local/share/nvim/mason`).

## File Structure

```
~/.config/nvim-minimal/
├── init.lua              # Entry point
├── lua/
│   ├── options.lua       # Neovim native options, colorscheme
│   ├── plugins.lua       # Plugin list, setup calls, autocmds
│   ├── lsp.lua           # LSP server configs, buffer-local keymaps
│   ├── dap-config.lua    # DAP adapters, configurations, listeners
│   └── mappings.lua      # All keymaps
├── nvim-pack-lock.json   # Plugin version lockfile
└── README.md
```

## Plugins

| Plugin | Purpose |
|--------|---------|
| [gruber-darker.nvim](https://github.com/blazkowolf/gruber-darker.nvim) | Colorscheme |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | File icons |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP server defaults |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Autocompletion |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Snippet definitions |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File explorer |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | File explorer (buffer-based) |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | Tabline |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keymap help popup |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Diagnostics/references list |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Utility library (dep of telescope) |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git decorations |
| [marks.nvim](https://github.com/chentoast/marks.nvim) | Better mark management |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close brackets |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Terminal manager |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Code formatter |
| [autosave.nvim](https://github.com/0x00-ketsu/autosave.nvim) | Auto-save |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP/DAP/linter installer |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug adapter protocol |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | DAP UI |
| [nvim-nio](https://github.com/nvim-neotest/nvim-nio) | Async IO (dep of nvim-dap-ui) |

## Keymaps

### Insert Mode

| Key | Action |
|-----|--------|
| `<C-h>` | Cursor left |
| `<C-j>` | Cursor down |
| `<C-k>` | Cursor up |
| `<C-l>` | Cursor right |
| `jk` | Exit insert mode |

### Normal Mode

| Key | Action |
|-----|--------|
| `;` | Enter command mode |
| `<C-s>` | Save file |
| `<leader>fm` | Format buffer (conform) |
| `<leader>xx` | Toggle trouble diagnostics list |
| `<leader>e` | Toggle nvim-tree |
| `<leader>o` | Open oil.nvim |
| `<leader>x` | Close buffer |
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `<C-h/j/k/l>` | Navigate windows |

### LSP (buffer-local)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Hover info |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>d` | Open diagnostic float |
| `<leader>q` | Diagnostic loclist |

### Terminal (toggleterm)

| Key | Action |
|-----|--------|
| `<leader>lg` | LazyGit (float) |
| `<A-i>` | Toggle float terminal |
| `<A-v>` | Toggle vertical terminal |
| `<A-h>` | Toggle horizontal terminal |

### Debug (DAP)

| Key | Action |
|-----|--------|
| `<F5>` | Continue |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<leader>lp` | Log point |
| `<leader>dr` | Open REPL |
| `<leader>dl` | Re-run last config |
| `<leader>dh` | Evaluate expression |

### Completion (blink.cmp)

| Key | Action |
|-----|--------|
| `<CR>` | Accept selected item |
| `<Tab>` | Snippet forward |
| `<S-Tab>` | Snippet backward |

## LSP Servers

Configured via `vim.lsp.config` with explicit `filetypes` and `cmd`:

| Server | Languages | Installed via |
|--------|-----------|---------------|
| `rust-analyzer` | Rust | Mason |
| `vtsls` | TS/JS/TSX/JSX | Mason |
| `pyright` | Python | Mason |
| `clangd` | C/C++/ObjC | Mason |
| `gopls` | Go | Mason |
| `zls` | Zig | Mason |
| `lua-language-server` | Lua | Mason |
| `bash-language-server` | Bash/Zsh | Mason |

## Debug Adapters

| Adapter | Languages | Backend |
|---------|-----------|---------|
| `lldb` | C/C++/Rust/Zig | `codelldb` (Mason) |
| `go` | Go | `dlv` (Mason) |
| `bash` | Sh/Zsh | `bash-debug-adapter` (Mason) |

## Mason

Shares the Mason install directory with NvChad at `~/.local/share/nvim/mason` to avoid duplicating LSP/DAP binaries. The Mason `bin` directory is prepended to `PATH` in `options.lua`.

## Treesitter

Parsers are auto-installed on first launch via `TSInstall` for: `c`, `cpp`, `go`, `javascript`, `lua`, `python`, `rust`, `typescript`, `zig`.

- Preferred **native Neovim APIs** over external plugins where possible (`vim.pack`, `vim.lsp.config`, `vim.snippet`, `vim.diagnostic.jump`)
- All keymaps in one file (`lua/mappings.lua`)
