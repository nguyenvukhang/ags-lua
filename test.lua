Set = {}
Set.mt = {}

function Set.new (t)   -- 2nd version
  local set = {}
  setmetatable(set, Set.mt)
  for _, l in ipairs(t) do set[l] = true end
  return set
end

function Set.union (a,b)
  local res = Set.new{}
  for k in pairs(a) do res[k] = true end
  for k in pairs(b) do res[k] = true end
  return res
end

function Set.intersection (a,b)
  local res = Set.new{}
  for k in pairs(a) do
    res[k] = b[k]
  end
  return res
end

function Set.tostring (set)
  local s = "{"
  local sep = ""
  for e in pairs(set) do
    s = s .. sep .. e
    sep = ", "
  end
  return s .. "}"
end

function Set.print (s)
  print(Set.tostring(s))
end

local s1 = Set.new{10, 20, 30, 50}
local s2 = Set.new{30, 1}
print(getmetatable(s1))
print(getmetatable(s2))

Set.print(s1)
