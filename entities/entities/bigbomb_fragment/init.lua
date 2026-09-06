AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/items/battery.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	util.SpriteTrail(self, 0, Color(200,200,200), false, 16, 1, 1.2, 1/8.5, "trails/smoke.vmt")

	timer.Create( tostring(self) .. "blowup", 2.5+math.random(), 1, function() if IsValid( self ) then self:Explode() end end )
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
end

function ENT:OnRemove()
	timer.Destroy(tostring(self) .. "blowup")
end
function ENT:Explode()
	util.BlastDamage( self, (self.Owner or self:GetOwner()), self:GetPos(), 384, 150 )

	local effectdata = EffectData()
		effectdata:SetStart(self:GetPos())
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(3)
	util.Effect("HelicopterMegaBomb", effectdata)

	local effectdata2 = EffectData()
		effectdata2:SetStart(self:GetPos())
		effectdata2:SetOrigin(self:GetPos())
		effectdata2:SetScale(3)
	util.Effect("Explosion", effectdata2)

	self:EmitSound(Sound("weapons/c4/c4_explode1.wav"))
	self:Remove()
end
