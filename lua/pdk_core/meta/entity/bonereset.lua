local meta = FindMetaTable( "Entity" )

local Vector = Vector
local Angle = Angle
local error = error
local pairs = pairs

--- Reset bone scale, angles and positions.
--- @return nil
function meta:ResetBonePositions( networking )
	
    if not self:GetBoneCount() then return end
	
	if networking and SERVER then
		net.Start( "pdk.resetbones" )
			net.WriteEntity( self )
		net.Broadcast()
	end
	
	for i = 0, self:GetBoneCount() do

		self:ManipulateBoneScale( i, Vector(1, 1, 1), false )
		self:ManipulateBoneAngles( i, Angle(0, 0, 0), false )
		self:ManipulateBonePosition( i, Vector(0, 0, 0), false )

	end

end

if CLIENT then

	local function receiveResetBones()
		net.ReadEntity():ResetBonePositions()
	end

	net.Receive( "pdk.resetbones", receiveResetBones )

else
	
	util.AddNetworkString( "pdk.resetbones" )

end