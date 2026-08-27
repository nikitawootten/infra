return {
	{
		"colorful-menu.nvim",
		auto_enable = true,
		on_plugin = { "blink.cmp" },
	},
	{
		"blink.cmp",
		auto_enable = true,
		event = "DeferredUIEnter",
		after = function(_)
			require("blink.cmp").setup({
				keymap = { preset = "default" },
				cmdline = {
					enabled = true,
					completion = { menu = { auto_show = true } },
					sources = function()
						local t = vim.fn.getcmdtype()
						if t == "/" or t == "?" then
							return { "buffer" }
						end
						if t == ":" or t == "@" then
							return { "cmdline" }
						end
						return {}
					end,
				},
				signature = { enabled = true, window = { show_documentation = true } },
				completion = {
					menu = {
						draw = {
							treesitter = { "lsp" },
							components = {
								label = {
									text = function(ctx)
										return require("colorful-menu").blink_components_text(ctx)
									end,
									highlight = function(ctx)
										return require("colorful-menu").blink_components_highlight(ctx)
									end,
								},
							},
						},
					},
					documentation = { auto_show = true },
				},
				sources = {
					default = { "lsp", "path", "buffer", "omni" },
					providers = {
						path = { score_offset = 50 },
						lsp = { score_offset = 40 },
					},
				},
			})
		end,
	},
	{
		"copilot.lua",
		auto_enable = true,
		event = "InsertEnter",
		cmd = { "Copilot" },
		after = function(_)
			require("copilot").setup({
				panel = { enabled = false },
				server_opts_overrides = {
					-- suppress auth error popups when not signed in
					handlers = {
						["window/showMessage"] = function(_, result, _)
							if result.type > vim.lsp.protocol.MessageType.Warning then
								return
							end
							vim.notify(result.message, vim.log.levels.WARN)
						end,
					},
				},
				suggestion = {
					enabled = true,
					auto_trigger = true,
					-- NB: avoid <C-[> (== <Esc>) and <C-h> (== <BS>) here, they shadow core keys
					keymap = { accept = "<C-l>", next = "<M-]>", prev = "<M-[>", dismiss = "<C-]>" },
				},
			})
			vim.keymap.set("n", "<leader>tc", function()
				require("copilot.suggestion").toggle_auto_trigger()
			end, { desc = "Toggle Copilot auto-trigger" })
		end,
	},
}
