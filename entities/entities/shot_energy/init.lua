AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/weapons/w_missile_closed.mdl" )
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
	self.Upgraded = false
end

function ENT:Think()
	if (not IsValid((self.Owner or self:GetOwner()))) then
		self:Remove()
	end
	self:GetPhysicsObject():SetVelocity(self:GetForward()*99999)
end

function ENT:OnRemove()
end

function ENT:PhysicsCollide( data, physobj )
	ShockWaveExplosion(data.HitPos,(self.Owner or self:GetOwner()),data.HitNormal,22)

	local start = data.HitPos+data.HitNormal*-30
	local endpos = data.HitPos+data.HitNormal*30
	util.Decal("Scorch",start,endpos)

	self.DidHit = true
	self:GetPhysicsObject():SetVelocity(Angle(0,0,0))
end

function ENT:PhysicsUpdate()
	local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos()
		trace.filter = {self, (self.Owner or self:GetOwner())}
	trace = util.TraceLine(trace)
	if trace.Hit then self.DidHit=true end
	if (self.DidHit == true) then
		local ang = self:GetAngles()
		if (self.Upgraded) then
			util.BlastDamage( self, (self.Owner or self:GetOwner()), self:GetPos(), 60, 40 )
		else
			util.BlastDamage( self, (self.Owner or self:GetOwner()), self:GetPos(), 60, 30 )
		end
		self:Fire("kill", "", 0)

		self:Remove()
	end
end

function ENT:SetMode(t)
	self:SetNWInt("mode",t)
end
