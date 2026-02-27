return {
  {
    "amitds1997/remote-nvim.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
  },
  {
    "dlvhdr/gh-blame.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    lazy = true,
    cmd = "GhBlame",
  },
}
