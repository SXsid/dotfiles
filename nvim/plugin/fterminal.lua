return {
	dir = vim.fn.stdpath("config"), -- tells lazy this is local
	name = "floaterminal",

	config = function()
		local state = {
			buf = -1,
			win = -1,
		}

		local function create_window()
			local width = math.floor(vim.o.columns * 0.6)
			local height = math.floor(vim.o.lines * 0.6)

			local col = math.floor((vim.o.columns - width) / 2)
			local row = math.floor((vim.o.lines - height) / 2)

			if not vim.api.nvim_buf_is_valid(state.buf) then
				state.buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_option(state.buf, "bufhidden", "hide")
			end

			state.win = vim.api.nvim_open_win(state.buf, true, {
				relative = "editor",
				width = width,
				height = height,
				col = col,
				row = row,
				style = "minimal",
				border = "rounded",
			})
		end

		local function toggle()
			if not vim.api.nvim_win_is_valid(state.win) then
				create_window()

				if vim.bo[state.buf].buftype ~= "terminal" then
					vim.fn.termopen(vim.o.shell)
				end

				vim.cmd("startinsert")
			else
				vim.api.nvim_win_hide(state.win)
			end
		end

		vim.keymap.set("n", "<leader>zt", toggle, { desc = "Toggle Floating Terminal" })
		vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Exit Terminal Mode" })
	end,
}
