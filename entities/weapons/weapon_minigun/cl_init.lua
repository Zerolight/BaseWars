include('shared.lua')

SWEP.PrintName			= "M61 VULCAN"
SWEP.Slot				= 3
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_minigun.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_minigun")
end
