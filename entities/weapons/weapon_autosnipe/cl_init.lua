include('shared.lua')

SWEP.PrintName			= "7.62MM HK G3SG1 SNIPER"
SWEP.Slot				= 3
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_g3.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_g3")
end
