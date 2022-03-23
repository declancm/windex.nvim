# windex.nvim

🧼 __A neovim plugin for cleeean nvim window and tmux pane functions.__ 🧼

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

## ⏱️ Maximizing Window Comparison

A comparison of vim-maximizer and windex.nvim with maximizing a nvim window and a tmux pane split.

### vim-maximizer

Has weird thing in top where it didn't maximize properly and doesn't maximize the tmux pane.

<![vim-maximizer](https://user-images.githubusercontent.com/90937622/159694125-322f371f-4334-4731-bf02-cfde05945654.png)>

### windex.nvim

Perfectly maximizes the nvim window and tmux pane! 👑

<![windex](https://user-images.githubusercontent.com/90937622/159694138-5b99ec1d-e860-42fb-9af6-ca23b98dda25.png)>


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

## 🎞️ Demo Video

### Nvim Window / Tmux Pane Movement and Terminal Toggle

<https://user-images.githubusercontent.com/90937622/159681079-58f36668-e78b-41fa-b929-e9ebc9dd8d3b.mp4>
