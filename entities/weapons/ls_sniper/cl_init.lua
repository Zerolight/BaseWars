include('shared.lua')

SWEP.PrintName			= "7.62MM AI AWP"
SWEP.Slot				= 3
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_awp.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_awp")
end
