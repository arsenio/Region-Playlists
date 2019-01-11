-- Test

local r = reaper

local root = ({r.get_action_context()})[2]:match("^(.*[/\\])")

local manager = assert(loadfile(root .. "include/gui.lua"))

function init()
end

manager()
