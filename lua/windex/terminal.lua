local M = {}

-- Toggle the native terminal.
M.toggle = function(command)
  if vim.bo.buftype == 'terminal' then
    vim.g.term_bufnr = vim.fn.bufnr()
    if vim.g.term_prev == nil or vim.fn.bufname(vim.g.term_prev) == '' then
      local keys = vim.api.nvim_replace_termcodes('<C-\\><C-N><C-^>', true, false, true)
      vim.api.nvim_feedkeys(keys, 'n', true)
    else
      vim.cmd('keepalt buffer ' .. vim.g.term_prev)
    end
    require('windex.maximize').restore()
  else
    require('windex.maximize').maximize()
    vim.g.term_prev = vim.fn.bufnr()
    if command ~= nil then
      vim.cmd('keepalt terminal ' .. command)
    elseif vim.g.term_bufnr == nil or vim.fn.bufname(vim.g.term_bufnr) == '' then
      vim.cmd 'keepalt terminal'
    else
      vim.cmd('keepalt buffer ' .. vim.g.term_bufnr)
    end
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.signcolumn = 'no'
    vim.cmd 'startinsert'
  end
end

return M
