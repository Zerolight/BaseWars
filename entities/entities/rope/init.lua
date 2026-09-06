AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local sndOnline = Sound( "hl1/fvox/activated.wav" )

function ENT:Initialize()

	self:DrawShadow( false )
	self:SetSolid( SOLID_NONE )

end

function ENT:Think()
end
