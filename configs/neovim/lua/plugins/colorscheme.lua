return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = true,
	priority = 1000, -- Make sure to load this before all the other start plugins.
	opts = {
		flavour = "mocha",
	},
	init = function()
		vim.cmd.colorscheme("catppuccin")
	end,
}
