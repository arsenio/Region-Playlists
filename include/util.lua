--[[
Utility methods for use elsewhere

Arsenio Santos
https://github.com/arsenio/Region-Playlists
]]--

math.randomseed(os.time())

local util = {}

function util.is_empty(s)
  return (not s or s == "")
end

function util.trim(s)
  if util.is_empty(s) then
    return ""
  end
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function util.split(s, delim)
  result = {}

  if s then
    for match in (s..delim):gmatch("(.-)"..delim) do
      table.insert(result, match)
    end
  end

  return result
end

function util.uuid()
    local random = math.random

    local template ='yyyyxxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%X', v)
    end)
end

return util
