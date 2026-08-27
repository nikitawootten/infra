return {
	{
		"snacks.nvim",
		auto_enable = true,
		lazy = false,
		priority = 1000,
		after = function(_)
			require("snacks").setup({
				bigfile = { enabled = true },
				quickfile = { enabled = true },
				input = { enabled = true },
				notifier = { enabled = true },
				words = { enabled = true },
				explorer = { replace_netrw = true },
				-- NB: auto_close closes the picker whenever another window is focused.
				-- The explorer has to stay open to work as a toggleable sidebar.
				picker = { sources = { explorer = { auto_close = false } } },
				git = {},
				terminal = {},
				scope = {},
				indent = { animate = { enabled = false } },
				statuscolumn = {
					left = { "mark", "git" },
					right = { "sign", "fold" },
					folds = { open = false, git_hl = false },
					git = { patterns = { "GitSign", "MiniDiffSign" } },
					refresh = 50,
				},
			})

			-- Sidebar/terminal toggles
			local function toggle_explorer()
				local explorer = Snacks.picker.get({ source = "explorer" })[1]
				if not explorer then
					Snacks.explorer.open()
				elseif explorer:is_focused() then
					explorer:close()
				else
					explorer:focus()
				end
			end
			-- Snacks.terminal.focus already implements exactly that three-state behaviour.
			local function toggle_terminal()
				Snacks.terminal.focus()
			end

			vim.keymap.set("n", "-", toggle_explorer, { desc = "Toggle file explorer" })
			vim.keymap.set("n", "<M-b>", toggle_explorer, { desc = "Toggle file explorer" })
			vim.keymap.set({ "n", "t" }, "<C-`>", toggle_terminal, { desc = "Toggle terminal" })
			vim.keymap.set("n", "<C-\\>", toggle_terminal, { desc = "Toggle terminal" })
			vim.keymap.set("n", "<leader>gg", function()
				Snacks.lazygit.open()
			end, { desc = "LazyGit" })
			vim.keymap.set("n", "<leader>gS", function()
				Snacks.picker.git_status()
			end, { desc = "Git status" })
			vim.keymap.set("n", "<leader>gh", function()
				Snacks.picker.git_diff()
			end, { desc = "Git diff hunks" })
			vim.keymap.set("n", "<leader>gl", function()
				Snacks.picker.git_log()
			end, { desc = "Git log" })
			vim.keymap.set("n", "<leader>gL", function()
				Snacks.picker.git_log_file()
			end, { desc = "Git log (file)" })
			vim.keymap.set("n", "<leader>gw", function()
				local paths = {}
				for _, line in ipairs(vim.fn.systemlist("git worktree list --porcelain")) do
					local path = line:match("^worktree (.+)$")
					if path then
						table.insert(paths, path)
					end
				end
				vim.ui.select(paths, { prompt = "Worktree (tcd)" }, function(choice)
					if choice then
						vim.cmd.tcd(vim.fn.fnameescape(choice))
						vim.notify("tcd → " .. choice)
					end
				end)
			end, { desc = "Switch worktree (tcd)" })
			-- Buffers
			vim.keymap.set("n", "<leader>bd", function()
				Snacks.bufdelete()
			end, { desc = "Delete buffer" })
			vim.keymap.set("n", "<leader>bo", function()
				Snacks.bufdelete.other()
			end, { desc = "Delete other buffers" })
			-- Find: things you open
			vim.keymap.set("n", "<leader><leader>", function()
				Snacks.picker.files()
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>ff", function()
				Snacks.picker.files()
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fb", function()
				Snacks.picker.buffers()
			end, { desc = "Buffers" })
			vim.keymap.set("n", "<leader>fr", function()
				Snacks.picker.recent()
			end, { desc = "Recent files" })
			vim.keymap.set("n", "<leader>fg", function()
				Snacks.picker.grep()
			end, { desc = "Live grep" })
			vim.keymap.set({ "n", "x" }, "<leader>fw", function()
				Snacks.picker.grep_word()
			end, { desc = "Grep word" })
			-- Search: editor state
			vim.keymap.set("n", "<leader>sb", function()
				Snacks.picker.lines()
			end, { desc = "Buffer lines" })
			vim.keymap.set("n", "<leader>sd", function()
				Snacks.picker.diagnostics()
			end, { desc = "Diagnostics" })
			vim.keymap.set("n", "<leader>sh", function()
				Snacks.picker.help()
			end, { desc = "Help pages" })
			vim.keymap.set("n", "<leader>sk", function()
				Snacks.picker.keymaps()
			end, { desc = "Keymaps" })
			vim.keymap.set("n", "<leader>sr", function()
				Snacks.picker.resume()
			end, { desc = "Resume" })
		end,
	},
}
