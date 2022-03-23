local M = {}

-- Toggle maximizing nvim window.
M.toggle_nvim = function()
  if not vim.w.__window_maximized then
    -- Maximize nvim windows.
    if vim.fn.winnr() == 1 then
      vim.cmd [[echohl ErrorMsg | echo "Error: Only one window." | echohl None ]]
      return
    end
    local savedOptions = vim.opt.sessionoptions
    vim.opt.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize' }
    vim.cmd 'mksession! ~/.cache/nvim/.maximize_session.vim'
    vim.opt.sessionoptions = savedOptions
    vim.cmd 'only'
    vim.w.__window_maximized = true
  else
    -- Restore nvim windows.
    if vim.fn.filereadable(vim.fn.getenv 'HOME' .. '/.cache/nvim/.maximize_session.vim') == 1 then
      local savedPosition = vim.fn.getcurpos()
      vim.cmd 'so ~/.cache/nvim/.maximize_session.vim'
      vim.fn.delete(vim.fn.getenv 'HOME' .. '/.cache/nvim/.maximize_session.vim')
      vim.fn.setpos('.', savedPosition)
    end
    vim.w.__window_maximized = false
  end
end

-- Toggle maximizing the current nvim window and tmux pane.
M.toggle = function()
  if os.execute 'tmux -V > /dev/null 2>&1' ~= 0 then
    require('windex.maximize').toggle_nvim()
  end
  if not vim.w.__window_maximized then
    require('windex.maximize').maximize()
  else
    require('windex.maximize').restore()
  end
end

-- Maximize the current nvim window and tmux pane.
M.maximize = function()
  -- Maximize nvim window.
  if vim.fn.winnr() ~= 1 then
    local savedOptions = vim.opt.sessionoptions
    vim.opt.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize' }
    vim.cmd 'mksession! ~/.cache/nvim/.maximize_session.vim'
    vim.opt.sessionoptions = savedOptions
    vim.cmd 'only'
  end
  -- Maximize tmux pane.
  if require('windex.utils').tmux_maximized() == false then
    os.execute 'tmux resize-pane -Z > /dev/null 2>&1'
  end
  vim.w.__window_maximized = true
end

-- Restore the nvim windows and tmux panes.
M.restore = function()
  -- Restore nvim windows.
  if vim.fn.filereadable(vim.fn.getenv 'HOME' .. '/.cache/nvim/.maximize_session.vim') == 1 then
    local savedPosition = vim.fn.getcurpos()
    vim.cmd 'so ~/.cache/nvim/.maximize_session.vim'
    vim.fn.delete(vim.fn.getenv 'HOME' .. '/.cache/nvim/.maximize_session.vim')
    vim.fn.setpos('.', savedPosition)
  end
  -- Restore tmux panes.
  if require('windex.utils').tmux_maximized() == true then
    os.execute 'tmux resize-pane -Z > /dev/null 2>&1'
  end
  vim.w.__window_maximized = false
end

return M
