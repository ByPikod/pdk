local LocalPlayer = LocalPlayer
local bit = bit
local net = net

local meta = FindMetaTable( "Player" )

hook.Add( "StartCommand", "pdk.ignorekeys", function( ply, mv )

    local ignore = ply.pdk_ignore
    if not ignore then return end
    
    --[[

        How it works ? Example:

        a = jump
        b = sprint
        c = attack 1
        d = attack 2

        keys:            a b c d
        user pressed:    1 1 0 0
        will ignored:    0 1 0 0

        User pressed jump and sprint buttons at the same time. If we want to ignore
        sprint key, we should find non-intersecting variables.

        bit not operator:

        keys:            a b c d
        will ignored:    0 1 0 0
        bit not:         1 0 1 1      

        bit and operator:

        keys:            a b c d
        user pressed:    1 1 0 0
        will ignored:    1 0 1 1
        bit and:         1 0 0 0

        Now we only have the non-intersecting keys.

    ]]
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
        
        if keys == 0 then keys = nil end
        
        self.pdk_ignore = keys

    end

else

    util.AddNetworkString( "pdk.player.ignorekeys" )

    --- Ignore specific set of keys for this player. Keys will be ignored in StartCommand hook.
    --- @param keys number Sum of the keys you want to ignore for this player. Put "0" to disable it.
    --- @return nil
    function meta:IgnoreKeys( keys, networking )

        if keys == 0 then keys = nil end
        self.pdk_ignore = keys

        if not networking then return end
        net.Start( "pdk.player.ignorekeys" )
            net.WriteInt( keys, 32 )
        net.Send( self )

    end

end