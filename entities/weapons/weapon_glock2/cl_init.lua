include('shared.lua')

SWEP.PrintName			= "9MM GLOCK 18"
SWEP.Slot				= 1
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_glock.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_glock")
end
