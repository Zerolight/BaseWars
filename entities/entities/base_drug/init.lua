AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props_lab/jar01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self:SetVar("damage",20)
	self.Time = CurTime()
end

function ENT:OnTakeDamage(dmg)
	self:SetVar("damage",self:GetVar("damage") - dmg:GetDamage())

	if(self:GetVar("damage") <= 0) then
		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetMagnitude( 2 )
			effectdata:SetScale( 2 )
			effectdata:SetRadius( 3 )
		util.Effect( "Sparks", effectdata )
		self:Remove()
	end
end

function ENT:Use(activator,caller)
	if (caller:GetTable().Roided ~= true) then
		Roidup(caller)
		self:Remove()
	end
end

function ENT:Think()

end

function ENT:GetTime()
	return self.Time
end

function ENT:ResetTime()
	self.Time = CurTime()
end
