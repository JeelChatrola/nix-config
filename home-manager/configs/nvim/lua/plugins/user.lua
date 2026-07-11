return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      contrast = "hard",
    },
  },
  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = "gruvbox",
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Move Left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Move Down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Move Up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Move Right" },
    },
  },
}
