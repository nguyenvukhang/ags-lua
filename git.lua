local u = require('utils')

local git = {}

local cmd_get_table = function (cmd)
  local r = os.capture(cmd, true)
  if r == nil or r == '' then
    return nil
  else
    return u.split(r, '\n\r')
  end
end

git.status = function (dir)
  return cmd_get_table("git -C "..dir.." status -s")
end

git.commits = function (dir)
  return cmd_get_table("git -C "..dir.." cherry -v --abbrev")
end

return git
