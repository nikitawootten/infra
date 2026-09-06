-- support devenv's uv integration
local function find_venv(root)
	if vim.env.VIRTUAL_ENV then
		return vim.env.VIRTUAL_ENV
	end
	for _, dir in ipairs({ root .. "/.venv", root .. "/.devenv/state/venv" }) do
		if vim.uv.fs_stat(dir .. "/bin/python") then
			return dir
		end
	end
end

return {
	{
		"nvim-lspconfig",
		auto_enable = true,
		lsp = function(plugin)
			vim.lsp.config(plugin.name, plugin.lsp or {})
			vim.lsp.enable(plugin.name)
		end,
		before = function(_)
			vim.lsp.config("*", {
				on_attach = function(_, bufnr)
					local nmap = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc and ("LSP: " .. desc) or nil })
					end
					nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
					nmap("gd", function()
						Snacks.picker.lsp_definitions()
					end, "[G]oto [D]efinition")
					nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
					nmap("gr", function()
						Snacks.picker.lsp_references()
					end, "[G]oto [R]eferences")
					nmap("gI", function()
						Snacks.picker.lsp_implementations()
					end, "[G]oto [I]mplementation")
					nmap("<leader>ds", function()
						Snacks.picker.lsp_symbols()
					end, "[D]ocument [S]ymbols")
					nmap("<leader>ws", function()
						Snacks.picker.lsp_workspace_symbols()
					end, "[W]orkspace [S]ymbols")
					nmap("K", vim.lsp.buf.hover, "Hover documentation")
					nmap("gK", vim.lsp.buf.signature_help, "Signature documentation")
					nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					if vim.lsp.inlay_hint then
						pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
						nmap("<leader>th", function()
							local on = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
							vim.lsp.inlay_hint.enable(not on, { bufnr = bufnr })
						end, "Toggle inlay hints")
					end
				end,
			})
		end,
	},
	{
		"trouble.nvim",
		auto_enable = true,
		cmd = { "Trouble" },
		keys = {
			{ "<leader>xx", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", desc = "Buffer diagnostics (Trouble)" },
			{ "<leader>xs", desc = "Symbols (Trouble)" },
			{ "<leader>xl", desc = "LSP refs/defs (Trouble)" },
			{ "<leader>xL", desc = "Location list (Trouble)" },
			{ "<leader>xQ", desc = "Quickfix (Trouble)" },
		},
		after = function(_)
			require("trouble").setup({})
			local function tr(args)
				return function()
					vim.cmd("Trouble " .. args)
				end
			end
			vim.keymap.set("n", "<leader>xx", tr("diagnostics toggle"), { desc = "Diagnostics (Trouble)" })
			vim.keymap.set(
				"n",
				"<leader>xX",
				tr("diagnostics toggle filter.buf=0"),
				{ desc = "Buffer diagnostics (Trouble)" }
			)
			vim.keymap.set("n", "<leader>xs", tr("symbols toggle focus=false"), { desc = "Symbols (Trouble)" })
			vim.keymap.set(
				"n",
				"<leader>xl",
				tr("lsp toggle focus=false win.position=right"),
				{ desc = "LSP refs/defs (Trouble)" }
			)
			vim.keymap.set("n", "<leader>xL", tr("loclist toggle"), { desc = "Location list (Trouble)" })
			vim.keymap.set("n", "<leader>xQ", tr("qflist toggle"), { desc = "Quickfix (Trouble)" })
		end,
	},
	{
		"lazydev.nvim",
		auto_enable = true,
		cmd = { "LazyDev" },
		ft = "lua",
		after = function(_)
			require("lazydev").setup({
				library = {
					{ words = { "nixInfo%.lze" }, path = (nixInfo.get_nix_plugin_path("lze") or "") .. "/lua" },
					{ words = { "nixInfo%.lze" }, path = (nixInfo.get_nix_plugin_path("lzextras") or "") .. "/lua" },
				},
			})
		end,
	},
	{
		"lua_ls",
		lsp = {
			filetypes = { "lua" },
			settings = {
				Lua = {
					signatureHelp = { enabled = true },
					diagnostics = { globals = { "nixInfo", "vim" }, disable = { "missing-fields" } },
				},
			},
		},
	},
	{
		"nixd",
		lsp = {
			filetypes = { "nix" },
			settings = {
				nixd = {
					nixpkgs = { expr = [[import <nixpkgs> {}]] },
					formatting = { command = { "nixfmt" } },
					diagnostic = { suppress = { "sema-escaping-with" } },
				},
			},
		},
	},
	{
		"ty",
		lsp = {
			filetypes = { "python" },
			cmd = function(dispatchers, config)
				return vim.lsp.rpc.start(
					{ "ty", "server" },
					dispatchers,
					{ env = { VIRTUAL_ENV = find_venv(config.root_dir) } }
				)
			end,
		},
	},
	{
		"ruff",
		lsp = { filetypes = { "python" } },
	},
	{
		"vtsls",
		lsp = { filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" } },
	},
	{
		"rust_analyzer",
		lsp = { filetypes = { "rust" } },
	},
}
