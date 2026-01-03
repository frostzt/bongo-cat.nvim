-- bongo-cat.nvim/lua/bongo-cat/config.lua
-- Default configuration and user overrides

local M = {}

M.defaults = {
  -- Window settings
  window = {
    position = "bottom-right", -- "top-left", "top-right", "bottom-left", "bottom-right"
    width = 45,
    height = 10,
    border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
    winblend = 0, -- Transparency (0-100)
    zindex = 50,
  },

  -- Animation settings
  animation = {
    fps = 30, -- Frames per second for animations
    idle_timeout = 2000, -- Ms before cat goes idle
    sleep_timeout = 30000, -- Ms before cat falls asleep (30 seconds)
    combo_decay = 1000, -- Ms before combo resets
  },

  -- Combo thresholds (keystrokes per second)
  combo = {
    enabled = true,
    thresholds = {
      normal = 0, -- Default state
      excited = 3, -- Gets excited
      hyper = 6, -- Maximum excitement
    },
  },

  -- Stats tracking
  stats = {
    enabled = true,
    persist = true, -- Save stats between sessions
    file = vim.fn.stdpath("data") .. "/bongo-cat-stats.json",
  },

  -- Mode-specific appearances
  modes = {
    enabled = true,
    -- Each mode can have custom frames or behaviors
  },

  -- Event reactions
  events = {
    on_save = true, -- Happy animation on save
    on_error = true, -- Sad animation on error
    on_lsp_progress = false, -- React to LSP loading
  },

  -- Auto-start
  auto_start = false, -- Start automatically when Neovim opens

  -- Keymaps (set to false to disable)
  keymaps = {
    toggle = "<leader>bc", -- Toggle visibility
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

function M.get(key)
  if key then
    local keys = vim.split(key, ".", { plain = true })
    local value = M.options
    for _, k in ipairs(keys) do
      if value == nil then
        return nil
      end
      value = value[k]
    end
    return value
  end
  return M.options
end

return M
