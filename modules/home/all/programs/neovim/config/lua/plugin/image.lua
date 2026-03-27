require("image").setup({
  backend = "kitty",
  processor = "magick_cli",
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = true,
      download_remote_images = true,
      only_render_image_at_cursor = true,
      only_render_image_at_cursor_mode = "popup",
      floating_windows = false,
      filetypes = { "markdown", "vimwiki" },
    },
    neorg = {
      enabled = false,
      filetypes = { "norg" },
    },
    typst = {
      enabled = false,
      filetypes = { "typst" },
    },
    html = {
      enabled = false,
    },
    css = {
      enabled = false,
    },
  },
  max_width = nil,
  max_height = nil,
  max_width_window_percentage = nil,
  max_height_window_percentage = 50,
  scale_factor = 1.0,
  window_overlap_clear_enabled = true,
  window_overlap_clear_ft_ignore = {
    "cmp_menu",
    "cmp_docs",
    "snacks_notif",
    "scrollview",
    "scrollview_sign",
  },
  editor_only_render_when_focused = true,
  tmux_show_only_in_active_window = false,
  hijack_file_patterns = {
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.gif",
    "*.webp",
    "*.avif",
  },
  kitty_method = "normal",
})
