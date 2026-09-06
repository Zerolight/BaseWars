AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.HoldType				= "ar2"

function SWEP:OnRestore()

	self:ResetVariables()

	return true
end

function SWEP:OnRemove()

	self:ResetVariables()

	return true
end

function SWEP:Equip(NewOwner)

	self:ResetVariables()

	return true
end

function SWEP:OnDrop()

	self:ResetVariables()

	return true
end
