local M = {}

local tmux = require('windex.tmux')
local utils = require('windex.utils')

-- Toggle maximizing the current nvim window and tmux pane.
M.toggle = function(maximize_option)
  -- Check the function argument.
  maximize_option = maximize_option or 'all'
  if not utils.contains({ 'none', 'nvim', 'all' }, maximize_option) then
    utils.error_msg('Not a valid argument')
    return
  end

  -- Check if tmux requirement is passed.
  if maximize_option == 'all' and not tmux.requirement_passed() then
    utils.error_msg("Tmux 1.8+ is required. Use 'maximize_nvim_window()' instead or install/update Tmux")
    return
  end

  if vim.t.maximized then
    M.restore()
  else
    M.maximize(maximize_option)
  end
end

-- Maximize the current nvim window and tmux pane.
M.maximize = function(maximize_option)
  maximize_option = maximize_option or 'all'
  if not utils.contains({ 'none', 'nvim', 'all' }, maximize_option) then
    utils.error_msg('Not a valid argument')
    return
  end

  vim.t.saved_maximize_option = maximize_option
  if
    (maximize_option == 'none')
    or (maximize_option == 'nvim' and vim.fn.winnr('$') == 1)
    or (maximize_option == 'all' and vim.fn.winnr('$') == 1 and (tmux.is_maximized() or tmux.single_pane()) == true)
  then
    return
  end

  -- Maximize nvim window.
  if vim.fn.winnr('$') ~= 1 then
    -- A temporary file for storing the current session. It's unique and per tab.
    vim.t.tmp_session_file = '~/.cache/nvim/.maximize_session-' .. os.time() .. '.vim'

    -- Save options.
    vim.t.saved_cmdheight = vim.opt_local.cmdheight:get()
    vim.t.saved_cmdwinheight = vim.opt_local.cmdwinheight:get()

    -- Handle floating windows
    -- TODO: after the next Neovim release, we don't need to handle float wins
    -- (https://github.com/neovim/neovim/commit/3fe6bf3a1e50299dbdd6314afbb18e468eb7ce08)

    -- Close floating windows because they break session files.
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= '' then
        vim.api.nvim_win_close(win, false)
      end
    end

    -- If a floating window still exists, it contains unsaved changes so return.
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= '' then
        utils.error_msg('Cannot maximize. A floating window with unsaved changes exists')
        return
      end
    end

    -- Save the session.
    local saved_sessionoptions = vim.opt_local.sessionoptions:get()
    vim.opt_local.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'help', 'winsize' }
    vim.cmd('mksession! ' .. vim.t.tmp_session_file)
    vim.opt_local.sessionoptions = saved_sessionoptions

    vim.cmd('only')
  end

  -- Maximize tmux pane.
  if maximize_option == 'all' and tmux.requirement_passed() then
    if tmux.is_maximized() == false then
      tmux.execute('resize-pane -Z')
    end
  end

  vim.t.maximized = true
end

-- Restore the nvim windows and tmux panes.
M.restore = function(maximize_option)
  -- Set the function argument.
  maximize_option = maximize_option or vim.t.saved_maximize_option or 'all'
  if maximize_option == 'none' then
    return
  end

  -- Restore tmux panes.
  if maximize_option == 'all' and tmux.requirement_passed() then
    if tmux.is_maximized() then
      tmux.execute('resize-pane -Z')
      vim.cmd('sleep 50m')
    end
  end

  -- Restore nvim windows.
  if vim.fn.filereadable(vim.fn.expand(vim.t.tmp_session_file)) == 1 then
    -- Save changes to all buffers.
    vim.cmd('wall')

    -- Save the current file and cursor position.
    local saved_file_name = vim.fn.getreg('%')
    local saved_cursor_position = vim.fn.getcurpos()

    -- Source the saved session.
    vim.cmd('silent source ' .. vim.t.tmp_session_file)

    -- Delete the saved session.
    vim.fn.delete(vim.fn.expand(vim.t.tmp_session_file))

    -- Restore the current file and cursor position.
    if vim.fn.getreg('%') ~= saved_file_name then
      vim.cmd('edit ' .. saved_file_name)
    end
    vim.fn.setpos('.', saved_cursor_position)

    -- Restore saved options.
    vim.opt_local.cmdheight = vim.t.saved_cmdheight
    vim.opt_local.cmdwinheight = vim.t.saved_cmdwinheight
  end

  vim.t.maximized = false
end

return M
