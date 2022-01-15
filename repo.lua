local git = require('git')
local Repo = {}
Repo.mt = {}

function Repo.new (dir)   -- 2nd version
  local repo = {}
  setmetatable(repo, Repo.mt)
  repo.branch = git.branch(dir)
  repo.remote = git.remote(dir)
  repo.commits = git.commits(dir)
  repo.status = git.status(dir)
  repo.dir = dir
  return repo
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

return Repo
