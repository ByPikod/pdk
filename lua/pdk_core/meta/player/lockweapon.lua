local hook = hook
local net = net

local meta = FindMetaTable( "Player" )

if CLIENT then

    net.Receive( "pdk.core.lockweapon", function()
        
        if net.ReadBool() then
            LocalPlayer():LockWeapon()
        else
            LocalPlayer():UnlockWeapon()
        end

    end )

    --- Prevent the player from switching between weapons.
    --- @return nil
    function meta:LockWeapon()

        if self ~= LocalPlayer() then
            return 
        end
        
        hook.Add( "PlayerSwitchWeapon", "pdk.core.lockweapon", function()
            return true
        end )

    end

    --- Allow the player to switching between weapons.
    --- @return nil
    function meta:UnlockWeapon()
        hook.Remove( "PlayerSwitchWeapon", "pdk.core.lockweapon" )
    end

else
    
    util.AddNetworkString( "pdk.core.lockweapon" )
    
    hook.Add( "PlayerSwitchWeapon", "pdk.core.lockweapon", function( ply, old, new )
        
        if ply.pdk_weaponsLocked then
            return true
        end

    end )

    --- Prevent the player from switching between weapons.
    --- @param networking bool Should the player's computer also perform the action ?
    --- @return nil
    function meta:LockWeapon( networking )

        self.pdk_weaponsLocked = true
        
        if networking then
            
            net.Start( "pdk.core.lockweapon" )
            net.WriteBool( true )
            net.Send( self )

        end

    end

    --- Allow the player to switching between weapons.
    --- @param networking bool Should the player's computer also perform the action ?
    --- @return nil
    function meta:UnlockWeapon( networking )
        
        self.pdk_weaponsLocked = false

        if networking then
            
            net.Start( "pdk.core.lockweapon" )
            net.WriteBool( false )
            net.Send( self )

        end

    end

end