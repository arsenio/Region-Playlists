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
  if util.is_empty(selected) then
    return
  end

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

      GUI.Val("PlaylistSelector", selected)
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

    reaper.SetProjExtState(project, ext, "selected", "")
    GUI.Val("PlaylistSelector", 1)
    update_playlists()
    update_items()
  end
end

function handlers.item_select(selected)
  if util.is_empty(selected) then
    return
  end

  selected = tonumber(selected)
  if selected then
    GUI.elms.ItemDelete:enable()
    list = GUI.elms.Items.list
    if selected == 1 then
      GUI.elms.ItemUp:disable()
      GUI.elms.ItemDown:enable()
    elseif selected == #list then
      GUI.elms.ItemUp:enable()
      GUI.elms.ItemDown:disable()
    else
      GUI.elms.ItemUp:enable()
      GUI.elms.ItemDown:enable()
    end
    return
  end

  GUI.elms.ItemDelete:disable()
  GUI.elms.ItemUp:disable()
  GUI.elms.ItemDown:disable()
end

function handlers.item_up()
  retval, str_value = reaper.GetProjExtState(project, ext, playlist_id .. "_items")
  local items = {}
  if not util.is_empty(str_value) then
    items = util.split(str_value, ",")
  end

  local selected = GUI.Val("Items")
  if selected > 1 then
    local label = GUI.elms.Items.list[selected]
    table.remove(GUI.elms.Items.list, selected)

    local value = items[selected]
    table.remove(items, selected)

    selected = selected - 1
    table.insert(GUI.elms.Items.list, selected, label)
    table.insert(items, selected, value)
    reaper.SetProjExtState(project, ext, playlist_id .. "_items", table.concat(items, ","))

    handlers._items_reselect(selected)
  end
end

function handlers.item_down()
  retval, str_value = reaper.GetProjExtState(project, ext, playlist_id .. "_items")
  local items = {}
  if not util.is_empty(str_value) then
    items = util.split(str_value, ",")
  end

  local selected = GUI.Val("Items")
  if selected < #list then
    local label = GUI.elms.Items.list[selected]
    table.remove(GUI.elms.Items.list, selected)

    local value = items[selected]
    table.remove(items, selected)

    selected = selected + 1
    table.insert(GUI.elms.Items.list, selected, label)
    table.insert(items, selected, value)
    reaper.SetProjExtState(project, ext, playlist_id .. "_items", table.concat(items, ","))

    handlers._items_reselect(selected)
  end
end

function handlers._items_reselect(selected)
  local new_selection = util.fill_table(false, #GUI.elms.Items.list)
  new_selection[selected] = true
  GUI.Val("Items", new_selection)

  if selected == 1 then
    GUI.elms.ItemUp:disable()
    GUI.elms.ItemDown:enable()
  elseif selected == #GUI.elms.Items.list then
    GUI.elms.ItemUp:enable()
    GUI.elms.ItemDown:disable()
  else
    GUI.elms.ItemUp:enable()
    GUI.elms.ItemDown:enable()
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
  engaged = true
  play_state = reaper.GetPlayState()
  if play_state == 1 then -- "Playing"
    GUI.elms.Play.caption = "Play"
    reaper.CSurf_OnPause()
    return
  end

  if play_state == 2 then -- "Paused"
    GUI.elms.Play.caption = "Play"
    retval, str_value = reaper.GetProjExtState(project, ext, playlist_id .. "_items")
    if not util.is_empty(str_value) then
      local items = util.split(str_value, ",")
      local place = 1
      local selected = GUI.Val("Items")
      if selected then
        place = selected
      end
      if place <= #items then
        reaper.CSurf_OnPlay()
        GUI.elms.Play.caption = "Pause"
      else
        reaper.CSurf_OnStop()
        engaged = false
        bools = util.fill_table(false, #items)
        selected = GUI.Val("Items", bools)
      end
    end
  end

  if play_state == 0 then -- "Stopped"
    GUI.elms.Play.caption = "Pause"
    retval, str_value = reaper.GetProjExtState(project, ext, playlist_id .. "_items")
    if not util.is_empty(str_value) then
      local items = util.split(str_value, ",")
      local index = 1
      local selected = GUI.Val("Items")
      if selected then
        index = selected
      end
      if items[index] == "P" then
        reaper.CSurf_OnPause()
        index = index + 1
        if #items >= index then
          reaper.GoToRegion(project, items[index], false)
        end
      else
        reaper.GoToRegion(project, items[index], false)
        reaper.CSurf_OnPlay()
      end
      bools = util.fill_table(false, #items)
      bools[index] = true
      selected = GUI.Val("Items", bools)
      return
    end
  end
end

function handlers.stop()
  engaged = false
  GUI.elms.Play.caption = "Play"
  reaper.CSurf_OnStop()

  retval, str_value = reaper.GetProjExtState(project, ext, playlist_id .. "_items")
  if not util.is_empty(str_value) then
    local items = util.split(str_value, ",")
    if items[1] ~= "P" then
      reaper.GoToRegion(project, items[1], false)
    end
    bools = util.fill_table(false, #items)
    selected = GUI.Val("Items", bools)
    return
  end
end

return handlers
