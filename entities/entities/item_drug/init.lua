AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props_junk/glassjug01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self:SetVar("damage",10)
	self.Time = CurTime()
	timer.Create( tostring(self), 180, 1, function() if IsValid( self ) then self:Remove() end end )
end

function ENT:Use(activator,caller)
	DrugPlayer(caller)
	caller:SetHealth( caller:Health()+math.random(5,15));
	if (caller:Health()>caller:GetMaxHealth()*1.1) then
		caller:SetHealth(caller:GetMaxHealth()*1.1)
	end
	self:Remove()
end

function ENT:Think()

end

function ENT:IsDrug()
	return true
end

function ENT:OnRemove( )
	timer.Destroy(tostring(self))
end
