include('shared.lua')

SWEP.PrintName			= "FRAGMENTATION GRENADE"
SWEP.Slot				= 4
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_grenade.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_grenade")
end
