AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( "bigbomb" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()
	self:SetModel("models/weapons/w_crowbar.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.DidHit=false
end

function ENT:Think()
	if (IsValid(self:GetOwner())==false) then
		self:Remove()
	end
end

function ENT:HitShit()
	self:GetPhysicsObject():Wake()
	self.DidHit = true
end
function ENT:Explode()
	util.BlastDamage( self, self:GetOwner(), self:GetPos(), 384, 250 )
	local effectdata = EffectData()
		effectdata:SetStart(self:GetPos())
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(1.5)
	util.Effect("HelicopterMegaBomb", effectdata)
	local effectdata2 = EffectData()
		effectdata2:SetStart(self:GetPos())
		effectdata2:SetOrigin(self:GetPos())
		effectdata2:SetScale(1.5)
	util.Effect("Explosion", effectdata2)
	self:EmitSound(Sound("weapons/explode3.wav"))
	self:Remove()
end

function ENT:Touch()
	self.DidHit = true
end
function ENT:PhysicsUpdate()
	if (self.DidHit == true) then
		self:Explode()
	end
end
function ENT:PhysicsCollide( data, physobj )
	self.DidHit = true
end
