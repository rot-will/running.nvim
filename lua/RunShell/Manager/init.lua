local Session = require('RunShell/Manager/Session')
local Tab = require('RunShell/Manager/Tab')
local global = require('RunShell/global')

local slots = {
  on_winclose = function(args)
    local tab = Tab.get_current_tab()
    if tab == nil then
      return
    end
    tab:clean()
  end,
  on_tabnew = function(args)
    local tabid = tonumber(args.match)
    Tab.new_instance(tabid)
  end,
  on_tabclose = function(args)
    local tabid = tonumber(args.match)
    Tab.delete_instance(tabid)
  end,
  on_vimenter = function(args)
    Tab.new_instance()
  end,
  on_bufdelete = function(args)
    local bufid = args.buf
    if Session.has(bufid) then
      Tab.unlink(bufid)
      Session.delete_instance(bufid)
    end
  end
}

local M = {}
function M.init()
  vim.api.nvim_create_autocmd('WinClosed', {
    callback = slots.on_windows

  })
  vim.api.nvim_create_autocmd('TabNewEntered', {
    callback = slots.on_tabnew
  })

  vim.api.nvim_create_autocmd('TabClosed', {
    callback = slots.on_tabclose
  })

  vim.api.nvim_create_autocmd('VimEnter', {
    callback = slots.on_vimenter
  })

  vim.api.nvim_create_autocmd('BufDelete', {
    callback = slots.on_bufdelete
  })
  return true
end

function M.run(comm)
  local tab = Tab.get_current_tab()
  return tab:run(comm)
end

---@param bufid number?
---@return boolean
function M.delete(bufid)
  if bufid ~= nil and Session.has(bufid) == false then
    return false
  end
  if bufid == nil then
    bufid = Tab.unlink(bufid)
  end
  Tab.unlink(bufid)
  Session.delete_instance(bufid)
  return true
end

function M.list()
  return Session.list_bufs()
end

function M.next(bufid)
  local tab = Tab.get_current_tab()
  tab:use_next(bufid)
end

function M.prev(bufid)
  local tab = Tab.get_current_tab()
  tab:use_prev(bufid)
end

function M.use(bufid)
  local tab = Tab.get_current_tab()
  tab:use(bufid)
end

---@param bufid number?
function M.unuse(bufid)
  if bufid == nil then
    local tab = Tab.get_current_tab()
    tab:unlink_buf()
    return
  end
  Tab.unlink(bufid)
end

function M.is_visiable()
  local tab = Tab.get_current_tab()
  tab:is_visiable()

end

return M
