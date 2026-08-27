return {
	{
		"nvim-treesitter",
		lazy = false,
		auto_enable = true,
		after = function(_)
			local function try_attach(buf, language)
				if not vim.api.nvim_buf_is_valid(buf) then
					return false
				end
				if not vim.treesitter.language.add(language) then
					return false
				end
				vim.treesitter.start(buf, language)
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				for _, win in ipairs(vim.fn.win_findbuf(buf)) do
					vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.wo[win][0].foldmethod = "expr"
					vim.wo[win][0].foldlevel = 99
				end
				return true
			end
			local installable = require("nvim-treesitter").get_available()
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf, filetype = args.buf, args.match
					local language = vim.treesitter.language.get_lang(filetype)
					if not language then
						return
					end
					if not try_attach(buf, language) then
						if vim.tbl_contains(installable, language) then
							require("nvim-treesitter").install(language):await(function()
								try_attach(buf, language)
							end)
						end
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter-textobjects",
		auto_enable = true,
		lazy = false,
		before = function(_)
			vim.g.no_plugin_maps = true
		end,
		after = function(_)
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = { ["@parameter.outer"] = "v", ["@function.outer"] = "V" },
					include_surrounding_whitespace = false,
				},
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			for _, s in ipairs({
				{ "af", "@function.outer", "a function" },
				{ "if", "@function.inner", "inner function" },
				{ "ac", "@class.outer", "a class" },
				{ "ic", "@class.inner", "inner class" },
				{ "aa", "@parameter.outer", "a parameter" },
				{ "ia", "@parameter.inner", "inner parameter" },
				{ "al", "@loop.outer", "a loop" },
				{ "il", "@loop.inner", "inner loop" },
				{ "ai", "@conditional.outer", "a conditional" },
				{ "ii", "@conditional.inner", "inner conditional" },
				{ "ab", "@block.outer", "a block" },
				{ "ib", "@block.inner", "inner block" },
			}) do
				local lhs, obj, desc = s[1], s[2], s[3]
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject(obj, "textobjects")
				end, { desc = desc })
			end

			local move = require("nvim-treesitter-textobjects.move")
			for _, m in ipairs({
				{ "]m", "goto_next_start", "@function.outer", "Next function start" },
				{ "]M", "goto_next_end", "@function.outer", "Next function end" },
				{ "[m", "goto_previous_start", "@function.outer", "Previous function start" },
				{ "[M", "goto_previous_end", "@function.outer", "Previous function end" },
				{ "]]", "goto_next_start", "@class.outer", "Next class start" },
				{ "][", "goto_next_end", "@class.outer", "Next class end" },
				{ "[[", "goto_previous_start", "@class.outer", "Previous class start" },
				{ "[]", "goto_previous_end", "@class.outer", "Previous class end" },
				{ "]a", "goto_next_start", "@parameter.inner", "Next parameter" },
				{ "[a", "goto_previous_start", "@parameter.inner", "Previous parameter" },
				{ "]l", "goto_next_start", "@loop.outer", "Next loop" },
				{ "[l", "goto_previous_start", "@loop.outer", "Previous loop" },
			}) do
				local lhs, fn, obj, desc = m[1], m[2], m[3], m[4]
				vim.keymap.set({ "n", "x", "o" }, lhs, function()
					move[fn](obj, "textobjects")
				end, { desc = desc })
			end

			local swap = require("nvim-treesitter-textobjects.swap")
			vim.keymap.set("n", "<leader>cs", function()
				swap.swap_next("@parameter.inner")
			end, { desc = "[C]ode [s]wap parameter next" })
			vim.keymap.set("n", "<leader>cS", function()
				swap.swap_previous("@parameter.inner")
			end, { desc = "[C]ode [S]wap parameter previous" })
		end,
	},
}
