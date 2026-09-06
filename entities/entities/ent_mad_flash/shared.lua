ENT.Type 			= "anim"
ENT.PrintName		= "Flash"
ENT.Author			= "Worshipper"
ENT.Contact			= "Josephcadieux@hotmail.com"
ENT.Purpose			= ""
ENT.Instructions		= ""

function ENT:SetupDataTables()

	self:DTVar("Boal", 0, "Explode")
end

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data, phys)

	if data.Speed > 50 then
		self:EmitSound(Sound("Flashbang.Bounce"))
	end

	local impulse = -data.Speed * data.HitNormal * 0.4 + (data.OurOldVelocity * -0.6)
	phys:ApplyForceCenter(impulse)

	if not self.Collide then self.Collide = false end
	if self.Collide then return end

	timer.Simple(0.9, function()
		if not self then return end
		if not IsFirstTimePredicted() then return end

		self:SetDTBool(0, true)
	end)

	timer.Simple(1, function()
		if not self then return end
		if not IsFirstTimePredicted() then return end

		self:Explode()
	end)

	self.Collide = true
end
