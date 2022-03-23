local M = {}

-- TODO: save all active session file locations to a list then delete on VimLeave

M.setup = function(options)
  vim.g.__windex_setup_completed = 1

  -- Default values:
  local defaults = {
    default_keymaps = true,
    disable = false,
  }

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
  if options.disable == true then
    return
  end

  -- Restore windows when terminal is exited.
  vim.cmd [[au TermClose * lua require('windex.functions').restore_all()]]

  -- Previous window function autocmds.
  vim.cmd [[au FocusGained * lua vim.g.__windex_previous = 'tmux']]
  vim.cmd [[au WinLeave * lua vim.g.__windex_previous = 'nvim']]

  -- Delete session file.
  -- vim.cmd [[au WinLeave * if &buftype != '' | call delete('./.maximize_session.vim') | endif]]

  local keymap = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }

  -- Keymaps:
  if options.default_keymaps == true then
    -- Toggle the native terminal.
    keymap('t', '<C-n>', '<C-Bslash><C-N>', opts)
    keymap('n', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>", opts)
    keymap('t', '<C-Bslash>', "<Cmd>lua require('windex').toggle_terminal()<CR>", opts)

    -- Toggle maximizing the current window.
    keymap('n', '<Leader>z', "<Cmd>lua require('windex').toggle_nvim_maximize()<CR>", opts)
    keymap('n', '<Leader>Z', "<Cmd>lua require('windex').toggle_maximize()<CR>", opts)

    -- Switch to previous nvim window or tmux pane.
    keymap('n', '<Leader>;', "<Cmd>lua require('windex').previous_window()<CR>", opts)

    -- Move between nvim windows and tmux panes.
    keymap('n', '<Leader>k', "<Cmd>lua require('windex').switch_to('Up')<CR>", opts)
    keymap('n', '<Leader>j', "<Cmd>lua require('windex').switch_to('Down')<CR>", opts)
    keymap('n', '<Leader>h', "<Cmd>lua require('windex').switch_to('Left')<CR>", opts)
    keymap('n', '<Leader>l', "<Cmd>lua require('windex').switch_to('Right')<CR>", opts)
    keymap('n', '<Leader><Up>', "<Cmd>lua require('windex').switch_to('Up')<CR>", opts)
    keymap('n', '<Leader><Down>', "<Cmd>lua require('windex').switch_to('Down')<CR>", opts)
    keymap('n', '<Leader><Left>', "<Cmd>lua require('windex').switch_to('Left')<CR>", opts)
    keymap('n', '<Leader><Right>', "<Cmd>lua require('windex').switch_to('Right')<CR>", opts)

    -- Save and close the window in the direction selected.
    keymap('n', '<Leader>xk', "<Cmd>lua require('windex').quit('Up')<CR>", opts)
    keymap('n', '<Leader>xj', "<Cmd>lua require('windex').quit('Down')<CR>", opts)
    keymap('n', '<Leader>xh', "<Cmd>lua require('windex').quit('Left')<CR>", opts)
    keymap('n', '<Leader>xl', "<Cmd>lua require('windex').quit('Right')<CR>", opts)
    keymap('n', '<Leader>x<Up>', "<Cmd>lua require('windex').quit('Up')<CR>", opts)
    keymap('n', '<Leader>x<Down>', "<Cmd>lua require('windex').quit('Down')<CR>", opts)
    keymap('n', '<Leader>x<Left>', "<Cmd>lua require('windex').quit('Left')<CR>", opts)
    keymap('n', '<Leader>x<Right>', "<Cmd>lua require('windex').quit('Right')<CR>", opts)
  end
end

M.toggle_terminal = function(...)
  require('windex.functions').toggle_terminal(...)
end
M.toggle_nvim_maximize = function()
  require('windex.functions').toggle_nvim_maximize()
end
M.toggle_maximize = function()
  require('windex.functions').toggle_maximize()
end
M.maximize_windows = function()
  require('windex.functions').maximize_all()
end
M.restore_windows = function()
  require('windex.functions').restore_all()
end
M.quit = function(...)
  require('windex.functions').quit(...)
end
M.switch_to = function(...)
  require('windex.functions').switch_to(...)
end
M.previous = function()
  require('windex.functions').previous()
end
M.create_tmux_pane = function(...)
  require('windex.functions').create_tmux_pane(...)
end

return M
