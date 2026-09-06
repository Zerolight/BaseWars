include('shared.lua')

SWEP.PrintName			= "BENELLI M4 SUPER 90"
SWEP.Slot				= 2
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_xm1014.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_xm1014")
end
