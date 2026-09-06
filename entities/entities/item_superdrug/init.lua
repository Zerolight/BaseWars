AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( "item_superdrug" )
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
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self.Time = CurTime()
end

function ENT:Use(activator,caller)
	caller:SetNWBool("superdrug", true)
	if (caller:GetTable().Regened ~= true) then
		Regenup(caller, CfgVars["superduration"])
	end
	if (caller:GetTable().Roided ~= true) then
		Roidup(caller, CfgVars["superduration"])
	end
	if (caller:GetTable().Amp ~= true) then
		Ampup(caller, CfgVars["superduration"])
	end
	if (caller:GetTable().PainKillered ~= true) then
		PainKillerup(caller, CfgVars["superduration"])
	end
	if (caller:GetTable().Mirror ~= true) then
		Mirrorup(caller, CfgVars["superduration"])
	end
	if (caller:GetTable().Focus ~= true) then
		Focusup(caller, CfgVars["superduration"])
	end

	if (caller:GetTable().Antidoted ~= true) then
		Antidoteup(caller, CfgVars["superduration"])
	end
	caller:SetNWBool("superdrug", false)
	self:Remove()
end

function ENT:Think()
end

function ENT:OnTakeDamage(dmg)
end
