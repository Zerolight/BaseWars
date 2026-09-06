include('shared.lua')

SWEP.PrintName			= "Pick Lock"
SWEP.Slot				= 0
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_fists.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_fists")
end
