local pi = pi
local registry = debug.getregistry()

registry.PIP = registry.PIP or {}
pi.Plugin = pi.Plugin or {}
pi.Plugin._plugins = pi.Plugin._plugins or {}

--- Plugin base
local meta = FindMetaTable("PIP")

--- Register your plugin table.
--- @param object table Plugin table.
--- @return void
function pi.Plugin:Register( object )

    if not object.Name then
        error( "An error has occurred while registering plugin: Plugin table have no \"Name\" field." )
    end

    setmetatable( object, meta )
    meta.__index = meta

    table.insert( self._plugins, object )

    return object

end

--- Returns plugin list.
--- @return table Plugins table
function pi.Plugin:GetPlugins()

    return self._plugins

end

--- Returns plugin by its name
--- @return table Plugin table
function pi.Plugin:GetPluginByName( pluginName )

    for _, v in ipairs( self._plugins ) do

        if v.Name == pluginName then
            return v
        end

    end

    return false

end