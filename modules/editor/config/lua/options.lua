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
