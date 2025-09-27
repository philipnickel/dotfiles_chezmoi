-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
--
--
--
--
lvim.transparent_window = true

vim.opt.relativenumber = false
vim.opt.wrap = true

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

table.insert(lvim.plugins, {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = function() vim.fn["mkdp#util#install"]() end,
})

-- Quarto support
table.insert(lvim.plugins, {
  "quarto-dev/quarto-nvim",
  dependencies = {
    "jmbuhr/otter.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  ft = { "quarto" },
  config = function()
    require("quarto").setup({
      debug = false,
      closePreviewOnExit = true,
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "r", "python", "julia", "bash", "html" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "slime", -- 'molten' or 'slime'
        ft_runners = {
          r = "slime",
          python = "slime",
        }, -- filetype to runner, ie. `{ python = "molten" }`
        never_run = { "yaml" }, -- filetypes which are never sent to a code runner
      },
    })
  end,
})

-- Better syntax highlighting for code blocks
table.insert(lvim.plugins, {
  "jmbuhr/otter.nvim",
  dependencies = {
    "hrsh7th/nvim-cmp",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {},
})

-- REPL integration with vim-slime
table.insert(lvim.plugins, {
  "jpalardy/vim-slime",
  config = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = {
      socket_name = "default",
      target_pane = "{last}",
    }
    vim.g.slime_dont_ask_default = 1
    vim.g.slime_no_mappings = 1
  end,
})

-- Alternative: Iron.nvim for more advanced REPL management
table.insert(lvim.plugins, {
  "hkupty/iron.nvim",
  config = function()
    local iron = require("iron.core")
    iron.setup({
      config = {
        scratch_repl = true,
        repl_definition = {
          r = {
            command = { "R" },
          },
          python = {
            command = { "python3" },
            format = require("iron.fts.common").bracketed_paste,
          },
        },
        repl_open_cmd = require("iron.view").bottom(40),
      },
      keymaps = {
        send_motion = "<space>sc",
        visual_send = "<space>sc",
        send_file = "<space>sf",
        send_line = "<space>sl",
        send_until_cursor = "<space>su",
        send_mark = "<space>sm",
        mark_motion = "<space>mc",
        mark_visual = "<space>mc",
        remove_mark = "<space>md",
        cr = "<space>s<cr>",
        interrupt = "<space>s<space>",
        exit = "<space>sq",
        clear = "<space>cl",
      },
      highlight = {
        italic = true,
      },
      ignore_blank_lines = true,
    })
  end,
})

-- Enhanced Telescope extensions for better search
table.insert(lvim.plugins, {
  "nvim-telescope/telescope-live-grep-args.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("live_grep_args")
  end,
})

table.insert(lvim.plugins, {
  "nvim-telescope/telescope-fzf-native.nvim",
  build = "make",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("fzf")
  end,
})


table.insert(lvim.plugins, {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
})




-- Markdown preview key binding
lvim.keys.normal_mode["<leader>mp"] = "<cmd>MarkdownPreviewToggle<cr>"

-- Quarto keybindings
lvim.keys.normal_mode["<leader>qp"] = "<cmd>QuartoPreview<cr>"
lvim.keys.normal_mode["<leader>qq"] = "<cmd>QuartoClosePreview<cr>"
lvim.keys.normal_mode["<leader>qh"] = "<cmd>QuartoHelp<cr>"
lvim.keys.normal_mode["<leader>qe"] = "<cmd>QuartoSendAbove<cr>"
lvim.keys.normal_mode["<leader>qa"] = "<cmd>QuartoSendAll<cr>"

-- Run code chunks in Quarto
lvim.keys.normal_mode["<leader>rc"] = function()
  require("quarto.runner").run_cell()
end
lvim.keys.normal_mode["<leader>ra"] = function()
  require("quarto.runner").run_above()
end
lvim.keys.normal_mode["<leader>rA"] = function()
  require("quarto.runner").run_all()
end

-- vim-slime keybindings for REPL interaction
lvim.keys.normal_mode["<leader>ss"] = "<Plug>SlimeLineSend"
lvim.keys.visual_mode["<leader>ss"] = "<Plug>SlimeRegionSend"
lvim.keys.normal_mode["<leader>sp"] = "<Plug>SlimeParagraphSend"
lvim.keys.normal_mode["<leader>sc"] = "<Plug>SlimeConfig"

-- Iron.nvim REPL management (alternative to slime)
lvim.keys.normal_mode["<leader>ir"] = "<cmd>IronRepl<cr>"
lvim.keys.normal_mode["<leader>iR"] = "<cmd>IronRestart<cr>"
lvim.keys.normal_mode["<leader>if"] = "<cmd>IronFocus<cr>"
lvim.keys.normal_mode["<leader>ih"] = "<cmd>IronHide<cr>"

-- Which-key descriptions for better discoverability
lvim.builtin.which_key.mappings["m"] = {
  name = "Markdown",
  p = { "<cmd>MarkdownPreviewToggle<cr>", "Toggle Preview" },
}

lvim.builtin.which_key.mappings["q"] = {
  name = "Quarto",
  p = { "<cmd>QuartoPreview<cr>", "Preview" },
  q = { "<cmd>QuartoClosePreview<cr>", "Close Preview" },
  h = { "<cmd>QuartoHelp<cr>", "Help" },
  e = { "<cmd>QuartoSendAbove<cr>", "Send Above" },
  a = { "<cmd>QuartoSendAll<cr>", "Send All" },
}

lvim.builtin.which_key.mappings["r"] = {
  name = "Run Code",
  c = { function() require("quarto.runner").run_cell() end, "Run Cell" },
  a = { function() require("quarto.runner").run_above() end, "Run Above" },
  A = { function() require("quarto.runner").run_all() end, "Run All" },
}

lvim.builtin.which_key.mappings["s"] = {
  name = "REPL/Slime",
  s = { "<Plug>SlimeLineSend", "Send Line/Selection" },
  p = { "<Plug>SlimeParagraphSend", "Send Paragraph" },
  c = { "<Plug>SlimeConfig", "Configure Slime" },
}

lvim.builtin.which_key.mappings["i"] = {
  name = "Iron REPL",
  r = { "<cmd>IronRepl<cr>", "Open REPL" },
  R = { "<cmd>IronRestart<cr>", "Restart REPL" },
  f = { "<cmd>IronFocus<cr>", "Focus REPL" },
  h = { "<cmd>IronHide<cr>", "Hide REPL" },
}

lvim.builtin.which_key.mappings["o"] = {
  name = "Otter",
  a = { function() require("otter").activate() end, "Activate" },
  d = { function() require("otter").deactivate() end, "Deactivate" },
  c = { function() require("otter").ask_definition() end, "Definition" },
  t = { function() require("otter").ask_type_definition() end, "Type Definition" },
  h = { function() require("otter").ask_hover() end, "Hover" },
  r = { function() require("otter").ask_references() end, "References" },
  f = { function() require("otter").ask_format() end, "Format" },
  s = { function() require("otter").ask_rename() end, "Rename" },
}

-- LaTeX/VimTeX keybindings (using local leader, which is '\' by default)
lvim.builtin.which_key.mappings["l"] = {
  name = "LaTeX",
  l = { "<cmd>VimtexCompile<cr>", "Compile" },
  v = { "<cmd>VimtexView<cr>", "View PDF" },
  k = { "<cmd>VimtexStop<cr>", "Stop" },
  c = { "<cmd>VimtexClean<cr>", "Clean" },
  C = { "<cmd>VimtexClean!<cr>", "Clean All" },
  s = { "<cmd>VimtexStatus<cr>", "Status" },
  i = { "<cmd>VimtexInfo<cr>", "Info" },
  t = { "<cmd>VimtexTocToggle<cr>", "Toggle TOC" },
  T = { "<cmd>VimtexTocOpen<cr>", "Open TOC" },
  w = { "<cmd>VimtexCountWords<cr>", "Count Words" },
  e = { "<cmd>VimtexErrors<cr>", "Show Errors" },
}

-- Code block creation helpers
local function insert_code_block(lang)
  local lines = {
    "```{" .. lang .. "}",
    "",
    "```"
  }
  vim.api.nvim_put(lines, "l", true, true)
  vim.api.nvim_feedkeys("k", "n", false)
end

lvim.builtin.which_key.mappings["c"] = {
  name = "Code Blocks",
  r = { function() insert_code_block("r") end, "R Block" },
  p = { function() insert_code_block("python") end, "Python Block" },
  j = { function() insert_code_block("julia") end, "Julia Block" },
  b = { function() insert_code_block("bash") end, "Bash Block" },
  s = { function() insert_code_block("sql") end, "SQL Block" },
  m = { function() insert_code_block("mermaid") end, "Mermaid Block" },
  c = { function()
    local lang = vim.fn.input("Language: ")
    if lang ~= "" then
      insert_code_block(lang)
    end
  end, "Custom Block" },
}

-- Enhanced Find menu - override default <leader>f
lvim.builtin.which_key.mappings["f"] = {
  name = "Find",
  f = { "<cmd>Telescope find_files<cr>", "Files" },
  g = { function() require("telescope").extensions.live_grep_args.live_grep_args() end, "Grep" },
  w = { "<cmd>Telescope grep_string<cr>", "Word under cursor" },
  b = { "<cmd>Telescope buffers<cr>", "Buffers" },
  r = { "<cmd>Telescope oldfiles<cr>", "Recent files" },
  G = { "<cmd>Telescope git_files<cr>", "Git files" },
  h = { "<cmd>Telescope help_tags<cr>", "Help tags" },
  c = { "<cmd>Telescope commands<cr>", "Commands" },
  s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols" },
  S = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace symbols" },
  d = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
  k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
  m = { "<cmd>Telescope marks<cr>", "Marks" },
  j = { "<cmd>Telescope jumplist<cr>", "Jump list" },
  q = { "<cmd>Telescope quickfix<cr>", "Quickfix" },
  l = { "<cmd>Telescope loclist<cr>", "Location list" },
}

-- Filetype detection
vim.filetype.add({
  extension = {
    qmd = "quarto",
    tex = "tex",
    latex = "tex",
  },
  pattern = {
    ["*.qmd"] = "quarto",
    ["*.tex"] = "tex",
    ["*.latex"] = "tex",
  },
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.tex", "*.latex" },
  callback = function(args)
    vim.api.nvim_buf_set_option(args.buf, "filetype", "tex")
  end,
})

-- Auto-activate otter for quarto files
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.qmd",
  callback = function()
    require("otter").activate({ "r", "python", "julia", "bash", "html" })
  end,
})

-- Enhanced telescope configuration
lvim.builtin.telescope.defaults.file_ignore_patterns = {
  "%.git/",
  "node_modules/",
  "%.npm/",
  "%.next/",
  "%.DS_Store",
}

-- Ensure our find menu overrides the default
vim.api.nvim_create_autocmd("User", {
  pattern = "LunarVimColorSchemeLoaded",
  callback = function()
    -- Remove default find_files binding to avoid conflicts
    lvim.keys.normal_mode["<leader>f"] = nil
  end,
})

-- Configure nvim-tree to open PDFs with Zathura
lvim.builtin.nvimtree.setup.system_open = {
  cmd = "open", -- This will be overridden by our custom function
}

-- Configure nvim-tree the LunarVim way using on_config_done callback
lvim.builtin.nvimtree.on_config_done = function()
  -- Custom function to handle PDF files in nvim-tree
  local function nvim_tree_on_attach(bufnr)
    local api = require("nvim-tree.api")

    -- First, apply default nvim-tree keybindings
    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- Apply all default nvim-tree keybindings
    require("nvim-tree.api").config.mappings.default_on_attach(bufnr)

    local function open_file_with_system()
      local node = api.tree.get_node_under_cursor()
      if node and node.absolute_path then
        -- Handle PDFs with Zathura
        if node.absolute_path:match("%.pdf$") then
          vim.fn.jobstart({ "zathura", node.absolute_path }, { detach = true })
        -- Handle images with Preview (via 'open' command)
        elseif node.absolute_path:match("%.png$") or
               node.absolute_path:match("%.jpe?g$") or
               node.absolute_path:match("%.gif$") or
               node.absolute_path:match("%.bmp$") or
               node.absolute_path:match("%.tiff?$") or
               node.absolute_path:match("%.webp$") then
          vim.fn.jobstart({ "open", node.absolute_path }, { detach = true })
        else
          api.node.open.edit()
        end
      end
    end

    -- Override only the specific keybindings for Enter and 'o' for PDF/image handling
    vim.keymap.set('n', '<CR>', open_file_with_system, opts('Open: PDFs with Zathura, Images with Preview'))
    vim.keymap.set('n', 'o', open_file_with_system, opts('Open: PDFs with Zathura, Images with Preview'))
  end

  require("nvim-tree").setup({
    filters = {
      dotfiles = false,
      custom = {
        "__pycache__",
        "*.pyc",
        ".DS_Store",
        "^\\.git$"
      }
    },
    filesystem_watchers = {
      enable = true,
    },
    actions = {
      use_system_clipboard = true,
      change_dir = {
        enable = true,
        global = false,
      },
      open_file = {
        quit_on_open = false,
        resize_window = false,
      },
      remove_file = {
        close_window = true,
      },
    },
    on_attach = nvim_tree_on_attach,
  })
end

-- Language server configurations for Quarto
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "r_language_server" })

local lspconfig = require("lspconfig")

-- R language server
lspconfig.r_language_server.setup({
  on_attach = require("lvim.lsp").common_on_attach,
  capabilities = require("lvim.lsp").common_capabilities(),
})

-- Python language server (if not already configured)
if not vim.tbl_contains(lvim.lsp.automatic_configuration.skipped_servers, "pyright") then
  vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
end

lspconfig.pyright.setup({
  on_attach = require("lvim.lsp").common_on_attach,
  capabilities = require("lvim.lsp").common_capabilities(),
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
      },
    },
  },
})

-- Treesitter configuration for Quarto and LaTeX
vim.list_extend(lvim.builtin.treesitter.ensure_installed, {
  "r",
  "python",
  "markdown",
  "markdown_inline",
  "julia",
  "bash",
  "yaml",
  "html",
  "css",
  "javascript",
  "typescript",
  "lua",
  "latex",
  "bibtex",
})

-- Pick a PDF viewer that is available on the system
local function pick_vimtex_viewer()
  if vim.fn.executable("zathura") == 1 then
    return "zathura"
  end

  if vim.fn.executable("sioyek") == 1 then
    return "sioyek"
  end

  local uname = vim.loop.os_uname().sysname
  if uname == "Darwin" and vim.fn.executable("open") == 1 then
    vim.g.vimtex_view_general_viewer = "open"
    vim.g.vimtex_view_general_options = "-a Preview"
    return "general"
  end

  if vim.fn.executable("xdg-open") == 1 then
    vim.g.vimtex_view_general_viewer = "xdg-open"
    vim.g.vimtex_view_general_options = ""
    return "general"
  end

  return nil -- fall back to VimTeX defaults if nothing sensible found
end

local vimtex_view_method = pick_vimtex_viewer()
if vimtex_view_method then
vim.g.vimtex_view_method = vimtex_view_method

  if vimtex_view_method == "zathura" then
    vim.g.vimtex_view_zathura_use_synctex = 1
  end
end
vim.g.tex_flavor = 'latex'
vim.g.vimtex_quickfix_mode = 0
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_progname = 'nvr'
vim.g.vimtex_compiler_latexmk = {
  build_dir = '',
  callback = 1,
  continuous = 1,
  executable = 'latexmk',
  hooks = {},
  options = {
    '-verbose',
    '-file-line-error',
    '-synctex=1',
    '-interaction=nonstopmode',
  },
}

-- VimTeX plugin installation
table.insert(lvim.plugins, {
  "lervag/vimtex",
  lazy = false,     -- we don't want to lazy load VimTeX
  config = function()
    -- VimTeX is now loaded - no additional config needed
    -- since we set the global variables above
  end
})

-- Configure Telescope to open PDFs with Zathura and images with Preview
local function open_with_system_app(prompt_bufnr)
  local selection = require("telescope.actions.state").get_selected_entry()
  require("telescope.actions").close(prompt_bufnr)
  if selection and selection.path then
    -- Handle PDFs with Zathura
    if selection.path:match("%.pdf$") then
      vim.fn.jobstart({ "zathura", selection.path }, { detach = true })
    -- Handle images with Preview
    elseif selection.path:match("%.png$") or
           selection.path:match("%.jpe?g$") or
           selection.path:match("%.gif$") or
           selection.path:match("%.bmp$") or
           selection.path:match("%.tiff?$") or
           selection.path:match("%.webp$") then
      vim.fn.jobstart({ "open", selection.path }, { detach = true })
    else
      vim.cmd("edit " .. selection.path)
    end
  end
end

-- Override default file open action for telescope
lvim.builtin.telescope.defaults.mappings = {
  i = {
    ["<CR>"] = function(prompt_bufnr)
      local selection = require("telescope.actions.state").get_selected_entry()
      if selection and selection.path and (
        selection.path:match("%.pdf$") or
        selection.path:match("%.png$") or
        selection.path:match("%.jpe?g$") or
        selection.path:match("%.gif$") or
        selection.path:match("%.bmp$") or
        selection.path:match("%.tiff?$") or
        selection.path:match("%.webp$")
      ) then
        open_with_system_app(prompt_bufnr)
      else
        require("telescope.actions").select_default(prompt_bufnr)
      end
    end,
  },
  n = {
    ["<CR>"] = function(prompt_bufnr)
      local selection = require("telescope.actions.state").get_selected_entry()
      if selection and selection.path and (
        selection.path:match("%.pdf$") or
        selection.path:match("%.png$") or
        selection.path:match("%.jpe?g$") or
        selection.path:match("%.gif$") or
        selection.path:match("%.bmp$") or
        selection.path:match("%.tiff?$") or
        selection.path:match("%.webp$")
      ) then
        open_with_system_app(prompt_bufnr)
      else
        require("telescope.actions").select_default(prompt_bufnr)
      end
    end,
  },
}
