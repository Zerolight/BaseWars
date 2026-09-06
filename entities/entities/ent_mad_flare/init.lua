AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self.Owner = (self.Owner or self:GetOwner())

	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	self:SetModel("models/items/ar2_grenade.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self:EmitSound("Weapon_FlareGun.Burn")

	self.Timer = CurTime() + 1
	self.RepeatTimer = CurTime() + 1

	self:SetNWBool("Smoke", true)
	self.Explode = false
end

function ENT:Think()

	if self.RepeatTimer < CurTime() then
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
		util.Effect("effect_mad_flare_fire", effectdata)
	end

	if self.Timer < CurTime() then
		self:Explosion()
		self.Timer = CurTime() + 10
	end

	if self:WaterLevel() > 2 then
		self:Remove()
	end

	if self.Explode then
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z - 100)
		tracedata.filter = self
		local tr = util.TraceLine(tracedata)

		local flame = ents.Create("point_hurt")
		flame:SetPos(self:GetPos())
		flame:SetOwner(self.Owner)
		flame:SetKeyValue("DamageRadius", 100)
		flame:SetKeyValue("Damage", 5)
		flame:SetKeyValue("DamageDelay", 0.4)
		flame:SetKeyValue("DamageType", 8)
		flame:Spawn()
		flame:Fire("TurnOn", "", 0)
		flame:Fire("kill", "", 0.5)

		if (math.random(0, 6) < 1 and self:WaterLevel() <= 0 and tr.HitWorld) then
			local fire = ents.Create("env_fire")
			fire:SetPos(self:GetPos() + Vector( math.random(-60, 60), math.random(-60, 60), 0))
			fire:SetKeyValue("health", math.random(5, 15))
			fire:SetKeyValue("firesize", "32")
			fire:SetKeyValue("fireattack", "10")
			fire:SetKeyValue("damagescale", "1.0")
			fire:SetKeyValue("StartDisabled", "0")
			fire:SetKeyValue("firetype", "0")
			fire:SetKeyValue("spawnflags", "128")
			fire:Spawn()
			fire:Fire("StartFire", "", 0)
		end
	end
end

function ENT:Explosion()

	self.Explode = true

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("effect_mad_flare_explosion", effectdata)

	local explo = ents.Create("env_explosion")
		explo:SetOwner(self.Owner)
		explo:SetPos(self:GetPos())
		explo:SetKeyValue("iMagnitude", "50")
		explo:SetKeyValue("spawnflags", "783")
		explo:Spawn()
		explo:Activate()
		explo:Fire("Explode", "", 0)

	self:Fire("kill", "", 5)
end

function ENT:OnRemove()

	self:StopSound("Weapon_FlareGun.Burn")
end
