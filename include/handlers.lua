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
  if selected and not util.is_empty(util.trim(GUI.elms.PlaylistSelector.optarray[GUI.Val("PlaylistSelector")])) then
    GUI.elms.PlaylistDelete:enable()
    GUI.elms.ItemAdd:enable()
    GUI.elms.ItemDelete:disable()
    GUI.elms.ItemUp:disable()
    GUI.elms.ItemDown:disable()
  else
    GUI.elms.PlaylistDelete:disable()
    GUI.elms.ItemAdd:disable()
    GUI.elms.ItemDelete:disable()
    GUI.elms.ItemUp:disable()
    GUI.elms.ItemDown:disable()
  end
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
  GUI.elms.PlaylistSelector:init()
  GUI.elms.PlaylistSelector:redraw()
  handlers.select(#playlists)
  update_playlists()
end

function handlers.delete(selected)
  local playlists = {}
  retval, str_value = reaper.GetProjExtState(project, ext, "playlists")
  if not util.is_empty(str_value) then
    playlists = util.split(str_value, ",")
  end

  id = table.remove(playlists, selected)
  if not util.is_empty(id) then
    reaper.SetProjExtState(project, ext, id .. "_name", "")
    if #playlists then
      reaper.SetProjExtState(project, ext, "playlists", table.concat(playlists, ","))
    else
      reaper.SetProjExtState(project, ext, "playlists", "")
    end

--    reaper.SetProjExtState(project, ext, "selected", "")
    GUI.Val("PlaylistSelector", 1)
    update_playlists()
  end
end

function handlers.add()
  local options = "Add a pause|"
  local regions = {}
  local marker_count = reaper.CountProjectMarkers(0)
  for index=0, marker_count - 1 do
    local retval, is_region, start, stop, name, region_id = reaper.EnumProjectMarkers(index)
    if is_region then
      name = util.trim(name:gsub(",", "，")) -- See comma comment in gui.lua
      table.insert(regions, name)
    end
  end
  for index,region in ipairs(regions) do
    options = options .. "|" .. region
  end

  local selected = gfx.showmenu(options)
  if selected then
    list = GUI.elms.Items.list
    selected = math.floor(selected)
    if selected == 1 then
      table.insert(list, "-- Pause --")
    else
      table.insert(list, regions[selected - 1]) -- offset due to "Pause"
    end
    GUI.elms.Items.list = list
    GUI.elms.Items:init()
    GUI.elms.Items:redraw()
  end
end

function handlers.play()
  play_state = reaper.GetPlayState()
  if play_state == 1 then -- "Playing"
    GUI.elms.Play.caption = "Play"
    reaper.CSurf_OnPause()
    return
  end

  if play_state == 0 then -- "Stopped"
    reaper.GoToRegion(project, 1, false)
  end

  GUI.elms.Play.caption = "Pause"
  reaper.CSurf_OnPlay()
end

function handlers.stop()
  GUI.elms.Play.caption = "Play"
  reaper.CSurf_OnStop()
end

return handlers
