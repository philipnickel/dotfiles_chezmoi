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
    vim.g.vimtex_view_zathura_options = "--synctex-forward @line:@col:@file"
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

-- Quarto support
table.insert(lvim.plugins, {
  "quarto-dev/quarto-nvim",
  ft = { "quarto", "markdown" },
  dependencies = {
    "jmbuhr/otter.nvim",
  },
  opts = {
    lspFeatures = {
      enabled = true,
      chunks = "curly",
      languages = { "r", "python", "julia", "bash", "lua", "html" },
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
      default_method = "slime",
    },
  },
})

-- Vim-slime for REPL integration
table.insert(lvim.plugins, {
  "jpalardy/vim-slime",
  init = function()
    vim.b['quarto_is_python_chunk'] = false
    Quarto_is_in_python_chunk = function()
      require('otter.tools.functions').is_otter_language_context('python')
    end

    vim.cmd([[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
    ]])

    -- Default to neovim, but can be changed to tmux
    vim.g.slime_target = "neovim"
    vim.g.slime_no_mappings = true
    vim.g.slime_python_ipython = 1
  end,
  config = function()
    vim.g.slime_input_pid = false
    vim.g.slime_suggest_default = true
    vim.g.slime_menu_config = false
    vim.g.slime_neovim_ignore_unlisted = true

    local function mark_terminal()
      local job_id = vim.b.terminal_job_id
      vim.print('job_id: ' .. job_id)
    end

    local function set_terminal()
      vim.fn.call('slime#config', {})
    end

    local function toggle_slime_tmux_neovim()
      if vim.g.slime_target == "tmux" then
        vim.g.slime_target = "neovim"
        vim.print("Slime target: neovim")
      else
        vim.g.slime_target = "tmux"
        vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
        vim.print("Slime target: tmux")
      end
    end

    vim.keymap.set('n', '<leader>cm', mark_terminal, { desc = '[m]ark terminal' })
    vim.keymap.set('n', '<leader>cs', set_terminal, { desc = '[s]et terminal' })
    vim.keymap.set('n', '<leader>ct', toggle_slime_tmux_neovim, { desc = '[t]oggle slime tmux/neovim' })
  end,
})

-- Jupytext for opening ipynb files as quarto
table.insert(lvim.plugins, {
  "GCBallesteros/jupytext.nvim",
  opts = {
    custom_language_formatting = {
      python = {
        extension = "qmd",
        style = "quarto",
        force_ft = "quarto",
      },
      r = {
        extension = "qmd",
        style = "quarto",
        force_ft = "quarto",
      },
    },
  },
})

-- Nabla for math preview
table.insert(lvim.plugins, {
  "jbyuki/nabla.nvim",
  keys = {
    { "<leader>qm", ":lua require('nabla').toggle_virt()<cr>", desc = "toggle [m]ath equations" },
  },
})

-- Image clipboard support
table.insert(lvim.plugins, {
  "HakonHarnes/img-clip.nvim",
  event = "BufEnter",
  ft = { "markdown", "quarto", "latex" },
  opts = {
    default = {
      dir_path = "img",
    },
    filetypes = {
      markdown = {
        url_encode_path = true,
        template = "![$CURSOR]($FILE_PATH)",
        drag_and_drop = {
          download_images = false,
        },
      },
      quarto = {
        url_encode_path = true,
        template = "![$CURSOR]($FILE_PATH)",
        drag_and_drop = {
          download_images = false,
        },
      },
    },
  },
  config = function(_, opts)
    require("img-clip").setup(opts)
    vim.keymap.set("n", "<leader>ii", ":PasteImage<cr>", { desc = "insert [i]mage from clipboard" })
  end,
})

-- Molten for Jupyter kernel integration
table.insert(lvim.plugins, {
  "benlubas/molten-nvim",
  version = "^1.0.0",
  build = ":UpdateRemotePlugins",
  enabled = true,
  init = function()
    vim.g.molten_image_provider = "image.nvim"
    vim.g.molten_auto_open_output = true
    vim.g.molten_auto_open_html_in_browser = true
    vim.g.molten_tick_rate = 200
  end,
  config = function()
    local function molten_init()
      local quarto_cfg = require("quarto.config").config
      quarto_cfg.codeRunner.default_method = "molten"
      vim.cmd([[MoltenInit]])
    end
    local function molten_deinit()
      local quarto_cfg = require("quarto.config").config
      quarto_cfg.codeRunner.default_method = "slime"
      vim.cmd([[MoltenDeinit]])
    end
    vim.keymap.set("n", "<localleader>mi", molten_init, { silent = true, desc = "Initialize molten" })
    vim.keymap.set("n", "<localleader>md", molten_deinit, { silent = true, desc = "Stop molten" })
    vim.keymap.set("n", "<localleader>mp", ":MoltenImagePopup<CR>", { silent = true, desc = "molten image popup" })
    vim.keymap.set("n", "<localleader>mb", ":MoltenOpenInBrowser<CR>", { silent = true, desc = "molten open in browser" })
    vim.keymap.set("n", "<localleader>mh", ":MoltenHideOutput<CR>", { silent = true, desc = "hide output" })
    vim.keymap.set("n", "<localleader>ms", ":noautocmd MoltenEnterOutput<CR>", { silent = true, desc = "show/enter output" })
  end,
})