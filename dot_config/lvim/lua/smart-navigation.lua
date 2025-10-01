-- Smart Navigation
-- Jump between comments, headings, and other semantic elements based on filetype

local M = {}

-- ============================================================================
-- Comment Detection by Filetype
-- ============================================================================

-- Get comment patterns for current filetype
local function get_comment_patterns()
  local ft = vim.bo.filetype

  -- Define comment patterns for each filetype
  local patterns = {
    python = { "^%s*#", "^%s*\"\"\"", "^%s*'''" },
    lua = { "^%s*%-%-", "^%s*%-%-%[%[" },
    vim = { "^%s*\"" },
    tex = { "^%s*%%" },
    latex = { "^%s*%%" },
    markdown = { "^%s*<!%-%-", "^#{1,6}%s" },  -- Also matches headings
    html = { "^%s*<!%-%-" },
    css = { "^%s*/%*" },
    javascript = { "^%s*//", "^%s*/%*" },
    typescript = { "^%s*//", "^%s*/%*" },
    rust = { "^%s*//", "^%s*/%*" },
    go = { "^%s*//" },
    c = { "^%s*//", "^%s*/%*" },
    cpp = { "^%s*//", "^%s*/%*" },
    java = { "^%s*//", "^%s*/%*" },
    sh = { "^%s*#" },
    bash = { "^%s*#" },
    zsh = { "^%s*#" },
    yaml = { "^%s*#" },
    toml = { "^%s*#" },
    conf = { "^%s*#" },
    r = { "^%s*#" },
  }

  return patterns[ft] or { "^%s*#" }  -- Default to # if filetype not found
end

-- Check if a line matches any comment pattern
local function is_comment_line(line_text, patterns)
  for _, pattern in ipairs(patterns) do
    if line_text:match(pattern) then
      return true
    end
  end
  return false
end

-- ============================================================================
-- Navigation Functions
-- ============================================================================

-- Jump to next comment
function M.jump_to_next_comment()
  local patterns = get_comment_patterns()
  local current_line = vim.fn.line('.')
  local last_line = vim.fn.line('$')

  -- Search forward from current line + 1
  for line_num = current_line + 1, last_line do
    local line_text = vim.fn.getline(line_num)
    if is_comment_line(line_text, patterns) then
      vim.fn.cursor(line_num, 1)
      vim.cmd('normal! ^')  -- Move to first non-blank character
      return
    end
  end

  -- No comment found, notify user
  vim.notify("No more comments below", vim.log.levels.INFO)
end

-- Jump to previous comment
function M.jump_to_prev_comment()
  local patterns = get_comment_patterns()
  local current_line = vim.fn.line('.')

  -- Search backward from current line - 1
  for line_num = current_line - 1, 1, -1 do
    local line_text = vim.fn.getline(line_num)
    if is_comment_line(line_text, patterns) then
      vim.fn.cursor(line_num, 1)
      vim.cmd('normal! ^')  -- Move to first non-blank character
      return
    end
  end

  -- No comment found, notify user
  vim.notify("No more comments above", vim.log.levels.INFO)
end

-- ============================================================================
-- LaTeX-Specific Navigation
-- ============================================================================

-- Jump to next LaTeX section/subsection/etc.
function M.jump_to_next_section()
  local current_line = vim.fn.line('.')
  local last_line = vim.fn.line('$')

  -- Pattern matches \section, \subsection, \subsubsection, \chapter, etc.
  local section_pattern = "^%s*\\[a-z]*section"

  for line_num = current_line + 1, last_line do
    local line_text = vim.fn.getline(line_num)
    if line_text:match(section_pattern) then
      vim.fn.cursor(line_num, 1)
      vim.cmd('normal! ^')
      return
    end
  end

  vim.notify("No more sections below", vim.log.levels.INFO)
end

function M.jump_to_prev_section()
  local current_line = vim.fn.line('.')
  local section_pattern = "^%s*\\[a-z]*section"

  for line_num = current_line - 1, 1, -1 do
    local line_text = vim.fn.getline(line_num)
    if line_text:match(section_pattern) then
      vim.fn.cursor(line_num, 1)
      vim.cmd('normal! ^')
      return
    end
  end

  vim.notify("No more sections above", vim.log.levels.INFO)
end

-- ============================================================================
-- Markdown-Specific Navigation
-- ============================================================================

-- Jump to next markdown heading
function M.jump_to_next_heading()
  local current_line = vim.fn.line('.')
  local last_line = vim.fn.line('$')

  -- Pattern matches # headings
  local heading_pattern = "^#{1,6}%s"

  for line_num = current_line + 1, last_line do
    local line_text = vim.fn.getline(line_num)
    if line_text:match(heading_pattern) then
      vim.fn.cursor(line_num, 1)
      vim.cmd('normal! ^')
      return
    end
  end

  vim.notify("No more headings below", vim.log.levels.INFO)
end

function M.jump_to_prev_heading()
  local current_line = vim.fn.line('.')
  local heading_pattern = "^#{1,6}%s"

  for line_num = current_line - 1, 1, -1 do
    local line_text = vim.fn.getline(line_num)
    if line_text:match(heading_pattern) then
      vim.fn.cursor(line_num, 1)
      vim.cmd('normal! ^')
      return
    end
  end

  vim.notify("No more headings above", vim.log.levels.INFO)
end

-- ============================================================================
-- Smart Navigation (filetype-aware)
-- ============================================================================

-- Jump to next semantic element (comment, heading, or section based on filetype)
function M.jump_to_next_semantic()
  local ft = vim.bo.filetype

  if ft == "tex" or ft == "latex" then
    M.jump_to_next_section()
  elseif ft == "markdown" or ft == "quarto" then
    M.jump_to_next_heading()
  else
    M.jump_to_next_comment()
  end
end

function M.jump_to_prev_semantic()
  local ft = vim.bo.filetype

  if ft == "tex" or ft == "latex" then
    M.jump_to_prev_section()
  elseif ft == "markdown" or ft == "quarto" then
    M.jump_to_prev_heading()
  else
    M.jump_to_prev_comment()
  end
end

-- ============================================================================
-- Setup Keymaps
-- ============================================================================

function M.setup()
  -- Visual and normal mode: Shift+J/K to jump between semantic elements
  vim.keymap.set({'n', 'v'}, '<S-j>', M.jump_to_next_semantic,
    { desc = "Jump to next comment/heading/section", silent = true })
  vim.keymap.set({'n', 'v'}, '<S-k>', M.jump_to_prev_semantic,
    { desc = "Jump to previous comment/heading/section", silent = true })

  -- Alternative: use ]c and [c for comment navigation
  vim.keymap.set({'n', 'v'}, ']c', M.jump_to_next_comment,
    { desc = "Jump to next comment", silent = true })
  vim.keymap.set({'n', 'v'}, '[c', M.jump_to_prev_comment,
    { desc = "Jump to previous comment", silent = true })

  -- LaTeX-specific: ]s and [s for sections
  vim.keymap.set({'n', 'v'}, ']s', M.jump_to_next_section,
    { desc = "Jump to next section (LaTeX)", silent = true })
  vim.keymap.set({'n', 'v'}, '[s', M.jump_to_prev_section,
    { desc = "Jump to previous section (LaTeX)", silent = true })

  -- Markdown-specific: ]h and [h for headings
  vim.keymap.set({'n', 'v'}, ']h', M.jump_to_next_heading,
    { desc = "Jump to next heading (Markdown)", silent = true })
  vim.keymap.set({'n', 'v'}, '[h', M.jump_to_prev_heading,
    { desc = "Jump to previous heading (Markdown)", silent = true })
end

return M
