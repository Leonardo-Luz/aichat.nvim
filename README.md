## aichat.nvim

*A Neovim plugin that provides an integrated AI chatbot experience within your editor.*

**Features:**

* AI-powered chat functionality within Neovim.

**Dependecies:**

* `leonardo-luz/floatwindow.nvim`
* `leonardo-luz/ai.nvim`

**Installation:**  Add `leonardo-luz/aichat.nvim` to your Neovim plugin manager (e.g., `init.lua` or `plugins.lua`).  For example:

```lua
{ 'leonardo-luz/aichat.nvim' }
```

**Usage:**

* `:AiChat`: Starts a new AI chat session.

**Normal Mode:**

* `<Esc><Esc>` or `q`: Quits the current chat session.
* `<leader>r`: Resets the current chat conversation.
* `<C-k>`: Switches the focus to the upper window (input or response, depending on current focus).
* `<C-j>`: Switches the focus to the lower window (input or response, depending on current focus).

**Insert Mode:**

* `<CR>` (Enter): Sends the current input to the AI.
