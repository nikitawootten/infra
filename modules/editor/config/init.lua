-- Adapted from https://github.com/BirdeeHub/nix-wrapper-modules/blob/main/templates/neovim/init.lua

vim.loader.enable() -- <- bytecode caching
do
    -- Set up a global in a way that also handles non-nix compat
    local ok
    ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
    if not ok then
        package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
            __call = function(_, default) return default end
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
    nixInfo.lze = setmetatable(require('lze'), getmetatable(require('lzextras')))
    function nixInfo.get_nix_plugin_path(name)
        return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
    end
end

nixInfo.lze.register_handlers {
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
}

-- NOTE: This config uses lzextras.lsp handler https://github.com/BirdeeHub/lzextras?tab=readme-ov-file#lsp-handler
-- Because we have the paths, we can set a more performant fallback function
-- for when you don't provide a filetype to trigger on yourself.
-- If you do provide a filetype, this will never be called.
nixInfo.lze.h.lsp.set_ft_fallback(function(name)
    local lspcfg = nixInfo.get_nix_plugin_path "nvim-lspconfig"
    if lspcfg then
        local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
        return (ok and cfg or {}).filetypes or {}
    else
        -- the less performant thing we are trying to avoid at startup
        return (vim.lsp.config[name] or {}).filetypes or {}
    end
end)

-- NOTE: These 2 should be set up before any plugins with keybinds are loaded.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

if os.getenv('SSH_TTY') then
    local osc52 = require('vim.ui.clipboard.osc52')
    vim.g.clipboard = {
        name = 'OSC 52',
        copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
        paste = { ['+'] = osc52.paste('+'), ['*'] = osc52.paste('*') },
    }
end

-- [[ Setting options ]]
vim.o.exrc = false
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.opt.inccommand = 'split'
vim.opt.scrolloff = 10
vim.wo.number = true
vim.o.mouse = 'a'
vim.opt.cpoptions:append('I')
vim.o.expandtab = true
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.wo.relativenumber = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menu,preview,noselect'
vim.o.termguicolors = true
vim.o.showmode = false

-- Diagnostics: gutter signs + sorted, sourced virtual text
vim.diagnostic.config({
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '󰅚',
            [vim.diagnostic.severity.WARN] = '󰀪',
            [vim.diagnostic.severity.INFO] = '󰋽',
            [vim.diagnostic.severity.HINT] = '󰌶',
        },
    },
    virtual_text = { spacing = 2, source = 'if_many' },
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
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.hl.on_yank() end,
    group = highlight_group,
    pattern = '*',
})

-- [[ Keymaps ]]
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Move line up' })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll down' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll up' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next search result' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous search result' })
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next diagnostic' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end,
    { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']e',
    function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true }) end,
    { desc = 'Next error' })
vim.keymap.set('n', '[e',
    function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true }) end,
    { desc = 'Previous error' })

-- clipboard yanks (kept off the default register to avoid clobbering)
vim.keymap.set({ "v", "x", "n" }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({ "n", "v", "x" }, '<leader>Y', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+', { noremap = true, silent = true, desc = 'Paste from clipboard (insert)' })
vim.keymap.set("x", "<leader>P", '"_dP', { noremap = true, silent = true, desc = 'Paste over selection' })

-- Spell checking
vim.opt.spelllang = { 'en_us' }
vim.opt.spellfile = vim.fn.stdpath('config') .. '/spell/en.utf-8.add'
vim.opt.spelloptions = 'camel'
vim.opt.spellcapcheck = ''

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Enable spell-check for prose filetypes',
    pattern = { 'markdown', 'gitcommit', 'text', 'rst', 'tex', 'typst' },
    callback = function()
        vim.opt_local.spell = true
    end,
})

vim.keymap.set('n', '<leader>ts', function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
end, { desc = 'Toggle spell-check' })

vim.keymap.set('n', '<leader>zn', ']s', { desc = 'Next misspelling' })
vim.keymap.set('n', '<leader>zp', '[s', { desc = 'Previous misspelling' })
vim.keymap.set('n', '<leader>za', 'zg', { desc = 'Add word to dictionary' })
vim.keymap.set('n', '<leader>zu', 'zug', { desc = 'Undo add word' })
vim.keymap.set('n', '<leader>z=', 'z=', { desc = 'Suggest corrections' })
vim.keymap.set('i', '<C-s>', '<C-g>u<Esc>[s1z=`]a<C-g>u', { desc = 'Fix previous spelling' })

nixInfo.lze.load {
    {
        "trigger_colorscheme",
        event = "VimEnter",
        load = function(_)
            vim.schedule(function()
                vim.cmd.colorscheme("tokyonight-night")
            end)
        end,
    },
    {
        "tokyonight.nvim",
        auto_enable = true,
        colorscheme = { "tokyonight", "tokyonight-night", "tokyonight-storm", "tokyonight-day", "tokyonight-moon" },
    },
    {
        "snacks.nvim",
        auto_enable = true,
        lazy = false,
        priority = 1000,
        after = function(_)
            require('snacks').setup({
                explorer = { replace_netrw = true },
                picker = { sources = { explorer = { auto_close = true } } },
                git = {},
                terminal = {},
                scope = {},
                indent = {},
                statuscolumn = {
                    left = { "mark", "git" },
                    right = { "sign", "fold" },
                    folds = { open = false, git_hl = false },
                    git = { patterns = { "GitSign", "MiniDiffSign" } },
                    refresh = 50,
                },
            })

            vim.keymap.set("n", "-", function() Snacks.explorer.open() end, { desc = 'File explorer' })
            vim.keymap.set("n", "<c-\\>", function() Snacks.terminal.open() end, { desc = 'Terminal' })
            vim.keymap.set("n", "<leader>_", function() Snacks.lazygit.open() end, { desc = 'LazyGit' })
            vim.keymap.set('n', "<leader><leader>", function() Snacks.picker.files() end, { desc = "Find files" })
            vim.keymap.set('n', "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
            vim.keymap.set('n', "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find git files" })
            vim.keymap.set('n', "<leader>f?", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
            vim.keymap.set('n', "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
            vim.keymap.set('n', "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent files" })
            -- Search
            vim.keymap.set('n', "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep" })
            vim.keymap.set({ "n", "x" }, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "Grep word" })
            vim.keymap.set('n', "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer lines" })
            vim.keymap.set('n', "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
            vim.keymap.set('n', "<leader>sh", function() Snacks.picker.help() end, { desc = "Help pages" })
            vim.keymap.set('n', "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
            vim.keymap.set('n', "<leader>sr", function() Snacks.picker.resume() end, { desc = "Resume" })
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
            vim.lsp.config('*', {
                on_attach = function(_, bufnr)
                    local nmap = function(keys, func, desc)
                        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc and ('LSP: ' .. desc) or nil })
                    end
                    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
                    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
                    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
                    nmap('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
                    nmap('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
                    nmap('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')
                    nmap('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')
                    nmap('K', vim.lsp.buf.hover, 'Hover documentation')
                    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature documentation')
                    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                    if vim.lsp.inlay_hint then
                        pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
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
            local function tr(args) return function() vim.cmd("Trouble " .. args) end end
            vim.keymap.set("n", "<leader>xx", tr("diagnostics toggle"), { desc = "Diagnostics (Trouble)" })
            vim.keymap.set("n", "<leader>xX", tr("diagnostics toggle filter.buf=0"),
                { desc = "Buffer diagnostics (Trouble)" })
            vim.keymap.set("n", "<leader>xs", tr("symbols toggle focus=false"), { desc = "Symbols (Trouble)" })
            vim.keymap.set("n", "<leader>xl", tr("lsp toggle focus=false win.position=right"),
                { desc = "LSP refs/defs (Trouble)" })
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
            require('lazydev').setup({
                library = {
                    { words = { "nixInfo%.lze" }, path = (nixInfo.get_nix_plugin_path("lze") or "") .. '/lua' },
                    { words = { "nixInfo%.lze" }, path = (nixInfo.get_nix_plugin_path("lzextras") or "") .. '/lua' },
                },
            })
        end,
    },
    {
        "lua_ls",
        lsp = {
            filetypes = { 'lua' },
            settings = {
                Lua = {
                    signatureHelp = { enabled = true },
                    diagnostics = { globals = { "nixInfo", "vim" }, disable = { 'missing-fields' } },
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
                if not vim.treesitter.language.add(language) then return false end
                vim.treesitter.start(buf, language)
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.wo.foldmethod = "expr"
                vim.o.foldlevel = 99
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                return true
            end
            local installable = require("nvim-treesitter").get_available()
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local buf, filetype = args.buf, args.match
                    local language = vim.treesitter.language.get_lang(filetype)
                    if not language then return end
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
            require("nvim-treesitter-textobjects").setup {
                select = {
                    lookahead = true,
                    selection_modes = { ['@parameter.outer'] = 'v', ['@function.outer'] = 'V' },
                    include_surrounding_whitespace = false,
                },
            }
            local sel = function(obj, group)
                return function() require("nvim-treesitter-textobjects.select").select_textobject(obj, group) end
            end
            vim.keymap.set({ "x", "o" }, "am", sel("@function.outer", "textobjects"))
            vim.keymap.set({ "x", "o" }, "im", sel("@function.inner", "textobjects"))
            vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer", "textobjects"))
            vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner", "textobjects"))
            vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer", "textobjects"))
            vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner", "textobjects"))
            vim.keymap.set({ "x", "o" }, "al", sel("@loop.outer", "textobjects"))
            vim.keymap.set({ "x", "o" }, "il", sel("@loop.inner", "textobjects"))
            vim.keymap.set({ "x", "o" }, "ai", sel("@conditional.outer", "textobjects"))
            vim.keymap.set({ "x", "o" }, "ii", sel("@conditional.inner", "textobjects"))
            vim.keymap.set({ "x", "o" }, "ab", sel("@block.outer", "textobjects"))
            vim.keymap.set({ "x", "o" }, "ib", sel("@block.inner", "textobjects"))
        end,
    },
    {
        "conform.nvim",
        auto_enable = true,
        keys = { { "<leader>FF", desc = "[F]ormat [F]ile" } },
        after = function(_)
            local conform = require("conform")
            conform.setup({
                formatters_by_ft = {
                    nix = { "nixfmt" },
                    lua = { "stylua" },
                    python = { "isort", "black" },
                    rust = { "rustfmt" },
                },
                format_on_save = { lsp_format = "fallback", timeout_ms = 1000 },
            })
            vim.keymap.set({ "n", "v" }, "<leader>FF", function()
                conform.format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
            end, { desc = "[F]ormat [F]ile" })
        end,
    },
    {
        "nvim-lint",
        auto_enable = true,
        event = "FileType",
        after = function(_)
            require('lint').linters_by_ft = {}
            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function() require("lint").try_lint() end,
            })
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
                keymap = { preset = 'default' },
                cmdline = {
                    enabled = true,
                    completion = { menu = { auto_show = true } },
                    sources = function()
                        local t = vim.fn.getcmdtype()
                        if t == '/' or t == '?' then return { 'buffer' } end
                        if t == ':' or t == '@' then return { 'cmdline' } end
                        return {}
                    end,
                },
                signature = { enabled = true, window = { show_documentation = true } },
                completion = {
                    menu = {
                        draw = {
                            treesitter = { 'lsp' },
                            components = {
                                label = {
                                    text = function(ctx) return require("colorful-menu").blink_components_text(ctx) end,
                                    highlight = function(ctx)
                                        return require("colorful-menu").blink_components_highlight(
                                            ctx)
                                    end,
                                },
                            },
                        },
                    },
                    documentation = { auto_show = true },
                },
                sources = {
                    default = { 'lsp', 'path', 'buffer', 'omni' },
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
        after = function(_) require('nvim-surround').setup() end,
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
        after = function(_) require('fidget').setup({}) end,
    },
    {
        "lualine.nvim",
        auto_enable = true,
        event = "DeferredUIEnter",
        after = function(_)
            require('lualine').setup({
                options = {
                    icons_enabled = true,
                    theme = "tokyonight",
                    component_separators = '|',
                    section_separators = '',
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff' },
                    lualine_c = { { 'filename', path = 1, status = true } },
                    lualine_x = { 'diagnostics', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' },
                },
                inactive_sections = {
                    lualine_b = { { 'filename', path = 3, status = true } },
                    lualine_x = { 'filetype' },
                },
            })
        end,
    },
    {
        "gitsigns.nvim",
        auto_enable = true,
        event = "DeferredUIEnter",
        after = function(_)
            require('gitsigns').setup({
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end
                    map({ 'n', 'v' }, ']c', function()
                        if vim.wo.diff then return ']c' end
                        vim.schedule(function() gs.next_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, desc = 'Next hunk' })
                    map({ 'n', 'v' }, '[c', function()
                        if vim.wo.diff then return '[c' end
                        vim.schedule(function() gs.prev_hunk() end)
                        return '<Ignore>'
                    end, { expr = true, desc = 'Previous hunk' })
                    map('n', '<leader>gs', gs.stage_hunk, { desc = 'Stage hunk' })
                    map('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset hunk' })
                    map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview hunk' })
                    map('n', '<leader>gb', function() gs.blame_line { full = false } end, { desc = 'Blame line' })
                    map('n', '<leader>gd', gs.diffthis, { desc = 'Diff against index' })
                    map('n', '<leader>gD', function()
                        gs.diffthis '~'
                    end, { desc = 'git diff against last commit' })

                    map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
                    map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

                    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
                end,
            })
        end,
    },
    {
        "which-key.nvim",
        auto_enable = true,
        event = "DeferredUIEnter",
        after = function(_)
            require('which-key').setup({ preset = "helix" })
            require('which-key').add {
                { "<leader>c", group = "[c]ode" },
                { "<leader>d", group = "[d]ocument" },
                { "<leader>f", group = "[f]ind" },
                { "<leader>g", group = "[g]it" },
                { "<leader>r", group = "[r]ename" },
                { "<leader>s", group = "[s]earch" },
                { "<leader>t", group = "[t]oggles" },
                { "<leader>w", group = "[w]orkspace" },
                { "<leader>x", group = "[x] diagnostics/trouble" },
                { "<leader>F", group = "[F]ormat" },
            }
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
