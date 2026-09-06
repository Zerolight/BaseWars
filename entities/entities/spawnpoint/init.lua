AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

    self:SetModel( "models/props_trainstation/trainstation_clock001.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetAngles(Angle(-90, 0, 0))
    local ply = (self.Owner or self:GetOwner())
    local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)
    if(phys:IsValid()) then phys:Wake() end
    self:SetNWInt("damage",100)
    local spawnpointp = true
    ply:GetTable().maxspawn = ply:GetTable().maxspawn + 1
    ply:GetTable().Spawnpoint = self
	self:SetNWInt("power",0)
end

function ENT:Think( )
	if (IsValid((self.Owner or self:GetOwner()))~=true) then
		self:Remove()
	end
end

function ENT:OnRemove( )
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxspawn = ply:GetTable().maxspawn - 1
	end
end
