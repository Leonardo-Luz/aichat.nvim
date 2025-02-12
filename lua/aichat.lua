local textGen = require("textgen")
local floatwindow = require("floatwindow")

local M = {}

local state = {}

local window_config = function()
  return {}
end

M.start = function()
  vim.print("Work in progress...")

  state.window_config = window_config()
end

vim.api.nvim_create_user_command("AiChat", function()
  M.start()
end, {})

return M
