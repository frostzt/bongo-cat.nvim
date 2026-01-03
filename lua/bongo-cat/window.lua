-- bongo-cat.nvim/lua/bongo-cat/window.lua
-- Floating window management

local config = require("bongo-cat.config")
local animation = require("bongo-cat.animation")

local M = {}

-- Window state
M.state = {
	buf = nil,
	win = nil,
	visible = false,
}

-- Calculate window position based on config
local function get_window_position()
	local pos = config.get("window.position")
	local width = config.get("window.width")
	local height = config.get("window.height")

	local ui = vim.api.nvim_list_uis()[1]
	local editor_width = ui.width
	local editor_height = ui.height

	local row, col

	if pos == "top-left" then
		row = 1
		col = 1
	elseif pos == "top-right" then
		row = 1
		col = editor_width - width - 2
	elseif pos == "bottom-left" then
		row = editor_height - height - 4
		col = 1
	elseif pos == "bottom-right" then
		row = editor_height - height - 4
		col = editor_width - width - 2
	else
		-- Default to bottom-right
		row = editor_height - height - 4
		col = editor_width - width - 2
	end

	return row, col
end

-- Create the floating window buffer
local function create_buffer()
	if M.state.buf and vim.api.nvim_buf_is_valid(M.state.buf) then
		return M.state.buf
	end

	local buf = vim.api.nvim_create_buf(false, true)

	-- Buffer options
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)
	vim.api.nvim_buf_set_option(buf, "filetype", "bongo-cat")

	M.state.buf = buf
	return buf
end

-- Open the floating window
function M.open()
	if M.state.visible and M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
		return
	end

	local buf = create_buffer()
	local row, col = get_window_position()

	local win_opts = {
		relative = "editor",
		width = config.get("window.width"),
		height = config.get("window.height"),
		row = row,
		col = col,
		style = "minimal",
		border = config.get("window.border"),
		zindex = config.get("window.zindex"),
	}

	M.state.win = vim.api.nvim_open_win(buf, false, win_opts)
	M.state.visible = true

	-- Window options
	vim.api.nvim_win_set_option(M.state.win, "winblend", config.get("window.winblend"))
	vim.api.nvim_win_set_option(M.state.win, "winhighlight", "Normal:BongoCatNormal,FloatBorder:BongoCatBorder")
	vim.api.nvim_win_set_option(win, "wrap", false)
	vim.api.nvim_win_set_option(win, "signcolumn", "no")
	vim.api.nvim_win_set_option(win, "number", false)
	vim.api.nvim_win_set_option(win, "relativenumber", false)
	vim.api.nvim_win_set_option(win, "cursorline", false)

	-- And ensure window is wide enough
	local win_config = {
		relative = "editor",
		width = 80, -- Increase if needed
		height = 10,
		-- ... rest of config
	}

	-- Set initial frame
	M.render(animation.get_frame("idle"))
end

-- Close the floating window
function M.close()
	if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
		vim.api.nvim_win_close(M.state.win, true)
	end
	M.state.win = nil
	M.state.visible = false
end

-- Toggle the floating window
function M.toggle()
	if M.state.visible then
		M.close()
	else
		M.open()
	end
end

-- Render a frame to the buffer
function M.render(frame)
	if not M.state.buf or not vim.api.nvim_buf_is_valid(M.state.buf) then
		return
	end

	-- Ensure frame fits window
	local lines = {}
	local width = config.get("window.width")

	for _, line in ipairs(frame) do
		-- Pad or truncate lines to fit width
		if #line < width then
			line = line .. string.rep(" ", width - #line)
		elseif #line > width then
			line = line:sub(1, width)
		end
		table.insert(lines, line)
	end

	-- Pad with empty lines if needed
	local height = config.get("window.height")
	while #lines < height do
		table.insert(lines, string.rep(" ", width))
	end

	vim.api.nvim_buf_set_option(M.state.buf, "modifiable", true)
	vim.api.nvim_buf_set_lines(M.state.buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(M.state.buf, "modifiable", false)
end

-- Update window position (e.g., on resize)
function M.update_position()
	if not M.state.win or not vim.api.nvim_win_is_valid(M.state.win) then
		return
	end

	local row, col = get_window_position()

	vim.api.nvim_win_set_config(M.state.win, {
		relative = "editor",
		row = row,
		col = col,
	})
end

-- Check if window is visible
function M.is_visible()
	return M.state.visible and M.state.win and vim.api.nvim_win_is_valid(M.state.win)
end

-- Setup highlight groups
function M.setup_highlights()
	vim.api.nvim_set_hl(0, "BongoCatNormal", { link = "Normal", default = true })
	vim.api.nvim_set_hl(0, "BongoCatBorder", { link = "FloatBorder", default = true })
end

return M
