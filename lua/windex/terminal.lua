local M = {}

-- Toggle the native terminal.
M.toggle = function(maximizeOption, command)
  maximizeOption = maximizeOption or 'All'
  if maximizeOption == '' then
    maximizeOption = 'All'
  end
  if vim.bo.buftype == 'terminal' then
    require('windex.terminal').exit(maximizeOption)
  else
    require('windex.terminal').enter(maximizeOption, command)
  end
end

M.enter = function(maximizeOption, command)
  -- Maximize the window.
  if maximizeOption ~= 'None' then
    require('windex.maximize').maximize(maximizeOption)
  end
  -- Save the previous buffer number.
  vim.g.__windex_term_prev = vim.fn.bufnr()
  -- If a command is given or no previous terminal buffer exists, create a new one.
  -- Otherwise, enter the buffer of the previous terminal.
  if command ~= nil then
    vim.cmd('keepalt terminal ' .. command)
  elseif vim.g.__windex_term_bufnr == nil or vim.fn.bufname(vim.g.__windex_term_bufnr) == '' then
    vim.cmd('keepalt terminal')
  else
    vim.cmd('keepalt buffer ' .. vim.g.__windex_term_bufnr)
  end
  -- Set the local terminal options.
  vim.opt_local.relativenumber = false
  vim.opt_local.number = false
  vim.opt_local.signcolumn = 'no'
  vim.cmd('startinsert')
end

M.exit = function(maximizeOption)
  -- Save the terminal buffer number.
  vim.g.__windex_term_bufnr = vim.fn.bufnr()
  -- Return to the previous buffer.
  if vim.g.__windex_term_prev == nil or vim.fn.bufname(vim.g.__windex_term_prev) == '' then
    local keys = vim.api.nvim_replace_termcodes('<C-\\><C-N><C-^>', true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', true)
  else
    vim.cmd('keepalt buffer ' .. vim.g.__windex_term_prev)
  end
  -- Restore the windows.
  if maximizeOption ~= 'None' then
    require('windex.maximize').restore(maximizeOption)
  end
end

return M
