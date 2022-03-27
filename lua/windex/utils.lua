local M = {}

M.tmux_requirement_passed = function()
  -- Check if command fails. If it fails, tmux is not installed.
  if os.execute('tmux -V') ~= 0 then
    return false
  end
  -- Check if the version number is 1.8 or greater (for 'resize-pane -Z').
  local exitStatus = os.execute([[
  #!/usr/bin/env bash
  (
    tmuxVersion=$(tmux -V | sed 's/[^0-9.]*//g')
    exit $(echo "$tmuxVersion >= 1.8" | bc -l)
  ) > /dev/null 2>&1
  ]])
  if exitStatus == 0 then
    return false
  else
    return true
  end
end

M.tmux_maximized = function()
  -- Compare the size of the current tmux pane with the tmux window.
  local exitStatus = os.execute([[
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
  ]])
  if exitStatus == 0 then
    return true
  else
    return false
  end
end

M.argument_is_valid = function(argument, optionalValues)
  local argumentValid = false
  for _, value in pairs(optionalValues) do
    if argument == value then
      argumentValid = true
      break
    end
  end
  if not argumentValid then
    vim.cmd([[echohl ErrorMsg | echo "Error: Not a valid argument." | echohl None]])
    return false
  end
  return true
end

return M
