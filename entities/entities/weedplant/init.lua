AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props/cs_office/plant01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	timer.Create( tostring(self), 60, 0, function() if IsValid( self ) then self:giveMoney() end end )
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Create( tostring(self) .. "notifyoff", 600, 1, function() if IsValid( self ) then self:notifypl() end end )
	self:SetNWInt("damage",110)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxweed=ply:GetTable().maxweed + 1
	self.Inactive = false
	self:SetNWInt("power",0)
	self.Hemp = false
	self.Payout = {CfgVars["weedcost"],"Plant"}
end

function ENT:giveMoney()
	local ply = (self.Owner or self:GetOwner())

	if(ply:Alive() and not self.Inactive) then
		if self.Hemp==true then
			if (self:GetNWInt("upgrade")==2) then
				ply:AddMoney( 20 );
				Notify( ply, 2, 3, "Paid $20 for selling drugs." );
			elseif(self:GetNWInt("upgrade")==1) then
				ply:AddMoney( 15 );
				Notify( ply, 2, 3, "Paid $15 for selling drugs." );
			else
				ply:AddMoney( 10 );
				Notify( ply, 2, 3, "Paid $10 for selling drugs." );
			end
		else
			if (self:GetNWInt("upgrade")==2) then
				ply:AddMoney( 75 );
				Notify( ply, 2, 3, "Paid $75 for selling drugs." );
			elseif(self:GetNWInt("upgrade")==1) then
				ply:AddMoney( 50 );
				Notify( ply, 2, 3, "Paid $50 for selling drugs." );
			else
				ply:AddMoney( 25 );
				Notify( ply, 2, 3, "Paid $25 for selling drugs." );
			end
		end
	end

end

function ENT:shutOff()
	local ply = (self.Owner or self:GetOwner())
	self.Inactive = true
	Notify( ply, 1, 3, "NOTICE: A PLANT HAS DIED FROM LACK OF WATER" );
	self:Remove()
end
function ENT:notifypl()
	local ply = (self.Owner or self:GetOwner())
	Notify( ply, 4, 3, "NOTICE: A PLANT NEEDS WATER" );
	Notify( ply, 4, 3, "PRESS USE ON IT TO WATER IT" );
	self:SetColor(Color(255, 150, 0, 255))
end

function ENT:Explode()

end

function ENT:Use(activator,caller)
	timer.Create( tostring(self) .. "drug", 30, 1, function() if IsValid( self ) then self:createDrug() end end )
	timer.Destroy( tostring(self) .. "afkshutoff")
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Destroy( tostring(self) .. "notifyoff")
	timer.Create( tostring(self) .. "notifyoff", 600, 1, function() if IsValid( self ) then self:notifypl() end end )
	self.Inactive = false
	if self.Hemp then
		self:SetColor(Color(200, 255, 200, 255))
	else
		self:SetColor(Color(255, 255, 255, 255))
	end
end

function ENT:createDrug()

end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	self:NextThink(CurTime()+0.1)
	return true
end

function ENT:OnRemove( )
	timer.Destroy(tostring(self))
	timer.Destroy(tostring(self) .. "drug")
	timer.Destroy(tostring(self) .. "afkshutoff")
	timer.Destroy(tostring(self) .. "notifyoff")
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxweed=ply:GetTable().maxweed - 1
	end
end

function ENT:Worthless()
	self.Hemp=true
	self:SetNWInt("damage",40)
	self:SetColor(Color(200, 255, 200, 255))
end
