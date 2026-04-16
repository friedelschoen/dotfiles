vim.lsp.enable "gopls"
vim.lsp.enable "pyright"
vim.lsp.enable "clangd"

vim.lsp.config("ltex_plus", {
	cmd = { "ltex-ls-plus" },
	filetypes = { "markdown", "tex", "plaintex" },
	-- root_markers = { ".git" },
	settings = {
		ltex = {
			language = "nl",
		},
	},
})

vim.lsp.enable "ltex_plus"

vim.lsp.inlay_hint.enable(true)
-- vim.lsp.codelens.enable(true)

vim.diagnostic.config {
	virtual_text = {
		spacing = 2,
		prefix = "▎", --,", -- of "", "▎", ""
	},
	signs = true,
	underline = true,
	update_in_insert = true,
	severity_sort = true,
	float = {
		focusable = false,
	},
}

vim.api.nvim_create_autocmd("LspAttach", {
	pattern = "*",
	-- group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method "textDocument/implementation" then
			-- Create a keymap for vim.lsp.buf.implementation ...
		end
		-- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
		if client:supports_method "textDocument/completion" then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })

			vim.keymap.set("i", "<c-space>", function()
				vim.lsp.completion.get()
			end)
		end
	end,
})

local hover_grp = vim.api.nvim_create_augroup("HoverOrDiag", { clear = true })

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	group = hover_grp,
	callback = function()
		local opts = {
			close_events = { "CursorMoved", "InsertEnter", "BufHidden", "BufLeave" },
			scope = "cursor",
			focusable = false,
			focus = false,
		}

		-- Toon alleen de diagnostic onder de cursor
		local float_bufnr, winid = vim.diagnostic.open_float(opts)
		if winid then
			return
		end

		-- Geen diagnostic onder cursor? Dan hover
		local clients = vim.lsp.get_clients { bufnr = 0, method = "textDocument/hover" }
		if #clients > 0 then
			vim.lsp.buf.hover(opts)
		end
	end,
})
