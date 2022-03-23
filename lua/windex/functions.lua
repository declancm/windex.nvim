local M = {}

-- TODO: Implement ZA and ZO commands in a function.

-- Toggle the native terminal.
M.toggle_terminal = function(command)
  if vim.bo.buftype == 'terminal' then
    vim.g.term_bufnr = vim.fn.bufnr()
    if vim.g.term_prev == nil or vim.fn.bufname(vim.g.term_prev) == '' then
      local keys = vim.api.nvim_replace_termcodes('<C-\\><C-N><C-^>', true, false, true)
      vim.api.nvim_feedkeys(keys, 'n', true)
    else
      vim.cmd('keepalt buffer ' .. vim.g.term_prev)
    end
    require('windex.functions').restore_all()
  else
    require('windex.functions').maximize_all()
    vim.g.term_prev = vim.fn.bufnr()
    if command ~= nil then
      vim.cmd('keepalt terminal ' .. command)
    elseif vim.g.term_bufnr == nil or vim.fn.bufname(vim.g.term_bufnr) == '' then
      vim.cmd 'keepalt terminal'
    else
      vim.cmd('keepalt buffer ' .. vim.g.term_bufnr)
    end
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.signcolumn = 'no'
    vim.cmd 'startinsert'
  end
end

-- Toggle maximizing nvim window.
M.toggle_nvim_maximize = function()
  if not vim.w.__window_maximized then
    -- Maximize
    if vim.fn.winnr() == 1 then
      vim.cmd [[echohl ErrorMsg | echo "Error: Only one window." | echohl None ]]
      return
    end
    local savedOptions = vim.opt.sessionoptions
    vim.opt.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize' }
    vim.cmd 'mksession! .maximize_session.vim'
    vim.opt.sessionoptions = savedOptions
    vim.cmd 'only'
    vim.w.__window_maximized = true
  else
    -- Unmaximize
    local savedPosition = vim.fn.getcurpos()
    vim.cmd 'so ./.maximize_session.vim'
    vim.fn.delete './.maximize_session.vim'
    vim.fn.setpos('.', savedPosition)
    vim.w.__window_maximized = false
  end
end

M.maximize_all = function()
  -- Check if tmux pane is maximized.
  local exitStatus = os.execute [[
  #!/usr/bin/env bash

  (
    paneWidth=$(tmux display-message -p '#{pane_width}')
    windowWidth=$(tmux display-message -p '#{window_width}')
    paneHeight=$(tmux display-message -p '#{pane_height}')
    windowHeight=$(tmux display-message -p '#{window_height}')
    if [ $paneWidth -ne $windowWidth ] || [ $paneHeight -ne $windowHeight ]
    then
      exit 1
    else
      exit 0
    fi
  ) > /dev/null 2>&1
  ]]
  local tmuxMaximized
  if exitStatus == 0 then
    tmuxMaximized = true
  else
    tmuxMaximized = false
  end
  -- Maximize nvim window.
  if vim.fn.winnr() ~= 1 then
    local savedOptions = vim.opt.sessionoptions
    vim.opt.sessionoptions = { 'blank', 'buffers', 'curdir', 'folds', 'help', 'tabpages', 'winsize' }
    vim.cmd 'mksession! .maximize_session.vim'
    vim.opt.sessionoptions = savedOptions
    vim.cmd 'only'
  end
  -- Maximize tmux pane.
  if tmuxMaximized == false then
    os.execute 'tmux resize-pane -Z > /dev/null 2>&1'
  end
  vim.w.__window_maximized = true
end

M.restore_all = function()
  -- Check if tmux pane is maximized.
  local exitStatus = os.execute [[
  #!/usr/bin/env bash

  (
    paneWidth=$(tmux display-message -p '#{pane_width}')
    windowWidth=$(tmux display-message -p '#{window_width}')
    paneHeight=$(tmux display-message -p '#{pane_height}')
    windowHeight=$(tmux display-message -p '#{window_height}')
    if [ $paneWidth -ne $windowWidth ] || [ $paneHeight -ne $windowHeight ]
    then
      exit 1
    else
      exit 0
    fi
  ) > /dev/null 2>&1
  ]]
  local tmuxMaximized
  if exitStatus == 0 then
    tmuxMaximized = true
  else
    tmuxMaximized = false
  end
  -- Restore nvim windows.
  if vim.fn.filereadable './.maximize_session.vim' == 1 then
    local savedPosition = vim.fn.getcurpos()
    vim.cmd 'so ./.maximize_session.vim'
    vim.fn.delete './.maximize_session.vim'
    vim.fn.setpos('.', savedPosition)
  end
  -- Restore tmux panes.
  if tmuxMaximized == true then
    os.execute 'tmux resize-pane -Z > /dev/null 2>&1'
  end
  vim.w.__window_maximized = false
end

-- Toggle maximizing the current nvim window and tmux pane.
M.toggle_maximize = function()
  if not vim.w.__window_maximized then
    require('windex.functions').maximize_all()
  else
    require('windex.functions').restore_all()
  end
end

-- Save and quit nvim window or kill tmux pane in the direction selected.
M.quit = function(direction)
  local previousWindow = vim.fn.winnr()
  if direction == 'Up' then
    vim.cmd 'wincmd k'
  elseif direction == 'Down' then
    vim.cmd 'wincmd j'
  elseif direction == 'Left' then
    vim.cmd 'wincmd h'
  elseif direction == 'Right' then
    vim.cmd 'wincmd l'
  end
  local newWindow = vim.fn.winnr()
  if previousWindow == newWindow then
    if direction == 'Up' then
      os.execute 'tmux select-pane -U \\; kill-pane > /dev/null 2>&1'
    elseif direction == 'Down' then
      os.execute 'tmux select-pane -D \\; kill-pane > /dev/null 2>&1'
    elseif direction == 'Left' then
      os.execute 'tmux select-pane -L \\; kill-pane > /dev/null 2>&1'
    elseif direction == 'Right' then
      os.execute 'tmux select-pane -R \\; kill-pane > /dev/null 2>&1'
    end
  else
    if previousWindow == newWindow then
      return
    end
    vim.cmd 'exit'
    -- vim.cmd [[exec (&modifiable && &modified) ? 'wq' : 'q']]
  end
end

-- Move between nvim windows and tmux panes.
M.switch_to = function(direction)
  local previousWindow = vim.fn.winnr()
  if direction == 'Up' then
    vim.cmd 'wincmd k'
  elseif direction == 'Down' then
    vim.cmd 'wincmd j'
  elseif direction == 'Left' then
    vim.cmd 'wincmd h'
  elseif direction == 'Right' then
    vim.cmd 'wincmd l'
  end
  local newWindow = vim.fn.winnr()
  if previousWindow == newWindow then
    if direction == 'Up' then
      os.execute 'tmux select-pane -U > /dev/null 2>&1'
    elseif direction == 'Down' then
      os.execute 'tmux select-pane -D > /dev/null 2>&1'
    elseif direction == 'Left' then
      os.execute 'tmux select-pane -L > /dev/null 2>&1'
    elseif direction == 'Right' then
      os.execute 'tmux select-pane -R > /dev/null 2>&1'
    end
  end
end

-- Switch to previous nvim window or tmux pane.
M.previous = function()
  if vim.g.__windex_previous == 'tmux' then
    local tmuxStatus = os.execute 'tmux select-pane -l > /dev/null 2>&1'
    if tmuxStatus ~= 0 then
      vim.cmd 'wincmd p'
    end
  else
    local previousWindow = vim.fn.winnr()
    vim.cmd 'wincmd p'
    local newWindow = vim.fn.winnr()
    if previousWindow == newWindow then
      os.execute 'tmux select-pane -l > /dev/null 2>&1'
    end
  end
end

-- Create a tmux pane.
M.create_tmux_pane = function(direction)
  if direction == 'Vertical' then
    os.execute "tmux split-window -h -c '#{pane_current_path}'"
  elseif direction == 'Horizontal' then
    os.execute "tmux split-window -v -c '#{pane_current_path}'"
  end
end

return M
