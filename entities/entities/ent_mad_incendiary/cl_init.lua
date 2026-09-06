include('shared.lua')

language.Add("ent_mad_grenade", "Grenade")

function ENT:Initialize()

	self.OneTime = true
end

function ENT:Draw()

	self:DrawModel()
end

function ENT:Think()

	if self:WaterLevel() > 2 then return end

	if (self:GetDTBool(0)) then
		local light = DynamicLight(self:EntIndex())
		if (light) then
			light.Pos = self:GetPos()
			light.r = 255
			light.g = 115
			light.b = 40
			light.Brightness = 1
			light.Decay = math.random(500, 800) * 5
			light.Size = math.random(500, 800)
			light.DieTime = CurTime() + 1
		end
	end

	if (self:GetDTBool(0) and self.OneTime) then
		self:Smoke()
		self.OneTime = false
	end
end

function ENT:Smoke()

	local vPos = Vector(math.Rand(-5, 5), math.Rand(-5, 5), 0)
	local vOffset = self:LocalToWorld(Vector(0, 0, self:OBBMins().z))

	local emitter = ParticleEmitter(vOffset)

	for i = 1, 700 do
		timer.Simple(i / 100, function()
			if not self or self:WaterLevel() > 2 then return end

			local vPos = Vector(math.Rand(-5, 5), math.Rand(-5, 5), 0)
			local vOffset = self:LocalToWorld(Vector(0, 0, self:OBBMins().z))

			local smoke = emitter:Add("particle/particle_smokegrenade", vOffset)
			smoke:SetVelocity(VectorRand() * 200)
			smoke:SetGravity(Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(50, 150)))
			smoke:SetDieTime(5)
			smoke:SetStartAlpha(255)
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(0)
			smoke:SetEndSize(math.Rand(50, 200))
			smoke:SetRoll(math.Rand(-180, 180))
			smoke:SetRollDelta(math.Rand(-0.2,0.2))
			smoke:SetColor(Color(25, 25, 25))
			smoke:SetAirResistance(math.Rand(25, 100))
			smoke:SetBounce(0.5)
			smoke:SetCollide(true)
		end)
	end

	emitter:Finish()
end

function ENT:IsTranslucent()

	return true
end
