include('shared.lua')

SWEP.PrintName			= ".45 HK UMP-45"
SWEP.Slot				= 2
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_ump.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_ump")
end
