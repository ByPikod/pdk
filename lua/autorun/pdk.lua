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

local pi = pi
local AddCSLuaFile = AddCSLuaFile
local xpcall = xpcall
local print = print

--- @module util
--- Pretty useful set of helper functions.
pi.util = pi.util or {}

pi.version = 2

--- Load the library.
--- @return nil
function pi.Load()

    print("PDK is loading...")

    AddCSLuaFile( "pdk_core/utils/include.lua" )
    include( "pdk_core/utils/include.lua" )
    
    -- Util
    pi.util.Include( "pdk_core/utils/logs.lua" )
    pi.util.Include( "pdk_core/utils/profiler.lua" )

    -- Pi Plugin Manager
    pi.util.Include( "pdk_core/pip/pip.lua" )
    pi.util.Include( "pdk_core/pip/utils.lua" )

    -- Pi Meta Table Utils
    pi.util.Include( "pdk_core/meta/entity/bones.lua" )
    pi.util.Include( "pdk_core/meta/player/lockweapon.lua" )
    pi.util.Include( "pdk_core/meta/player/ignorekeys.lua" )

    pi.print( "Library activated.")

    -- Plugins
    pi.print( "Plugins are loading..." )

    pi.util.IncludeDir( "pdk", true, 

        -- Include Files
        function( root, file, level )
            
            -- Not include if directory level is not 1 or file's name is not plugin.
            if level ~= 1 or file:lower() ~= "plugin.lua" then
                return true
            end
            
            -- Include file without getting stuck in prefix rule
            xpcall( 
                pi.util.Include,
                function( err )
                    pi.print( "An error has ocurred while plugin file including: "..file, pi.LOG_ERROR )
                    print( err )
                end,
                root .. "/" .. file 
            )

            return true -- Include cancelled (because we already included).

        end,
        function( root, directory, level )

            if level > 1 then
                return true
            end

        end 

    )

    pi.print( "Plugins are loaded." )

end

pi.Load()