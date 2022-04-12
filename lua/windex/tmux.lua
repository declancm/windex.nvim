local M = {}

local TMUX = os.getenv('TMUX')

-- This function is taken from 'https://github.com/numToStr/Navigator.nvim'.
M.execute = function(command)
  local socket = vim.split(TMUX, ',')[1]
  local tmux = string.format('tmux -S %s %s', socket, command)

  local handle = assert(io.popen(tmux), string.format('Error: Unable to execute the tmux command', tmux))
  local result = handle:read()
  handle:close()

  return result
end

M.requirement_passed = function()
  -- Check if tmux is installed.
  if not TMUX then
    return false
  end

  -- Check if the version number is 1.8 or greater (for 'resize-pane -Z').
  if tonumber(M.execute('-V'):match('[0-9.]+')) >= 1.8 then
    return true
  end
  return false
end

M.is_maximized = function()
  return M.execute("display-message -p '#{window_zoomed_flag}'") == '1'
end

M.single_pane = function(direction)
  -- Check if tmux is installed.
  if not TMUX then
    return true
  end

  -- Check if only one pane.
  if M.execute("display-message -p '#{window_panes}'") == '1' then
    return true
  end

  -- Check if pane is maximized.
  if M.is_maximized() then
    return true
  end

  if not direction then
    return
  end

  -- Compare dimensions of the tmux pane and tmux window in direction
  if direction == 'h' or direction == 'l' then
    return M.execute("display-message -p '#{pane_width}'") == M.execute("display-message -p '#{window_width}'")
  elseif direction == 'j' or direction == 'k' then
    return M.execute("display-message -p '#{pane_height}'") == M.execute("display-message -p '#{window_height}'")
  end
end

return M
