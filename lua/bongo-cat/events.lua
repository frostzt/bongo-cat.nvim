-- bongo-cat.nvim/lua/bongo-cat/events.lua
-- Autocmds and event handling

local config = require("bongo-cat.config")
local animation = require("bongo-cat.animation")
local window = require("bongo-cat.window")
local stats = require("bongo-cat.stats")

local M = {}

-- Event state
M.state = {
  augroup = nil,
  idle_timer = nil,
  sleep_timer = nil, -- For sleepy animation after long idle
  combo_timer = nil,
  event_timer = nil, -- For temporary event animations
}

-- Handle keystroke event
local function on_keystroke()
  if not window.is_visible() then
    return
  end

  -- Record the keystroke and get current KPS
  local kps = stats.record_keystroke()

  -- Update combo level
  local thresholds = config.get("combo.thresholds")
  animation.set_combo_level(kps, thresholds)

  -- Show bongo animation
  window.render(animation.get_bongo_frame())

  -- Reset idle timer
  if M.state.idle_timer then
    M.state.idle_timer:stop()
  end

  -- Reset sleep timer
  if M.state.sleep_timer then
    M.state.sleep_timer:stop()
  end

  M.state.idle_timer = vim.defer_fn(function()
    if window.is_visible() then
      -- Go back to idle
      stats.reset_streak()
      animation.state.combo_level = "normal"
      local mode = vim.api.nvim_get_mode().mode
      if config.get("modes.enabled") then
        window.render(animation.get_mode_frame(mode))
      else
        window.render(animation.get_idle_frame())
      end

      -- Start sleep timer for longer idle
      M.state.sleep_timer = vim.defer_fn(function()
        if window.is_visible() then
          window.render(animation.get_event_frame("sleep"))
        end
      end, config.get("animation.sleep_timeout") - config.get("animation.idle_timeout"))
    end
  end, config.get("animation.idle_timeout"))
end

-- Handle mode change
local function on_mode_change()
  if not window.is_visible() then
    return
  end

  if not config.get("modes.enabled") then
    return
  end

  local mode = vim.api.nvim_get_mode().mode
  window.render(animation.get_mode_frame(mode))
end

-- Handle save event
local function on_save()
  if not window.is_visible() then
    return
  end

  if not config.get("events.on_save") then
    return
  end

  -- Show happy animation
  window.render(animation.get_event_frame("save"))

  -- Reset after a short delay
  if M.state.event_timer then
    M.state.event_timer:stop()
  end

  M.state.event_timer = vim.defer_fn(function()
    if window.is_visible() then
      local mode = vim.api.nvim_get_mode().mode
      window.render(animation.get_mode_frame(mode))
    end
  end, 1500)
end

-- Handle error/diagnostic event
local function on_error()
  if not window.is_visible() then
    return
  end

  if not config.get("events.on_error") then
    return
  end

  -- Show sad animation
  window.render(animation.get_event_frame("error"))

  -- Reset after a short delay
  if M.state.event_timer then
    M.state.event_timer:stop()
  end

  M.state.event_timer = vim.defer_fn(function()
    if window.is_visible() then
      local mode = vim.api.nvim_get_mode().mode
      window.render(animation.get_mode_frame(mode))
    end
  end, 2000)
end

-- Handle window resize
local function on_resize()
  if window.is_visible() then
    window.update_position()
  end
end

-- Setup all autocmds
function M.setup()
  -- Create augroup
  M.state.augroup = vim.api.nvim_create_augroup("BongoCat", { clear = true })

  -- Keystroke detection via CursorMovedI and TextChangedI
  vim.api.nvim_create_autocmd({ "CursorMovedI", "TextChangedI" }, {
    group = M.state.augroup,
    callback = on_keystroke,
  })

  -- Mode change detection
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = M.state.augroup,
    callback = on_mode_change,
  })

  -- Save event
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = M.state.augroup,
    callback = on_save,
  })

  -- Error detection via diagnostics
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = M.state.augroup,
    callback = function()
      local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      if #diagnostics > 0 then
        on_error()
      end
    end,
  })

  -- Window resize
  vim.api.nvim_create_autocmd("VimResized", {
    group = M.state.augroup,
    callback = on_resize,
  })

  -- Save stats on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = M.state.augroup,
    callback = function()
      stats.save()
    end,
  })
end

-- Cleanup autocmds
function M.cleanup()
  if M.state.augroup then
    vim.api.nvim_del_augroup_by_id(M.state.augroup)
    M.state.augroup = nil
  end

  if M.state.idle_timer then
    M.state.idle_timer:stop()
    M.state.idle_timer = nil
  end

  if M.state.combo_timer then
    M.state.combo_timer:stop()
    M.state.combo_timer = nil
  end

  if M.state.event_timer then
    M.state.event_timer:stop()
    M.state.event_timer = nil
  end

  if M.state.sleep_timer then
    M.state.sleep_timer:stop()
    M.state.sleep_timer = nil
  end
end

return M
