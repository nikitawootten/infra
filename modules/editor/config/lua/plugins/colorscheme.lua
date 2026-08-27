-- Written by Noctalia's `nvim-base16` user template; see modules/personal/niri.nix.
local noctalia_base16 = vim.fn.stdpath("state") .. "/noctalia-base16.lua"

local function apply_noctalia_base16()
	local ok, colors = pcall(dofile, noctalia_base16)
	if not ok then
		return
	end
	require("base16-colorscheme").setup(colors)
	-- setup() only rewrites highlight groups, so nothing else learns the palette moved.
	vim.api.nvim_exec_autocmds("ColorScheme", { pattern = vim.g.colors_name })
end

local noctalia_signal = vim.uv.new_signal()
noctalia_signal:start("sigusr1", vim.schedule_wrap(apply_noctalia_base16))

return {
	{
		"trigger_colorscheme",
		event = "VimEnter",
		load = function(_)
			vim.schedule(function()
				vim.cmd.colorscheme("base16-tokyo-night-dark")
				apply_noctalia_base16()
			end)
		end,
	},
	{
		"base16-nvim",
		auto_enable = true,
		colorscheme = { "base16-tokyo-night-dark" },
	},
}
