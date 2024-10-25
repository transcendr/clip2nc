local M = {}

local function sync_clipboard()
	local clipboard_content = vim.fn.getreg("+")
	vim.fn.system("echo " .. vim.fn.shellescape(clipboard_content) .. " | nc localhost 2224")
end

function M.setup(opts)
	opts = opts or {}

	vim.api.nvim_create_autocmd({ "TextYankPost" }, {
		callback = function()
			sync_clipboard()
		end,
	})

	vim.api.nvim_create_autocmd({ "VimLeave" }, {
		callback = function()
			sync_clipboard()
		end,
	})
end

return M
