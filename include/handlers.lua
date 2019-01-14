--[[
Handlers for Region Playlists

Arsenio Santos
https://github.com/arsenio/Region-Playlists
]]--

local handlers = {}

local root = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local util = require(root .. "include.util")

ext = "Region Playlists"
regions = {}

function handlers.select(selected)
  reaper.SetProjExtState(project, ext, "selected", selected)
end

function handlers.new(name)
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

function handlers.delete(selected)
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

function handlers.play()
  play_state = reaper.GetPlayState()
  if play_state == 1 then -- "Playing"
    GUI.elms.Play.caption = "Play"
    reaper.CSurf_OnPause()
    return
  end

  last_region_index = 1
  regions = {}
  local marker_count = reaper.CountProjectMarkers(0)
  for index=0, marker_count - 1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(index)
    if isrgn then
      last_region_index = markrgnindexnumber
      table.insert(regions, name .. " (" .. pos .. " -> " .. rgnend .. ")")
    end
  end

  if play_state == 0 then -- "Stopped"
    reaper.GoToRegion(project, last_region_index, false)
  end

  GUI.elms.Play.caption = "Pause"
  reaper.CSurf_OnPlay()
end

function handlers.stop()
  GUI.elms.Play.caption = "Play"
  reaper.CSurf_OnStop()
end

return handlers
