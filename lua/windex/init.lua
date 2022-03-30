local M = {}

local utils = require('cinnamon.utils')

M.setup = function(options)
  vim.g.__windex_setup_loaded = 1

  -- Check if user is on Windows.
  if vim.fn.has('win32') == 1 then
    utils.error_msg("A unix system is required for 'windex' :(. Have you tried using WSL?")
    return
  end

  -- OPTIONS:

  -- Default values:
  local defaults = {
    default_keymaps = true,
    arrow_keys = false,
    disable = false,
    numbered_terminal = false,
  }
  -- Setting options:
  if options == nil then
    options = defaults
  else
    for key, value in pairs(defaults) do
      if options[key] == nil then
        options[key] = value
      end
    end
  end

  -- Disable plugin.
  if options.disable then
    return
  end
  -- Use line numbers within terminal.
  if options.numbered_term then
    vim.g.__windex_numbered_term = true
  end

  -- AUTOCMDS:

  -- Restore windows when terminal is exited.
  vim.cmd([[
  aug windex_terminal
  au!
  au TermClose * lua require('windex.maximize').restore()
  aug END
  ]])
  -- Previous window autocmds.
  vim.cmd([[
  aug windex_previous
  au!
  au FocusGained * lua vim.g.__windex_previous = 'tmux'
  au WinLeave * lua vim.g.__windex_previous = 'nvim'
  aug END
  ]])
  -- Delete session file from cache.
  vim.cmd([[
  aug windex_maximize
  au!
  au VimEnter * call delete(getenv('HOME') . '/.cache/nvim/.maximize_session.vim')
  au VimLeave * call delete(getenv('HOME') . '/.cache/nvim/.maximize_session.vim')
  aug END
  ]])

  -- KEYMAPS:

  local keymap = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }

  if options.default_keymaps == true then
    -- Enter normal mode in terminal.
    keymap('t', '<C-n>', '<C-Bslash><C-N>', opts)
    -- Check if user is using a valid version of tmux.
    if require('windex.utils').tmux_requirement_passed() then
      -- Toggle the native terminal.
      keymap('n', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>", opts)
      keymap('t', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>", opts)
      -- Toggle maximizing the current window.
      keymap('n', '<Leader>z', "<Cmd>lua require('windex').toggle_maximize()<CR>", opts)
    else
      -- Toggle the native terminal.
      keymap('n', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal('nvim')<CR>", opts)
      keymap('t', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal('nvim')<CR>", opts)
      -- Toggle maximizing the current window.
      keymap('n', '<Leader>z', "<Cmd>lua require('windex').toggle_nvim_maximize()<CR>", opts)
    end
    -- Check if the user wants to use h,j,k,l or arrow keys.
    if options.arrow_keys == false then
      -- Move between nvim windows and tmux panes.
      keymap('n', '<Leader>k', "<Cmd>lua require('windex').switch_window('up')<CR>", opts)
      keymap('n', '<Leader>j', "<Cmd>lua require('windex').switch_window('down')<CR>", opts)
      keymap('n', '<Leader>h', "<Cmd>lua require('windex').switch_window('left')<CR>", opts)
      keymap('n', '<Leader>l', "<Cmd>lua require('windex').switch_window('right')<CR>", opts)
      -- Save and close the window in the direction selected.
      keymap('n', '<Leader>xk', "<Cmd>lua require('windex').close_window('up')<CR>", opts)
      keymap('n', '<Leader>xj', "<Cmd>lua require('windex').close_window('down')<CR>", opts)
      keymap('n', '<Leader>xh', "<Cmd>lua require('windex').close_window('left')<CR>", opts)
      keymap('n', '<Leader>xl', "<Cmd>lua require('windex').close_window('right')<CR>", opts)
    else
      -- Move between nvim windows and tmux panes.
      keymap('n', '<Leader><Up>', "<Cmd>lua require('windex').switch_window('up')<CR>", opts)
      keymap('n', '<Leader><Down>', "<Cmd>lua require('windex').switch_window('down')<CR>", opts)
      keymap('n', '<Leader><Left>', "<Cmd>lua require('windex').switch_window('left')<CR>", opts)
      keymap('n', '<Leader><Right>', "<Cmd>lua require('windex').switch_window('right')<CR>", opts)
      -- Save and close the window in the direction selected.
      keymap('n', '<Leader>x<Up>', "<Cmd>lua require('windex').close_window('up')<CR>", opts)
      keymap('n', '<Leader>x<Down>', "<Cmd>lua require('windex').close_window('down')<CR>", opts)
      keymap('n', '<Leader>x<Left>', "<Cmd>lua require('windex').close_window('left')<CR>", opts)
      keymap('n', '<Leader>x<Right>', "<Cmd>lua require('windex').close_window('right')<CR>", opts)
    end
    -- Switch to previous nvim window or tmux pane.
    keymap('n', '<Leader>;', "<Cmd>lua require('windex').previous_window()<CR>", opts)
  end
end

-- API:

-- Maximize:
M.toggle_nvim_maximize = function()
  require('windex.maximize').toggle('nvim')
end
M.toggle_maximize = function()
  require('windex.maximize').toggle('all')
end
M.maximize_windows = function(...)
  require('windex.maximize').maximize(...)
end
M.restore_windows = function(...)
  require('windex.maximize').restore(...)
end
-- Terminal:
M.toggle_terminal = function(...)
  require('windex.terminal').toggle(...)
end
M.enter_terminal = function(...)
  require('windex.terminal').enter(...)
end
M.exit_terminal = function(...)
  require('windex.terminal').exit(...)
end
-- Movement:
M.switch_window = function(...)
  require('windex.movement').switch(...)
end
M.close_window = function(...)
  require('windex.movement').close(...)
end
M.previous_window = function()
  require('windex.movement').previous()
end
M.create_pane = function(...)
  require('windex.movement').create_pane(...)
end

return M
