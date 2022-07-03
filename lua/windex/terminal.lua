local M = {}

local config = require('windex.config')
local utils = require('windex.utils')
local maximize = require('windex.maximize')

local terminal_maximized
local terminal_restore_option
local previous_buffer
local terminal_buffer

-- Toggle the native terminal.
M.toggle = function(maximize_option, command)
  if vim.bo.buftype == 'terminal' then
    M.exit()
  else
    if not maximize_option or maximize_option == '' then
      maximize_option = 'all'
    else
      maximize_option = maximize_option:lower()
    end

    if not utils.contains({ 'none', 'nvim', 'all' }, maximize_option) then
      utils.error_msg('Not a valid argument')
      return
    end

    M.enter(maximize_option, command)
  end
end

M.enter = function(maximize_option, command)
  if maximize_option then
    maximize_option = maximize_option:lower()
  else
    maximize_option = 'all'
  end

  if not utils.contains({ 'none', 'nvim', 'all' }, maximize_option) then
    utils.error_msg('Not a valid argument')
    return
  end

  if vim.t.maximized then
    terminal_maximized = false
  else
    terminal_maximized = true
  end
  terminal_restore_option = maximize_option

  -- Maximize the window.
  if maximize_option ~= 'none' then
    maximize.maximize(maximize_option)
  end

  -- Save the previous buffer number.
  previous_buffer = vim.fn.bufnr()

  -- If a command is given or no previous terminal buffer exists, create a new one.
  -- Otherwise, enter the buffer of the previous terminal.
  if command ~= nil then
    vim.cmd('keepalt terminal ' .. command)
  elseif terminal_buffer == nil or vim.fn.bufname(terminal_buffer) == '' then
    vim.cmd('keepalt terminal')
  else
    vim.cmd('keepalt buffer ' .. terminal_buffer)
  end

  -- Set the local terminal options for better visuals.
  if config.numbered_term then
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
  terminal_buffer = vim.fn.bufnr()

  -- Return to the previous buffer.
  if previous_buffer == nil or vim.fn.bufname(previous_buffer) == '' then
    local keys = vim.api.nvim_replace_termcodes('<C-\\><C-N><C-^>', true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', true)
  else
    vim.cmd('keepalt buffer ' .. previous_buffer)
  end

  -- Restore the windows.
  M.restore()
end

M.restore = function()
  if terminal_maximized then
    maximize.restore(terminal_restore_option)
  end
end

return M
