local M={}

function M.readlines(path)
    local f=io.open(path,'r');
    if not f then
        return {}
    end
    local lines={}
    local line=""
    while true do
        local c=f:read(1)
        if not c then break end
        if c == '\n' or c=='\r' then
            table.insert(lines,line)
            line=""
        else
            line=line..c
        end
    end
    if line:len() ~= 0 then
        table.insert(lines,line)
    end
    f:close()
    return lines
end


function M.writelines(path,lines)
    local f=io.open(path,'w');
    if not f then
        return
    end
    for _,line in ipairs(lines)do
       f:write(line.."\n")
    end
    f:close()
    return
end

function M.ensure_path(path)
  local full_path = vim.fn.expand(path)

  if vim.fn.filereadable(full_path) == 1 then
    return true
  end

  local dir = vim.fn.fnamemodify(full_path, ":h")

  if vim.fn.isdirectory(dir) == 0 then
    local ok = vim.fn.mkdir(dir, "p")
    if ok ~= 1 then
      error("Don't create directory: " .. dir)
      return false
    end
  end
  return true
end



return M
