-- Adapted from https://github.com/BirdeeHub/nix-wrapper-modules/blob/main/templates/neovim/init.lua

vim.loader.enable() -- <- bytecode caching
do
	-- Set up a global in a way that also handles non-nix compat
	local ok
	ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
	if not ok then
		package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
			__call = function(_, default)
				return default
			end,
		})
		_G.nixInfo = require(vim.g.nix_info_plugin_name)
		-- If you always use the fetcher function to fetch nix values,
		-- rather than indexing into the tables directly,
		-- it will use the value you specified as the default
		-- TODO: for non-nix compat, vim.pack.add in another file and require here.
	end
	nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil
	---@module 'lzextras'
	---@type lzextras | lze
	nixInfo.lze = setmetatable(require("lze"), getmetatable(require("lzextras")))
	function nixInfo.get_nix_plugin_path(name)
		return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
	end
end

nixInfo.lze.register_handlers({
	{
		-- adds an `auto_enable` field to lze specs
		-- if true, will disable it if not installed by nix.
		-- if string, will disable if that name was not installed by nix.
		-- if a table of strings, it will disable if any were not.
		spec_field = "auto_enable",
		set_lazy = false,
		modify = function(plugin)
			if vim.g.nix_info_plugin_name then
				if type(plugin.auto_enable) == "table" then
					for _, name in pairs(plugin.auto_enable) do
						if not nixInfo.get_nix_plugin_path(name) then
							plugin.enabled = false
							break
						end
					end
				elseif type(plugin.auto_enable) == "string" then
					if not nixInfo.get_nix_plugin_path(plugin.auto_enable) then
						plugin.enabled = false
					end
				elseif type(plugin.auto_enable) == "boolean" and plugin.auto_enable then
					if not nixInfo.get_nix_plugin_path(plugin.name) then
						plugin.enabled = false
					end
				end
			end
			return plugin
		end,
	},
	{
		-- we made an options.settings.cats with the value of enable for our top level specs
		-- give for_cat = "name" to disable if that one is not enabled
		spec_field = "for_cat",
		set_lazy = false,
		modify = function(plugin)
			if vim.g.nix_info_plugin_name then
				if type(plugin.for_cat) == "string" then
					plugin.enabled = nixInfo(false, "settings", "cats", plugin.for_cat)
				end
			end
			return plugin
		end,
	},
	-- From lzextras. This one makes it so that
	-- you can set up lsps within lze specs,
	-- and trigger lspconfig setup hooks only on the correct filetypes
	-- It is (unfortunately) important that it be registered after the above 2,
	-- as it also relies on the modify hook, and the value of enabled at that point
	nixInfo.lze.lsp,
})

-- NOTE: This config uses lzextras.lsp handler https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
-- Because we have the paths, we can set a more performant fallback function
-- for when you don't provide a filetype to trigger on yourself.
-- If you do provide a filetype, this will never be called.
nixInfo.lze.h.lsp.set_ft_fallback(function(name)
	local lspcfg = nixInfo.get_nix_plugin_path("nvim-lspconfig")
	if lspcfg then
		local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
		return (ok and cfg or {}).filetypes or {}
	else
		-- the less performant thing we are trying to avoid at startup
		return (vim.lsp.config[name] or {}).filetypes or {}
	end
end)

-- NOTE: These 2 should be set up before any plugins with keybinds are loaded.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

if os.getenv("SSH_TTY") then
	local osc52 = require("vim.ui.clipboard.osc52")
	vim.g.clipboard = {
		name = "OSC 52",
		copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
		paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
	}
end

-- direnv.vim reapplies the pre-nvim environment on every DirChanged, dropping the
-- wrapper's runtimePkgs from PATH. Re-append (not prepend) so a devshell still wins.
local wrapper_path = vim.env.PATH or ""
vim.api.nvim_create_autocmd("User", {
	pattern = "DirenvLoaded",
	callback = function()
		local present = {}
		for entry in vim.gsplit(vim.env.PATH or "", ":", { trimempty = true }) do
			present[entry] = true
		end
		local missing = {}
		for entry in vim.gsplit(wrapper_path, ":", { trimempty = true }) do
			if not present[entry] then
				table.insert(missing, entry)
			end
		end
		if #missing > 0 then
			vim.env.PATH = vim.env.PATH .. ":" .. table.concat(missing, ":")
		end
	end,
})

-- [[ Setting options ]]
vim.o.exrc = false
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.opt.inccommand = "split"
vim.opt.scrolloff = 10
vim.wo.number = true
vim.o.mouse = "a"
vim.opt.cpoptions:append("I")
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = "yes"
vim.wo.relativenumber = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = "menu,preview,noselect,fuzzy"
vim.o.termguicolors = true
vim.o.showmode = false
vim.o.winborder = "rounded"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.confirm = true

-- Diagnostics: gutter signs + sorted, sourced virtual text
vim.diagnostic.config({
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚",
			[vim.diagnostic.severity.WARN] = "󰀪",
			[vim.diagnostic.severity.INFO] = "󰋽",
			[vim.diagnostic.severity.HINT] = "󰌶",
		},
	},
	virtual_text = { spacing = 2, source = "if_many" },
})

-- [[ Disable auto comment on enter ]]
-- See :help formatoptions
vim.api.nvim_create_autocmd("FileType", {
	desc = "remove formatoptions",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- [[ Keymaps ]]
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result" })
-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Next error" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Previous error" })

-- clipboard yanks (kept off the default register to avoid clobbering)
vim.keymap.set({ "v", "x", "n" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", '"+yy', { noremap = true, silent = true, desc = "Yank line to clipboard" })
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
vim.keymap.set("i", "<C-p>", "<C-r><C-p>+", { noremap = true, silent = true, desc = "Paste from clipboard (insert)" })
vim.keymap.set("x", "<leader>P", '"_dP', { noremap = true, silent = true, desc = "Paste over selection" })

-- Quickfix list navigation
vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "[q", "<cmd>cprevious<CR>zz", { desc = "Previous quickfix item" })
vim.keymap.set("n", "]Q", "<cmd>clast<CR>zz", { desc = "Last quickfix item" })
vim.keymap.set("n", "[Q", "<cmd>cfirst<CR>zz", { desc = "First quickfix item" })

-- Buffer cycling
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- Terminal mode: leave the terminal by window motion
for _, key in ipairs({ "h", "j", "k", "l" }) do
	vim.keymap.set("t", "<C-w>" .. key, [[<C-\><C-n><C-w>]] .. key, { desc = "Go to " .. key .. " window" })
end

-- Spell checking
vim.opt.spelllang = { "en_us" }
local spelldir = vim.fn.stdpath("data") .. "/spell"
vim.fn.mkdir(spelldir, "p")
vim.opt.spellfile = spelldir .. "/en.utf-8.add"
vim.opt.spelloptions = "camel"
vim.opt.spellcapcheck = ""

vim.api.nvim_create_autocmd("FileType", {
	desc = "Enable spell-check for prose filetypes",
	pattern = { "markdown", "gitcommit", "text", "rst", "tex", "typst" },
	callback = function()
		vim.opt_local.spell = true
	end,
})

vim.keymap.set("n", "<leader>ts", function()
	vim.opt_local.spell = not vim.opt_local.spell:get()
end, { desc = "Toggle spell-check" })

vim.keymap.set("n", "<leader>za", "zg", { desc = "Add word to dictionary" })
vim.keymap.set("n", "<leader>zu", "zug", { desc = "Undo add word" })
vim.keymap.set("n", "<leader>z=", "z=", { desc = "Suggest corrections" })
vim.keymap.set("i", "<C-s>", "<C-g>u<Esc>[s1z=`]a<C-g>u", { desc = "Fix previous spelling" })

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

nixInfo.lze.load({
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
		"basedpyright",
		lsp = { filetypes = { "python" } },
	},
	{
		"rust_analyzer",
		lsp = { filetypes = { "rust" } },
	},
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
					python = { "isort", "black" },
					rust = { "rustfmt" },
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
		"gitsigns.nvim",
		auto_enable = true,
		event = "DeferredUIEnter",
		after = function(_)
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end
					map({ "n", "v" }, "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Next hunk" })
					map({ "n", "v" }, "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Previous hunk" })
					map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
					map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset hunk" })
					map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
					map("n", "<leader>gb", function()
						gs.blame_line({ full = false })
					end, { desc = "Blame line" })
					map("n", "<leader>gd", gs.diffthis, { desc = "Diff against index" })
					map("n", "<leader>gD", function()
						gs.diffthis("~")
					end, { desc = "git diff against last commit" })

					map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
					map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle git show deleted" })

					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
				end,
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
	{
		"direnv.vim",
		auto_enable = true,
		lazy = false,
		before = function(_)
			vim.g.direnv_silent_load = 1
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
})
