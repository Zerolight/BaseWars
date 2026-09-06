include('shared.lua')

function ENT:Draw()
	self:DrawModel()
end

function ENT.Initialize()
	killicon.AddFont("shot_glround","HL2MPTypeDeath","7",Color(100,100,100,255))
end

function ENT:IsTranslucent()
	return true
end
