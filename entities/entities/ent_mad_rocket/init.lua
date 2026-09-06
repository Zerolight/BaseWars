AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local RocketSound = Sound("Missile.Accelerate")

function ENT:Initialize()

	self.Owner = (self.Owner or self:GetOwner())

	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	self:SetModel("models/weapons/w_missile_closed.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.SpawnTime = CurTime()

	self.PhysObj = self:GetPhysicsObject()

	if (self.PhysObj:IsValid()) then
		self.PhysObj:EnableGravity(false)
		self.PhysObj:EnableDrag(false)
		self.PhysObj:SetMass(30)
        	self.PhysObj:Wake()
	end

	self:EmitSound(RocketSound)
	util.PrecacheSound("explode_4")

	self.TimeLeft = CurTime() + 3
end

function ENT:Think()

	local phys 		= self:GetPhysicsObject()
	local ang 		= self:GetForward() * 7500
	local upang
	local rightang

	upang 	= self:GetUp() * math.Rand(500, 2000) * (math.sin(CurTime() * math.Rand(500, 1000)))
	rightang 	= self:GetRight() * math.Rand(500, 2000) * (math.cos(CurTime() * math.Rand(500, 1000)))

	local force

	if self:WaterLevel() > 0 or self.TimeLeft < CurTime() then
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		self:StopSound(RocketSound)
	else
		if self.SpawnTime + 0.75 < CurTime() then
			force = ang + upang + rightang
		else
			force = ang
		end

		phys:ApplyForceCenter(force)
	end
end

function ENT:Explosion()

	local trace = {}
	trace.start = self:GetPos() + Vector(0, 0, 32)
	trace.endpos = self:GetPos() - Vector(0, 0, 128)
	trace.Entity = self
	trace.mask  = 16395
	local Normal = util.TraceLine(trace).HitNormal

	self.Scale = 2
	self.EffectScale = self.Scale ^ 0.65

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("HelicopterMegaBomb", effectdata)

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetNormal(Normal)
		effectdata:SetScale(self.EffectScale)
	util.Effect("effect_mad_ignition", effectdata)

	local explo = ents.Create("env_explosion")
		explo:SetOwner(self.Owner)
		explo:SetPos(self:GetPos())
		explo:SetKeyValue("iMagnitude", "200")
		explo:Spawn()
		explo:Activate()
		explo:Fire("Explode", "", 0)

	local shake = ents.Create("env_shake")
		shake:SetOwner(self.Owner)
		shake:SetPos(self:GetPos())
		shake:SetKeyValue("amplitude", "2000")
		shake:SetKeyValue("radius", "900")
		shake:SetKeyValue("duration", "2.5")
		shake:SetKeyValue("frequency", "255")
		shake:SetKeyValue("spawnflags", "4")
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)

	local ar2Explo = ents.Create("env_ar2explosion")
		ar2Explo:SetOwner(self.Owner)
		ar2Explo:SetPos(self:GetPos())
		ar2Explo:Spawn()
		ar2Explo:Activate()
		ar2Explo:Fire("Explode", "", 0)

	local en = ents.FindInSphere(self:GetPos(), 300)
end

function ENT:PhysicsCollide(data, physobj)

	util.Decal("Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)

	self:Explosion()

	self:Remove()
end

function ENT:OnRemove()

	self:StopSound(RocketSound)
end
