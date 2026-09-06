return {
	{
		"conform.nvim",
		auto_enable = true,
		event = "DeferredUIEnter",
		keys = {
			{ "<leader>cf", desc = "[C]ode [F]ormat" },
			{ "<leader>tf", desc = "Toggle format on save" },
		},
		after = function(_)
			local conform = require("conform")
			conform.setup({
				formatters_by_ft = {
					nix = { "nixfmt" },
					lua = { "stylua" },
					python = { "ruff_organize_imports", "ruff_format" },
					rust = { "rustfmt" },
					javascript = { "prettier" },
					javascriptreact = { "prettier" },
					typescript = { "prettier" },
					typescriptreact = { "prettier" },
				},
				format_on_save = function(bufnr)
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { lsp_format = "fallback", timeout_ms = 1000 }
				end,
			})
			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				conform.format({ lsp_format = "fallback", async = false, timeout_ms = 1000 })
			end, { desc = "[C]ode [F]ormat" })
			vim.keymap.set("n", "<leader>tf", function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify("Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
			end, { desc = "Toggle format on save" })
		end,
	},
}
