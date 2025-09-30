-- Keymaps configuration for LunarVim
-- This file contains custom keybindings that are NOT part of which-key menus

local function is_code_chunk()
  local has_otter, otter_keeper = pcall(require, 'otter.keeper')
  if not has_otter then
    return false
  end
  local current, _ = otter_keeper.get_current_language_context()
  if current then
    return true
  else
    return false
  end
end

--- Insert code chunk of given language
local function insert_code_chunk(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
  local keys
  if is_code_chunk() then
    keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
  else
    keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
  end
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

local function new_terminal(lang)
  vim.cmd('vsplit term://' .. lang)
end

local function new_terminal_smart_python()
  -- Check if ipython is available in current environment
  local has_ipython = vim.fn.executable('ipython') == 1
  if has_ipython then
    new_terminal('ipython --no-confirm-exit --no-autoindent')
  else
    new_terminal('python')
  end
end

local function delete_cell()
  -- Find the current cell boundaries
  local current_line = vim.fn.line('.')
  local ft = vim.bo.filetype

  if ft == 'python' then
    -- For Python files with #%% delimiters
    vim.fn.cursor(current_line, 1)
    local cell_start = vim.fn.search('^#%%', 'bcnW')
    vim.fn.cursor(current_line, 1)
    local cell_end = vim.fn.search('^#%%', 'nW')

    if cell_start > 0 then
      if cell_end > 0 then
        -- Delete from #%% to line before next #%%
        vim.cmd(cell_start .. ',' .. (cell_end - 1) .. 'delete')
      else
        -- Delete from #%% to end of file
        vim.cmd(cell_start .. ',$delete')
      end
    end
  else
    -- For Quarto/markdown files with ``` delimiters
    vim.fn.cursor(current_line, 1)
    -- Find opening ``` delimiter
    local cell_start = vim.fn.search('^```', 'bcnW')

    if cell_start > 0 then
      vim.fn.cursor(cell_start, 1)
      -- Find closing ``` delimiter (next ``` after the opening)
      local cell_end = vim.fn.search('^```', 'W')

      if cell_end > 0 then
        -- Delete from opening ``` to closing ``` (inclusive)
        vim.cmd(cell_start .. ',' .. cell_end .. 'delete')
      else
        -- No closing delimiter found, delete to end of file
        vim.cmd(cell_start .. ',$delete')
      end
    end
  end
end

-- Cell navigation
local function next_cell()
  local ft = vim.bo.filetype
  if ft == 'python' then
    -- For Python, search for #%% and move to line below it
    local found = vim.fn.search('^#%%', 'W')
    if found > 0 then
      vim.cmd('normal! j')  -- Move to first line below #%%
    end
  else
    -- For Quarto, search for ``` and move to next line (inside the block)
    local found = vim.fn.search('^```{', 'W')
    if found > 0 then
      vim.cmd('normal! j')  -- Move to first line inside code block
    end
  end
end

local function prev_cell()
  local ft = vim.bo.filetype
  if ft == 'python' then
    -- For Python, move up one line first to avoid matching current cell, then search backwards
    local current_line = vim.fn.line('.')
    vim.fn.cursor(current_line - 1, 1)
    local found = vim.fn.search('^#%%', 'bW')
    if found > 0 then
      vim.cmd('normal! j')  -- Move to first line below #%%
    end
  else
    -- For Quarto, move up first then search backwards for ``` and move to next line
    local current_line = vim.fn.line('.')
    vim.fn.cursor(current_line - 1, 1)
    local found = vim.fn.search('^```{', 'bW')
    if found > 0 then
      vim.cmd('normal! j')  -- Move to first line inside code block
    end
  end
end

vim.keymap.set('n', ']c', next_cell, { silent = true, desc = 'next code cell' })
vim.keymap.set('n', '[c', prev_cell, { silent = true, desc = 'previous code cell' })

-- Visual mode: run selection
vim.keymap.set('v', '<cr>', function()
  local ft = vim.bo.filetype
  if ft == 'python' then
    vim.cmd("'<,'>SlimeSend")
  else
    require("quarto.runner").run_range()
  end
end, { silent = true, desc = 'run visual range' })

-- Insert mode shortcuts for code chunks
vim.keymap.set('i', '<m-i>', function() insert_code_chunk('r') end, { silent = true, desc = 'r code chunk' })
vim.keymap.set('i', '<m-I>', function() insert_code_chunk('python') end, { silent = true, desc = 'python code chunk' })

-- Which-key groups for Quarto
lvim.builtin.which_key.mappings["q"] = {
  name = "Quarto",
  a = { ":QuartoActivate<cr>", "Activate" },
  p = { ":lua require('quarto').quartoPreview()<cr>", "Preview" },
  q = { ":lua require('quarto').quartoClosePreview()<cr>", "Close Preview" },
  h = { ":QuartoHelp ", "Help" },
  m = { ":lua require('nabla').toggle_virt()<cr>", "Toggle Math" },
  c = { function()
    local file = vim.fn.expand('%:p')
    local dir = vim.fn.expand('%:p:h')
    local basename = vim.fn.expand('%:t:r')
    -- Remove HTML output and _files folder
    vim.fn.system('rm -f ' .. dir .. '/' .. basename .. '.html')
    vim.fn.system('rm -rf ' .. dir .. '/' .. basename .. '_files')
    vim.print('Cleaned: ' .. basename .. '.html and ' .. basename .. '_files/')
  end, "Clean output files" },
}

-- Helper functions for running code (works for both Quarto and Python files)
local function run_cell_smart()
  local ft = vim.bo.filetype
  if ft == 'python' then
    vim.fn['slime#send_cell']()
  else
    require("quarto.runner").run_cell()
  end
end

local function run_all_smart()
  local ft = vim.bo.filetype
  if ft == 'python' then
    -- Send entire file to slime
    vim.fn['slime#send'](table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n') .. '\r')
  else
    require("quarto.runner").run_all(true)
  end
end

local function run_line_smart()
  local ft = vim.bo.filetype
  if ft == 'python' then
    vim.fn['slime#send'](vim.fn.getline('.') .. '\r')
  else
    require("quarto.runner").run_line()
  end
end

-- Run code keybindings (top-level for quick access)
lvim.builtin.which_key.mappings["r"] = {
  name = "Run",
  r = { run_cell_smart, "Run Cell" },
  a = { run_all_smart, "Run All Cells" },
  l = { run_line_smart, "Run Line" },
  u = { function()
    local ft = vim.bo.filetype
    if ft ~= 'python' then
      require("quarto.runner").run_above()
    end
  end, "Run Cell and Above" },
  d = { function()
    local ft = vim.bo.filetype
    if ft ~= 'python' then
      require("quarto.runner").run_below()
    end
  end, "Run Cell and Below" },
  j = { next_cell, "Next Cell" },
  k = { prev_cell, "Previous Cell" },
  x = { delete_cell, "Delete Cell" },
}

-- Override LunarVim's default <leader>c (close buffer) with code/chunks
lvim.builtin.which_key.mappings["c"] = {
  name = "Code/Chunks",
  m = { "<cmd>lua vim.fn.call('slime#config', {})<cr>", "Mark terminal" },
  s = { "<cmd>lua vim.fn.call('slime#config', {})<cr>", "Set terminal" },
  t = { "<cmd>lua vim.g.slime_target = vim.g.slime_target == 'tmux' and 'neovim' or 'tmux'; vim.print('Slime target: ' .. vim.g.slime_target)<cr>", "Toggle tmux/neovim" },
  r = { function() new_terminal('R --no-save') end, "New R terminal" },
  p = { new_terminal_smart_python, "New Python/IPython terminal" },
  i = { new_terminal_smart_python, "New Python/IPython terminal" },
  j = { function() new_terminal('julia') end, "New Julia terminal" },
  n = { function() new_terminal('$SHELL') end, "New Shell terminal" },
}

lvim.builtin.which_key.mappings["o"] = {
  name = "Otter & Code",
  a = { function() require('otter').activate() end, "Otter Activate" },
  d = { function() require('otter').deactivate() end, "Otter Deactivate" },
  r = { function() insert_code_chunk('r') end, "R chunk" },
  p = { function() insert_code_chunk('python') end, "Python chunk" },
  j = { function() insert_code_chunk('julia') end, "Julia chunk" },
  b = { function() insert_code_chunk('bash') end, "Bash chunk" },
  l = { function() insert_code_chunk('lua') end, "Lua chunk" },
}