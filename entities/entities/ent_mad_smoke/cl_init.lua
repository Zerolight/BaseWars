include('shared.lua')

language.Add("ent_mad_smoke", "Grenade")

function ENT:Initialize()
end

function ENT:Draw()

	self:DrawModel()
end

function ENT:Think()

	if self:GetDTBool(0) then
		self:Smoke()
		self:SetDTBool(0, false)
	end
end

function ENT:Smoke()

	local vPos = Vector(math.Rand(-5, 5), math.Rand(-5, 5), 0)
	local vOffset = self:LocalToWorld(Vector(0, 0, self:OBBMins().z))

	local emitter = ParticleEmitter(vOffset)

	for i = 1, 400 do
		timer.Simple(i / 75, function()
			if not self or self:WaterLevel() > 2 then return end

			local vPos = Vector(math.Rand(-5, 5), math.Rand(-5, 5), 0)
			local vOffset = self:LocalToWorld(Vector(0, 0, self:OBBMins().z))

			local smoke = emitter:Add("particle/particle_smokegrenade", vOffset)
			smoke:SetVelocity(VectorRand() * 300)
			smoke:SetGravity(Vector(math.Rand(-100, 100), math.Rand(-100, 100), math.Rand(0, 25)))
			smoke:SetDieTime(45)
			smoke:SetStartAlpha(255)
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(0)
			smoke:SetEndSize(350)
			smoke:SetRoll(math.Rand(-180, 180))
			smoke:SetRollDelta(math.Rand(-0.2,0.2))
			smoke:SetColor(Color(120, 120, 120))
			smoke:SetAirResistance(math.Rand(150, 600))
			smoke:SetBounce(0.5)
			smoke:SetCollide(true)
		end)
	end

	emitter:Finish()
end

function ENT:IsTranslucent()

	return true
end
