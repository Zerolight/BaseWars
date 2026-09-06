ENT.Type = "anim"

ENT.PrintName		= "Grenade Round"
ENT.Author			= "HLTV Proxy"
ENT.Contact			= ""
ENT.Purpose			= nil
ENT.Instructions	= nil

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide( data, physobj )

	if (data.Speed > 80 and data.DeltaTime > 0.2 ) then
		self:EmitSound( "Rubber.BulletImpact" )
		self:EmitSound(Sound("HEGrenade.Bounce"))
	end

	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()

	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

	local TargetVelocity = NewVelocity * LastSpeed * 0.75

	physobj:SetVelocity( TargetVelocity )

end
