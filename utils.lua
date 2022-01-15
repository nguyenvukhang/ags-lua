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

return utils
