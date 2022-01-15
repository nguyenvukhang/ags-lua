local u = require('utils')
local c = require('colors')

local git = {}

local cmd_get_table = function (cmd)
  local r = os.capture(cmd, true)
  if r == nil or r == '' then
    return nil
  else
    return u.split(r, '\n\r')
  end
end

local cmd_get_string = function (cmd)
  local r = os.capture(cmd, true)
  if r == nil or r == '' then
    return nil
  else
    return r:gsub('[\r\n]$', '')
  end
end

git.status = function (dir)
  return cmd_get_table("git -C "..dir.." status -s")
end

git.commits = function (dir)
  local t =  cmd_get_table("git -C "..dir.." cherry -v --abbrev")
  if t == nil then return nil end
  local r = {}
  for _, i in pairs(t) do
    local _, _, b, id, msg = string.find(i, "^(%p) (%w+) (.*)$")
    id = c.yellow(id)
    table.insert(r, b..' '..id..' '..msg)
  end
  return r
end

git.branch = function (dir)
  return cmd_get_string("git -C "..dir.." branch --show-current")
end

git.remote = function (dir, upstream)
  local origin = upstream or 'origin'
  local r = cmd_get_string("git -C "..dir.." config --get remote."..origin..".url")
  -- lua regex: https://www.lua.org/pil/20.2.html
  r = r:gsub('^https://.*/(.*)/', '%1/')
  r = r:gsub('^git@.*:', '')
  return r:gsub('%.git$', '')
end

return git
