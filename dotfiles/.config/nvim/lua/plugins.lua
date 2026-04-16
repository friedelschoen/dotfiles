local gh = function(url)
	return "https://github.com/" .. url
end

vim.pack.add {
	-- colorschemes --
	gh "navarasu/onedark.nvim",
	gh "mofiqul/vscode.nvim",
	gh "morhetz/gruvbox",
	gh "projekt0n/github-nvim-theme",

	-- language support --
	gh "stevearc/conform.nvim", -- formatter
	gh "neovim/nvim-lspconfig", -- lsp configurations
	gh "nvim-treesitter/nvim-treesitter", -- ts-grammer manager

	-- other --
	gh "junegunn/fzf.vim", -- pretty file-picker
	gh "Pocco81/auto-save.nvim", -- autosave file after change
	{ src = gh "nvim-neo-tree/neo-tree.nvim", version = "v3.x" }, -- filetree
	gh "lewis6991/gitsigns.nvim", -- git status
	gh "akinsho/bufferline.nvim", -- fancy "tabbar"
	gh "petertriho/nvim-scrollbar", -- visual scrollbar
	gh "rachartier/tiny-code-action.nvim", -- visualize code actions
	gh "numToStr/Comment.nvim", -- comment and uncomment lines
	gh "folke/todo-comments.nvim", -- highlight TODO's
	gh "timantipov/md-table-tidy.nvim", -- format markdown tables
	gh "hedyhli/outline.nvim", -- show buffer outlines (functions, headers)
	gh "lukas-reineke/indent-blankline.nvim", -- indentation visualizer

	-- dependencies --
	gh "nvim-lua/plenary.nvim", -- utilties; ->neo-tree, tiny-code-action, todo-comments
	gh "MunifTanjim/nui.nvim", -- ui toolkit; ->neo-tree
	gh "nvim-tree/nvim-web-devicons", -- file icons; ->neo-tree
	gh "nvim-telescope/telescope.nvim", -- popups ->tiny-code-action
}

require("conform").setup {
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofmt" },
		c = { "clang-format" },
	},
}

require("auto-save").setup {
	trigger_events = { "InsertLeave" },
	debounce_delay = 500,
}

require("neo-tree").setup {
	window = {
		position = "right",
	},
	filesystem = {
		filtered_items = {
			visible = true,
		},
	},
}

require("bufferline").setup {}

require("scrollbar").setup {}

require("Comment").setup {}

require("todo-comments").setup {}

require("md-table-tidy").setup {}

require("gitsigns").setup {}

require("outline").setup {}

require("ibl").setup {}

require("nvim-treesitter").install {
	"go",
	"comment",
	"markdown-inline",
	"markdown",
}

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format {
			bufnr = args.buf,
			lsp_format = "fallback",
		}
	end,
})
