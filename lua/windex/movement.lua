local M = {}

local tmux = require('windex.tmux')
local utils = require('windex.utils')

-- Save and quit nvim window or kill tmux pane in the direction selected.
M.close = function(direction)
  local directionValues = { 'up', 'down', 'left', 'right', 'Up', 'Down', 'Left', 'Right' }
  if not utils.argument_is_valid(direction, directionValues) then
    return
  end
  local previousWindow = vim.fn.winnr()
  local paneDirection
  if direction == 'up' or direction == 'Up' then
    vim.cmd('wincmd k')
    paneDirection = 'U'
  elseif direction == 'down' or direction == 'Down' then
    vim.cmd('wincmd j')
    paneDirection = 'D'
  elseif direction == 'left' or direction == 'Left' then
    vim.cmd('wincmd h')
    paneDirection = 'L'
  else
    vim.cmd('wincmd l')
    paneDirection = 'R'
  end
  local newWindow = vim.fn.winnr()
  if previousWindow == newWindow then
    if tmux.requirement_passed() then
      os.execute([[
      #!/usr/bin/env bash
      (
        previousPane=$(tmux display-message -p '#{pane_id}')
        newPane=$(tmux select-pane -]] .. paneDirection .. [[; tmux display-message -p '#{pane_id}')
        if [ $previousPane != $newPane ]; then
          tmux kill-pane
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
  local directionValues = { 'up', 'down', 'left', 'right', 'Up', 'Down', 'Left', 'Right' }
  if not utils.argument_is_valid(direction, directionValues) then
    return
  end
  local previousWindow = vim.fn.winnr()
  local paneDirection
  if direction == 'up' or direction == 'up' then
    vim.cmd('wincmd k')
    paneDirection = 'U'
  elseif direction == 'down' or direction == 'Down' then
    vim.cmd('wincmd j')
    paneDirection = 'D'
  elseif direction == 'left' or direction == 'Left' then
    vim.cmd('wincmd h')
    paneDirection = 'L'
  else
    vim.cmd('wincmd l')
    paneDirection = 'R'
  end
  local newWindow = vim.fn.winnr()
  if previousWindow == newWindow then
    if tmux.requirement_passed() then
      os.execute('tmux select-pane -' .. paneDirection .. ' > /dev/null 2>&1')
    end
  end
end

-- Switch to previous nvim window or tmux pane.
M.previous = function()
  -- Check if user has tmux installed.
  if not tmux.requirement_passed() then
    vim.cmd('wincmd p')
    return
  end
  -- Perform the switch.
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
M.create_pane = function(direction)
  if not tmux.requirement_passed() then
    utils.error_msg('Tmux 1.8+ is required')
    return
  end
  if direction == 'vertical' or direction == 'Vertical' then
    os.execute("tmux split-window -h -c '#{pane_current_path}'")
  elseif direction == 'horizontal' or direction == 'Horizontal' then
    os.execute("tmux split-window -v -c '#{pane_current_path}'")
  else
    utils.error_msg('Not a valid argument')
  end
end

return M
