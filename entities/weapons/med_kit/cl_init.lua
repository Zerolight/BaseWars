include('shared.lua')

SWEP.PrintName			= "MEDIC KIT"
SWEP.Slot				= 4
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_medic.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_medic")
end

language.Add("Undone_Medic Kit", "Undone Medic Kit")
language.Add("Cleanup_Medic Kit", "Clean Up Medic Kit")
language.Add("Cleaned_Medic Kit", "Cleaned Medic Kit")
