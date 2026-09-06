AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self.Owner = (self.Owner or self:GetOwner())

	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	self:SetModel("models/weapons/w_c4_planted.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end

	self.Used = false

	self.Defuse	= 0
	self.DefuseDelay = CurTime()

	self:SetDTInt(0, self.Timer)
	self.ThinkTimer = CurTime() + self:GetDTInt(0)
end

function ENT:Use(activator, caller)

	self.Used = true
	self.Defuser = activator
end

function ENT:Think()

	if not self.Used then
		if self.DefuseDelay < CurTime() then
			self.Defuse = math.Clamp(self.Defuse - 0.02, 0, 1)
			self.DefuseDelay = CurTime() + 0.1
		end
	elseif self.Used then
		if self.DefuseDelay < CurTime() then
			self.Defuse = math.Clamp(self.Defuse + 0.02, 0, 1)
			self.DefuseDelay = CurTime() + 0.1
		end
	end

	self:SetColor(Color(255, 255 * (1 - self.Defuse), 255 * (1 - self.Defuse), 255))

	if self.Defuse >= 1 then
		self:Remove()
		self:EmitSound("C4.DisarmFinish")
		self.Defuser:PrintMessage(HUD_PRINTTALK, "You've defused the bomb.")
	end

	if self.ThinkTimer < CurTime() then
		self:Explosion()
	end

	self.Used = false
	self.Defuser = nil
end

function ENT:Explosion()

	local trace = {}
	trace.start = self:GetPos() + Vector(0, 0, 32)
	trace.endpos = self:GetPos() - Vector(0, 0, 128)
	trace.Entity = self
	trace.mask  = 16395
	local Normal = util.TraceLine(trace).HitNormal

	self.Scale = 6
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
		explo:SetKeyValue("iMagnitude", "500")
		explo:Spawn()
		explo:Activate()
		explo:Fire("Explode", "", 0)

	local shake = ents.Create("env_shake")
		shake:SetOwner(self.Owner)
		shake:SetPos(self:GetPos())
		shake:SetKeyValue("amplitude", "2000")
		shake:SetKeyValue("radius", "1250")
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

	self:EmitSound(Sound("C4.Explode"))

	self:Remove()

	local en = ents.FindInSphere(self:GetPos(), 400)

end
