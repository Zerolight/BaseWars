include("shared.lua")

language.Add("ent_mad_mine", "Mine")

function ENT:Initialize()

	self.Owner = self:GetDTEntity(0)
	self.Alpha = 255
end

function ENT:Draw()

	if self:GetDTBool(0) then
		if (LocalPlayer() == self.Owner) then
			self.Alpha = math.Approach(self.Alpha, 100, 5)
		else
			self.Alpha = math.Approach(self.Alpha, 1, 5)
		end
	else
		self.Alpha = math.Approach(self.Alpha, 255, 5)
	end

	self:SetColor(Color(255, 255, 255, self.Alpha))
	self:DrawModel()
end
