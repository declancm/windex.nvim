# windex.nvim

__A neovim plugin for cleeean 🧼 nvim window and tmux pane functions.__

## ✨ Features

### Maximize Current Window

* Maximize the current nvim window completely without any of the ugly borders
  that other plugins create.
* Maximize the current nvim window __and__ tmux pane for when you need something
  comletely fullscreen.

### Cleaner Window Movement

* Treats tmux panes as nvim windows which allows for easy window/pane movement,
  with the same keymaps.
* Save and quit the nvim window (or kill the tmux pane) in the selected direction.

### Terminal Toggle

* Toggle the (improved) native terminal which will open fullscreen.

## 🎞️ Demo Video

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
keymap('n', '<Leader>z', "<Cmd>lua require('windex').toggle_nvim_maximize()<CR>", opts)
keymap('n', '<Leader>Z', "<Cmd>lua require('windex').toggle_maximize()<CR>", opts)

-- Switch to previous nvim window or tmux pane:
keymap('n', '<Leader>;', "<Cmd>lua require('windex').previous()<CR>", opts)

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
execute. This sequence is remapped to CTRL-N by default._
