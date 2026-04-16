local map = vim.keymap.set

-- Keymaps
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>q!<cr>", { desc = "Quit without saving" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>s", function()
	vim.opt.spell = not vim.opt.spell:get()
	print("spell:", vim.opt.spell:get() and "on" or "off")
end, { desc = "Toggle spell" })

map("n", "C-/", "<cmd>noh<cr>")

map("x", "C-a", "<esc>ggVG", {})

map({ "n", "x" }, "gra", function()
	require("tiny-code-action").code_action()
end, { noremap = true, silent = true })
