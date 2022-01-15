local colors = {}

colors.red    = function(t) return '\27[31m'..t..'\27[0m' end
colors.green  = function(t) return '\27[32m'..t..'\27[0m' end
colors.yellow = function(t) return '\27[33m'..t..'\27[0m' end
colors.blue   = function(t) return '\27[34m'..t..'\27[0m' end
colors.purple = function(t) return '\27[35m'..t..'\27[0m' end
colors.cyan   = function(t) return '\27[36m'..t..'\27[0m' end
colors.gray   = function(t) return '\27[37m'..t..'\27[0m' end

return colors
