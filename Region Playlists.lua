--[[
Region Playlists

Arsenio Santos
https://github.com/arsenio/Region-Playlists
]]--

local root = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local util = require(root .. "include.util")
local handlers = require(root .. "include.handlers")

ext = "Region Playlists"
selected_id = nil
regions = {}

-- Get a handle on the current project
project = reaper.EnumProjects(-1, "")

function debug_reset()
  keys = {}
  idx = 0
  retval = true
  repeat
    retval, key, val = reaper.EnumProjExtState(project, ext, idx)
    if not util.is_empty(key) then
      table.insert(keys, key)
    end
    idx = idx + 1
  until not retval
  for index,key in ipairs(keys) do
    reaper.SetProjExtState(project, ext, key, "")
  end
end
-- debug_reset()

function update_playlists()
  local playlists = {}
  retval, str_value = reaper.GetProjExtState(project, ext, "playlists")

  if not util.is_empty(str_value) then
    playlist_ids = util.split(str_value, ",")
    for index,id in ipairs(playlist_ids) do
      if not util.is_empty(id) then
        retval, name = reaper.GetProjExtState(project, ext, id .. "_name")
        if retval then
          table.insert(playlists, name)
        end
      end
    end
  end

  if #playlists > 0 then
    GUI.elms.PlaylistSelector.optarray = playlists
  else
    GUI.elms.PlaylistSelector.opts = ""
  end

  retval, str_value = reaper.GetProjExtState(project, ext, "selected")
  if util.is_empty(str_value) then
    GUI.Val("PlaylistSelector", -1)
    GUI.elms_hide[GUI.elms.PlaylistDelete.z] = true
  else
    selected = tonumber(str_value)
    GUI.Val("PlaylistSelector", selected)
    GUI.elms_hide[GUI.elms.PlaylistDelete.z] = false
  end
end

local manager = assert(loadfile(root .. "include/gui.lua"))
manager(handlers.select, handlers.new, handlers.delete,
        handlers.play, handlers.stop)
update_playlists()
