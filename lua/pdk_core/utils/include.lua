local pi = pi
local include = include
local AddCSLuaFile = AddCSLuaFile
local file = file

if SERVER then

    --- Include a file to the client side.
    --- @param fileName string The name of the script to be executed.
    --- @return any Returns anything that the executed Lua script returns in CLIENT side. Return nothing in server side.
    pi.util.IncludeClient = AddCSLuaFile

    --- Include a file to the server side.
    --- @param fileName string The name of the script to be executed.
    --- @return any Anything that the executed Lua script returns.
    pi.util.IncludeServer = include

    --- Include a file to both server side and client side.
    --- @param fileName string The name of the script to be executed.
    --- @return any Anything that the executed Lua script returns.
    function pi.util.Include( fileName )
        AddCSLuaFile( fileName )
        return include( fileName )
    end

elseif CLIENT then

    pi.util.IncludeServer = function() end
    pi.util.IncludeClient = include
    pi.util.Include = include

end

--- Include the files in a specific directory.
--- @param directory string Directory path to include.
--- @param recursive boolean Should include sub directories too ?
--- @return void
function pi.util.IncludeDir( directory, recursive )

    directory = directory .. "/"

    local files, directories = file.Find( directory .. "*", "LUA" )

    for _, v in ipairs( files ) do

        if string.EndsWith( v, ".lua" ) then

            local file = directory .. v

            local prefix = string.lower( string.Left( File, 3 ) ):lower()

            if prefix == "sv_" then
                pi.util.IncludeServer( file )
            elseif prefix == "cl_" then
                pi.util.IncludeClient( file )
            elseif prefix == "sh_" then
                pi.util.Include( file )
            end

        end

    end

    if not recursive then return end
    for _, v in ipairs( directories ) do
        pi.util.IncludeDir( directory .. v )
    end

end