-- [[ Keymaps ]]
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result" })
-- Move current line up/down in Normal mode
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- Move current line up/down in Insert mode
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })

-- Move selected lines up/down in Visual mode
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Common file/session commands
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Write file" })
vim.keymap.set("n", "<leader>W", "<cmd>wall<CR>", { desc = "Write all files" })
vim.keymap.set("n", "<leader>qq", "<cmd>quit<CR>", { desc = "Quit" })
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

-- Tab management
vim.keymap.set("n", "<leader><Tab>n", "<cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader><Tab>d", "<cmd>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "]t", "<cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "[t", "<cmd>tabprevious<CR>", { desc = "Previous tab" })

-- UI toggles
vim.keymap.set("n", "<leader>tn", function()
	vim.wo.number = not vim.wo.number
end, { desc = "Toggle line numbers" })
vim.keymap.set("n", "<leader>tr", function()
	vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = "Toggle relative numbers" })
vim.keymap.set("n", "<leader>tw", function()
	vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle wrap" })
vim.keymap.set("n", "<leader>td", function()
	local config = vim.diagnostic.config()
	vim.diagnostic.config({
		virtual_text = config.virtual_text and false or { spacing = 2, source = "if_many" },
	})
end, { desc = "Toggle diagnostic virtual text" })
vim.keymap.set("n", "<leader>tC", function()
	vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
end, { desc = "Toggle conceallevel" })

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
