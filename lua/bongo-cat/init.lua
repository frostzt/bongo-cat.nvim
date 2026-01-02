-- bongo-cat.nvim/lua/bongo-cat/init.lua
-- Main entry point and setup

local config = require("bongo-cat.config")
local window = require("bongo-cat.window")
local events = require("bongo-cat.events")
local stats = require("bongo-cat.stats")
local animation = require("bongo-cat.animation")

local M = {}

M.is_setup = false

-- Setup the plugin
function M.setup(opts)
  -- Only setup once
  if M.is_setup then
    return
  end

  -- Initialize configuration
  config.setup(opts)

  -- Setup highlight groups
  window.setup_highlights()

  -- Initialize stats
  stats.init()

  -- Setup event handlers
  events.setup()

  -- Setup keymaps
  local keymap = config.get("keymaps.toggle")
  if keymap then
    vim.keymap.set("n", keymap, function()
      M.toggle()
    end, { desc = "Toggle Bongo Cat", silent = true })
  end

  -- Auto-start if configured
  if config.get("auto_start") then
    vim.defer_fn(function()
      M.show()
    end, 100)
  end

  M.is_setup = true
end

-- Show the bongo cat window
function M.show()
  window.open()
end

-- Hide the bongo cat window
function M.hide()
  window.close()
end

-- Toggle the bongo cat window
function M.toggle()
  window.toggle()
end

-- Get current stats
function M.get_stats()
  return {
    session = stats.get_session_stats(),
    all_time = stats.get_all_time_stats(),
  }
end

-- Show stats in a notification
function M.show_stats()
  local lines = stats.format_stats()
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Bongo Cat Stats" })
end

-- Trigger a specific animation
function M.play(anim_name)
  if not window.is_visible() then
    return
  end

  local frame = animation.get_frame(anim_name)
  if frame then
    window.render(frame)
  end
end

-- Reset stats
function M.reset_stats()
  stats.state.session = {
    keystrokes = 0,
    start_time = os.time(),
    current_streak = 0,
    best_streak = 0,
  }
  vim.notify("Session stats reset!", vim.log.levels.INFO, { title = "Bongo Cat" })
end

-- Get health check info
function M.health()
  local health = {
    setup = M.is_setup,
    visible = window.is_visible(),
    config = config.get(),
    session_stats = stats.get_session_stats(),
  }
  return health
end

return M
