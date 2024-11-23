-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

lspconfig.gopls.setup {
   on_attach = function(client, bufnr)
      -- Enable LSP-based formatting
      if client.server_capabilities.documentFormattingProvider then
         vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.code_action({
                context = {
                  only = {"source.organizeImports"},
                  diagnostics = {},
                },
                apply = true,
              })

               vim.lsp.buf.format()  -- Automatically format on save
            end,
         })
      end
   end,
   settings = {
      gopls = {
         analyses = {
            unusedparams = true, -- highlight and remove unused params  
            unusedwrite = true, -- highlight and remove unused writes
         },
         staticcheck = true,
      },
   },
}

lspconfig.ts_ls.setup({
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
  },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      suggest = {
        includeCompletionsForModuleExports = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
})

lspconfig.tailwindcss.setup({
  filetypes = {
    "typescriptreact",
    "typescript",
    "javascript",
    "javascriptreact",
    "html",
    "css"
  },
  init_options = {
    userLanguages = {
      typescript = "javascript",
      typescriptreact = "javascript",
    },
  },
})

-- configuring single server, example: typescript
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }
