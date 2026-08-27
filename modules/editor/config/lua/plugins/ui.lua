return {
	{
		"fidget.nvim",
		auto_enable = true,
		event = "DeferredUIEnter",
		after = function(_)
			require("fidget").setup({})
		end,
	},
	{
		"lualine.nvim",
		auto_enable = true,
		event = "DeferredUIEnter",
		after = function(_)
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "base16",
					component_separators = "|",
					section_separators = "",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff" },
					lualine_c = { { "filename", path = 1, status = true } },
					lualine_x = { "diagnostics", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_b = { { "filename", path = 3, status = true } },
					lualine_x = { "filetype" },
				},
			})
		end,
	},
	{
		"which-key.nvim",
		auto_enable = true,
		event = "DeferredUIEnter",
		after = function(_)
			require("which-key").setup({ preset = "helix" })
			vim.keymap.set("n", "<leader>?", function()
				require("which-key").show({ global = false })
			end, { desc = "Buffer-local keymaps (which-key)" })
			require("which-key").add({
				{ "<leader>b", group = "[b]uffer" },
				{ "<leader>c", group = "[c]ode" },
				{ "<leader>d", group = "[d]ocument" },
				{ "<leader>f", group = "[f]ind" },
				{ "<leader>g", group = "[g]it" },
				{ "<leader>r", group = "[r]ename" },
				{ "<leader>s", group = "[s]earch" },
				{ "<leader>t", group = "[t]oggles" },
				{ "<leader>w", group = "[w]orkspace" },
				{ "<leader>x", group = "[x] diagnostics/trouble" },
				{ "<leader>z", group = "[z] spelling" },
			})
		end,
	},
}
