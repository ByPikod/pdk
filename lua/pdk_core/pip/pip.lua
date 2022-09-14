local pi = pi
local setmetatable = setmetatable
local table = table
local error = error
local ipairs = ipairs
local resource = resource

local registry = debug.getregistry()


registry.PIP = registry.PIP or {}
pi.plugin = pi.plugin or {}
pi.plugin._plugins = pi.plugin._plugins or {}

--- Plugin base
local meta = FindMetaTable("PIP")

--- Register your plugin table.
--- @param object table Plugin table.
--- @return table Plugin table
function pi.plugin:Register( object )

    self = self or pi.plugin

    if not object.Name then
        error( "An error has occurred while registering plugin: Plugin table have no \"Name\" field." )
    end

    if not object.Description then
        error( "An error has occurred while registering plugin: Plugin table have no \"Run\" callback." )
    end

    setmetatable( object, meta )
    meta.__index = meta

    table.insert( self._plugins, object )
    
    if object.Assets then
        
        for _, v in ipairs( object.Assets ) do
            resource.AddFile( v )
        end

    end

    return object

end

--- Returns plugin list.
--- @return table Plugins table
function pi.plugin:GetPlugins()

    self = self or pi.plugin
    return self._plugins

end

--- Returns plugin by its name
--- @param pluginName string
--- @return table Plugin table
function pi.plugin:GetPluginByName( pluginName )

    self = self or pi.plugin
    for _, v in ipairs( self._plugins ) do

        if v.Name == pluginName then
            return v
        end

    end

    return false

end