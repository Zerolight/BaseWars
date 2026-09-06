AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/items/combine_rifle_ammo01.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetKeyValue("physdamagescale", "9999")
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.DidHit = false
	self.GoofyTiem = CurTime()
	util.SpriteTrail(self, 0, Color(200,200,200), false, 16, 1, 1.5, 1/8.5, "trails/smoke.vmt")
	self:GetPhysicsObject():SetVelocity(self:GetUp()*2000)
	timer.Create( self .. "blowup", 4, 1, function() if IsValid( self ) then self:HitShit() end end )
end

function ENT:Think()
	if (self.GoofyTiem < CurTime()-5) then
		self.DidHit = true
	end
end

function ENT:OnRemove()
	timer.Destroy(self .. "blowup")
end

function ENT:PhysicsCollide( data, physobj )

end
function ENT:Touch()
	self.DidHit = true
end
function ENT:PhysicsUpdate()
	if (self.DidHit == true) then
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 250, 90 )

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

		self:Fire("kill", "", 0)
		self:EmitSound(Sound("weapons/explode3.wav"))
		self:Remove()
	end
end
function ENT:HitShit()
	self:GetPhysicsObject():Wake()
	self.DidHit = true
	Msg("!")
end
