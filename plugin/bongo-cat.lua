-- bongo-cat.nvim/plugin/bongo-cat.lua
-- Auto-load and commands

-- Prevent loading twice
if vim.g.loaded_bongo_cat then
  return
end
vim.g.loaded_bongo_cat = true

-- Create user commands
vim.api.nvim_create_user_command("BongoCat", function(opts)
  local bongo = require("bongo-cat")
  local arg = opts.args

  if arg == "" or arg == "toggle" then
    bongo.toggle()
  elseif arg == "show" then
    bongo.show()
  elseif arg == "hide" then
    bongo.hide()
  elseif arg == "stats" then
    bongo.show_stats()
  elseif arg == "reset" then
    bongo.reset_stats()
  elseif arg == "health" then
    local health = bongo.health()
    vim.print(health)
  else
    -- Try to play animation by name
    bongo.play(arg)
  end
end, {
  nargs = "?",
  complete = function()
    return { "toggle", "show", "hide", "stats", "reset", "health", "happy", "sad", "idle" }
  end,
  desc = "Control Bongo Cat",
})

-- Convenience commands
vim.api.nvim_create_user_command("BongoCatShow", function()
  require("bongo-cat").show()
end, { desc = "Show Bongo Cat" })

vim.api.nvim_create_user_command("BongoCatHide", function()
  require("bongo-cat").hide()
end, { desc = "Hide Bongo Cat" })

vim.api.nvim_create_user_command("BongoCatStats", function()
  require("bongo-cat").show_stats()
end, { desc = "Show Bongo Cat Stats" })
