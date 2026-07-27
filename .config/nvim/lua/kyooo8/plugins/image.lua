return {
	"3rd/image.nvim",
	enabled = vim.env.TERM_PROGRAM == "WezTerm",
	build = false,
	opts = {
		backend = "sixel",
		processor = "magick_cli",
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "markdown", "vimwiki" },
			},
		},
		max_width = 100,
		max_height = 24,
		max_width_window_percentage = 50,
		max_height_window_percentage = 30,
		window_overlap_clear_enabled = true,
		editor_only_render_when_focused = true,
		tmux_show_only_in_active_window = true,
		hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
	},
}
