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

	self.Timer = CurTime() + 0.075
	self.Explode = false

end

function ENT:Think()

	if self.Timer < CurTime() then
		self.Explode = true
		self.Timer = CurTime() + 100
	end

	if self:WaterLevel() > 2 then
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

	local en = ents.FindInSphere(self:GetPos(), 100)

	for k, v in pairs(en) do
		if (v:GetPhysicsObject():IsValid()) then

			if (math.random(1, 100) < 10) then
				v:Fire("enablemotion", "", 0)
				constraint.RemoveAll(v)
			end
		end
	end
end

function ENT:PhysicsCollide(data, physobj)

	if data.Speed > 50 then
		self:EmitSound(Sound("Grenade.ImpactHard"))
	end

	if not self.Explode then
		self:Fire("kill", "", 5)
		self:SetNWBool("Explode", true)
		self.Timer = CurTime() + 100
		self.Explode = false
		return
	end

	self.Explode = false

	util.Decal("Scorch", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal)

	self:Explosion()
	self:Remove()
end
