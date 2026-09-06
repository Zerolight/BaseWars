AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( "drugfactory" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()
	self:SetModel( "models/props_junk/MetalBucket01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then

		phys:Wake()
	end
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",250)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxmoneyvault=ply:GetTable().maxmoneyvault + 1
	self.LastUsed = CurTime()
	self:SetNWInt("power",0)
	self.scrap = false
	self.LastUsed = CurTime()

end

function ENT:Use(activator,caller)
end

function ENT:Think()
end

function ENT:DropDrug()
end

function ENT:DropSuperDrug()
end

function ENT:EjectMoney()
end

function ENT:OnRemove( )
	self:EjectMoney()
	timer.Destroy(tostring(self))
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxmoneyvault=ply:GetTable().maxmoneyvault- 1
	end
end

function ENT:Touch(ent)
		if (ent:GetClass()=="prop_moneybag" and ent:GetClass()=="") then
			ent:Remove()
			self.Money = ent:GetTable().Amount
		end
end

function ENT:MakeScraps()
end

function ENT:CanRefine(mode,ply)
end

function ENT:SetMode(mode)
end
