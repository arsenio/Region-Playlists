-- Script bootstrapped by Lokasenna's GUI Builder

local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()


--[[
    *********************
    * Insert Code here! *
    *********************    
]]--


GUI.req("Classes/Class - Menubox.lua")()
GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Listbox.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end


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
    optarray = {},
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

GUI.New("PlaylistNew", "Button", {
    z = 11,
    x = 466,
    y = 8,
    w = 48,
    h = 24,
    caption = "New",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame"
})

GUI.New("PlaylistDelete", "Button", {
    z = 11,
    x = 530,
    y = 8,
    w = 48,
    h = 24,
    caption = "Delete",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame"
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

GUI.New("Play", "Button", {
    z = 11,
    x = 98,
    y = 310,
    w = 170,
    h = 30,
    caption = "Play",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame"
})

GUI.New("PauseStop", "Button", {
    z = 11,
    x = 278,
    y = 310,
    w = 170,
    h = 30,
    caption = "Stop",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame"
})

GUI.Init()
GUI.Main()
