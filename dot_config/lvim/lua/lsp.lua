-- Language Server Protocol configurations for LunarVim
-- This file contains LSP server configurations

-- Configure LSP hover window to be scrollable and navigable
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded",
    max_width = 80,
    max_height = 30,
    focusable = true,  -- Makes the hover window focusable/scrollable
  }
)

-- Disable the default K mapping for LSP hover (conflicts with navigation)
lvim.lsp.buffer_mappings.normal_mode["K"] = nil

-- Use Shift+I for hover (I = Info)
lvim.lsp.buffer_mappings.normal_mode["<S-i>"] = {
  vim.lsp.buf.hover,
  "Show hover documentation"
}

-- No other custom LSP configurations needed for current setup
-- LunarVim handles most LSP servers automatically