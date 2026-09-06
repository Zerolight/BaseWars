ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include('shared.lua')

language.Add( "meteor", "meteor" )

function ENT:Initialize()

	mx, mn = self:GetRenderBounds()
	self:SetRenderBounds( mn + Vector(0,0,128), mx, 0 )

end

function ENT:Think()

end
