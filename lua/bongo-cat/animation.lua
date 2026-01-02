-- bongo-cat.nvim/lua/bongo-cat/animation.lua
-- ASCII art frames and animation logic

local M = {}

-- Bongo Cat ASCII Art Frames
-- Each frame is a table of strings (lines)

-- Cute Japanese-style sideways cat
M.frames = {
  -- Idle state - cat sitting peacefully
  idle = {
    [[                           ]],
    [[      /|、                  ]],
    [[     (˚ˎ 。7                ]],
    [[      |、~ヽ                ]],
    [[      じしf,)ノ              ]],
    [[                           ]],
    [[   ┌─────────────────────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Left paw down
  bongo_left = {
    [[                           ]],
    [[      /|、                  ]],
    [[     (˚ˎ 。7                ]],
    [[      |、~ヽ                ]],
    [[     じしf,)ノ               ]],
    [[        /                  ]],
    [[   ┌──●──────────────────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Right paw down
  bongo_right = {
    [[                           ]],
    [[      /|、                  ]],
    [[     (˚ˎ 。7                ]],
    [[      |、~ヽ                ]],
    [[      じしf,)ノ              ]],
    [[             \             ]],
    [[   ┌────────────────●────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Both paws down (for hyper mode)
  bongo_both = {
    [[                           ]],
    [[      /|、        !!       ]],
    [[     (°ˎ 。7                ]],
    [[      |、~ヽ                ]],
    [[     じしf,)ノ               ]],
    [[        /  \               ]],
    [[   ┌──●────────────●─────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Excited left paw
  excited_left = {
    [[            *   *          ]],
    [[      /|、   *              ]],
    [[     (°ˎ 。7                ]],
    [[      |、~ヽ                ]],
    [[     じしf,)ノ               ]],
    [[        /                  ]],
    [[   ┌──●──────────────────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Excited right paw
  excited_right = {
    [[            *   *          ]],
    [[      /|、   *              ]],
    [[     (°ˎ 。7                ]],
    [[      |、~ヽ                ]],
    [[      じしf,)ノ              ]],
    [[             \             ]],
    [[   ┌────────────────●────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Excited state (faster typing)
  excited = {
    [[            *   *          ]],
    [[      /|、   *              ]],
    [[     (°ˎ 。7                ]],
    [[      |、~ヽ                ]],
    [[      じしf,)ノ              ]],
    [[                           ]],
    [[   ┌─────────────────────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Happy (on save)
  happy = {
    [[          ♪  ♫             ]],
    [[      /|、                  ]],
    [[     (^ˎ ^7    ♪           ]],
    [[      |、~ヽ                ]],
    [[      じしf,)ノ              ]],
    [[                           ]],
    [[   ┌─────────────────────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Sad (on error)
  sad = {
    [[                           ]],
    [[      /|、                  ]],
    [[     (T ˎ T7               ]],
    [[      |、~ヽ                ]],
    [[      じしf,)ノ              ]],
    [[                           ]],
    [[   ┌─────────────────────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Alert (visual mode)
  alert = {
    [[           !               ]],
    [[      /|、                  ]],
    [[     (°ˎ 。7  ?             ]],
    [[      |、~ヽ                ]],
    [[      じしf,)ノ              ]],
    [[                           ]],
    [[   ┌─────────────────────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Command mode
  command = {
    [[                           ]],
    [[      /|、                  ]],
    [[     (˚ˎ 。7   ...          ]],
    [[      |、~ヽ                ]],
    [[      じしf,)ノ              ]],
    [[                           ]],
    [[   ┌─────────────────────┐ ]],
    [[   │ :                   │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },

  -- Sleepy - long idle
  sleepy = {
    [[                  z z z    ]],
    [[      /|、                  ]],
    [[     (- ˎ -7               ]],
    [[      |、~ヽ                ]],
    [[      じしf,)ノ              ]],
    [[                           ]],
    [[   ┌─────────────────────┐ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   │ ░░░░░░░░░░░░░░░░░░░ │ ]],
    [[   └─────────────────────┘ ]],
  },
}

-- Animation state
M.state = {
  current_frame = "idle",
  last_paw = "left", -- Alternate between left and right
  combo_level = "normal", -- "normal", "excited", "hyper"
  is_animating = false,
  keystroke_count = 0,
}

-- Get the current frame to display
function M.get_frame(frame_name)
  return M.frames[frame_name] or M.frames.idle
end

-- Get bongo frame alternating paws with combo awareness
function M.get_bongo_frame()
  M.state.keystroke_count = M.state.keystroke_count + 1

  -- Hyper mode - both paws!
  if M.state.combo_level == "hyper" then
    return M.frames.bongo_both
  end

  -- Excited mode - use excited paw frames
  if M.state.combo_level == "excited" then
    if M.state.last_paw == "left" then
      M.state.last_paw = "right"
      return M.frames.excited_right
    else
      M.state.last_paw = "left"
      return M.frames.excited_left
    end
  end

  -- Normal mode - alternate paws
  if M.state.last_paw == "left" then
    M.state.last_paw = "right"
    return M.frames.bongo_right
  else
    M.state.last_paw = "left"
    return M.frames.bongo_left
  end
end

-- Set combo level based on keystrokes per second
function M.set_combo_level(kps, thresholds)
  local prev_level = M.state.combo_level

  if kps >= thresholds.hyper then
    M.state.combo_level = "hyper"
  elseif kps >= thresholds.excited then
    M.state.combo_level = "excited"
  else
    M.state.combo_level = "normal"
  end

  return prev_level ~= M.state.combo_level
end

-- Get idle frame based on combo level
function M.get_idle_frame()
  if M.state.combo_level == "excited" or M.state.combo_level == "hyper" then
    return M.frames.excited
  end
  return M.frames.idle
end

-- Get mode-specific frame
function M.get_mode_frame(mode)
  local mode_frames = {
    n = M.frames.idle,
    i = M.frames.idle,
    v = M.frames.alert,
    V = M.frames.alert,
    [""] = M.frames.alert, -- Visual block
    c = M.frames.command,
    R = M.frames.alert,
    t = M.frames.command,
  }
  return mode_frames[mode] or M.frames.idle
end

-- Get event frame
function M.get_event_frame(event)
  local event_frames = {
    save = M.frames.happy,
    error = M.frames.sad,
    sleep = M.frames.sleepy,
  }
  return event_frames[event] or M.frames.idle
end

-- Reset animation state
function M.reset()
  M.state.combo_level = "normal"
  M.state.keystroke_count = 0
end

return M
