AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self.Time = CurTime()
	if (self.Upgrade==nil) then
		self.Upgrade = false
	end
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.CollisionGroup = COLLISION_GROUP_WEAPON
end

function ENT:Use(activator,caller)
	local class = self:GetNWString("weaponclass")

	local plweapon = activator:GetWeapon(class)
	if IsValid(plweapon) then
		if class~="weapon_worldslayer" then
			activator:GiveAmmo(plweapon:GetTable().Primary.DefaultClip, plweapon:GetPrimaryAmmoType())
		else
			return
		end
	else
		activator:Give(class)
	end
	local weapon = activator:GetWeapon(class)
	if IsValid(weapon) and self.Upgrade then
		weapon:Upgrade(true)
	end

	if IsValid(self.spawner) and activator~=self.spawner then
		Notify(self.spawner,4,3,activator:GetName() .. " picked up your gun factory weapon.")
	end
	self:Remove()

end

function ENT:GetTime()
	return self.Time
end

function ENT:SetUpgraded(bool)
	self.Upgrade = bool
end

function ENT:IsUpgraded()
	return self.Upgrade
end
