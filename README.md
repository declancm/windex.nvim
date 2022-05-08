# windex.nvim

🧼 __A neovim plugin for cleeean neovim window (and optionally tmux pane) functions.__ 🧼

Works with or without tmux!


## ✨ Features

Please see [maximize.nvim](https://github.com/declancm/maximize.nvim) for just the window maximizing feature.

### Window Maximizing

* Use `<leader>z` to toggle maximizing the current neovim window (without any of
  the ugly borders that other maximizing plugins create) AND the current
  tmux pane.
* Works with plugins such as 'nvim-scrollview', which have floating windows
  (unlike other maximizing plugins).

### Terminal Toggle

* Use `<C-\>` to toggle the (improved) native terminal which will open
  fullscreen. _(See the demo video below)_

### Cleaner Window Movement

* Treats tmux panes as neovim windows which allows for easy window/pane movement.
* Use `<leader>{motion}` to switch to the window (or tmux pane) in the specified 
  direction.
* Use `<leader>x{motion}` to save and quit the window (or kill the tmux pane) in
  the specified direction.
* Use `<leader>;` to jump to the previous window (or tmux pane).
* Use vim keymaps to create tmux panes.

_Note: The {motion} keys by default are h, j, k and l, but can be replaced
  with the arrow keys. See 'Configuration' for details._

## 🔥 Demos

<details>
<summary markdown="span">Maximizing Performance Comparison with Vim-Maximizer</summary>

<!-- A comparison of vim-maximizer and windex.nvim with maximizing a nvim window and a tmux pane split. -->

### vim-maximizer

Has weird thing in the top left where it didn't maximize properly and doesn't maximize the tmux pane. 🤢

![vim-maximizer](https://user-images.githubusercontent.com/90937622/159694125-322f371f-4334-4731-bf02-cfde05945654.png)

### windex.nvim

Perfectly maximizes the neovim window and tmux pane! 👑

![windex](https://user-images.githubusercontent.com/90937622/159694138-5b99ec1d-e860-42fb-9af6-ca23b98dda25.png)

</details>

<details>
<summary markdown="span">Demo Video - Terminal Toggle</summary>

### Window / Pane Movement and Terminal Toggle

https://user-images.githubusercontent.com/90937622/159681079-58f36668-e78b-41fa-b929-e9ebc9dd8d3b.mp4

</details>

## 📦 Installation

Install with your favourite plugin manager and run the setup function.

_Note: I highly recommend using [bufresize.nvim](https://github.com/kwkarlwang/bufresize.nvim) especially when using tmux._

### Packer

```lua
use {
  'declancm/windex.nvim',
  config = function() require('windex').setup() end
}
```

## ⚙️ Configuration

A settings table can be passed into the setup function for custom options.

### Default Settings

```lua
-- KEYMAPS:
default_keymaps = true, -- Enable default keymaps.
extra_keymaps = false,  -- Enable extra keymaps.
arrow_keys = false,     -- Default window movement keymaps use arrow keys instead of 'h,j,k,l'.

-- OPTIONS:
numbered_term = false,  -- Enable line numbers in the terminal.
save_buffers = false,   -- Save all buffers before switching tmux panes.
warnings = true,        -- Enable warnings before some actions such as closing tmux panes.
```

### Example Configuration

```lua
require('windex').setup {
  extra_keymaps = true,
  save_buffers = true,
}
```

## ⌨️  Keymaps

_Note: If the tmux requirement is not passed, the non-tmux keymaps will be
used instead._

### Default Keymaps

```lua
-- MAXIMIZE:

-- Toggle maximizing the current window:
vim.keymap.set('n', '<Leader>z', "<Cmd>lua require('windex').toggle_maximize()<CR>")

-- TERMINAL:

-- Toggle the terminal:
vim.keymap.set({ 'n', 't' }, '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>")

-- Enter normal mode within terminal:
vim.keymap.set('t', '<C-n>', '<C-Bslash><C-n>')

-- MOVEMENT:

-- Move between nvim windows and tmux panes:
vim.keymap.set('n', '<Leader>k', "<Cmd>lua require('windex').switch_window('up')<CR>")
vim.keymap.set('n', '<Leader>j', "<Cmd>lua require('windex').switch_window('down')<CR>")
vim.keymap.set('n', '<Leader>h', "<Cmd>lua require('windex').switch_window('left')<CR>")
vim.keymap.set('n', '<Leader>l', "<Cmd>lua require('windex').switch_window('right')<CR>")

-- Save and close the nvim window or kill the tmux pane in the direction selected:
vim.keymap.set('n', '<Leader>xk', "<Cmd>lua require('windex').close_window('up')<CR>")
vim.keymap.set('n', '<Leader>xj', "<Cmd>lua require('windex').close_window('down')<CR>")
vim.keymap.set('n', '<Leader>xh', "<Cmd>lua require('windex').close_window('left')<CR>")
vim.keymap.set('n', '<Leader>xl', "<Cmd>lua require('windex').close_window('right')<CR>")

-- Switch to previous nvim window or tmux pane:
vim.keymap.set('n', '<Leader>;', "<Cmd>lua require('windex').previous_window()<CR>")
```

### Extra Keymaps

```lua
-- MOVEMENT:

-- Create nvim panes:
vim.keymap.set('n', '<Leader>v', '<Cmd>wincmd v<CR>')
vim.keymap.set('n', '<Leader>s', '<Cmd>wincmd s<CR>')

-- Create tmux panes:
vim.keymap.set('n', '<Leader>tv', "<Cmd>lua require('windex').create_pane('vertical')<CR>")
vim.keymap.set('n', '<Leader>ts', "<Cmd>lua require('windex').create_pane('horizontal')<CR>")
```

## ℹ️ API

_Note: Check the default keymaps on how to implement the functions in keymaps._

### Maximize Current Window

* Maximize the current neovim window completely without any of the ugly borders
  that other plugins create.

  ```lua
  require('windex').toggle_nvim_maximize()
  ```

* Maximize the current neovim window __AND__ tmux pane for when you need something
  comletely fullscreen.

  ```lua
  require('windex').toggle_maximize()
  ```

### Terminal Toggle

* Toggle the (improved) interactive native terminal.

  ```lua
  require('windex').toggle_terminal([{maximize} [, {command}]])
  ```

  * The {maximize} values are:
  
    * 'none' - No maximizing,
    
    * 'nvim' - Maximize the neovim window,
    
    * 'all' - Maximize the neovim window and tmux pane (the default).

  * The optional {command} argument is a command to run in a non-interactive
    terminal.

  * __Example:__ Custom keymap to open lazygit fullscreen.

    ```lua
    vim.api.nvim_set_keymap(
      'n',
      '<C-g>',
      "<Cmd>lua require('windex').toggle_terminal('all','lazygit')<CR>",
      { noremap = true, silent = true }
    )
    ```

### Cleaner Window Movement

* Treats tmux panes as neovim windows which allows for easy window/pane movement,
  with the same function. The {direction} values are: 'up', 'down', 'left' or
  'right'.

  ```lua
  require('windex').switch_window({direction})
  ```

* Save and quit the neovim window, or kill the tmux pane, in the selected
  direction. The {direction} values are: 'up', 'down', 'left' or 'right'.

  ```lua
  require('windex').close_window({direction})
  ```

* Jump to the last neovim window or tmux pane.

  ```lua
  require('windex').previous_window()
  ```

* Create a tmux pane. The {split} values are: 'vertical' or 'horizontal'.

  ```lua
  require('windex').create_pane({split})
  ```
