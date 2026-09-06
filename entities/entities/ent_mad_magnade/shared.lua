ENT.Type 			= "anim"
ENT.PrintName		= "Sticky Grenade"
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
		self:EmitSound(Sound("Grenade.ImpactHard"))
	end

end
