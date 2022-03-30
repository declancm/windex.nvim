local M = {}

M.error_msg = function(message, code)
  code = code or 'Error'
  vim.cmd("echohl ErrorMsg | echom '" .. code .. ': ' .. message .. "' | echohl None")
end

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

M.argument_is_valid = function(argument, optionalValues)
  local argumentValid = false
  for _, value in pairs(optionalValues) do
    if argument == value then
      argumentValid = true
      break
    end
  end
  if not argumentValid then
    require('windex.utils').error_msg('Not a valid argument')
    return false
  end
  return true
end

return M
