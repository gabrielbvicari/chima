return {
  { "sekke276/dark_flat.nvim", lazy = false, priority = 1000, enable = false },
  { "olimorris/onedarkpro.nvim", lazy = false, priority = 1000, enable = false },
  { "dasupradyumna/midnight.nvim", lazy = false, priority = 1000, enable = false },
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, enable = false },
  { "nyoom-engineering/oxocarbon.nvim", lazy = false, priority = 1000, enable = false },
  { "zenbones-theme/zenbones.nvim", dependencies = "rktjmp/lush.nvim", lazy = false, priority = 1000, enable = false },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      no_italic = true,
      term_colors = true,
      transparent_background = true,
      styles = {
        comments = {},
        conditionals = {},
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
      },
      color_overrides = {
        mocha = {
          rosewater = "#ffc0b9",
          flamingo = "#f5aba3",
          pink = "#f592d6",
          mauve = "#c0afff",
          red = "#ea746c",
          maroon = "#ff8595",
          peach = "#fa9a6d",
          yellow = "#ffe081",
          green = "#99d783",
          teal = "#47deb4",
          sky = "#00d5ed",
          sapphire = "#00dfce",
          blue = "#00baee",
          lavender = "#abbff3",
          text = "#cccccc",
          subtext1 = "#bbbbbb",
          subtext0 = "#aaaaaa",
          overlay2 = "#999999",
          overlay1 = "#888888",
          overlay0 = "#777777",
          surface2 = "#333333",
          surface1 = "#222222",
          surface0 = "#111111",
          base = "#000000",
          mantle = "#000000",
          crust = "#000000",
        },
      },
      integrations = {
        telescope = {
          enabled = true,
          style = "nvchad",
        },
        dropbar = {
          enabled = true,
          color_mode = true,
        },
        neotree = true,
        bufferline = true,
      },
      custom_highlights = {
        NeoTreeTabActive = { bg = "#111111" },
        NeoTreeTabInactive = { bg = "#000000" },
        NeoTreeTabSeparatorActive = { fg = "#111111", bg = "#111111" },
        NeoTreeTabSeparatorInactive = { fg = "#000000", bg = "#000000" },
        ColorColumn = { bg = "#111111" },
      },
    },
  },
  -- Fix LazyVim bufferline integration with Catppuccin
  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      if (vim.g.colors_name or ""):find("catppuccin") then
        -- Use the current Catppuccin API
        opts.highlights = require("catppuccin.special.bufferline").get_theme()
      end
    end,
  },
}
