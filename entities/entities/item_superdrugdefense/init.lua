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
	if not caller:GetTable().Superdrugoffense and not caller:GetTable().Superdrugdefense and not caller:GetTable().Superdrugweapmod then
		caller:SetNWBool("superdrug", true)

		Regenup(caller, CfgVars["superduration"])
		Antidoteup(caller, CfgVars["superduration"])
		PainKillerup(caller, CfgVars["superduration"])
		Mirrorup(caller, CfgVars["superduration"])
		Adrenalineup(caller, CfgVars["superduration"])
		Randup(caller,CfgVars["superduration"])
		Superup(caller,CfgVars["superduration"],"defense")

		caller:SetNWBool("superdrug", false)
		self:Remove()
	end
end

function ENT:Think()
end

function ENT:OnTakeDamage(dmg)
end
