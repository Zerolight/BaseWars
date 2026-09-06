ENT.Type = "anim"

function ENT:SetEndPos( endpos )

	self:SetNWVector( 0, endpos )
	self:SetCollisionBoundsWS( self:GetPos(), endpos, Vector() * 0.25 )

end

function ENT:GetEndPos()
	return self:GetNWVector( 0 )
end
