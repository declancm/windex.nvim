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

M.single_pane = function()
  -- If tmux not installed, no other tmux panes exist.
  if not TMUX then
    return true
  end

  return M.execute("display-message -p '#{window_panes}'") == '1'
end

M.is_first_pane = function()
  return M.execute("display-message -p '#{pane_index}'") == '1'
end

M.is_last_pane = function()
  return M.execute("display-message -p '#{pane_index}'") == M.execute("display-message -p '#{window_panes}'")
end

return M
