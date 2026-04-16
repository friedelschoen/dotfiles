-- Leader
vim.g.mapleader = " "

-- Basic UI/UX
local o = vim.opt
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.termguicolors = true
o.wrap = false
o.scrolloff = 4
o.sidescrolloff = 4
o.colorcolumn = "120"
o.ww = "<,>,[,]" -- hitting right at EOL sets cursor to next line
o.mouse = "a"

-- Editing
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true
o.textwidth = 120
o.formatoptions = "jcroqlnt" -- pretty sane defaults for prose + code

-- Search
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true

-- Files
o.undofile = true
o.swapfile = false
o.backup = false
o.writebackup = false
o.bufhidden = "wipe" -- buffer verdwijnt bij close

-- Clipboard
o.clipboard = "unnamedplus"

-- Spelling (toggle when you need it)
o.spell = false
-- o.spelllang = { "en_gb", "nl" }

-- Minimal statusline (mode + file + position)
o.laststatus = 3
vim.o.statusline = table.concat {
	" %{%v:lua.vim.fn.mode()%} ",
	"%f",
	"%=",
	"%l:%c  %p%% ",
}

-- lsp
o.completeopt = "menuone,popup,noinsert"
o.updatetime = 500

-- theme
o.background = "dark"
vim.cmd [[colorscheme onedark]]
