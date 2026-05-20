-- Markdown-specific tweaks
local o = vim.opt_local
o.wrap = true
o.linebreak = true       -- wrap on word boundaries
o.conceallevel = 2       -- hide formatting markers where possible
o.spell = false
--o.spellcapcheck = ""     -- don't over-aggressively flag headings
o.textwidth = 120
-- o.colorcolumn = ""       -- no ruler bar while writing
o.formatoptions = "tc"

-- Easier formatting
vim.keymap.set("n", "Q", "gwip", { buffer = true, desc = "Reflow paragraph" })

