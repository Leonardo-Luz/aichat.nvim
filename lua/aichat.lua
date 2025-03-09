local generate_ai_text = require("textgen").generate_text
local floatwindow = require("floatwindow")

local M = {}

local state = {
  loop = nil,
  window_config = {
    background = {
      floating = {
        buf = -1,
        win = -1,
      },
    },
    header = {
      floating = {
        buf = -1,
        win = -1,
      },
    },
    response = {
      floating = {
        buf = -1,
        win = -1,
      },
    },
    input = {
      floating = {
        buf = -1,
        win = -1,
      },
    },
    footer = {
      floating = {
        buf = -1,
        win = -1,
      },
    },
  },
  buftext = "",
}

local create_window_config = function()
  local win_width = vim.o.columns
  local win_height = vim.o.lines

  local float_width = math.floor(win_width * 0.6)
  local float_height = math.floor(win_height * 0.6)

  local row = math.floor((win_height - float_height) / 2)
  local col = math.floor((win_width - float_width) / 2)

  local header_height = 2
  local footer_height = 1
  local response_height = math.floor(float_height / 2)
  local input_height = response_height - 5 - 1 - 3 - 1

  return {
    background = {
      floating = {
        buf = -1,
        win = -1,
      },
      opts = {
        relative = "editor",
        style = "minimal",
        zindex = 1,
        width = float_width,
        height = float_height,
        col = col,
        row = row,
        border = "rounded",
      },
      enter = false,
    },
    header = {
      floating = {
        buf = -1,
        win = -1,
      },
      opts = {
        relative = "editor",
        style = "minimal",
        zindex = 4,
        width = float_width - 2,
        height = header_height,
        col = col + 1,
        row = row + 1,
        border = { " ", " ", " ", " ", " ", " ", " ", " " },
      },
      enter = false,
    },
    response = {
      floating = {
        buf = -1,
        win = -1,
      },
      opts = {
        relative = "editor",
        style = "minimal",
        zindex = 3,
        width = float_width - 20,
        height = response_height - 1,
        col = col + 9,
        row = row + 5,
        border = { " ", " ", " ", " ", " ", " ", " ", " " },
      },
      enter = false,
    },
    input = {
      floating = {
        buf = -1,
        win = -1,
      },
      opts = {
        relative = "editor",
        style = "minimal",
        zindex = 3,
        width = float_width - 20,
        height = input_height,
        col = col + 9,
        row = row + response_height + 6,
        border = { " ", " ", " ", " ", " ", " ", " ", "" },
      },
    },
    footer = {
      floating = {
        buf = -1,
        win = -1,
      },
      opts = {
        relative = "editor",
        style = "minimal",
        zindex = 4,
        width = float_width,
        height = footer_height,
        col = col + 1,
        row = row + float_height,
        border = "none",
      },
      enter = false,
    },
  }
end

local foreach_float = function(callback)
  for name, float in pairs(state.window_config) do
    callback(name, float)
  end
end

local exit_window = function()
  if state.loop ~= nil then
    vim.fn.timer_stop(state.loop)
  end

  foreach_float(function(_, float)
    pcall(vim.api.nvim_win_close, float.floating.win, true)
  end)
end

local function goto_buffer_end(floating, offset)
  local last_line = vim.api.nvim_buf_line_count(floating.buf)
  local last_col = vim.api.nvim_buf_get_lines(floating.buf, last_line - 1, last_line, false)[1]:len()

  vim.api.nvim_win_set_cursor(floating.win, { last_line - offset, last_col + 1 })
end

local set_content = function()
  local footer = string.format("  AI CHAT BOT v.1.0")

  local lines = vim.split(state.buftext, "\n")

  vim.api.nvim_buf_set_lines(state.window_config.footer.floating.buf, 0, -1, false, { footer })

  vim.api.nvim_buf_set_lines(state.window_config.input.floating.buf, 0, -1, true, {})

  vim.api.nvim_buf_set_lines(state.window_config.response.floating.buf, 0, -1, true, {})

  vim.api.nvim_buf_set_lines(state.window_config.response.floating.buf, 0, -1, false, {})
  vim.api.nvim_buf_set_lines(state.window_config.response.floating.buf, 0, #lines, false, lines)
end

local loading = function()
  local footer = string.format("  AI CHAT BOT v.1.0 - LOADING")
  vim.api.nvim_buf_set_lines(state.window_config.footer.floating.buf, 0, -1, false, { footer })
end

local create_remaps = function()
  vim.keymap.set("n", "<esc><esc>", function()
    exit_window()
  end, {
    buffer = state.window_config.input.floating.buf,
  })

  vim.keymap.set("n", "q", function()
    exit_window()
  end, {
    buffer = state.window_config.input.floating.buf,
  })

  vim.keymap.set("n", "<esc><esc>", function()
    exit_window()
  end, {
    buffer = state.window_config.response.floating.buf,
  })

  vim.keymap.set("n", "q", function()
    exit_window()
  end, {
    buffer = state.window_config.response.floating.buf,
  })

  vim.keymap.set("n", "<C-k>", function()
    vim.api.nvim_set_current_win(state.window_config.input.floating.win)
  end, {
    buffer = state.window_config.response.floating.buf,
  })

  vim.keymap.set("n", "<C-k>", function()
    vim.api.nvim_set_current_win(state.window_config.response.floating.win)
  end, {
    buffer = state.window_config.input.floating.buf,
  })

  vim.keymap.set("n", "<C-j>", function()
    vim.api.nvim_set_current_win(state.window_config.input.floating.win)
  end, {
    buffer = state.window_config.response.floating.buf,
  })

  vim.keymap.set("n", "<C-j>", function()
    vim.api.nvim_set_current_win(state.window_config.response.floating.win)
  end, {
    buffer = state.window_config.input.floating.buf,
  })

  vim.keymap.set("i", "<CR>", function()
    loading()

    local input = table.concat(vim.api.nvim_buf_get_lines(state.window_config.input.floating.buf, 0, -1, false), "\n")

    for _, text in pairs(vim.api.nvim_buf_get_lines(state.window_config.input.floating.buf, 0, -1, false)) do
      local padding = (""):rep(state.window_config.response.opts.width - text:len(), " ")
      state.buftext = state.buftext .. padding .. text .. "\n"
    end

    state.buftext = state.buftext .. "loading..." .. "\n"

    set_content()

    goto_buffer_end(state.window_config.response.floating, 2)

    local async_gen = function()
      local generated_text = generate_ai_text({ prompt = input }).generated_text

      state.buftext = string.gsub(state.buftext, "loading...\n$", "")
      state.buftext = state.buftext .. (state.buftext == "" and "" or "\n") .. generated_text .. "\n"
      set_content()

      local count = #vim.split(generated_text, "\n")
      goto_buffer_end(state.window_config.response.floating, count)
    end

    state.loop = vim.fn.timer_start(20, async_gen, { ["repeat"] = 1 })
  end, {
    buffer = state.window_config.input.floating.buf,
  })

  vim.keymap.set("n", "<leader>r", function()
    state.buftext = ""
    set_content()
  end, {
    buffer = state.window_config.input.floating.buf,
  })

  -- vim.api.nvim_create_autocmd("BufLeave", {
  --   buffer = state.window_config.input.floating.buf,
  --   callback = function()
  --     exit_window()
  --   end,
  -- })

  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("present-resized", {}),
    callback = function()
      if
        not vim.api.nvim_win_is_valid(state.window_config.input.floating.win)
        or state.window_config.input.floating.win == nil
      then
        return
      end

      local updated = create_window_config()

      foreach_float(function(name, float)
        float.opts = updated[name].opts
        vim.api.nvim_win_set_config(float.floating.win, updated[name].opts)
      end)

      set_content()
    end,
  })
end

M.start = function()
  state.window_config = create_window_config()

  foreach_float(function(_, float)
    float.floating = floatwindow.create_floating_window(float)
  end)

  local title_text = "AI Chat Bot"
  local padding = string.rep(" ", (state.window_config.header.opts.width - #title_text) / 2)
  local title = padding .. title_text

  vim.api.nvim_buf_set_lines(state.window_config.header.floating.buf, 0, -1, false, { title })

  vim.bo[state.window_config.response.floating.buf].filetype = "markdown"

  set_content()

  create_remaps()
end

local toggle_chat = function()
  if not vim.api.nvim_win_is_valid(state.window_config.input.floating.win) then
    M.start()
  else
    exit_window()
  end
end

vim.api.nvim_create_user_command("AiChat", function()
  toggle_chat()
end, {})

return M
