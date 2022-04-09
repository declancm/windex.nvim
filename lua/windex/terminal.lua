local M = {}

local options = require('windex').options
local utils = require('windex.utils')
local maximize = require('windex.maximize')

-- Toggle the native terminal.
M.toggle = function(maximize_option, command)
  if vim.bo.buftype == 'terminal' then
    M.exit()
  else
    maximize_option = maximize_option or 'all'
    if maximize_option == '' then
      maximize_option = 'all'
    end

    if not utils.argument_is_valid(maximize_option, { 'none', 'nvim', 'all' }) then
      return
    end

    M.enter(maximize_option, command)
  end
end

M.enter = function(maximize_option, command)
  maximize_option = maximize_option or 'all'
  if not utils.argument_is_valid(maximize_option, { 'none', 'nvim', 'all' }) then
    return
  end

  if vim.w.__windex_maximized then
    vim.w.__windex_term_restore = false
  else
    vim.w.__windex_term_restore = true
  end
  vim.w.__windex_term_restore_option = maximize_option

  -- Maximize the window.
  if maximize_option ~= 'none' then
    maximize.maximize(maximize_option)
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

  -- Set the local terminal options for better visuals.
  if options.numbered_term then
    vim.opt_local.number = true
  else
    vim.opt_local.number = false
  end
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = 'no'
  vim.cmd('startinsert')
end

M.exit = function()
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
  M.restore()
end

M.restore = function()
  if vim.w.__windex_term_restore then
    maximize.restore(vim.w.__windex_term_restore_option)
  end
end

return M
