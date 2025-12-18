local global = require('RunShell/global')
local Session = require('RunShell/Manager/Session')





---@class Tab
---@field tabid number
---@field winid number?
---@field bufid number?
local Tab = {}
Tab.__index = Tab

---@type table<number,Tab>
tabs = {}

---@param tabid number?
---@return Tab
function Tab:new(tabid)
  if tabid == nil then
    tabid = vim.api.nvim_get_current_tabpage()
  end
  if tabs[tabid] ~= nil then
    return tabs[tabid]
  end
  local metadata = {
    tabid = tabid,
    winid = nil,
    bufid = nil,
  }

  return setmetatable(metadata, Tab)
end

---@return number
function Tab:start()
  vim.cmd('botright ' .. global.windows.config.height .. 'split')
  local winid = vim.api.nvim_get_current_win()
  self.winid = winid
  return winid
end

---@return nil
function Tab:stop()
  if self.winid ~= nil then
    vim.api.nvim_win_close(self.winid, true)
    self.winid = nil
  end
end

---@param comm string
---@return boolean
function Tab:run(comm)
  local winid = self.winid
  if winid == nil then
    winid = self:start()
  end
  local buf = Session.new_instance()
  local status = buf:start(winid, comm)
  self.bufid = buf:get_bufid()

  return status
end

---@return nil
function Tab:clean()
  self.winid = nil
end

---@return number?
function Tab:get_winid()
  return self.winid
end

---@return number?
function Tab:get_bufid()
  if self.winid ~= nil then
    return self.bufid
  end
  return nil
end

---@param bufid number?
---@return boolean
function Tab:use_next(bufid)
  if bufid == nil then
    bufid = self:get_bufid()
  end

  local buf = Session.next(bufid)
  if buf == nil then
    return false
  end

  local winid = self.winid
  if winid == nil then
    winid = self:start()
  end

  buf:use(winid)
  self.bufid = buf:get_bufid()
  return true
end

---@param bufid number?
---@return boolean
function Tab:use_prev(bufid)
  if bufid == nil then
    bufid = self:get_bufid()
  end
  local buf = Session.prev(bufid)
  if buf == nil then
    return false
  end
  local winid = self.winid
  if winid == nil then
    winid = self:start()
  end
  buf:use(winid)
  self.bufid = buf:get_bufid()
  return true
end

---@param bufid number?
---@return boolean
function Tab:use(bufid)
  if bufid==nil then
    bufid=self:get_bufid()
  end
  local buf = Session.get_session_by_id(bufid)
  if buf == nil then
    return false
  end
  local winid = self.winid
  if winid == nil then
    winid = self:start()
  end
  buf:use(winid)
  self.bufid = buf:get_bufid()
  return true
end

function Tab:unlink_buf()
  local status = self:use_next()
  if status == false then
    self:stop()
    self.bufid = nil
  end
end

function Tab:is_visiable()
  return self.winid ~= nil
end


---@param tabid number?
---@return Tab
function Tab.new_instance(tabid)
  if tabid==nil then
    tabid=vim.api.nvim_get_current_tabpage()
  end
  local tab = Tab:new(tabid)
  tabs[tabid] = tab
  return tab
end

---@return Tab
function Tab.get_current_tab()
  local tabid = vim.api.nvim_get_current_tabpage()
  local tab = tabs[tabid]
  if tab == nil then
    tab = Tab:new(tabid)
    tabs[tabid] = tab
  end
  return tab
end

---@reutrn number?
function Tab.get_shell_winid()
  local tab = Tab.get_current_tab()
  if tab == nil then
    return nil
  end
  return tab:get_winid()
end

---@return number?
function Tab.get_shell_bufid()
  local tab = Tab.get_current_tab()
  if tab == nil then
    return nil
  end
  return tab:get_bufid()
end

function Tab.delete_instance(tabid)
  local tab = nil
  if tabid == nil then
    return false
  else
    tab = tabs[tabid]
  end
  if tabs[tabid] ~= nil then
    tabs[tabid]:stop()
    tabs[tabid] = nil
    return true
  end
  return false
end

function Tab.unlink(bufid)
  if bufid == nil then
    local tab = Tab.get_current_tab()
    local bufid = tab:get_bufid()
    tab:unlink_buf()
    return bufid
  end

  for _, tab in pairs(tabs) do
    if tab:get_bufid() == bufid then
      tab:unlink_buf()
      return bufid
    end
  end
end

return Tab
