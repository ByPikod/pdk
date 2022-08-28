--[[

  ____________________________
 |  _____ _ _             _  |
 | |  __ (_) |           | | |
 | | |__) || | _____   __| | |
 | |  ___/ | |/ / _ \ / _  | |
 | | |   | |   | (_) | (_| | |
 | |_|   |_|_|\_\___/ \____| |
 |___________________________|

]]--
AddCSLuaFile()

--- Pi library namespace
--- @module pi
pi = pi or {}

--- @module util
--- Pretty useful set of helper functions.
pi.util = pi.util or {}

pi.version = "1.0.0"

--- Load the library.
--- @return void
function pi.Load()

    AddCSLuaFile("pdk_core/utils/include.lua")
    include("pdk_core/utils/include.lua")

    -- Util
    pi.util.Include("pdk_core/utils/logs.lua")
    pi.util.Include("pdk_core/utils/profiler.lua")
    pi.util.IncludeServer("pdk_core/utils/database.lua")

    -- Pi Plugin Manager
    pi.util.Include("pdk_core/pip/pip.lua")
    pi.util.Include("pdk_core/pip/utils.lua")

    pi.print("Library activated.")

end

pi.Load()