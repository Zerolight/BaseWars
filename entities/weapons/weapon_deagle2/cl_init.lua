include('shared.lua')

SWEP.PrintName			= ".50 DESERT EAGLE"
SWEP.Slot				= 1
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_deagle.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_deagle")
end
