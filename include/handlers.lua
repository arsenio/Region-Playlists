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

function handlers.playlist_select(selected)
  selected = tonumber(selected)
  playlist_id = nil
  reaper.SetProjExtState(project, ext, "selected", selected)
  if selected then
    local playlist_name = util.trim(GUI.elms.PlaylistSelector.optarray[GUI.Val("PlaylistSelector")])
    if not util.is_empty(playlist_name) then
      retval, str_value = reaper.GetProjExtState(project, ext, "playlists")
      if not util.is_empty(str_value) then
        local playlist_ids = util.split(str_value, ",")
        playlist_id = playlist_ids[selected]
      end

      GUI.elms.PlaylistDelete:enable()
      GUI.elms.ItemAdd:enable()
      GUI.elms.ItemDelete:disable()
      GUI.elms.ItemUp:disable()
      GUI.elms.ItemDown:disable()
      update_items()
      return
    end
  end

  GUI.elms.PlaylistDelete:disable()
  GUI.elms.ItemAdd:disable()
  GUI.elms.ItemDelete:disable()
  GUI.elms.ItemUp:disable()
  GUI.elms.ItemDown:disable()
  update_items()
end

function handlers.playlist_new(name)
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
  handlers.playlist_select(#playlists)
  update_playlists()
  update_items()
end

function handlers.playlist_delete(selected)
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
    update_items()
  end
end

function handlers.item_add()
  local options = "Add a pause|"
  local regions = {}
  local ids = {}
  local marker_count = reaper.CountProjectMarkers(project)
  for index=0, marker_count - 1 do
    local retval, is_region, start, stop, name, region_id = reaper.EnumProjectMarkers(index)
    if is_region then
      name = util.trim(name:gsub(",", "，")) -- See comma comment in gui.lua
      table.insert(regions, name)
      table.insert(ids, region_id)
    end
  end
  for index,region in ipairs(regions) do
    options = options .. "|" .. region
  end

  local selected = gfx.showmenu(options)
  if selected then
    retval, str_value = reaper.GetProjExtState(project, ext, playlist_id .. "_items")
    local items = {}
    if not util.is_empty(str_value) then
      items = util.split(str_value, ",")
    end

    list = GUI.elms.Items.list
    selected = math.floor(selected)
    if selected == 1 then
      table.insert(list, "-- Pause --")
      table.insert(items, "P")
    else
      table.insert(list, regions[selected - 1]) -- offset due to "Pause"
      table.insert(items, ids[selected - 1]) -- offset due to "Pause"
    end

    reaper.SetProjExtState(project, ext, playlist_id .. "_items", table.concat(items, ","))
    GUI.elms.Items.list = list
    GUI.elms.Items:init()
    GUI.elms.Items:redraw()
    update_items()
  end
end

function handlers.item_delete(selected)
  retval, str_value = reaper.GetProjExtState(project, ext, playlist_id .. "_items")
  if not util.is_empty(str_value) then
    local old_items = util.split(str_value, ",")
    local old_list = GUI.elms.Items.list
    local new_items = {}
    local new_list = {}
    local falses = {}
    for index,item in ipairs(old_list) do
      if index ~= selected then
        table.insert(new_list, item)
        table.insert(new_items, old_items[index])
        table.insert(falses, false)
      end
    end

    reaper.SetProjExtState(project, ext, playlist_id .. "_items", table.concat(new_items, ","))
    GUI.elms.Items.list = new_list
    GUI.Val("Items", falses)
    GUI.elms.Items:init()
    GUI.elms.Items:redraw()
    GUI.elms.ItemDelete:disable()
    update_items()
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
