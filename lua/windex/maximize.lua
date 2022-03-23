local M = {}

-- Toggle maximizing the current nvim window and tmux pane.
M.toggle = function(option)
  option = option or 'both'
  if option ~= 'nvim' then
    if require('windex.utils').tmux_requirement_passed() == false then
      vim.cmd([[echohl ErrorMsg | echo "Error: Tmux 1.8 or newer is required." | echohl None]])
      return
    end
  end
  if not vim.w.__windex_maximized then
    require('windex.maximize').maximize(option)
  else
    require('windex.maximize').restore(option)
  end
end

-- Maximize the current nvim window and tmux pane.
M.maximize = function(option)
  option = option or 'both'
  -- Maximize nvim window.
  if vim.fn.winnr('$') ~= 1 then
    local savedOptions = vim.opt.sessionoptions
    vim.opt.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize' }
    vim.cmd('mksession! ~/.cache/nvim/.maximize_session.vim')
    vim.opt.sessionoptions = savedOptions
    vim.cmd('only')
  end
  -- Maximize tmux pane.
  if option ~= 'nvim' then
    if require('windex.utils').tmux_maximized() == false then
      os.execute('tmux resize-pane -Z > /dev/null 2>&1')
    end
  end
  vim.w.__windex_maximized = true
end

-- Restore the nvim windows and tmux panes.
M.restore = function(option)
  option = option or 'both'
  -- Restore tmux panes.
  if option ~= 'nvim' then
    if require('windex.utils').tmux_maximized() == true then
      os.execute('tmux resize-pane -Z > /dev/null 2>&1')
    end
  end
  -- Restore nvim windows.
  if vim.fn.filereadable(vim.fn.getenv('HOME') .. '/.cache/nvim/.maximize_session.vim') == 1 then
    local savedPosition = vim.fn.getcurpos()
    vim.cmd('so ~/.cache/nvim/.maximize_session.vim')
    vim.fn.delete(vim.fn.getenv('HOME') .. '/.cache/nvim/.maximize_session.vim')
    vim.fn.setpos('.', savedPosition)
  end
  vim.w.__windex_maximized = false
end

return M
