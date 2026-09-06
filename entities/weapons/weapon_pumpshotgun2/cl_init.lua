include('shared.lua')

SWEP.PrintName			= "BENELLI M3 SUPER 90"
SWEP.Slot				= 2
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_m3.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_m3")
end
