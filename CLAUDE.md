# CLAUDE.md

Guide Claude Code (claude.ai/code) for this repo.

## Repository purpose

Personal Neovim config on **NvChad v2.5** starter. NvChad (`NvChad/NvChad` branch `v2.5`) consumed as lazy.nvim plugin — repo hold only user overrides. Target langs: PHP, TypeScript/React, Go.

## Entry point and load order

`init.lua` drive everything:

1. Set `vim.g.mapleader = " "` first (required before plugin load)
2. Bootstrap `lazy.nvim` into `stdpath("data")/lazy/lazy.nvim`
3. Call `lazy.setup` with two imports: `NvChad/NvChad` (lazy=false, branch v2.5) and local `plugins` dir
4. Load base46 compiled theme cache from `stdpath("data")/base46/defaults` and `statusline` via `dofile` (NvChad cache compiled highlights — no replace with `require`)
5. Require `options`, then `nvchad.autocmds`
6. Schedule `mappings` after UI ready
7. Register `BufWritePre` autocmd — auto-create parent dirs for saved file

NvChad load first with `lazy=false`, so any override plugin in `lua/plugins/` merge into NvChad lazy spec. User LSP config override NvChad defaults by re-calling `vim.lsp.config` and `vim.lsp.enable`.

## Directory layout

```
init.lua               bootstrap + theme cache + mappings schedule
lua/chadrc.lua         NvChad ChadrcConfig (theme selection)
lua/options.lua        wraps nvchad.options + user vim.opt additions
lua/mappings.lua       wraps nvchad.mappings + user keymaps
lua/plugins/           lazy.nvim plugin specs (auto-imported)
  init.lua             core overrides: conform, lspconfig, treesitter, mason, ts-autotag, colorizer
  php.lua              phpactor.nvim + RPC keymaps
  codeium.nvim         Codeium AI
lua/configs/           opt tables referenced from plugin specs
  lazy.lua             lazy.nvim options (defaults.lazy=true, rtp disable list, ui icons)
  lspconfig.lua        all LSP server setup (intelephense, ts_ls, tailwindcss, gopls, html, cssls)
  conform.lua          formatter-by-filetype map
lazy-lock.json         plugin commit pins (commit when updating)
.stylua.toml           Lua formatter config (2-space, double quotes, no call parens)
```

## LSP architecture

`lua/configs/lspconfig.lua` use **new `vim.lsp.config` API** (Neovim 0.11+), not legacy `lspconfig.<server>.setup`. Each server:

1. Fetch shared helpers from `require "nvchad.configs.lspconfig"` (expose `on_attach`, `on_init`, `capabilities`)
2. Set `vim.lsp.config.<name> = { cmd, root_markers, on_attach, on_init, capabilities, settings }`
3. Call `vim.lsp.enable('<name>')`

Servers wired: `html`, `cssls`, `gopls`, `ts_ls`, `tailwindcss`, `intelephense`.

**Special cases**:
- `gopls` has custom `on_attach` wrap NvChad `on_attach` + add `BufWritePre` autocmd running `source.organizeImports` code action + `vim.lsp.buf.format()`. Go format-on-save here, not conform.
- `intelephense` run alongside `phpactor.nvim` (LSP disabled in phpactor setup, `lspconfig.enabled = false`). Phpactor used only for RPC refactor (`context_menu`, `import_class`, `new_class`, `expand_class`). Intelephense handle completion/hover/diagnostics.
- `tailwindcss` filetype list include `typescriptreact`/`typescript` with `userLanguages` map TS → JS for class detection.

## Formatting strategy

Split across two mechanisms — intentional but know:

- **conform.nvim** (`lua/configs/conform.lua`): only `lua = { "stylua" }` wired. `format_on_save` commented out.
- **Go**: formatted via gopls `BufWritePre` autocmd in `lspconfig.lua` (not conform).
- **PHP**: `intelephense.format.enable = true` — LSP format only.
- **TS/TSX/JS/CSS/HTML**: `prettierd` installed via Mason but **not wired** into conform. No format on save for these.

Add formatter → prefer conform unless LSP own cleanly.

## Mason-managed binaries

`lua/plugins/init.lua` `ensure_installed`: `typescript-language-server`, `tailwindcss-language-server`, `prettierd`, `eslint_d`. `eslint_d` no consumer (no nvim-lint / none-ls); installed but inert.

Phpactor phar auto-install via `build` hook to `stdpath("data")/mason/packages/phpactor/phpactor.phar`.

## Treesitter parsers

Ensured in `lua/plugins/init.lua`: `vim, lua, vimdoc, html, css, javascript, typescript, tsx, json, go, markdown, query, php`.

## Keymaps

Two user maps in `lua/mappings.lua`:
- `jk` (insert) → `<ESC>`
- `;` (normal) → `:`

PHP-specific `<leader>p*` maps in `lua/plugins/php.lua`:
- `<leader>pm` context menu, `<leader>pi` import class, `<leader>pim` import missing, `<leader>pn` new class, `<leader>pe` expand class

Other keymaps from `nvchad.mappings` (no rewrite — add new only).

## lazy.nvim performance note

`lua/configs/lazy.lua` disable aggressive rtp plugin list incl. `ftplugin`, `syntax`, `synmenu`, `compiler`, `matchit`. Disable `matchit` kill `%` paren-jump extended matching. Disable `ftplugin`/`syntax` rely on treesitter for highlight + filetype. Filetype suddenly lose highlight or ft detection → suspect this list first.

## Common commands

```bash
# Apply Lua formatting (repo uses stylua)
stylua lua/ init.lua

# Headless plugin sync (useful after editing plugin specs)
nvim --headless "+Lazy! sync" +qa

# Force recompile base46 highlight cache after theme change
nvim --headless "+lua require('base46').load_all_highlights()" +qa

# Mason install a tool
nvim "+MasonInstall <tool>"

# Check LSP health / plugin health
nvim "+checkhealth"
```

No test suite — personal config, not library.

## When editing this config

- Keep overrides minimal — NvChad defaults the baseline, no re-implement behavior it provide.
- LSP server setup → `lua/configs/lspconfig.lua` using `vim.lsp.config` + `vim.lsp.enable` pattern (match existing style, no `lspconfig.<name>.setup`).
- Plugin specs → `lua/plugins/<name>.lua` or append `lua/plugins/init.lua`. `lazy.setup` import `plugins` dir auto.
- Commit `lazy-lock.json` alongside plugin spec changes to pin versions.
- `chadrc.lua` must return table typed `---@type ChadrcConfig` — structure mirror `github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua`.