local global=require('RunShell/global')


---@class Session
---@field bufid number
---@field jobid number?
local Session={}
Session.__index=Session

---@type table<number,Session>
local sessions={}

---@return Session
function Session:new()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "RunShell"


  local session_metadata={
    bufid=bufnr,
    jobid=nil
  }

  return setmetatable(session_metadata,Session)
end


---@param winid number
---@param comm string
---@return boolean
function Session:start(winid,comm)
  if winid==nil then
    return false
  end
  if self.jobid~=nil then
    vim.fn.jobstop(self.jobid)
  end

  vim.api.nvim_win_set_buf(winid,self.bufid)
  vim.api.nvim_set_current_win(winid)

  local jobid=vim.fn.jobstart(comm,{
    term=true
  })
  if jobid<=0 then
    return false
  end
  self.jobid=jobid
  return jobid
end

function Session:stop()
  if self:is_start() then
    vim.fn.jobstop(self:get_jobid())
    self.jobid=nil
  end

  vim.api.nvim_buf_delete(self:get_bufid(),{
    unload=true,
  })
 
  return true
end

---@param winid number
function Session:use(winid)
  if winid==nil then
    return false
  end
  if self.jobid==nil then
    return false
  end
  vim.api.nvim_win_set_buf(winid,self.bufid)
  return true
end


---@return number
function Session:get_bufid()
  return self.bufid
end
---@return number?
function Session:get_jobid()
  return self.jobid
end

---@return boolean
function Session:is_start()
  return self.jobid~=nil
end

---@return Session
function Session.new_instance()
  local session=Session:new()
  sessions[session.bufid]=session
  return session
end

---@return table
function Session.list_bufs()
  return vim.tbl_keys(sessions)
end

---@param bufid number?
---@param depth number?
---@return Session?
function Session.next(bufid,depth)
  if vim.tbl_count(sessions)==0 then
    return nil
  end
  if depth==nil then
    if bufid==nil then
      depth=0
    else
      depth=1
    end
  end
  if depth > vim.tbl_count(sessions) then
    return nil
  end
  local keys=Session.list_bufs()
  local bufindex = -1
  if bufid == nil then
    bufindex = 1
  else
    bufindex = vim.index(keys, bufid) + 2
    if bufindex >= #keys then
      bufindex = 1
    end
  end

  local session= sessions[keys[bufindex]]
  if session:is_start()==false then
    return Session.prev(session:get_bufid(),depth+1)
  end

  return session
end

---@param bufid number?
---@param depth number?
---@return Session?
function Session.prev(bufid,depth)
  if vim.tbl_count(sessions)==0 then
    return nil
  end
  if depth==nil then
    if bufid==nil then
      depth=0
    else
      depth=1
    end
  end
  if depth >= vim.tbl_count(sessions) then
    return nil
  end
  local keys=Session.list_bufs()
  local bufindex = -1
  if bufid == nil then
    bufindex = #keys
  else
    bufindex = vim.fn.index(keys, bufid)
    if bufindex < 1 then
      bufindex = vim.tbl_count(sessions)
    end
  end

  local session= sessions[keys[bufindex]]
  if session:is_start()==false then
    return Session.prev(session:get_bufid(),depth+1)
  end

  return session
end

---@param bufid number?
---@return Session?
function Session.get_session_by_id(bufid)
  if vim.tbl_count(sessions)==0 then
    return nil
  end
  if bufid~=nil then
    return sessions[bufid]
  end

  return Session.next()
end

---@param bufid number
---@return boolean
function Session.delete_instance(bufid)
  if bufid==nil then
    return false
  end

  if sessions[bufid]==nil then
    return false
  end
  sessions[bufid]=nil
  return true
end


---@param bufid number
---@return boolean
function Session.has(bufid)
  return sessions[bufid]~=nil
end


return Session
