include('shared.lua')

language.Add("ent_mad_grenadelauncher", "Grenade")

function ENT:Initialize()

	local vOffset 	= self:LocalToWorld(Vector(0, 0, self:OBBMins().z))
	local vNormal 	= (vOffset - self:GetPos()):GetNormalized()

	local emitter 	= ParticleEmitter(vOffset)

	for i = 1, 1500 do
		timer.Simple(i / 150, function()
			if not self or self:GetNWBool("Explode") then return end

			local vOffset 	= self:LocalToWorld(Vector(0, 0, self:OBBMins().z))
			local vNormal 	= (vOffset - self:GetPos()):GetNormalized()

			local particle = emitter:Add("particle/particle_smokegrenade", vOffset)
			particle:SetVelocity(vNormal * 5)
			particle:SetDieTime(5)
			particle:SetStartAlpha(155)
			particle:SetStartSize(2)
			particle:SetEndSize(10)
			particle:SetRoll(math.Rand(-5, 5))
			particle:SetColor(Color(150, 150, 150))
		end)
	end

	emitter:Finish()
end

function ENT:Draw()

	self:DrawModel()
end

function ENT:Think()
end

function ENT:IsTranslucent()

	return true
end
