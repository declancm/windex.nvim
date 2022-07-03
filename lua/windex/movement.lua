local M = {}

local config = require('windex.config')
local tmux = require('windex.tmux')
local utils = require('windex.utils')

local directions = {
  nvim = { up = 'k', down = 'j', left = 'h', right = 'l' },
  tmux = { up = 'U', down = 'D', left = 'L', right = 'R' },
}

M.status_previous = 'nvim'

-- Save and quit nvim window or kill tmux pane in the direction selected.
M.close = function(direction)
  if direction then
    direction = direction:lower()
  end
  if not utils.contains({ 'up', 'down', 'left', 'right' }, direction) then
    utils.error_msg('Not a valid argument')
    return
  end

  -- Quit the nvim window.
  local prev_window = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. directions.nvim[direction])
  local new_window = vim.api.nvim_get_current_win()
  if prev_window ~= new_window then
    vim.cmd('exit')
    return
  end

  -- Quit the tmux window.
  if tmux.requirement_passed() and not tmux.is_maximized() then
    local prev_pane = tmux.execute("display-message -p '#{pane_id}'")
    tmux.execute('select-pane -' .. directions.tmux[direction])
    local new_pane = tmux.execute("display-message -p '#{pane_id}'")
    if prev_pane ~= new_pane then
      if config.warnings then
        tmux.execute('select-pane  -l')
        -- TODO: use a floating window instead of command line
        local input = vim.fn.input(
          string.format("Are you sure you want to close the following tmux pane: '%s'? [y/n] ", new_pane)
        )
        if utils.contains({ 'y', 'yes' }, input:lower()) then
          tmux.execute('select-pane  -l')
          tmux.execute('kill-pane')
        end
      else
        tmux.execute('kill-pane')
      end
    end
  end
end

-- Move between nvim windows and tmux panes.
M.switch = function(direction)
  if direction then
    direction = direction:lower()
  end
  if not utils.contains({ 'up', 'down', 'left', 'right' }, direction) then
    utils.error_msg('Not a valid argument')
    return
  end

  -- Switch nvim window.
  local prev_window = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. directions.nvim[direction])
  local new_window = vim.api.nvim_get_current_win()

  -- If on an edge window, perform circular window movement.
  if prev_window == new_window and tmux.single_pane(directions.nvim[direction]) then
    local alt_directions = { h = 'l', j = 'k', k = 'j', l = 'h' }
    local at_alt_edge = false

    while not at_alt_edge do
      local new_cur_win = vim.api.nvim_get_current_win()
      vim.cmd('wincmd ' .. alt_directions[directions.nvim[direction]])
      at_alt_edge = new_cur_win == vim.api.nvim_get_current_win()
    end
  end

  new_window = vim.api.nvim_get_current_win()

  -- If nvim window hasn't changed, switch tmux pane.
  if prev_window == new_window and tmux.requirement_passed() and not tmux.is_maximized() then
    local prev_pane = tmux.execute("display-message -p '#{pane_id}'")
    tmux.execute('select-pane -' .. directions.tmux[direction])
    local new_pane = tmux.execute("display-message -p '#{pane_id}'")
    if prev_pane ~= new_pane and config.save_buffers then
      vim.cmd('wall')
    end
  end
end

-- Switch to previous nvim window or tmux pane.
M.previous = function()
  -- Check if user has tmux installed.
  if not tmux.requirement_passed() then
    vim.cmd('wincmd p')
    return
  end

  local function nvim_previous()
    local prev_window = vim.api.nvim_get_current_win()
    vim.cmd('wincmd p')
    local new_window = vim.api.nvim_get_current_win()
    return prev_window ~= new_window
  end

  local function tmux_previous()
    if tmux.single_pane() then
      return
    end
    local prev_pane = tmux.execute("display-message -p '#{pane_id}'")
    if not tmux.is_maximized() then
      tmux.execute('select-pane -l')
    end
    local new_pane = tmux.execute("display-message -p '#{pane_id}'")
    if prev_pane ~= new_pane and config.save_buffers then
      vim.cmd('wall')
    end
    return prev_pane ~= new_pane
  end

  -- Perform the switch.
  if M.status_previous == 'tmux' then
    if not tmux_previous() then
      nvim_previous()
    end
  else
    if not nvim_previous() then
      tmux_previous()
    end
  end
end

-- Create a tmux pane.
M.create_pane = function(direction)
  -- Check if tmux requirement is passed.
  if not tmux.requirement_passed() then
    utils.error_msg('Tmux 1.8+ is required')
    return
  end

  if direction then
    direction = direction:lower()
  end
  if direction == 'vertical' then
    tmux.execute("split-window -h -c '#{pane_current_path}'")
  elseif direction == 'horizontal' or direction == 'Horizontal' then
    tmux.execute("split-window -v -c '#{pane_current_path}'")
  else
    utils.error_msg('Not a valid argument')
  end
end

return M
