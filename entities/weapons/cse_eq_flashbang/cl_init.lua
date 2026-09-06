include('shared.lua')

SWEP.PrintName			= "FLASH GRENADE"
SWEP.Slot				= 4
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_flash.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_flash")
end
