include('shared.lua')

SWEP.PrintName			= "5.7MM FN P90"
SWEP.Slot				= 2
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_p90.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_p90")
end
