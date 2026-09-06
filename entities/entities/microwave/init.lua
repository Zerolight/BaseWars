AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props/cs_office/microwave.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",300)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxMicrowaves=ply:GetTable().maxMicrowaves + 1
	self:SetNWInt("power",0)
end

function ENT:Use(activator,caller)
	if self:IsPowered() then
		self:SetNWEntity( "user", activator )
		self:SetNWBool("sparking",true)
		timer.Create( tostring(self) .. "food", 1, 1, function() if IsValid( self ) then self:createFood() end end )
	end
end

function ENT:createFood()
	local spos = self.SparkPos
	local ang = self:GetAngles()
	local foodPos = self:GetPos()
	food = ents.Create("item_food")
	food:SetPos(self:GetPos()+ang:Forward()*spos.x+ang:Right()*spos.y+ang:Up()*spos.z)
	food:Spawn()
	local activator = self:GetNWEntity( "user" )
	self:SetNWBool("sparking",false)
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
end

function ENT:OnRemove( )
	timer.Destroy(tostring(self).."food")
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxMicrowaves=ply:GetTable().maxMicrowaves - 1
	end
end
