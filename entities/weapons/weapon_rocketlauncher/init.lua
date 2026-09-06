AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.HoldType				= "rpg"

function SWEP:NPCShoot_Primary(ShootPos, ShootDir)

	if (not self:CanPrimaryAttack()) then return end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	self:EmitSound(self.Primary.Sound)

	self:TakePrimaryAmmo(1)

	self:Rocket()
end
