# windex.nvim

🧼 __A neovim plugin for cleeean neovim window and tmux pane functions.__ 🧼

Works with or without tmux!

## ✨ Features

### Maximize Current Window

* Use `<leader>z` to toggle maximizing the current neovim window (without any of
  the ugly borders that other maximizing plugins create) AND the current
  tmux pane.
* Works with plugins such as 'nvim-scrollview', which have floating windows
  (unlike other maximizing plugins).

### Cleaner Window Movement

* Treats tmux panes as neovim windows which allows for easy window/pane movement.
* Use `<leader>{motion}` to swith to the window (or tmux pane) in the specified 
  direction.
* Use `<leader>x{motion}` to save and quit the window (or kill the tmux pane) in
  the specified direction.

_Note: The {motion} keys by default are h, j, k and l, but can be replaced
  with the arrow keys. See 'Configuration' for details._

### Terminal Toggle

* Use `<C-\>` to toggle the (improved) native terminal which will open
  fullscreen. _(See the demo video at the bottom of the readme _👀_)_

## ⏱️ Performance Comparison

A comparison of vim-maximizer and windex.nvim with maximizing a nvim window and a tmux pane split.

### vim-maximizer

Has weird thing in the top left where it didn't maximize properly and doesn't maximize the tmux pane. 🤢

![vim-maximizer](https://user-images.githubusercontent.com/90937622/159694125-322f371f-4334-4731-bf02-cfde05945654.png)

### windex.nvim

Perfectly maximizes the neovim window and tmux pane! 👑

![windex](https://user-images.githubusercontent.com/90937622/159694138-5b99ec1d-e860-42fb-9af6-ca23b98dda25.png)

## 📦 Installation

Install with your favourite plugin manager:

### Packer

```lua
use 'declancm/windex.nvim'
```

## ⚙️ Configuration

A settings table can be passed into the setup function for custom options.

The default settings are:

```lua
require('cinnamon').setup {
  default_keymaps = true, -- Enable default keymaps.
  arrow_keys = false,     -- Default keymaps use arrow keys instead of 'h,j,k,l'.
  disable = false,        -- Disable the plugin.
}
```

## ⌨️ Default Keymaps

```lua
local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- Toggle maximizing the current window:
-- (If your system doesn't pass the tmux requirement, 'toggle_nvim_maximize()' will be used instead.)
keymap('n', '<Leader>z', "<Cmd>lua require('windex').toggle_maximize()<CR>", opts)

-- Switch to previous nvim window or tmux pane:
keymap('n', '<Leader>;', "<Cmd>lua require('windex').previous_window()<CR>", opts)

-- Move between nvim windows and tmux panes:
keymap('n', '<Leader>k', "<Cmd>lua require('windex').switch_window('up')<CR>", opts)
keymap('n', '<Leader>j', "<Cmd>lua require('windex').switch_window('down')<CR>", opts)
keymap('n', '<Leader>h', "<Cmd>lua require('windex').switch_window('left')<CR>", opts)
keymap('n', '<Leader>l', "<Cmd>lua require('windex').switch_window('right')<CR>", opts)

-- Save and close the nvim window or kill the tmux pane in the direction selected:
keymap('n', '<Leader>xk', "<Cmd>lua require('windex').close_window('up')<CR>", opts)
keymap('n', '<Leader>xj', "<Cmd>lua require('windex').close_window('down')<CR>", opts)
keymap('n', '<Leader>xh', "<Cmd>lua require('windex').close_window('left')<CR>", opts)
keymap('n', '<Leader>xl', "<Cmd>lua require('windex').close_window('right')<CR>", opts)

-- Toggle the terminal:
keymap('n', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>", opts)
keymap('t', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>", opts)
keymap('t', '<C-n>', '<C-Bslash><C-n>', opts)
```

_Note: The default keymap to toggle the terminal is CTRL-\\. To enter normal mode in
terminal, the key combination is CTRL-\\ + CTRL-N which is no longer possible to 
execute. This sequence is therefore remapped to CTRL-N when in the terminal._

## ℹ️ Usage

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

## 🎬 Demo Video

### Nvim Window / Tmux Pane Movement and Terminal Toggle

https://user-images.githubusercontent.com/90937622/159681079-58f36668-e78b-41fa-b929-e9ebc9dd8d3b.mp4
