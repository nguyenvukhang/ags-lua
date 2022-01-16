#!/usr/bin/env lua

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

table.print = function(t)
  if t then
    for _, v in pairs(t) do
      print(v)
    end
  end
end

local utils = {}

-- checks if a file exists
utils.exists = function (file)
  local ok, _, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  -- return ok, err
  return ok
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
utils.lines_from = function (file)
  if not utils.exists(file) then
    print('\n~/.config/ags/scanlist does not exist.')
    return {}
  end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

utils.split = function (inputstr, sep)
  if sep == nil then sep = "%s" end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

utils.make_dict = function(t)
  local r = {}
  for _, v in pairs(t) do r[v] = true end
  return r
end

local u = utils

local colors = {}

colors.red    = function(t) return '\27[31m'..t..'\27[0m' end
colors.green  = function(t) return '\27[32m'..t..'\27[0m' end
colors.yellow = function(t) return '\27[33m'..t..'\27[0m' end
colors.blue   = function(t) return '\27[34m'..t..'\27[0m' end
colors.purple = function(t) return '\27[35m'..t..'\27[0m' end
colors.cyan   = function(t) return '\27[36m'..t..'\27[0m' end
colors.gray   = function(t) return '\27[37m'..t..'\27[0m' end

local c = colors

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

local Repo = {}
Repo.mt = {}

function Repo.new (dir)
  local repo = git.summary(dir)
  if repo.commits or repo.status then
    setmetatable(repo, Repo.mt)
    return repo
  else
    return nil
  end
end

function Repo.tostring (set)
  local s = "{"
  local sep = ""
  for k, e in pairs(set) do
    s = s .. sep .. k .. " = " .. e
    sep = ", "
  end
  return s .. "}"
end

function Repo.print (set)
  print(Repo.tostring(set))
end

local env = {}
env.home = os.getenv("HOME")

local parse_commands = function (arg)
  local a = u.make_dict(arg)
  return {
    list   = a["list"]   or a["ls"],
  }
end

local scanlist = u.lines_from(env.home..'/.config/ags/scanlist')

local git_repos = {}
local not_repos = {}
for _, k in pairs(scanlist) do
  local dir = k:gsub('^~', env.home)
  local g = dir .. '/.git'
  if u.exists(g) then
    table.insert(git_repos, dir)
  else
    table.insert(not_repos, dir)
  end
end

local repos = {}
for _, dir in pairs(git_repos) do
  local res = Repo.new(dir)
  if res then
    table.insert(repos, res)
  end
end

local list = {}

local verify_git = function (sl)
  local ok = {}
  for _, dir in pairs(sl) do
    local full_path = dir:gsub('^~', env.home)
    local g = full_path .. '/.git'
    if u.exists(g) then
      ok[dir] = true
    end
  end
  return ok
end

list.main = function (sl)
  table.sort(sl)
  print('\ncurrent scanlist:')
  local ok = verify_git(sl)
  for _, v in pairs(sl) do
    if ok[v] then
      print(c.green(v))
    else
      print(c.red(v))
    end
  end
  print()
end

local main = function ()
  for _, r in pairs(repos) do
    local name = c.green(r.name)
    print('\n'..c.gray('[')..name..c.gray('/'..r.branch..']'))
    table.print(r.commits)
    table.print(r.status)
  end
  print()
end

local commands = parse_commands(arg)

if commands.list then
  list.main(scanlist)
else
  main()
end
