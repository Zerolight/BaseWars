AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_junk/propanecanister001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetKeyValue("physdamagescale", "9999")
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
	end
	self.DidHit = false
	self.GoofyTiem = CurTime()
	util.SpriteTrail(self, 0, Color(200,200,200), false, 20, 1, 2, 1/8.5, "trails/smoke.vmt")

end

function ENT:Think()
	if (IsValid(self:GetOwner())==false) then
		self:Remove()
	end

end

function ENT:PhysicsCollide( data, physobj )
	data.HitNormal = data.HitNormal*-150
	local start = data.HitPos+data.HitNormal
	local endpos = data.HitPos+data.HitNormal*-1
	util.Decal("Scorch",start,endpos)

  	self.DidHit = true
	self:GetPhysicsObject():SetVelocity(Angle(0,0,0))
end
function ENT:PhysicsUpdate()

	local tracedata = {}
		tracedata.startpos = self:GetPos()
		tracedata.endpos = self:GetAngles():Up()*20
		tracedata.filter = self
	trace = util.TraceLine(tracedata)
	if (IsValid(trace.Entity)) then
		self.DidHit = true
	end
	if (self.DidHit == true) then
		util.BlastDamage( self, self:GetOwner(), self:GetPos(), 300, 250 )
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
