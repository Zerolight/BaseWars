AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( "item_helmet" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()
	self:SetModel( "models/props/de_tides/vending_hat.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(150, 140, 100, 255))
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self.Time = CurTime()
end

function ENT:OnTakeDamage(dmg)
end

function ENT:Use(activator,caller)
	if (caller:GetNWBool("helmeted")==false) then
		caller:SetNWBool("helmeted", true)
		self:Remove()
	end
end

function ENT:Think()

end
