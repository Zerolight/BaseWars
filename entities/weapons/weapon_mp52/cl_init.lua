include('shared.lua')

SWEP.PrintName			= "9MM HK MP-5A5"
SWEP.Slot				= 2
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_mp5.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_mp5")
end
