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
  local t = cmd_get_table("git -C "..dir.." status --short")
  if t == nil then return nil end
  local r = {}
  for _, i in pairs(t) do
    local _, _, tag = string.find(i, "^(..)")
    if string.sub(tag, 0, 1) == " " then
      i = c.red(i)
    else
      i = c.green(i)
    end
    table.insert(r, i)
  end
  return r
end

git.cherry = function (dir)
  local t =  cmd_get_table("git -C "..dir.." cherry -v --abbrev")
  if t == nil then return nil end
  local r = {}
  for _, i in pairs(t) do
    local _, _, _, id, msg = string.find(i, "^(%p) (%w+) (.*)$")
    id = c.yellow(id)
    table.insert(r, id..' '..msg)
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
  r = r:gsub('%.git$', '')
  local _, _, owner, repo_name = string.find(r, "^(.*)/(.*)$")
  return owner, repo_name
end

git.summary = function (dir)
  local owner, repo_name = git.remote(dir)
  return {
    owner = owner,
    name = repo_name,
    dir = dir,
    status = git.status(dir),
    commits = git.cherry(dir),
    branch = git.branch(dir),
  }
end

return git
