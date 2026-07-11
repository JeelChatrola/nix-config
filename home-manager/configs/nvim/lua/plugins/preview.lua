return {
  {
    "brianhuster/live-preview.nvim",
    cmd = "LivePreview",
    opts = {
      picker = "snacks.picker",
      sync_scroll = true,
    },
    keys = {
      { "<leader>mp", "<cmd>LivePreview start<cr>", desc = "Preview Document" },
      { "<leader>mP", "<cmd>LivePreview close<cr>", desc = "Close Document Preview" },
    },
  },
}
