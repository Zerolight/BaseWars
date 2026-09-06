AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self.Owner = (self.Owner or self:GetOwner())

	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	self:SetModel("models/weapons/w_eq_smokegrenade.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self.OneTime = true
end

function ENT:Think()

	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z - 100)
	tracedata.filter = self
	local tr = util.TraceLine(tracedata)

	if (self:GetDTBool(0) and self:WaterLevel() <= 0) then

		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
		util.Effect("effect_mad_incendiary_fire", effectdata)

		local en = ents.FindInSphere(self:GetPos(), math.random(0, 100))

		for k, v in pairs(en) do
			if (math.random(0, 2) < 1) then

				if (v:GetPhysicsObject():IsValid() and not v:IsPlayer() and not v.burned) then

					v:Ignite(math.random(5, 30), 0)
					v.burned = 1
				elseif (v:GetPhysicsObject():IsValid()) then

					if (math.random(1, 100) < 30) then
						v:Fire("enablemotion", "", 0)
						constraint.RemoveAll(v)
					end
				end
			end
		end

		local flame = ents.Create("point_hurt")
		flame:SetPos(self:GetPos())
		flame:SetOwner(self.Owner)
		flame:SetKeyValue("DamageRadius", 100)
		flame:SetKeyValue("Damage", 10)
		flame:SetKeyValue("DamageDelay", 0.4)
		flame:SetKeyValue("DamageType", 8)
		flame:Spawn()
		flame:Fire("TurnOn", "", 0)
		flame:Fire("kill", "", 0.5)
	end

	if (math.random(0, 6) < 1 and self:WaterLevel() <= 0 and self.TimerFire and tr.HitWorld) then
		local fire = ents.Create("env_fire")
			fire:SetPos(self:GetPos() + Vector( math.random(-100, 100), math.random(-100, 100), 0))
			fire:SetKeyValue("health", math.random(5, 15))
			fire:SetKeyValue("firesize", "64")
			fire:SetKeyValue("fireattack", "10")
			fire:SetKeyValue("damagescale", "1.0")
			fire:SetKeyValue("StartDisabled", "0")
			fire:SetKeyValue("firetype", "0")
			fire:SetKeyValue("spawnflags", "128")
			fire:Spawn()
			fire:Fire("StartFire", "", 0)
	end

	if (self:GetDTBool(0) and self.OneTime) then

		self.OneTime = false
		self.Fire = true

		self:EmitSound(Sound("Weapon_FlareGun.Burn"))
		self:Fire("kill", "", 10)
	end

	self:Extinguish()
end

function ENT:OnRemove()

	self:StopSound("Weapon_FlareGun.Burn")
end

function ENT:Explosion()
end
