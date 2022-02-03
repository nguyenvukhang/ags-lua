#!/usr/bin/env lua

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

return utils
