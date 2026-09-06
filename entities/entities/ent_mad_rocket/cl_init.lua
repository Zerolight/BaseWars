ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include("shared.lua")

language.Add("ent_mad_rocket", "Rocket")

function ENT:Initialize()

	self.TimeLeft = CurTime() + 3

	local vOffset 	= self:LocalToWorld(Vector(0, 0, self:OBBMins().z))
	local vNormal 	= (vOffset - self:GetPos()):GetNormalized()

	local emitter 	= ParticleEmitter(vOffset)

	for i = 1, 4500 do
		timer.Simple(i / 150, function()
			if not self then return end

			local vOffset 	= self:LocalToWorld(Vector(0, 0, self:OBBMins().z))
			local vNormal 	= (vOffset - self:GetPos()):GetNormalized()

			local particle = emitter:Add("particle/particle_smokegrenade", vOffset)
			particle:SetVelocity(vNormal * 5)
			particle:SetDieTime(10)
			particle:SetStartAlpha(255)
			particle:SetStartSize(5)
			particle:SetEndSize(25)
			particle:SetRoll(math.Rand(-5, 5))
			particle:SetColor(Color(160, 160, 160))
		end)
	end

	emitter:Finish()
end

function ENT:Think()

	if self.TimeLeft > CurTime() then
		local effectdata = EffectData()
 			effectdata:SetOrigin(self:LocalToWorld(Vector(0, 0, self:OBBMins().z)))
 			effectdata:SetAngle(self:GetAngles() + Vector(180, 0, 0))
			effectdata:SetScale(1.5)
 		util.Effect("MuzzleEffect", effectdata)
	end
end
