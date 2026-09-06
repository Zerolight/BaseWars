ENT.Type 			= "anim"
ENT.PrintName		= "Grenade"
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
		self:EmitSound(Sound("HEGrenade.Bounce"))
	end

	local impulse = -data.Speed * data.HitNormal * 0.4 + (data.OurOldVelocity * -0.6)
	phys:ApplyForceCenter(impulse)
end
