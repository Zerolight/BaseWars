AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self.Owner = (self.Owner or self:GetOwner())

	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	self:SetModel("models/crossbow_bolt.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(2)
        	phys:Wake()
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
		phys:AddGameFlag(FVPHYSICS_PENETRATING)
	end

	self.Moving = true
end

function ENT:Think()

	local phys 		= self:GetPhysicsObject()
	local ang 		= self:GetForward() * 100000
	local up		= self:GetUp() * -800

	local force		= ang + up

	phys:ApplyForceCenter(force)

	if (self.HitWeld) then
		self.HitWeld = false
		constraint.Weld(self.HitEnt, self, 0, 0, 0, true)
	end
end

function ENT:Impact(sent, normal, pos)

	if not IsValid(self) then
		return
	end

	local tr, info

	tr = {}
		tr.start = self:GetPos()
		tr.filter = {self, self.Owner}
		tr.endpos = pos
	tr = util.TraceLine(tr)

	if tr.HitSky then self:Remove() return end

	bullet = {}
	bullet.Num    = 1
	bullet.Src    = pos
	bullet.Dir    = normal
	bullet.Spread = Vector(0, 0, 0)
	bullet.Tracer = 0
	bullet.Force  = 0
	bullet.Damage = 0
	self:FireBullets(bullet)

	if not sent:IsPlayer() and not sent:IsNPC() then
		local effectdata = EffectData()
			effectdata:SetOrigin(pos - normal * 10)
			effectdata:SetEntity(self)
			effectdata:SetStart(pos)
			effectdata:SetNormal(normal)
		util.Effect("effect_mad_shotgunsmoke", effectdata)
	end

	if IsValid(sent) then
		info = DamageInfo()
			info:SetAttacker(self.Owner)
			info:SetInflictor(self)
			info:SetDamageType(bit.bor(DMG_GENERIC, DMG_SHOCK))
			info:SetDamage(100)
			info:SetMaxDamage(100)
			info:SetDamageForce(tr.HitNormal * 10)

		self:EmitSound("Weapon_Crossbow.BoltHitBody")
		sent:TakeDamageInfo(info)

		self:Remove()
		return
	end

	self:EmitSound("Weapon_Crossbow.BoltHitWorld")

	self:SetPos(pos - normal * 10)
	self:SetAngles(normal:Angle())

	if not IsValid(sent) then
		self:GetPhysicsObject():EnableMotion(false)
	end

	self:Fire("kill", "", 10)
end

function ENT:PhysicsCollide(data, phys)

	if self.Moving then
		self.Moving = false
		phys:Sleep()
		self:Impact(data.HitEntity, data.HitNormal, data.HitPos)
	end
end
