local M = {}

M.error_msg = function(message, code, color)
  code = code or 'Error'
  color = color or 'ErrorMsg'
  vim.cmd(string.format('echohl %s | echom "%s: %s" | echohl None', color, code, message))
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
    M.error_msg('Not a valid argument')
    return false
  end
  return true
end

return M
