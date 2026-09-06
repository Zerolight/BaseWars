AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self.Owner = (self.Owner or self:GetOwner())

	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	self:SetModel("models/weapons/w_magnade.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self.Timer = CurTime() + 3.25
	self.SoundTimer = CurTime() + 2
	self.EffectTimer = CurTime() + 3

	util.SpriteTrail(self, 0, Color(128, 255, 255, 255), false, 30, 0, 1, 1 / ((30 + 0) * 0.5), "trails/laser.vmt")
end

function ENT:Think()

	if self.EffectTimer < CurTime() then
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z - 10)
		tracedata.filter = self
		local tr = util.TraceLine(tracedata)

		if tr.Hit then
			self:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, 500))
		end

		self.EffectTimer = CurTime() + 5
	end

	if self.SoundTimer < CurTime() then
		self:EmitSound("weapons/strider_buster/strider_buster_stick1.wav")
		self.SoundTimer = CurTime() + 5

		local energyball = ents.Create("env_citadel_energy_core")
		energyball:SetPos(self:GetPos())
		energyball:SetKeyValue("scale", 2)
		energyball:Spawn()
		energyball:Activate()
		energyball:SetParent(self)
		energyball:Fire("StartCharge", "1", 0)
	end

	if self.Timer < CurTime() then
		self:Explosion()
		self:Remove()
	end
end

function ENT:Explosion()

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("HelicopterMegaBomb", effectdata)

	local explo = ents.Create("env_explosion")
		explo:SetOwner(self.Owner)
		explo:SetPos(self:GetPos())
		explo:SetKeyValue("iMagnitude", "125")
		explo:SetKeyValue("spawnflags", "66")
		explo:Spawn()
		explo:Activate()
		explo:Fire("Explode", "", 0)

	local shake = ents.Create("env_shake")
		shake:SetOwner(self.Owner)
		shake:SetPos(self:GetPos())
		shake:SetKeyValue("amplitude", "2000")
		shake:SetKeyValue("radius", "400")
		shake:SetKeyValue("duration", "2.5")
		shake:SetKeyValue("frequency", "255")
		shake:SetKeyValue("spawnflags", "4")
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)

	local en = ents.FindInSphere(self:GetPos(), 75)

	for k, v in pairs(en) do
		if (v:GetPhysicsObject():IsValid()) then

			if (math.random(1, 100) < 10) then
				v:Fire("enablemotion", "", 0)
				constraint.RemoveAll(v)
			end
		end
	end

	self:EmitSound("npc/ministrider/flechette_explode" .. math.random(1, 3) .. ".wav", 150)
end
