local pi = pi
local include = include
local AddCSLuaFile = AddCSLuaFile
local file = file
local string = string
local ipairs = ipairs

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
--- The realm which files will be included to is decided by their name.
--- Prefix "cl_" for client files, "sv_" for server files and "sh_" for shared files.
--- Directory/File will be skipped if releated callback returns True.
--- @param directory string Directory path to include.
--- @param recursive boolean Should include sub directories too ? If false, shouldSkipDirectory will never be called.
--- @param shouldSkipFile function If set, callback will be called for each file. If callback returns true, the directory will be skipped. It takes three arguments: shouldSkipFile( root, file, directoryLevel )
--- @param shouldSkipDirectory function If set, callback will be called for each directory. If callback returns true, the file will be skipped. It takes three arguments: shouldSkipDirectory( root, directory, directoryLevel )
--- @param directoryLevel number This is the repeat counter for recursive function. It will increase every time this function called itself.
--- @return nil
function pi.util.IncludeDir( directory, recursive, shouldSkipFile, shouldSkipDirectory, directoryLevel )
    
    -- Set directory level if not set.
    directoryLevel = directoryLevel or 0 

    -- List the files.
    local files, directories = file.Find( directory .. "/*", "LUA" )

    for _, v in ipairs( files ) do

        if string.EndsWith( v, ".lua" ) then


            if shouldSkipFile and shouldSkipFile( directory, v, directoryLevel ) then goto skip_file end

            local prefix = string.lower( string.Left( v, 3 ) ):lower()
            local file_name = directory .. "/" .. v

            if prefix == "sv_" then
                pi.util.IncludeServer( file_name )
            elseif prefix == "cl_" then
                pi.util.IncludeClient( file_name )
            elseif prefix == "sh_" then
                pi.util.Include( file_name )
            end

            ::skip_file::

        end

    end

    if not recursive then return end
    
    directoryLevel = directoryLevel + 1 -- Increase one
    for _, v in ipairs( directories ) do

        -- Call the callback function
        if shouldSkipDirectory and shouldSkipDirectory( directory, v, directoryLevel ) then goto skip_folder end
        
        pi.util.IncludeDir( directory .. "/" .. v, true, shouldSkipFile, shouldSkipDirectory, directoryLevel )

        ::skip_folder::

    end

end