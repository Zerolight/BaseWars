include('shared.lua')

SWEP.PrintName			= "5.56MM M4A1"
SWEP.Slot				= 3
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_m4.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_m4")
end
