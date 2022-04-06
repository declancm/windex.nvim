local M = {}

local tmux = require('windex.tmux')
local utils = require('windex.utils')

-- Toggle maximizing the current nvim window and tmux pane.
M.toggle = function(maximizeOption)
  maximizeOption = maximizeOption or 'all'
  if maximizeOption == 'all' or maximizeOption == 'All' then
    if tmux.requirement_passed() == false then
      utils.error_msg("Tmux 1.8+ is required. Use 'maximize_nvim_window()' instead or install/update Tmux")
      return
    end
  end
  if not vim.w.__windex_maximized then
    M.maximize(maximizeOption)
  else
    M.restore()
  end
end

-- Maximize the current nvim window and tmux pane.
M.maximize = function(maximizeOption)
  maximizeOption = maximizeOption or 'all'
  vim.w.__windex_restore_option = maximizeOption
  if maximizeOption == 'none' or maximizeOption == 'None' then
    return
  end
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
      utils.error_msg('Cannot maximize. A floating window with unsaved changes exists.')
      return
    end
  end
  -- Maximize nvim window.
  if vim.fn.winnr('$') ~= 1 then
    local savedOptions = vim.opt.sessionoptions:get()
    vim.opt.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize' }
    vim.cmd('mksession! ~/.cache/nvim/.maximize_session.vim')
    vim.opt.sessionoptions = savedOptions
    vim.cmd('only')
  end
  -- Maximize tmux pane.
  if maximizeOption == 'all' or maximizeOption == 'All' then
    if tmux.is_maximized() == false then
      os.execute('tmux resize-pane -Z > /dev/null 2>&1')
    end
  end
  vim.w.__windex_maximized = true
end

-- Restore the nvim windows and tmux panes.
M.restore = function(maximizeOption)
  maximizeOption = maximizeOption or vim.w.__windex_restore_option or 'all'
  if maximizeOption == 'none' or maximizeOption == 'None' then
    return
  end
  -- Restore tmux panes.
  if maximizeOption == 'all' or maximizeOption == 'All' then
    if tmux.is_maximized() == true then
      os.execute('tmux resize-pane -Z > /dev/null 2>&1')
    end
  end
  -- Restore nvim windows.
  if vim.fn.filereadable(vim.fn.getenv('HOME') .. '/.cache/nvim/.maximize_session.vim') == 1 then
    -- Save buffers.
    vim.cmd('wall')
    -- Source the saved session.
    local fileName = vim.fn.getreg('%')
    local savedPosition = vim.fn.getcurpos()
    vim.cmd('so ~/.cache/nvim/.maximize_session.vim')
    vim.fn.delete(vim.fn.getenv('HOME') .. '/.cache/nvim/.maximize_session.vim')
    if vim.fn.getreg('%') ~= fileName then
      vim.cmd('e ' .. fileName)
    end
    vim.fn.setpos('.', savedPosition)
  end
  vim.w.__windex_maximized = false
end

return M
