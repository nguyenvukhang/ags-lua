local git = require('git')
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

return Repo
