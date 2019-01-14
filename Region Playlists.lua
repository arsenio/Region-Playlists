--[[
Region Playlists

Arsenio Santos
https://github.com/arsenio/Region-Playlists
]]--

local root = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local util = require(root .. "include.util")

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

function handler_select(selected)
  reaper.SetProjExtState(project, ext, "selected", selected)

--[[
  local marker_count = reaper.CountProjectMarkers(0)
  for index=0, marker_count - 1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(index)
    if isrgn then
    end
  end
]]--
end

function handler_new(name)
  local id = util.uuid()
  reaper.SetProjExtState(project, ext, id .. "_name", name)

  local playlists = {}
  retval, str_value = reaper.GetProjExtState(project, ext, "playlists")
  if retval then
    for index,old_id in ipairs(util.split(str_value, ",")) do
      if not util.is_empty(old_id) then
        table.insert(playlists, old_id)
      end
    end
  end
  table.insert(playlists, id)
  reaper.SetProjExtState(project, ext, "playlists", table.concat(playlists, ","))

  GUI.Val("PlaylistSelector", #playlists)
  reaper.SetProjExtState(project, ext, "selected", #playlists)
  update_playlists()
end

function handler_delete(selected)
  local playlists = {}
  retval, str_value = reaper.GetProjExtState(project, ext, "playlists")
  if not util.is_empty(str_value) then
reaper.ShowConsoleMsg("Stored playlists = " .. str_value .. "\n")
    playlists = util.split(str_value, ",")
reaper.ShowConsoleMsg("Removing " .. selected .. " from " .. table.concat(playlists, ",")  .. "\n")
  end

  id = table.remove(playlists, selected)
  if not util.is_empty(id) then
    reaper.SetProjExtState(project, ext, id .. "_name", "")
    reaper.SetProjExtState(project, ext, "playlists", table.concat(playlists, ","))

    GUI.Val("PlaylistSelector", -1)
    reaper.SetProjExtState(project, ext, "selected", "")

    update_playlists()
  end
end

local manager = assert(loadfile(root .. "include/gui.lua"))
manager(handler_select, handler_new, handler_delete)
update_playlists()
