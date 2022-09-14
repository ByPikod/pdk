local IsValid = IsValid
local hook = hook
local net = net
local pi = pi

pi.level = pi.level or {}

pi.level.Name = "Levels"
pi.level.Description = "Picode's levels system."
pi.level.Version = 1
pi.level.Config = {
    multiplier = 1, -- How much xp needed to get to the next level ( initialExperience * level * multiplier ).
    initialExperience = 100, -- How much xp needed to get to the first level.
    broadcastLevel = true, -- If false the level data will not be sent to all the players.
    broadcastExperience = false -- If false, the xp data will not be sent to all the players. If true, the broadcastLevel option will be counted as true.
}

local config = pi.level.Config

pi.plugin:Register( pi.level )

local meta = FindMetaTable( "Player" )

if SERVER then

    local tonumber = tonumber
    local SQLStr = SQLStr
    local sql = sql

    util.AddNetworkString( "pdk.level.update_level" )

    --- Create the database if not exists
    sql.Query( [[
        CREATE TABLE IF NOT EXISTS pdk_levels( 
            id INTEGER PRIMARY KEY, 
            identifier TEXT NOT NULL,
            level INTEGER NOT NULL,
            xp INTEGER NOT NULL
        )
    ]] )

    --- Update the player's level and send it to client side.
    --- @param ply Player
    --- @param level number Level to set
    --- @param experience number XP to set
    --- @param silent bool Should player receive a notification from this action ?
    --- @return number, number Level and xp
    local function UpdateLevel( ply, level, experience, silent )
        
        local oldExperience, oldLevel = ply.__xp or -1, ply.__level or -1
        ply.__level, ply.__xp = level, experience

        ::CHECK_EXPERIENCE::
        local remainingToTheNextLevel = ply:GetRemainingToTheNextLevel()
        
        if experience > remainingToTheNextLevel then
            
            ply.__level = ply.__level + 1
            ply.__xp = ply.__xp - remainingToTheNextLevel

            goto CHECK_EXPERIENCE

        end

        net.Start( "pdk.level.update_level" )
                
            net.WriteBool( silent )
            net.WriteEntity( ply )
            net.WriteInt( ply.__level, 32 )
            net.WriteInt( ply.__xp, 32 )

            local streamType = 
            ( oldLevel ~= ply.__level ) and config[ "broadcastLevel" ] and net.Broadcast -- If any changes on level and broadcastLevel is enabled
            or config[ "broadcastExperience" ] and net.Broadcast -- If broadcastExperience is enabled make it broadcast anyway.
            or net.Send

       streamType( ply )

        -- Server side hook
        hook.Call( "PlayerLevelUpdated", nil, ply, oldLevel, ply.__level, oldExperience, ply.__xp, silent )

        -- return new level, experience data
        return ply.__level, ply.__xp

    end

    --- Update player's level on database.
    --- @param ply Player Player to update
    --- @return nil
    local function UpdateLevelData( ply )
        sql.Query( "UPDATE pdk_levels SET level = " .. ply.__level .. ", xp = " .. ply.__xp .. " WHERE identifier = " .. ply:GetUID() )
    end

    --- Initialize player level in join
    --- @param ply Player
    --- @return nil
    local function InitialUpdate( ply )

        timer.Simple(1, function()

            local result = sql.QueryRow( "SELECT level, xp FROM pdk_levels WHERE identifier = " .. ply:GetUID() )

            if not result then
                sql.Query( "INSERT INTO pdk_levels ( identifier, level, xp ) VALUES ( " .. ply:GetUID() .. ", 1, 0 )" )
            else
                result[ "level" ], result[ "xp" ] = tonumber( result[ "level" ] ), tonumber( result[ "xp" ] )
            end

            UpdateLevel( ply, result[ "level" ], result[ "xp" ], true )

        end)

    end

    hook.Add( "PlayerInitialSpawn", "pdk.level.initialize", InitialUpdate )

    --- Add any amount of experience to the player.
    --- @param experience number Experience amount to add
    --- @param silent bool Should player receive a notification from this action ?
    --- @return nil
    function meta:AddXP( experience, silent )
        self:SetXP( self:GetXP() + experience, silent )
    end

    --- Add level to the player.
    --- @param level number Level amount to add
    --- @param silent bool Should player receive a notification from this action ?
    --- @return nil
    function meta:AddLevel( level, silent )
        self:SetLevel( self:GetLevel() + level, 0, silent )
    end

    --- Set the amount of experience of the player.
    --- @param experience number Experience amount to set
    --- @param silent bool Should player receive a notification from this action ?
    --- @return nil
    function meta:SetXP( experience, silent )
        UpdateLevel( self, self.__level, experience, silent )
        UpdateLevelData( self )
    end

    --- Set level of player.
    --- @param level number New level value to set.
    --- @param experience number New experience value to set.
    --- @param silent bool Should player receive a notification from this action ?
    function meta:SetLevel( level, experience, silent )
        UpdateLevel( self, level, experience, silent )
        UpdateLevelData( self )
    end

else
    
    local LocalPlayer = LocalPlayer
    local render = render
    local Color = Color
    local chat = chat
    local draw = draw

    --- Update level data in player when receive an update.
    --- @return nil
    local function UpdateLevel()
        
        local silent, ply, level, xp = net.ReadBool(), net.ReadEntity(), net.ReadInt( 32 ), net.ReadInt( 32 )
        print( silent, " ", ply, " ", level, " ", xp )
        if not IsValid( ply ) then return end
        local oldExperience, oldLevel = ply.__xp, ply.__level
        ply.__xp, ply.__level = xp, level
    
        hook.Call( "PlayerLevelUpdated", nil, ply, oldLevel, level, oldExperience, xp, silent )

    end
    
    net.Receive( "pdk.level.update_level", UpdateLevel )

    --- Send notification to the chat
    --- @param ply Player
    --- @param oldLevel number
    --- @param newLevel number
    --- @param oldExperience number
    --- @param newExperience number
    --- @param silent boolean
    --- @return nil
    local function PlayerLevelNotification( ply, oldLevel, newLevel, oldExperience, newExperience, silent )
        
        -- we don't want to receive notifications for other players
        if ply ~= LocalPlayer() or silent then return end

        if oldLevel ~= newLevel then -- level is changed
            
            local text = 
                ( oldLevel < newLevel ) and "Tebrikler, " .. newLevel .. " seviyesine yükseldiniz!" -- level increased
                or "Maalesef " .. newLevel .. " seviyesine düştünüz." -- level decreased
            
            chat.AddText( Color( 255, 255, 255 ), text )

        elseif oldExperience ~= newExperience then -- only experience is changed
            
            local text = 
                ( oldExperience < newExperience ) and "Tecrübe puanı kazandınız: " .. newExperience -- experience increased
                or "Maalesef " .. newExperience .. " tecrübe puanı kaybettiniz." -- experience decreased
            
            chat.AddText( Color( 255, 255, 255 ), text )

        end

    end

    hook.Add( "PlayerLevelUpdated", "notification",  PlayerLevelNotification )

    local LevelHud = {}

    function LevelHud:Settings()
        
        -- Adjustments
        self.barBorderRadius = 100
        self.barWidth, self.barHeight = ScreenScale( 142 ), ScreenScale( 8 )
        self.barFillColor = Color( 52, 191, 89 )
        self.barBackgroundColor = Color( 255, 255, 255 )
        self.barBorderColor = Color( 255, 255, 255 )
        self.borderSize = 1
        self.texts = { 
            currentXP = { color = Color( 255, 255, 255 ) },
            currentLevel = { color = Color( 255, 255, 255 ) },
            nextLevel = { color = Color( 255, 255, 255 ) }
         }
        
        -- Don't touch
        self.screenWidth, self.screenHeight = ScrW(), ScrH()
        self.barX, self.barY = self.screenWidth / 2 - self.barWidth / 2, 10
        self.barEndX, self.barEndY = self.barX + self.barWidth, self.barY + self.barHeight
        self.borderBarX, self.borderBarY = self.barX - self.borderSize, self.barY - self.borderSize
        self.borderBarWidth, self.borderBarHeight = self.barWidth + self.borderSize * 2, self.barHeight + self.borderSize * 2
        self.texts.currentXP.x, self.texts.currentXP.y = self.screenWidth / 2, self.barY + self.barHeight / 2
        self.texts.currentLevel.x, self.texts.currentLevel.y = self.barX - 10, self.texts.currentXP.y
        self.texts.nextLevel.x, self.texts.nextLevel.y = self.barEndX + 10, self.texts.currentXP.y

    end

    LevelHud:Settings()

    --- Draw level hud
    --- @return nil
    function LevelHud:DrawHud()
        
        if self.screenHeight ~= ScrH() or self.screenWidth ~= ScrW() then
            self:Settings()
        end

        local me = LocalPlayer()
        -- local remainingToTheNextLevel = LocalPlayer():GetRemainingToTheNextLevel()
        
        draw.SimpleText( 
            me.__level or 0,
            "DermaDefault",
            self.texts.currentLevel.x,
            self.texts.currentLevel.y,
            self.texts.currentLevel.color,
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText( 
            me.__level or 0 + 1,
            "DermaDefault",
            self.texts.nextLevel.x,
            self.texts.nextLevel.y,
            self.texts.nextLevel.color,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )

        -- border & background
        draw.RoundedBox( self.barBorderRadius, self.borderBarX, self.borderBarY, self.borderBarWidth, self.borderBarHeight, self.barBorderColor )
        draw.RoundedBox( self.barBorderRadius, self.barX, self.barY, self.barWidth, self.barHeight, self.barBackgroundColor )

        -- fore plan
        render.SetScissorRect( self.barX, self.barY, self.barEndX, self.barEndY, true )
            draw.RoundedBox( self.barBorderRadius, self.barX, self.barY, self.barWidth, self.barHeight, self.barFillColor )
        render.SetScissorRect( 0, 0, 0, 0, false )

    end

    hook.Add( "HUDPaint", "pdk.level.hud", function() end  )

end

--- Returns the remeaning xp amount for getting to the next level.
--- @return number
function meta:GetRemainingToTheNextLevel()
    return config.initialExperience * self.__level * config.multiplier
end

--- Get the experience amount
--- @return number
function meta:GetXP()
    return self.__xp
end

--- Get detailed level data
--- @return table
function meta:GetLevel()
    return self.__level
end