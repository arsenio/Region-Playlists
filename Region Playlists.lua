--[[
Region Playlists

Arsenio Santos
https://github.com/arsenio/Region-Playlists
]]--

ext = "Region Playlists"
regions = {}
playlist_id = "foo"

local root = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local util = require(root .. "include.util")
local handlers = require(root .. "include.handlers")

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
    local playlist_ids = util.split(str_value, ",")
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
    GUI.elms.PlaylistSelector.optarray = {" "}
  end
  GUI.elms.PlaylistSelector:draw()

  retval, str_value = reaper.GetProjExtState(project, ext, "selected")
  handlers.playlist_select(str_value)
--[[
  if util.is_empty(str_value) then
    GUI.Val("PlaylistSelector", 1)
    GUI.elms.PlaylistDelete:disable()
  else
    selected = tonumber(str_value)
    GUI.Val("PlaylistSelector", selected)
    GUI.elms.PlaylistDelete:enable()
  end
--]]
  GUI.elms.PlaylistSelector:init()
  GUI.elms.PlaylistSelector:redraw()
end

function update_items()
  if not playlist_id then
    return
  end

  retval, str_value = reaper.GetProjExtState(project, ext, playlist_id .. "_items")
  local items = {}
  if not util.is_empty(str_value) then
    items = util.split(str_value, ",")
  end

  local regions = {}
  local marker_count = reaper.CountProjectMarkers(project)
  for index=0, marker_count - 1 do
    local retval, is_region, start, stop, name, region_id = reaper.EnumProjectMarkers(index)
    if is_region then
      name = util.trim(name:gsub(",", "，")) -- See comma comment in gui.lua
      regions[region_id] = name
    end
  end

  local list = {}
  for index,item_id in pairs(items) do
    if item_id == "P" then
      table.insert(list, "-- Pause --")
    else
      local item = "-- Unknown region --"
      local region = regions[tonumber(item_id)]
      if region then
        item = region
      end
      table.insert(list, region)
    end
  end
  GUI.elms.Items.list = list
  GUI.elms.Items:init()
  GUI.elms.Items:redraw()
end

local manager = assert(loadfile(root .. "include/gui.lua"))
manager(handlers.playlist_select, handlers.playlist_new, handlers.playlist_delete,
        handlers.item_add, handlers.item_delete,
        handlers.play, handlers.stop)
update_playlists()
update_items()
