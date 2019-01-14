--[[
GUI for Region Playlists

Arsenio Santos
Bootstrapped by Lokasenna's GUI Builder
https://github.com/arsenio/Region-Playlists
]]--

local root = ({reaper.get_action_context()})[2]:match("^(.*[/\\])")
local util = require(root .. "include.util")

local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
  reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
  return
end
loadfile(lib_path .. "Core.lua")()

local handler_select, handler_new, handler_delete,
      handler_play, handler_stop = ...


GUI.req("Classes/Class - Menubox.lua")()
GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Listbox.lua")()
GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Window.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end


-- Let's add generic enable and disable methods to buttons
function GUI.Button:enable()
  self.col_txt = "txt"
  self.col_fill = "elm_frame"
  GUI.elms_freeze[self.z] = false
  self:init()
  self:redraw()
end
function GUI.Button:disable()
  self.col_txt = "elm_frame"
  self.col_fill = "wnd_bg"
  GUI.elms_freeze[self.z] = true
  self:init()
  self:redraw()
end

-- And now, our actual GUI
GUI.name = "Region Playlists"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 600, 400
GUI.anchor, GUI.corner = "mouse", "C"

GUI.New("PlaylistSelector", "Menubox", {
  z = 11,
  x = 98,
  y = 10,
  w = 350,
  h = 20,
  caption = "Current Playlist ",
  opts = "",
  retval = 1,
  font_a = 3,
  font_b = 4,
  col_txt = "txt",
  col_cap = "txt",
  bg = "wnd_bg",
  pad = 4,
  noarrow = false,
  align = 0
})

function GUI.elms.PlaylistSelector:onmouseup()
  GUI.Menubox.onmouseup(self)
  selected = GUI.Val("PlaylistSelector")
  if selected then
    val = util.trim(GUI.elms.PlaylistSelector.optarray[selected])
    if util.is_empty(val) then
      GUI.elms.PlaylistDelete:disable()
    else
      GUI.elms.PlaylistDelete:enable()
    end
    handler_select(selected)
  end
end

GUI.New("PlaylistNew", "Button", {
  z = 11,
  x = 466,
  y = 8,
  w = 48,
  h = 24,
  caption = "New",
  font = 3,
  col_txt = "txt",
  col_fill = "elm_frame",
  func = function()
    local name = ""
    retval, name = reaper.GetUserInputs("New playlist", 1, "Playlist name,extrawidth=250", "")
    if retval then
      name = util.trim(name:gsub(",", " "))
      if not util.is_empty(name) then
        handler_new(name)
      end
    end
  end
})

GUI.New("PlaylistDelete", "Button", {
  z = 12,
  x = 530,
  y = 8,
  w = 48,
  h = 24,
  caption = "Delete",
  font = 3,
  col_txt = "elm_frame",
  col_fill = "wnd_bg",
  func = function()
    selected = GUI.Val("PlaylistSelector")
    handler_delete(selected)
  end
})

GUI.New("Items", "Listbox", {
  z = 11,
  x = 98,
  y = 44,
  w = 350,
  h = 250,
  list = {},
  multi = false,
  caption = "Items ",
  font_a = 3,
  font_b = 4,
  color = "txt",
  col_fill = "elm_fill",
  bg = "elm_bg",
  cap_bg = "wnd_bg",
  shadow = true,
  pad = 4
})

GUI.New("ItemAdd", "Button", {
  z = 13,
  x = 466,
  y = 268,
  w = 48,
  h = 24,
  caption = "Add",
  font = 3,
  col_txt = "elm_frame",
  col_fill = "wnd_bg"
})

GUI.New("ItemDelete", "Button", {
  z = 14,
  x = 530,
  y = 268,
  w = 48,
  h = 24,
  caption = "Delete",
  font = 3,
  col_txt = "elm_frame",
  col_fill = "wnd_bg"
})

GUI.New("ItemUp", "Button", {
  z = 14,
  x = 466,
  y = 140,
  w = 24,
  h = 24,
  caption = "↑",
  font = 3,
  col_txt = "elm_frame",
  col_fill = "wnd_bg"
})
GUI.New("ItemDown", "Button", {
  z = 14,
  x = 466,
  y = 174,
  w = 24,
  h = 24,
  caption = "↓",
  font = 3,
  col_txt = "elm_frame",
  col_fill = "wnd_bg"
})

GUI.New("Play", "Button", {
  z = 11,
  x = 98,
  y = 310,
  w = 170,
  h = 30,
  caption = "Play",
  font = 2,
  col_txt = "txt",
  col_fill = "elm_frame",
  func = handler_play
})

GUI.New("Stop", "Button", {
  z = 11,
  x = 278,
  y = 310,
  w = 170,
  h = 30,
  caption = "Stop",
  font = 2,
  col_txt = "txt",
  col_fill = "elm_frame",
  func = handler_stop
})

GUI.Init()
GUI.Main()
-- reaper.defer(Main)
