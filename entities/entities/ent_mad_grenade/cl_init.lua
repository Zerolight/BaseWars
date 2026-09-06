include('shared.lua')

language.Add("ent_mad_grenade", "Grenade")

function ENT:Draw()

	self:DrawModel()
end

function ENT:IsTranslucent()

	return true
end
