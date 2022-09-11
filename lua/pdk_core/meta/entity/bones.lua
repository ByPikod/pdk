local meta = FindMetaTable( "Entity" )

--- Reset bone scale, angles and positions.
--- @return nil
function meta:ResetBonePositions( networking )

    if not self:GetBoneCount() then return end

	for i = 0, self:GetBoneCount() do

		self:ManipulateBoneScale( i, Vector(1, 1, 1), networking )
		self:ManipulateBoneAngles( i, Angle(0, 0, 0), networking )
		self:ManipulateBonePosition( i, Vector(0, 0, 0), networking )

	end

end