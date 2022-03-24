local M = {}

-- Save and quit nvim window or kill tmux pane in the direction selected.
M.close = function(direction)
  local previousWindow = vim.fn.winnr()
  if direction == 'Up' then
    vim.cmd('wincmd k')
  elseif direction == 'Down' then
    vim.cmd('wincmd j')
  elseif direction == 'Left' then
    vim.cmd('wincmd h')
  elseif direction == 'Right' then
    vim.cmd('wincmd l')
  end
  local newWindow = vim.fn.winnr()
  if previousWindow == newWindow then
    -- TODO: Convert this into a function.
    if direction == 'Up' then
      os.execute([[
      #!/usr/bin/env bash
      (
        previousPane=$(tmux display-message -p '#{pane_id}')
        tmux select-pane -U
        newPane=$(tmux display-message -p '#{pane_id}')
        if [ $previousPane -ne $newPane ]; then
          kill-pane
        fi
      ) > /dev/null 2>&1
      ]])
    elseif direction == 'Down' then
      os.execute([[
      #!/usr/bin/env bash
      (
        previousPane=$(tmux display-message -p '#{pane_id}')
        tmux select-pane -D
        newPane=$(tmux display-message -p '#{pane_id}')
        if [ $previousPane -ne $newPane ]; then
          kill-pane
        fi
      ) > /dev/null 2>&1
      ]])
    elseif direction == 'Left' then
      os.execute([[
      #!/usr/bin/env bash
      (
        previousPane=$(tmux display-message -p '#{pane_id}')
        tmux select-pane -L
        newPane=$(tmux display-message -p '#{pane_id}')
        if [ $previousPane -ne $newPane ]; then
          kill-pane
        fi
      ) > /dev/null 2>&1
      ]])
    elseif direction == 'Right' then
      os.execute([[
      #!/usr/bin/env bash
      (
        previousPane=$(tmux display-message -p '#{pane_id}')
        tmux select-pane -R
        newPane=$(tmux display-message -p '#{pane_id}')
        if [ $previousPane -ne $newPane ]; then
          kill-pane
        fi
      ) > /dev/null 2>&1
      ]])
    end
  else
    vim.cmd('exit')
    -- vim.cmd [[exec (&modifiable && &modified) ? 'wq' : 'q']]
  end
end

-- Move between nvim windows and tmux panes.
M.switch = function(direction)
  local previousWindow = vim.fn.winnr()
  if direction == 'Up' then
    vim.cmd('wincmd k')
  elseif direction == 'Down' then
    vim.cmd('wincmd j')
  elseif direction == 'Left' then
    vim.cmd('wincmd h')
  elseif direction == 'Right' then
    vim.cmd('wincmd l')
  end
  local newWindow = vim.fn.winnr()
  if previousWindow == newWindow then
    if direction == 'Up' then
      os.execute('tmux select-pane -U > /dev/null 2>&1')
    elseif direction == 'Down' then
      os.execute('tmux select-pane -D > /dev/null 2>&1')
    elseif direction == 'Left' then
      os.execute('tmux select-pane -L > /dev/null 2>&1')
    elseif direction == 'Right' then
      os.execute('tmux select-pane -R > /dev/null 2>&1')
    end
  end
end

-- Switch to previous nvim window or tmux pane.
M.previous = function()
  if vim.g.__windex_previous == 'tmux' then
    local tmuxStatus = os.execute('tmux select-pane -l > /dev/null 2>&1')
    if tmuxStatus ~= 0 then
      vim.cmd('wincmd p')
    end
  else
    local previousWindow = vim.fn.winnr()
    vim.cmd('wincmd p')
    local newWindow = vim.fn.winnr()
    if previousWindow == newWindow then
      os.execute('tmux select-pane -l > /dev/null 2>&1')
    end
  end
end

-- Create a tmux pane.
M.create_tmux_pane = function(direction)
  if direction == 'Vertical' then
    os.execute("tmux split-window -h -c '#{pane_current_path}'")
  elseif direction == 'Horizontal' then
    os.execute("tmux split-window -v -c '#{pane_current_path}'")
  end
end

return M
