local RunShell = {}
RunShell.__index = RunShell

local global = require('RunShell/global')
local Manager = require('RunShell/Manager')
local util = require('RunShell/util')
local command = require("RunShell/command")


RunShell.config=global

function RunShell.setup(args)
  if global.initialize==true then
    return
  end
  if type(args) ~= "table" then
    return error("arguments must be a table")
  end

  if args.shellpath ~= nil then
    global.shellpath = args.shellpath
  end

  if args.default_shell ~= nil then
    global.default_shell = args.default_shell
  end

  if args.windows ~= nil then
    if args.windows.config ~= nil then
      if args.windows.config.height ~= nil then
        global.windows.config.height = args.windows.config.height
      end
    end
  end

  if args.prefix_key ~= nil then
    global.prefix_key = args.prefix_key
  end
  util.initshell()

  Manager.init()
  command.make_commands()
  global.initialize=true
end


function RunShell.run_default()
  if global.initialize~=true then
    return
  end
  util.run_shell(global.default)
end

function RunShell.run_shell(index)
  if global.initialize~=true then
    return
  end
  util.run_shell(index)
end

function RunShell.run_command(cmd)
  if global.initialize~=true then
    return
  end
  util.run(cmd)
end

function RunShell.next_session()
  if global.initialize~=true then
    return
  end
  Manager.next()
end

function RunShell.prev_session()
  if global.initialize~=true then
    return
  end
  Manager.prev()
end

function RunShell.list_sessions()
  if global.initialize~=true then
    return
  end
  return Manager.list()
end

function RunShell.hide_session()
  if global.initialize~=true then
    return
  end
  Manager.stop()
end

function RunShell.show_session()
  if global.initialize~=true then
    return
  end
  Manager.use()
end

function RunShell.is_visiable()
  if global.initialize~=true then
    return
  end
  Manager.is_visiable()
end


return RunShell
