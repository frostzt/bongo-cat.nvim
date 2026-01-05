# bongo-cat.nvim

https://github.com/user-attachments/assets/fb1ffa74-2d34-4675-983e-eb5111cf4461

An adorable Bongo Cat that plays along with your keystrokes in Neovim!

![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)

## Features

- **Animated Bongo Cat** - ASCII cat that plays bongo when you type
- **Mode Awareness** - Different expressions for Normal, Insert, Visual, and Command modes
- **Combo System** - Cat gets more excited as you type faster
- **Stats Tracking** - Track keystrokes, streaks, and session stats
- **Event Reactions** - Happy cat on save, sad cat on errors
- **Customizable** - Position, appearance, and behavior options

## Requirements

- Neovim >= 0.8.0

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "frostzt/bongo-cat.nvim",
  config = function()
    require("bongo-cat").setup()
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "frostzt/bongo-cat.nvim",
  config = function()
    require("bongo-cat").setup()
  end,
}
```

## Configuration

```lua
require("bongo-cat").setup({
  -- Window settings
  window = {
    position = "bottom-right", -- "top-left", "top-right", "bottom-left", "bottom-right"
    width = 40,
    height = 12,
    border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
    winblend = 0, -- Transparency (0-100)
    zindex = 50,
  },

  -- Animation settings
  animation = {
    fps = 30,
    idle_timeout = 2000, -- Ms before cat goes idle
    combo_decay = 1000, -- Ms before combo resets
  },

  -- Combo thresholds (keystrokes per second)
  combo = {
    enabled = true,
    thresholds = {
      normal = 0,
      excited = 3, -- Gets sparkly
      hyper = 6, -- Both paws bongo!
    },
  },

  -- Stats tracking
  stats = {
    enabled = true,
    persist = true, -- Save stats between sessions
  },

  -- Mode-specific appearances
  modes = {
    enabled = true,
  },

  -- Event reactions
  events = {
    on_save = true, -- Happy animation on save
    on_error = true, -- Sad animation on error
  },

  -- Auto-start
  auto_start = false,

  -- Keymaps
  keymaps = {
    toggle = "<leader>bc", -- Set to false to disable
  },
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:BongoCat` | Toggle Bongo Cat visibility |
| `:BongoCat show` | Show Bongo Cat |
| `:BongoCat hide` | Hide Bongo Cat |
| `:BongoCat stats` | Show session and all-time stats |
| `:BongoCat reset` | Reset session stats |
| `:BongoCat health` | Show plugin health info |
| `:BongoCatShow` | Show Bongo Cat |
| `:BongoCatHide` | Hide Bongo Cat |
| `:BongoCatStats` | Show stats |

## API

```lua
local bongo = require("bongo-cat")

-- Control visibility
bongo.show()
bongo.hide()
bongo.toggle()

-- Get stats
local stats = bongo.get_stats()
-- stats.session - current session stats
-- stats.all_time - persisted all-time stats

-- Play specific animation
bongo.play("happy")
bongo.play("sad")
bongo.play("idle")
```

## Cat States

| State | Trigger |
|-------|---------|
| Idle | No typing for 2 seconds |
| Bongo Left/Right | Alternates on each keystroke |
| Bongo Both | Hyper mode (6+ keys/sec) |
| Excited | Fast typing (3+ keys/sec) |
| Happy | After saving a file |
| Sad | When errors are detected |
| Alert | Visual mode |
| Command | Command-line mode |

## Acknowledgments

- Inspired by the [Bongo Cat](https://bongo.cat/) meme
- ASCII art created with love
