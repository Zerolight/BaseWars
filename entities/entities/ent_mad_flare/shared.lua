ENT.Type 			= "anim"
ENT.PrintName		= "Flare"
ENT.Author			= "Worshipper"
ENT.Contact			= "Josephcadieux@hotmail.com"
ENT.Purpose			= ""
ENT.Instructions		= ""

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

	if self:GetNWBool("Smoke") then
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
		util.Effect("effect_mad_flare_puff", effectdata)
	end

	self:SetNWBool("Smoke", false)
end
