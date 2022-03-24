# windex.nvim

🧼 __A neovim plugin for cleeean nvim window and tmux pane functions.__ 🧼

## ✨ Features

### Maximize Current Window

* Toggle maximizing the current neovim window completely (without any of the ugly borders
  that other plugins create) AND maximizing the current tmux pane.

### Cleaner Window Movement

* Treats tmux panes as neovim windows which allows for easy window/pane movement.
  Switch-to or close any nvim window/tmux pane.

### Terminal Toggle

* Toggle the (improved) native terminal which will open fullscreen. _(See the
  demo video at the bottom of the readme _👀_)_

## ⏱️ Performance Comparison

A comparison of vim-maximizer and windex.nvim with maximizing a nvim window and a tmux pane split.

### vim-maximizer

Has weird thing in the top left where it didn't maximize properly and doesn't maximize the tmux pane. 🤢

![vim-maximizer](https://user-images.githubusercontent.com/90937622/159694125-322f371f-4334-4731-bf02-cfde05945654.png)

### windex.nvim

Perfectly maximizes the nvim window and tmux pane! 👑

![windex](https://user-images.githubusercontent.com/90937622/159694138-5b99ec1d-e860-42fb-9af6-ca23b98dda25.png)

## 📦 Installation

Install with your favourite plugin manager:

### Packer

```lua
use 'declancm/windex.nvim'
```

## 🎉 Usage

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
  with the same function.

  ```lua
  require('windex').switch_window({direction})
  ```

* Save and quit the neovim window, or kill the tmux pane, in the selected direction.

  ```lua
  require('windex').close_window({direction})
  ```

* Jump to the last neovim window or tmux pane.

  ```lua
  require('windex').previous_window()
  ```

### Terminal Toggle

* Toggle the (improved) native terminal which will open fullscreen.

  ```lua
  require('windex').toggle_terminal([{maximize} [, {command}]])
  ```

  * The maximize argument can either be 'none', 'nvim', or 'both'. Respectively,
    this either does no maximizing, maximizes the current nvim window, or
    maximizes the neovim window and tmux pane when toggling the terminal. The
    default is 'both'.

  * Has an optional command argument to run a terminal command.

  * __Example:__ Custom keymap to open lazygit fullscreen.

    ```lua
    vim.api.nvim_set_keymap(
      'n',
      '<C-g>',
      "<Cmd>lua require('windex').toggle_terminal('both','lazygit')<CR>",
      { noremap = true, silent = true }
    )
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
keymap('n', '<Leader>k', "<Cmd>lua require('windex').switch_window('Up')<CR>", opts)
keymap('n', '<Leader>j', "<Cmd>lua require('windex').switch_window('Down')<CR>", opts)
keymap('n', '<Leader>h', "<Cmd>lua require('windex').switch_window('Left')<CR>", opts)
keymap('n', '<Leader>l', "<Cmd>lua require('windex').switch_window('Right')<CR>", opts)

-- Save and close the nvim window or kill the tmux pane in the direction selected:
keymap('n', '<Leader>xk', "<Cmd>lua require('windex').close_window('Up')<CR>", opts)
keymap('n', '<Leader>xj', "<Cmd>lua require('windex').close_window('Down')<CR>", opts)
keymap('n', '<Leader>xh', "<Cmd>lua require('windex').close_window('Left')<CR>", opts)
keymap('n', '<Leader>xl', "<Cmd>lua require('windex').close_window('Right')<CR>", opts)

-- Toggle the terminal:
keymap('n', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>", opts)
keymap('t', '<C-n>', '<C-Bslash><C-N>', opts)
```

_Note: The default keymap to toggle the terminal is CTRL-\\. To enter normal mode in
terminal, the key combination is CTRL-\\ + CTRL-N which is no longer possible to 
execute. This sequence is therefore remapped to CTRL-N when in the terminal._

## 🎬 Demo Video

### Nvim Window / Tmux Pane Movement and Terminal Toggle

https://user-images.githubusercontent.com/90937622/159681079-58f36668-e78b-41fa-b929-e9ebc9dd8d3b.mp4
