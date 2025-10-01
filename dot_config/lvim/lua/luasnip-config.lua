-- LuaSnip configuration for LunarVim
-- This file sets up LuaSnip keybindings, options, and loaders

local ls = require("luasnip")

-- ============================================================================
-- LuaSnip Configuration Options
-- ============================================================================

ls.config.set_config({
  -- Enable autotriggered snippets
  enable_autosnippets = true,

  -- Use Tab to trigger visual selection
  store_selection_keys = "<Tab>",

  -- Update snippets as you type (for dynamic nodes and repeated nodes)
  update_events = "TextChanged,TextChangedI",
})

-- ============================================================================
-- Keybindings for Snippet Expansion and Navigation
-- ============================================================================

-- Expand or jump in insert mode (use Tab for both expansion and jumping)
vim.cmd[[
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'
]]

-- Jump backward through snippet tabstops with Shift-Tab
vim.cmd[[
imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
]]

-- Cycle through choice nodes (if you use them)
vim.cmd[[
imap <silent><expr> <C-l> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-l>'
smap <silent><expr> <C-l> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-l>'
]]

-- ============================================================================
-- Load Snippets
-- ============================================================================

-- Load snippets from the luasnippets directory
-- LunarVim expects snippets in ~/.config/lvim/luasnippets/
require("luasnip.loaders.from_lua").lazy_load({
  paths = vim.fn.stdpath("config") .. "/luasnippets/"
})

-- ============================================================================
-- Snippet Reload Keymap
-- ============================================================================

-- Reload snippets with <Leader>L (useful when editing snippets in another vim instance)
vim.keymap.set('n', '<Leader>L', function()
  require("luasnip.loaders.from_lua").load({
    paths = vim.fn.stdpath("config") .. "/luasnippets/"
  })
  vim.notify("LuaSnip snippets reloaded!", vim.log.levels.INFO)
end, { desc = "Reload LuaSnip snippets" })
