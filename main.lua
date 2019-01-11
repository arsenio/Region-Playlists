-- Test

local r = reaper

local root = ({r.get_action_context()})[2]:match("^(.*[/\\])")

local manager = assert(loadfile(root .. "PlaylistManager.lua"))

function init()
end

manager()

-- r.ShowMessageBox("Hit OK to continue.", "Region Playlists", 0)
