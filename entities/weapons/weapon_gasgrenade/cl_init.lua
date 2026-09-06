include('shared.lua')

SWEP.PrintName			= "Gas Grenade"
SWEP.Slot				= 4
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_smoke.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_smoke")
end
