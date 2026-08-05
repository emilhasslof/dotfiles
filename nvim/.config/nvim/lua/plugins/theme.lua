-- Static theme for the portable setup (was an Omarchy dynamic-theme symlink).
-- Matches your Omarchy nordfox look. Change the colorscheme here to restyle.
return {
	{ "EdenEast/nightfox.nvim" },
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "nordfox",
		},
	},
}
