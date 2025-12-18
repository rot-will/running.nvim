local global = require('RunShell/global')
local util = require('RunShell/util')

local M = {}
-- function M.make_keymaps()
--   if global.is_set_key == nil then
--     return
--   end
--   vim.keymap.set('t', global.quit_key, '<C-\\><C-N>', { desc = "quit terminal" })
-- end

function M.make_commands()
  function complete(arg_lead)
    local completions = {}
    local start = tonumber(arg_lead)
    local end_ = #global.shell
    if start == nil then
      start = 1
    elseif end_ > start * 10 then
      end_ = (start + 1) * 10
      start = start * 10
    end
    for i = start, end_ do
      table.insert(completions, tostring(i))
    end
    return completions
  end

  vim.api.nvim_create_user_command('RunShell', function(opts)
    local index = tonumber(opts.args)
    util.run(global.shell[index])
  end, {
    nargs = 1,
    complete = complete,
  })

  vim.api.nvim_create_user_command('RunShellCmd', function(opts)
    util.run(opts.args)
  end, {
    nargs = "*"
  })

  vim.api.nvim_create_user_command('RunShellAdd', function(opts)
    util.clear_keys()
    table.insert(global.shell, opts.args)
    util.save_shell()
    util.register_shell()
  end, {
    nargs = "*",
  })

  vim.api.nvim_create_user_command('RunShellDel', function(opts)
    util.clear_keys()
    local index = tonumber(opts.args)
    table.remove(global.shell, index)
    if global.default > #global.shell then
      global.default = 1
    end
    util.save_shell()
    util.register_shell()
  end, {
    nargs = 1,
    complete = complete,
  })


  vim.api.nvim_create_user_command('RunShellDefault', function(opts)
    local index = tonumber(opts.args)
    if index == nil or index > #global.shell then
      error("Index should be less than " .. #global.shell .. "and greater than 1")
      return
    end
    global.default = index
    util.save_shell()
  end, {
    nargs = 1,
    complete = complete,
  })

  vim.api.nvim_create_user_command('RunShellList', function(opts)
    local index = tonumber(opts.args)
    if index == nil then
      print("Default: " .. global.default)
      for index_, value in ipairs(global.shell) do
        print(index_ .. " : " .. value)
      end
      return
    else
      if index > #global.shell then
        error("Index should be less than " .. #global.shell .. "and greater than 1")
        return
      end
      print(global.shell[index])
      return
    end
  end, {
    nargs = "?",
    complete = complete,
  })
end

return M
