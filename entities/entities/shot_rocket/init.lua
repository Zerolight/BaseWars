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
	util.SpriteTrail(self, 0, Color(200,200,200), false, 16, 1, 2, 1/8.5, "trails/smoke.vmt")
	self.SmokeTrail = ents.Create("env_rockettrail")
	self.SmokeTrail:SetPos(self:GetPos() + self:GetForward()*-15)
	self.SmokeTrail:SetAngles(self:GetAngles())
	self.SmokeTrail:SetParent(self)
	self.SmokeTrail:Spawn()
	self.Upgraded = false
end

function ENT:Think()
	if (IsValid(self:GetOwner())==false) then
		self:Remove()
	end
	if (self.GoofyTiem < CurTime()-.25) then
		if (self.Upgraded) then
			self:SetAngles(self:GetAngles()+Angle(math.random()*2.5-1.25, math.random()*2.5-1.25, 0))
		else
			self:SetAngles(self:GetAngles()+Angle(math.random()*4.5-2.25, math.random()*4.5-2.25, 0))
		end
	end
	self:GetPhysicsObject():SetVelocity(self:GetForward()*2000)
end

function ENT:OnRemove()
	self.SmokeTrail:Remove()
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
	local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos()
		trace.filter = {self, self:GetOwner()}
	trace = util.TraceLine(trace)
	if (trace.Hit and (IsValid(trace.Entity) and trace.Entity:GetClass()~="shot_rocket")) or (trace.Hit and not IsValid(trace.Entity)) then self.DidHit=true end
	if (self.DidHit == true) then
		if (self.Upgraded) then
			util.BlastDamage( self, self:GetOwner(), self:GetPos(), 310, 30 )

			util.BlastDamage( self, self:GetOwner(), self:GetPos(), 100, 25 )
		else
			util.BlastDamage( self, self:GetOwner(), self:GetPos(), 275, 25 )
			util.BlastDamage( self, self:GetOwner(), self:GetPos(), 80, 20 )
		end
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

function ENT:Upgrade()
	self.Upgraded = true
end
