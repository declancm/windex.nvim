local M = {}

-- Toggle the native terminal.
M.toggle = function(maximizeOption, command)
  maximizeOption = maximizeOption or 'both'
  if maximizeOption == '' then
    maximizeOption = 'both'
  end
  if vim.bo.buftype == 'terminal' then
    vim.g.__windex_term_bufnr = vim.fn.bufnr()
    if vim.g.__windex_term_prev == nil or vim.fn.bufname(vim.g.__windex_term_prev) == '' then
      local keys = vim.api.nvim_replace_termcodes('<C-\\><C-N><C-^>', true, false, true)
      vim.api.nvim_feedkeys(keys, 'n', true)
    else
      vim.cmd('keepalt buffer ' .. vim.g.__windex_term_prev)
    end
    if maximizeOption ~= 'none' then
      require('windex.maximize').restore(maximizeOption)
    end
  else
    if maximizeOption ~= 'none' then
      require('windex.maximize').maximize(maximizeOption)
    end
    vim.g.__windex_term_prev = vim.fn.bufnr()
    if command ~= nil then
      vim.cmd('keepalt terminal ' .. command)
    elseif vim.g.__windex_term_bufnr == nil or vim.fn.bufname(vim.g.__windex_term_bufnr) == '' then
      vim.cmd('keepalt terminal')
    else
      vim.cmd('keepalt buffer ' .. vim.g.__windex_term_bufnr)
    end
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.signcolumn = 'no'
    vim.cmd('startinsert')
  end
end

return M
