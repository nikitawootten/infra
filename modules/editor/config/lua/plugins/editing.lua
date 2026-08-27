return {
	{
		"nvim-surround",
		auto_enable = true,
		event = "DeferredUIEnter",
		after = function(_)
			require("nvim-surround").setup()
		end,
	},
	{
		"vim-startuptime",
		auto_enable = true,
		cmd = { "StartupTime" },
		before = function(_)
			vim.g.startuptime_event_width = 0
			vim.g.startuptime_tries = 10
			vim.g.startuptime_exe_path = nixInfo(vim.v.progpath, "progpath")
		end,
	},
	{
		"direnv.vim",
		auto_enable = true,
		lazy = false,
		before = function(_)
			vim.g.direnv_silent_load = 1
		end,
	},
}
