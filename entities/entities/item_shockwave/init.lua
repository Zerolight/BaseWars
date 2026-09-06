AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( "item_doubletap" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()

	self:SetModel( "models/props_lab/jar01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(150, 125, 75, 255))
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self:SetVar("damage",20)
	self.Time = CurTime()
end

function ENT:Use(activator,caller)
	if (caller:GetTable().ShockWaved ~= true) then
		ShockWaveup(caller)
		self:Remove()
	end
end

function ENT:Think()

end
