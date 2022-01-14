local utils = {}

-- checks if a file exists
utils.exists = function (file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      -- Permission denied, but it exists
      return true
    end
  end
  -- return ok, err
  return ok
end

return utils
