AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction(ply, tr)

	if (not tr.Hit) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	local ent = ents.Create("ent_mad_fuel")
		ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()

	self:SetModel("models/props_junk/gascan001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self:SetUseType(SIMPLE_USE)
end

function ENT:PhysicsCollide(data, physobj)

	if (data.Speed > 80 and data.DeltaTime > 0.2) then
		self:EmitSound("SolidMetal.ImpactSoft")
	end
end

function ENT:OnTakeDamage(dmginfo)

	self:TakePhysicsDamage(dmginfo)
end

function ENT:Use(activator, caller)

	self:Remove()

	self:EmitSound("BaseCombatCharacter.AmmoPickup")

	if (activator:IsPlayer()) then

		activator:SetNWInt("Fuel", 100)
	end
end

function FuelPlayerDeath(ply)

	ply:SetNWInt("Fuel", 0)
end
hook.Add("PlayerDeath", "FuelPlayerDeath", FuelPlayerDeath)
