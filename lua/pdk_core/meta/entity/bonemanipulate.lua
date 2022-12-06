local meta = FindMetaTable( "Entity" )

local pairs = pairs

--- Function created to prevent code from duplicated for both server and client sides.
local function applyBoneChangesTable( entity, boneChanges )
	
	for k, v in pairs( boneChanges.angles ) do
		entity:ManipulateBoneAngles( k, v, false )
	end

	for k, v in pairs( boneChanges.jiggle ) do
		entity:ManipulateBoneJiggle( k, v, false )
	end

	for k, v in pairs( boneChanges.position ) do
		entity:ManipulateBonePosition( k, v, false )
	end

	for k, v in pairs( boneChanges.scale ) do
		entity:ManipulateBoneScale( k, v, false )
	end

end

if CLIENT then 
    
    local function retrieveBoneChanges()
        
        local entity = net.ReadEntity()
        local boneChanges = net.ReadTable()
		
		-- First bone manipulation on the entity doesn't work properly unless it made by gmod's networking.
		-- I don't really know the reason but this is my solution.
		if not entity:HasBoneManipulations() then
			
			entity:ManipulateBoneAngles(1, Angle(0, 0, 0))

			timer.Simple(0.01, function()
			
				applyBoneChangesTable(entity, boneChanges)
			
			end)

			return 

		end
		
		applyBoneChangesTable(entity, boneChanges)

    end

    net.Receive( "pdk.manipulatebones", retrieveBoneChanges )
    
	return

end

local error = error

util.AddNetworkString("pdk.manipulatebones")

--- Start to building a network message to send to client for editing bone positions.
--- @return nil
function meta:StartBoneEditing()
	
	self.boneChanges = {
		angles = {},
		position = {},
		jiggle = {},
		scale = {}
	}

end

--- Manipulate bone angles
--- @param boneID number
--- @param angle Angle
--- @return nil
function meta:WriteBoneAngles( boneID, angle )

	if not self.boneChanges then 
		error( "Bone editing is not started! Please use ply:StartBoneEditing() first.") 
	end

	self.boneChanges.angles[boneID] = angle

end

--- Set bone jiggle
--- @param boneID number
--- @param enabled boolean
--- @return nil
function meta:WriteBoneJiggle( boneID, enabled )

	if not self.boneChanges then 
		error("Bone editing is not started! Please use ply:StartBoneEditing() first." ) 
	end

	self.boneChanges.jiggle[boneID] = enabled

end

--- Manipulate bone position
--- @param boneID number
--- @param pos Vector
--- @return nil
function meta:WriteBonePosition( boneID, pos )

	if not self.boneChanges then 
		error( "Bone editing is not started! Please use ply:StartBoneEditing() first." ) 
	end

	self.boneChanges.position[boneID] = pos

end

--- Manipulate bone scale
--- @param boneID number
--- @param scale Vector
--- @return nil
function meta:WriteBoneScale( boneID, scale )

	if not self.boneChanges then 
		error( "Bone editing is not started! Please use ply:StartBoneEditing() first." ) 
	end

	self.boneChanges.scale[boneID] = scale

end

--- Start to building a network message to send to client for editing bone positions.
--- @return nil
function meta:BroadcastBoneEditing()
	
	if (
		not self.boneChanges or
		not self.boneChanges.angles or
		not self.boneChanges.jiggle or
		not self.boneChanges.position or
		not self.boneChanges.scale
	) then 
		error( "Bone editing is not started! Please use ply:StartBoneEditing() first." ) 
	end
	
	applyBoneChangesTable( self, self.boneChanges )

    net.Start( "pdk.manipulatebones" )
        net.WriteEntity( self )
        net.WriteTable( self.boneChanges )
    net.Broadcast()

end