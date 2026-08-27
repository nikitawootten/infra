-- Adapted from https://github.com/BirdeeHub/nix-wrapper-modules/blob/main/templates/neovim/init.lua

vim.loader.enable() -- <- bytecode caching

require("nix-bootstrap")

-- NOTE: These 2 should be set up before any plugins with keybinds are loaded.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("env")
require("options")
require("keymaps")

local specs = {}
for _, name in ipairs({
	"colorscheme",
	"snacks",
	"lsp",
	"treesitter",
	"format",
	"completion",
	"editing",
	"ui",
	"git",
}) do
	vim.list_extend(specs, require("plugins." .. name))
end

nixInfo.lze.load(specs)
