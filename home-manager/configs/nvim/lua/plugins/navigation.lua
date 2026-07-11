return {
  { import = "lazyvim.plugins.extras.editor.snacks_picker" },
  { import = "lazyvim.plugins.extras.editor.snacks_explorer" },
  { import = "lazyvim.plugins.extras.editor.harpoon2" },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Move Left" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Move Down" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Move Up" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Move Right" },
    },
  },
}
