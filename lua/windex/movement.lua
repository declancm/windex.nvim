local M = {}

local tmux = require('windex.tmux')
local utils = require('windex.utils')

local directions = {
  nvim = { up = 'k', down = 'j', left = 'h', right = 'l' },
  tmux = { up = 'U', down = 'D', left = 'L', right = 'R' },
}

-- Save and quit nvim window or kill tmux pane in the direction selected.
M.close = function(direction)
  if not utils.argument_is_valid(direction, { 'up', 'down', 'left', 'right' }) then
    return
  end

  local previousWindow = vim.fn.winnr()

  -- Switch nvim window.
  vim.cmd('wincmd ' .. directions.nvim[direction])

  local newWindow = vim.fn.winnr()

  if previousWindow == newWindow then
    -- If nvim window hasn't changed, switch tmux pane and kill.
    if tmux.requirement_passed() then
      os.execute([[
      #!/usr/bin/env bash
      (
        previousPane=$(tmux display-message -p '#{pane_id}')
        newPane=$(tmux select-pane -]] .. directions.tmux[direction] .. [[; tmux display-message -p '#{pane_id}')
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
  if not utils.argument_is_valid(direction, { 'up', 'down', 'left', 'right' }) then
    return
  end

  local previousWindow = vim.fn.winnr()

  -- Switch nvim window.
  if direction == 'left' and tmux.single_pane() and vim.fn.winnr() == 1 then
    -- If already in the left-most nvim window, move to the last window.
    vim.cmd(vim.fn.winnr('$') .. ' wincmd w')
  elseif direction == 'right' and tmux.single_pane() and vim.fn.winnr() == vim.fn.winnr('$') then
    -- If already in the right-most nvim window, move to the first window.
    vim.cmd('1 wincmd w')
  else
    vim.cmd('wincmd ' .. directions.nvim[direction])
  end

  local newWindow = vim.fn.winnr()

  -- If nvim window hasn't changed, switch tmux pane.
  if previousWindow == newWindow then
    if tmux.requirement_passed() then
      tmux.execute('select-pane -' .. directions.tmux[direction])
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
      tmux.execute('select-pane -l')
    end
  end
end

-- Create a tmux pane.
M.create_pane = function(direction)
  -- Check if tmux requirement is passed.
  if not tmux.requirement_passed() then
    utils.error_msg('Tmux 1.8+ is required')
    return
  end

  if direction == 'vertical' then
    tmux.execute("split-window -h -c '#{pane_current_path}'")
  elseif direction == 'horizontal' or direction == 'Horizontal' then
    tmux.execute("split-window -v -c '#{pane_current_path}'")
  else
    utils.error_msg('Not a valid argument')
  end
end

return M
