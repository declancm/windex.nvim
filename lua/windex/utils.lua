local M = {}

M.tmux_maximized = function()
  -- Compare pane size with window size.
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
  return tmuxMaximized
end

return M
