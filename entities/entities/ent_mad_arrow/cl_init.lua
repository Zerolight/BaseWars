include('shared.lua')

language.Add("ent_mad_arrow", "Arrow")

function ENT:Draw()

	self:DrawModel()
end

function ENT:IsTranslucent()

	return true
end
