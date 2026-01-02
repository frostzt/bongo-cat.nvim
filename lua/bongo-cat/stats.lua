-- bongo-cat.nvim/lua/bongo-cat/stats.lua
-- Keystroke tracking and statistics

local config = require("bongo-cat.config")

local M = {}

-- Stats state
M.state = {
  -- Current session
  session = {
    keystrokes = 0,
    start_time = nil,
    current_streak = 0,
    best_streak = 0,
  },

  -- All time (persisted)
  all_time = {
    total_keystrokes = 0,
    total_sessions = 0,
    best_streak = 0,
    total_bongos = 0,
  },

  -- Combo tracking
  combo = {
    keystrokes = {}, -- Timestamps of recent keystrokes
    current_kps = 0, -- Current keystrokes per second
  },
}

-- Initialize stats
function M.init()
  M.state.session.start_time = os.time()
  M.load()
end

-- Record a keystroke
function M.record_keystroke()
  local now = vim.loop.now() -- Milliseconds

  -- Update session stats
  M.state.session.keystrokes = M.state.session.keystrokes + 1
  M.state.session.current_streak = M.state.session.current_streak + 1

  if M.state.session.current_streak > M.state.session.best_streak then
    M.state.session.best_streak = M.state.session.current_streak
  end

  -- Update all-time stats
  M.state.all_time.total_keystrokes = M.state.all_time.total_keystrokes + 1
  M.state.all_time.total_bongos = M.state.all_time.total_bongos + 1

  if M.state.session.current_streak > M.state.all_time.best_streak then
    M.state.all_time.best_streak = M.state.session.current_streak
  end

  -- Track for KPS calculation
  table.insert(M.state.combo.keystrokes, now)

  -- Clean old keystrokes (older than 1 second)
  local cutoff = now - 1000
  local new_keystrokes = {}
  for _, ts in ipairs(M.state.combo.keystrokes) do
    if ts > cutoff then
      table.insert(new_keystrokes, ts)
    end
  end
  M.state.combo.keystrokes = new_keystrokes

  -- Calculate KPS
  M.state.combo.current_kps = #M.state.combo.keystrokes

  return M.state.combo.current_kps
end

-- Reset streak (called after idle timeout)
function M.reset_streak()
  M.state.session.current_streak = 0
  M.state.combo.keystrokes = {}
  M.state.combo.current_kps = 0
end

-- Get current KPS
function M.get_kps()
  return M.state.combo.current_kps
end

-- Get session stats
function M.get_session_stats()
  local duration = os.time() - (M.state.session.start_time or os.time())
  return {
    keystrokes = M.state.session.keystrokes,
    duration = duration,
    current_streak = M.state.session.current_streak,
    best_streak = M.state.session.best_streak,
    kps = M.state.combo.current_kps,
  }
end

-- Get all-time stats
function M.get_all_time_stats()
  return M.state.all_time
end

-- Load stats from file
function M.load()
  if not config.get("stats.persist") then
    return
  end

  local file_path = config.get("stats.file")
  local file = io.open(file_path, "r")

  if file then
    local content = file:read("*all")
    file:close()

    if content and content ~= "" then
      local ok, data = pcall(vim.json.decode, content)
      if ok and data then
        M.state.all_time = vim.tbl_extend("force", M.state.all_time, data)
      end
    end
  end

  -- Increment session count
  M.state.all_time.total_sessions = M.state.all_time.total_sessions + 1
end

-- Save stats to file
function M.save()
  if not config.get("stats.persist") then
    return
  end

  local file_path = config.get("stats.file")
  local file = io.open(file_path, "w")

  if file then
    local ok, json = pcall(vim.json.encode, M.state.all_time)
    if ok then
      file:write(json)
    end
    file:close()
  end
end

-- Format stats for display
function M.format_stats()
  local session = M.get_session_stats()
  local all_time = M.get_all_time_stats()

  local duration_str
  if session.duration < 60 then
    duration_str = string.format("%ds", session.duration)
  elseif session.duration < 3600 then
    duration_str = string.format("%dm %ds", math.floor(session.duration / 60), session.duration % 60)
  else
    duration_str = string.format(
      "%dh %dm",
      math.floor(session.duration / 3600),
      math.floor((session.duration % 3600) / 60)
    )
  end

  return {
    string.format("Session: %d keystrokes (%s)", session.keystrokes, duration_str),
    string.format("Streak: %d (Best: %d)", session.current_streak, session.best_streak),
    string.format("Speed: %d keys/sec", session.kps),
    "",
    string.format("All-time: %d keystrokes", all_time.total_keystrokes),
    string.format("Sessions: %d | Best streak: %d", all_time.total_sessions, all_time.best_streak),
  }
end

return M
