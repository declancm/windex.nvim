local M = {}

-- TODO: change the tmux functions to use socket programming

M.requirement_passed = function()
  -- Check if tmux is installed.
  if not os.getenv('TMUX') then
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

M.single_pane = function()
  -- If tmux not installed, no other tmux panes exist.
  if not os.getenv('TMUX') then
    return true
  end

  local exitStatus = os.execute([[
  #!/usr/bin/env bash
  exit $(echo "$(tmux display-message -p '#{window_panes}') == 1" | bc -l) > /dev/null 2>&1
  ]])
  if exitStatus == 0 then
    return false
  else
    return true
  end
end

M.is_first_pane = function()
  local exitStatus = os.execute([[
  #!/usr/bin/env bash
  exit $(echo "$(tmux display-message -p '#{pane_index}') == 1" | bc -l) > /dev/null 2>&1
  ]])
  if exitStatus == 0 then
    return false
  else
    return true
  end
end

M.is_last_pane = function()
  local exitStatus = os.execute([[
  #!/usr/bin/env bash
  exit $(echo "$(tmux display-message -p '#{pane_index}') == $(tmux display-message -p '#{window_panes}')" | bc -l) > /dev/null 2>&1
  ]])
  if exitStatus == 0 then
    return false
  else
    return true
  end
end

return M
