local global = require('RunShell/global')
local Manager=require('RunShell/Manager')
local file=require('RunShell/file')


function save_shell()
  local nshell = { tostring(global.default) }
  for _, s in ipairs(global.shell) do
    table.insert(nshell, s)
  end
  file.writelines(global.shellpath, nshell)
end



function clear_keys()
  for i = 0, #global.shell - 1, 1 do
    vim.keymap.del('n', 't' .. i)
  end
end


function run(command)
  if command == nil then
    return
  end
  print(123)
  Manager.run(command)
  -- command='terminal ' .. opts.args
  -- vim.cmd([[
  --         wincmd s
  --         wincmd J
  --         terminal ]] .. command)
  -- vim.cmd('startinsert')
end

function run_shell(index)
  if index == nil or index > #global.shell then
    error("Index should be less than " .. #global.shell .. "and greater than 1")
    return
  end
  local command = global.shell[index]
  run(command)
end

function register_shell()
  if global.prefix_key==nil then
    return
  end
  for i = 0, #global.shell - 1, 1 do
    vim.keymap.set('n', global.prefix_key .. i, function()
      run_shell(i + 1)
    end, { desc = "run " .. global.shell[i + 1] })
  end
end


function initshell()
  file.ensure_path(global.shellpath)

  local result = file.readlines(global.shellpath)
  if #result < 2 then
    return {}, 0
  end
  global.default = tonumber(result[1])
  table.remove(result, 1)

  if #global.shell == 0 then
    global.shell = global.default_shell
    global.default = 1
    save_shell()
  end

  register_shell()
end

return {
  run = run,
  run_shell = run_shell,
  initshell = initshell,
  save_shell = save_shell,
  register_shell=register_shell
}
