local list = {}

local env = {}
local u = require('utils')
local c = require('colors')
env.home = os.getenv("HOME")

local verify_git = function (scanlist)
  local ok = {}
  for _, dir in pairs(scanlist) do
    local full_path = dir:gsub('^~', env.home)
    local g = full_path .. '/.git'
    if u.exists(g) then
      ok[dir] = true
    end
  end
  return ok
end

list.main = function (scanlist)
  table.sort(scanlist)
  print('\ncurrent scanlist:')
  local ok = verify_git(scanlist)
  for _, v in pairs(scanlist) do
    if ok[v] then
      print(c.green(v))
    else
      print(c.red(v))
    end
  end
  print()
end

return list
