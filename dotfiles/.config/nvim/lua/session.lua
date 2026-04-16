-- Save session
local session_file = vim.fn.expand "~/.local/state/neovim-qt.session.vim"
vim.g.save_session = 0

local group = vim.api.nvim_create_augroup("nvimqt_session", { clear = true })

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = group,
	callback = function()
		if vim.g.save_session == 1 then
			vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
		end
	end,
})

vim.api.nvim_create_user_command("ClearSession", function()
	vim.fn.delete(session_file)
	vim.g.save_session = 0
end, {})

vim.api.nvim_create_user_command("EnterSession", function()
	if vim.fn.filereadable(session_file) == 1 then
		vim.cmd("source " .. vim.fn.fnameescape(session_file))
		vim.cmd [[echom "Session restored!"]]
	else
		vim.cmd [[echom "No session file found."]]
	end
	vim.g.save_session = 1
end, {})
