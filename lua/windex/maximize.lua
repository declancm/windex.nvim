local M = {}

-- Toggle maximizing the current nvim window and tmux pane.
M.toggle = function(maximizeOption)
  maximizeOption = maximizeOption or 'both'
  if maximizeOption == 'both' then
    if require('windex.utils').tmux_requirement_passed() == false then
      vim.cmd([[echohl ErrorMsg]])
      vim.cmd([[echo "Error: Tmux 1.8+ is required. Use 'maximize_nvim_window()' instead or install/update Tmux."]])
      vim.cmd([[echohl None]])
      return
    end
  end
  if not vim.w.__windex_maximized then
    require('windex.maximize').maximize(maximizeOption)
  else
    require('windex.maximize').restore(maximizeOption)
  end
end

-- Maximize the current nvim window and tmux pane.
M.maximize = function(maximizeOption)
  maximizeOption = maximizeOption or 'both'
  -- Maximize nvim window.
  if vim.fn.winnr('$') ~= 1 then
    local savedOptions = vim.opt.sessionoptions
    vim.opt.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize' }
    vim.cmd('mksession! ~/.cache/nvim/.maximize_session.vim')
    vim.opt.sessionoptions = savedOptions
    vim.cmd('only')
  end
  -- Maximize tmux pane.
  if maximizeOption ~= 'nvim' then
    if require('windex.utils').tmux_maximized() == false then
      os.execute('tmux resize-pane -Z > /dev/null 2>&1')
    end
  end
  vim.w.__windex_maximized = true
end

-- Restore the nvim windows and tmux panes.
M.restore = function(maximizeOption)
  maximizeOption = maximizeOption or 'both'
  -- Restore tmux panes.
  if maximizeOption == 'both' then
    if require('windex.utils').tmux_maximized() == true then
      os.execute('tmux resize-pane -Z > /dev/null 2>&1')
    end
  end
  -- Restore nvim windows.
  if vim.fn.filereadable(vim.fn.getenv('HOME') .. '/.cache/nvim/.maximize_session.vim') == 1 then
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
