# windex.nvim

A neovim plugin for cleeean 🧼 nvim window and tmux pane functions.

## ✨ Features

* Swap between nvim windows and tmux panes.
* Save and quit the nvim window or kill the tmux pane in the selected direction.
* Maximize the current nvim window.
* Maximize the current nvim window and tmux pane.
* Toggle the native terminal which will open fullscreen.

## 📦 Installation

Install with your favourite plugin manager:

### Packer

```lua
use 'declancm/windex.nvim'
```

## Configuration

A settings table can be passed into the setup function for custom options.

The default settings are:

```lua
require('cinnamon').setup {
  default_keymaps = true -- Enable default keymaps.
  disable = false,       -- Disable the plugin.
}
```

## Default Keymaps

```lua
local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- Toggle the terminal:
keymap('t', '<C-n>', '<C-Bslash><C-N>', opts)
keymap('n', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>", opts)
keymap('t', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>", opts)

-- Toggle maximizing the current window:
keymap('n', '<Leader>z', "<Cmd>lua require('windex').toggle_nvim_maximize()<CR>", opts)
keymap('n', '<Leader>Z', "<Cmd>lua require('windex').toggle_maximize()<CR>", opts)

-- Switch to previous nvim window or tmux pane:
keymap('n', '<Leader>;', "<Cmd>lua require('windex').previous()<CR>", opts)

-- Move between nvim windows and tmux panes:
keymap('n', '<Leader>k', "<Cmd>lua require('windex').switch('Up')<CR>", opts)
keymap('n', '<Leader>j', "<Cmd>lua require('windex').switch('Down')<CR>", opts)
keymap('n', '<Leader>h', "<Cmd>lua require('windex').switch('Left')<CR>", opts)
keymap('n', '<Leader>l', "<Cmd>lua require('windex').switch('Right')<CR>", opts)
keymap('n', '<Leader><Up>', "<Cmd>lua require('windex').switch('Up')<CR>", opts)
keymap('n', '<Leader><Down>', "<Cmd>lua require('windex').switch('Down')<CR>", opts)
keymap('n', '<Leader><Left>', "<Cmd>lua require('windex').switch('Left')<CR>", opts)
keymap('n', '<Leader><Right>', "<Cmd>lua require('windex').switch('Right')<CR>", opts)

-- Save and close the nvim window or kill the tmux pane in the direction selected:
keymap('n', '<Leader>xk', "<Cmd>lua require('windex').quit('Up')<CR>", opts)
keymap('n', '<Leader>xj', "<Cmd>lua require('windex').quit('Down')<CR>", opts)
keymap('n', '<Leader>xh', "<Cmd>lua require('windex').quit('Left')<CR>", opts)
keymap('n', '<Leader>xl', "<Cmd>lua require('windex').quit('Right')<CR>", opts)
keymap('n', '<Leader>x<Up>', "<Cmd>lua require('windex').quit('Up')<CR>", opts)
keymap('n', '<Leader>x<Down>', "<Cmd>lua require('windex').quit('Down')<CR>", opts)
keymap('n', '<Leader>x<Left>', "<Cmd>lua require('windex').quit('Left')<CR>", opts)
keymap('n', '<Leader>x<Right>', "<Cmd>lua require('windex').quit('Right')<CR>", opts)
```
