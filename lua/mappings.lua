require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Keep cursor centered on half-page jumps
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Center screen on search next/prev + unfold
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- Paste over selection without clobbering unnamed register
map("x", "p", [["_dP]], { desc = "Paste without yanking replaced text" })

-- Diagnostics jump
map("n", "]d", function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.goto_prev() end, { desc = "Prev diagnostic" })

-- Close buffer, keep window layout
map("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Close buffer" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
