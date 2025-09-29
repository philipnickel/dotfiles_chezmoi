-- Plugin configurations for LunarVim
-- This file contains all plugin definitions and their configurations

-- which-key is handled by LunarVim's built-in system

-- Copilot integration
table.insert(lvim.plugins, {
  "zbirenbaum/copilot-cmp",
  event = "InsertEnter",
  dependencies = { "zbirenbaum/copilot.lua" },
  config = function()
    vim.defer_fn(function()
      require("copilot").setup() -- https://github.com/zbirenbaum/copilot.lua/blob/master/README.md#setup-and-configuration
      require("copilot_cmp").setup() -- https://github.com/zbirenbaum/copilot-cmp/blob/master/README.md#configuration
    end, 100)
  end,
})

-- Markdown preview
table.insert(lvim.plugins, {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function() vim.fn["mkdp#util#install"]() end,
})

-- REPL functionality handled by LunarVim's built-in features

-- Telescope is handled by LunarVim's built-in system

-- Tmux navigation
table.insert(lvim.plugins, {
  "christoomey/vim-tmux-navigator",
  config = function()
    -- Configure tmux navigator without defining keys
    -- LunarVim will handle key conflicts automatically
  end,
})

-- VimTeX for LaTeX support
table.insert(lvim.plugins, {
  "lervag/vimtex",
  ft = { "tex", "latex" },
  config = function()
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_quickfix_mode = 0
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      options = {
        "-pdf",
        "-interaction=nonstopmode",
        "-file-line-error",
        "-synctex=1",
        "-verbose",
      },
    }
  end,
})