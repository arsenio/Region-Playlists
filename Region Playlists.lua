--[[
Region Playlists

Arsenio Santos
https://github.com/arsenio/Region-Playlists
]]--

ext = "Region Playlists"
regions = {}
starts = {}
stops = {}
playlist_id = nil
engaged = false
crossfade = 0.10

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

  regions = {}
  local marker_count = reaper.CountProjectMarkers(project)
  for index=0, marker_count - 1 do
    local retval, is_region, start, stop, name, region_id = reaper.EnumProjectMarkers(index)
    if is_region then
      name = util.trim(name:gsub(",", "，")) -- See comma comment in gui.lua
      regions[region_id] = name
      starts[region_id] = start
      stops[region_id] = stop
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
manager(handlers)
update_playlists()
update_items()
reaper.CSurf_OnStop()

--[[
poller() is the function that continuously checks the playhead, and moves
it according to the playlist
]]--
local function poller()
  play_state = reaper.GetPlayState()
  if engaged then
    GUI.elms.Items:disable()
    -- If playing and engaged, find out if we're crossing a region stop
    if play_state == 1 then -- "Playing"
      local pos = reaper.GetPlayPosition()
      local best_region = 0
      for index,stop in pairs(stops) do
        local start = starts[index]
        local delta = stop - pos
        if delta > 0 and delta <= crossfade then
          best_region = index
          break
        end
      end

      -- If crossing a region stop, see if that region is in the playlist.
      -- If so, jump to the next region in the playlist or stop.
      if best_region ~= 0 then
        retval, str_value = reaper.GetProjExtState(project, ext, playlist_id .. "_items")
        local items = {}
        if not util.is_empty(str_value) then
          items = util.split(str_value, ",")
          local place = util.find(items, tostring(best_region))
          if place then
            if place + 1 <= #items then
              is_ready = false
              -- Iterating over the place var allows for multiple pauses
              -- in a row (not that you'd want to do that for any earthly
              -- reason). It also makes pause act like ffwd-and-pause.
              while not is_ready do
                place = place + 1
                if place <= #items then
                  if items[place] == "P" then
                    if reaper.GetPlayState() == 1 then
                      reaper.CSurf_OnPause()
                      GUI.elms.Play.caption = "Play"
                      GUI.elms.Play:redraw()
                    end
                  else
                    reaper.GoToRegion(project, items[place], false)
                    if reaper.GetPlayState() ~= 2 then
                      GUI.elms.Play.caption = "Pause"
                      GUI.elms.Play:redraw()
                    end
                    is_ready = true
                  end
                else
                  place = #items
                  is_ready = true
                end
              end
              bools = util.fill_table(false, #items)
              bools[place] = true
              selected = GUI.Val("Items", bools)
            else
              reaper.CSurf_OnStop()
              engaged = false
              GUI.elms.Play.caption = "Play"
              GUI.elms.Play:redraw()
              bools = util.fill_table(false, #items)
              selected = GUI.Val("Items", bools)
            end
          end
        end
      end
    end
  else
    GUI.elms.Items:enable()
  end
end

GUI.func = poller
GUI.freq = 0
