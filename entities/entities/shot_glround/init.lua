AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self:SetModel("models/items/grenadeammo.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end
	self.timer = CurTime() + 1.5
	self.solidify = CurTime() + 1
	self.Upgraded=false
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end

	if (self.solidify<CurTime()) then
		self.SetOwner(self)
	end
	if self.timer < CurTime() then
		util.BlastDamage( self, (self.Owner or self:GetOwner()), self:GetPos(), 256, 80 )

		local effectdata = EffectData()
			effectdata:SetStart(self:GetPos())
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetScale(1)
		util.Effect("HelicopterMegaBomb", effectdata)

		local effectdata2 = EffectData()
			effectdata2:SetStart(self:GetPos())
			effectdata2:SetOrigin(self:GetPos())
			effectdata2:SetScale(1)
		util.Effect("Explosion", effectdata2)

		self:EmitSound(Sound("weapons/hegrenade/explode"..math.random(3,5)..".wav"))
		self:Remove()
	end
end

function ENT:Upgrade()
	self.Upgraded = true
end

function ENT:OnTakeDamage( dmginfo )

end

function ENT:Use( activator, caller, type, value )
end

function ENT:StartTouch( entity )
end

function ENT:EndTouch( entity )
end

function ENT:Touch( entity )
end
