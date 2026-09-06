include('shared.lua')

SWEP.PrintName			= "9MM DUAL BERETTA ELITES"
SWEP.Slot				= 1
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_dual.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_dual")
end
