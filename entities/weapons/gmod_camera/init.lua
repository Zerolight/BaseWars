include('shared.lua')

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

function CC_GMOD_Camera( player, command, arguments )
	player:SelectWeapon( "gmod_camera" )
end
concommand.Add( "gmod_camera", CC_GMOD_Camera )

function SWEP:Deploy()

	self:GetOwner():DrawViewModel( false )

end

function SWEP:DoRotateThink()

end

function SWEP:ShouldDropOnDie()
	return false
end
