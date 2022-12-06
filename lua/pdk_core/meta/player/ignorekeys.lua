local LocalPlayer = LocalPlayer
local bit = bit
local net = net

local meta = FindMetaTable( "Player" )

hook.Add( "StartCommand", "pdk.ignorekeys", function( ply, mv )

    local ignore = ply.pdk_ignore
    if not ignore or ignore == 0 then return end
    mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( ignore ) ) )

end )

if CLIENT then

    net.Receive( "pdk.player.ignorekeys", function() 
        
        local keys = net.ReadInt( 32 )
        LocalPlayer():IgnoreKeys( keys )

    end)

    --- Ignore specific set of keys for this player. Keys will be ignored in StartCommand hook.
    --- @param keys number Sum of the keys you want to ignore for this player. Put "0" to disable it.
    --- @return nil
    function meta:IgnoreKeys( keys )
        
        if LocalPlayer() ~= self then
            return
        end
        
        if keys == nil then keys = 0 end
        
        self.pdk_ignore = keys

    end

else

    util.AddNetworkString( "pdk.player.ignorekeys" )

    --- Ignore specific set of keys for this player. Keys will be ignored in StartCommand hook.
    --- @param keys number Sum of the keys you want to ignore for this player. Put "0" to disable it.
    --- @return nil
    function meta:IgnoreKeys( keys, networking )

        if keys == nil then keys = 0 end
        self.pdk_ignore = keys

        if not networking then return end
        net.Start( "pdk.player.ignorekeys" )
            net.WriteInt( keys, 32 )
        net.Send( self )

    end

end