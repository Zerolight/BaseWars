AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self:SetModel("models/props_lab/pipesystem03b.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self.timer = CurTime() + 2 + math.random()
	self.solidify = CurTime() + 1
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end

	if (self.solidify<CurTime()) then
		self.SetOwner(self)
	end

	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos()+self:GetAngles():Right()*8)
		effectdata:SetMagnitude( 1 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 1 )
	util.Effect( "Sparks", effectdata )
	util.Effect( "Sparks", effectdata )
	util.Effect( "Sparks", effectdata )
	if self.timer < CurTime() then
		util.BlastDamage( self, (self.Owner or self:GetOwner()), self:GetPos(), 320, 70 )

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
