#!/usr/bin/env lua

function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
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

utils.cmd_get = function (cmd, t)
  local table = t or false
  local r = os.capture(cmd)
  if r == nil or r == '' then
    return nil
  else
    if table then
      return utils.split(r, '\n\r')
    else -- return string
      return r:gsub('[\r\n]$', '')
    end
  end
end

utils.parse_commands = function (arg)
  local a = {}
  for _, v in pairs(arg) do a[v] = true end
  return {
    list = a["list"] or a["ls"],
  }
end

local colors = {}

colors.red    = function(t) return '\27[31m'..t..'\27[0m' end
colors.green  = function(t) return '\27[32m'..t..'\27[0m' end
colors.yellow = function(t) return '\27[33m'..t..'\27[0m' end
colors.blue   = function(t) return '\27[34m'..t..'\27[0m' end
colors.purple = function(t) return '\27[35m'..t..'\27[0m' end
colors.cyan   = function(t) return '\27[36m'..t..'\27[0m' end
colors.gray   = function(t) return '\27[37m'..t..'\27[0m' end

local git = {}

git.status = function (dir)
  local t = utils.cmd_get("git -C "..dir.." status --short", true)
  if t == nil then return nil end
  local r = {}
  for _, i in pairs(t) do
    local _, _, tag = string.find(i, "^(..)")
    if string.sub(tag, 0, 1) == " " then
      i = colors.red(i)
    else
      i = colors.green(i)
    end
    table.insert(r, i)
  end
  return r
end

git.cherry = function (dir)
  local t =  utils.cmd_get("git -C "..dir.." cherry -v --abbrev", true)
  if t == nil then return nil end
  local r = {}
  for _, i in pairs(t) do
    local _, _, _, id, msg = string.find(i, "^(%p) (%w+) (.*)$")
    id = colors.yellow(id)
    table.insert(r, id..' '..msg)
  end
  return r
end

git.branch = function (dir)
  return utils.cmd_get("git -C "..dir.." branch --show-current")
end

git.remote = function (dir, upstream)
  local origin = upstream or 'origin'
  local r = utils.cmd_get("git -C "..dir.." config --get remote."..origin..".url")
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

function Repo.new (dir)
  local repo = git.summary(dir)
  if repo.commits or repo.status then
    return repo
  else
    return nil
  end
end

local env = {}
env.home = os.getenv("HOME")

local scanlist = utils.lines_from(env.home..'/.config/ags/scanlist')

local git_repos = {}
local not_repos = {}
for _, k in pairs(scanlist) do
  local dir = k:gsub('^~', env.home)
  local g = dir .. '/.git'
  if utils.exists(g) then
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

local verify_git = function (sl)
  local ok = {}
  for _, dir in pairs(sl) do
    local full_path = dir:gsub('^~', env.home)
    local g = full_path .. '/.git'
    if utils.exists(g) then
      ok[dir] = true
    end
  end
  return ok
end

local list = function (sl)
  table.sort(sl)
  print('\ncurrent scanlist:')
  local ok = verify_git(sl)
  for _, v in pairs(sl) do
    if ok[v] then
      print(colors.green(v))
    else
      print(colors.red(v))
    end
  end
  print()
end

local main = function ()
  for _, r in pairs(repos) do
    local name = r.name
    print('\n'..colors.gray('[')..name..colors.gray('/'..r.branch..']'))
    table.print(r.commits)
    table.print(r.status)
  end
  print()
end

local commands = utils.parse_commands(arg)

if commands.list then
  list(scanlist)
else
  main()
end
