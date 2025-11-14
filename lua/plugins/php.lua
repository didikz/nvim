return {
  {
    "gbprod/phpactor.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig"
    },
    lazy = false,
    build = function()
      require("phpactor.handler.update")()
    end,
    config = function()
      require("phpactor").setup({
        install = {
          bin = vim.fn.stdpath("data") .. "/mason/packages/phpactor/phpactor.phar",
        },
        lspconfig = {
          enabled = false,
        },
      })
      
      -- Use the correct RPC method names from AVAILABLE_RPC
      local phpactor = require("phpactor")
      
      vim.keymap.set('n', '<leader>pm', function()
        phpactor.rpc("context_menu", {})
      end, { desc = 'Phpactor context menu' })
      
      vim.keymap.set('n', '<leader>pi', function()
        phpactor.rpc("import_class", {})
      end, { desc = 'Import class' })
      
      vim.keymap.set('n', '<leader>pim', function()
        phpactor.rpc("import_missing_classes", {})
      end, { desc = 'Import all missing classes' })
      
      vim.keymap.set('n', '<leader>pn', function()
        phpactor.rpc("new_class", {})
      end, { desc = 'Create new class' })
      
      vim.keymap.set('n', '<leader>pe', function()
        phpactor.rpc("expand_class", {})
      end, { desc = 'Expand class' })
    end,
  },
}
