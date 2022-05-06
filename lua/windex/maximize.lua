local M = {}

local tmux = require('windex.tmux')
local utils = require('windex.utils')

M.maximized = false
local saved = {}
local saved_maximize_option

-- Toggle maximizing the current nvim window and tmux pane.
M.toggle = function(maximize_option)
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

  if M.maximized then
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

  saved_maximize_option = maximize_option
  if
    (maximize_option == 'none')
    or (maximize_option == 'nvim' and vim.fn.winnr('$') == 1)
    or (maximize_option == 'all' and vim.fn.winnr('$') == 1 and (tmux.is_maximized() or tmux.single_pane()) == true)
  then
    return
  end

  -- Save options.
  saved = {}
  saved.cmdheight = vim.opt.cmdheight
  saved.cmdwinheight = vim.opt.cmdwinheight

  -- Close floating windows because they break session files.
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_win_close(win, false)
    end
  end

  -- If a floating window still exists, it contains unsaved changes so return.
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      utils.error_msg('Cannot maximize. A floating window with unsaved changes exists')
      return
    end
  end

  -- Maximize nvim window.
  if vim.fn.winnr('$') ~= 1 then
    -- Save the session.
    local saved_sessionoptions = vim.opt.sessionoptions:get()
    vim.opt.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize' }
    vim.cmd('mksession! ~/.cache/nvim/.maximize_session.vim')
    vim.opt.sessionoptions = saved_sessionoptions

    vim.cmd('only')
  end

  -- Maximize tmux pane.
  if maximize_option == 'all' and tmux.requirement_passed() then
    if tmux.is_maximized() == false then
      tmux.execute('resize-pane -Z')
    end
  end

  M.maximized = true
end

-- Restore the nvim windows and tmux panes.
M.restore = function(maximize_option)
  maximize_option = maximize_option or saved_maximize_option or 'all'
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
  if vim.fn.filereadable(vim.fn.getenv('HOME') .. '/.cache/nvim/.maximize_session.vim') == 1 then
    vim.cmd('wall')
    local file_name = vim.fn.getreg('%')
    local saved_position = vim.fn.getcurpos()

    -- Source the saved session.
    vim.cmd('source ~/.cache/nvim/.maximize_session.vim')

    -- Delete the saved session.
    vim.fn.delete(vim.fn.getenv('HOME') .. '/.cache/nvim/.maximize_session.vim')

    if vim.fn.getreg('%') ~= file_name then
      vim.cmd('edit ' .. file_name)
    end
    vim.fn.setpos('.', saved_position)
  end

  -- Restore saved options.
  for option, value in pairs(saved) do
    vim.opt[option] = value
  end

  M.maximized = false
end

return M
