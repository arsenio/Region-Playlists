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

function util.fill_table(val, count)
  local list = {}
  for i=1, count do
    table.insert(list, val)
  end
  return list
end

function util.find(haystack, needle)
  local winner = 0
  for index,val in ipairs(haystack) do
    if val == needle then
      winner = index
      break
    end
  end
  return winner
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
