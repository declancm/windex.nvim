local M = {}

M.requirement_passed = function()
  -- Check if command fails. If it fails, tmux is not installed.
  if os.execute('tmux -V') ~= 0 then
    return false
  end
  -- Check if the version number is 1.8 or greater (for 'resize-pane -Z').
  local exitStatus = os.execute([[
  #!/usr/bin/env bash
  exit $(echo "$(tmux -V | sed 's/[^0-9.]*//g') >= 1.8" | bc -l) > /dev/null 2>&1
  ]])
  if exitStatus == 0 then
    return false
  else
    return true
  end
end

M.is_maximized = function()
  local exitStatus = os.execute([[
  #!/usr/bin/env bash
  exit $(tmux display-message -p '#{window_zoomed_flag}') > /dev/null 2>&1
  ]])
  if exitStatus == 0 then
    return false
  else
    return true
  end
end

return M
