AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props_vehicles/generatortrailer01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self:SetNWInt("damage",300)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxgenerator=ply:GetTable().maxgenerator + 1
	self.Inactive = false
	self.Powdist=1024
	self:SetNWEntity("socket1",nil)
	self:SetNWEntity("socket2",nil)
	self:SetNWEntity("socket3",nil)
	self:SetNWEntity("socket4",nil)
	self:SetNWEntity("socket5",nil)
	self.scrap = false
	timer.Create( tostring(self), 60, 0, function() if IsValid( self ) then self:giveMoney() end end )
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
end

function ENT:giveMoney()
	local ply = (self.Owner or self:GetOwner())
	if(IsValid(ply) and not self.Inactive) then
		if ply:CanAfford(5) then
			ply:AddMoney( -5 );
			Notify( ply, 2, 3, "$5 spent to keep Generator running." );
		else
			Notify( ply, 4, 3, "Generator has shut off from lack of money" )
			self:shutOff()
			timer.Destroy( tostring(self) .. "afkshutoff")
			timer.Destroy( tostring(self) .. "notifyoff")
		end
	elseif (self.Inactive) then
		Notify( ply, 4, 3, "A Generator is inactive, press use on it to make it active again." );
	end
end

function ENT:shutOff()
	local ply = (self.Owner or self:GetOwner())
	self.Inactive = true
	Notify( ply, 1, 3, "NOTICE: A GENERATOR HAS GONE INACTIVE" );
	Notify( ply, 1, 3, "PRESS USE ON IT TO MAKE IT WORK AGAIN" );
	self:SetColor(Color(255, 0, 0, 255))
end
function ENT:notifypl()
	local ply = (self.Owner or self:GetOwner())
	Notify( ply, 4, 3, "NOTICE: A GENERATOR IS ABOUT TO GO INACTIVE" );
	Notify( ply, 4, 3, "PRESS USE ON IT TO KEEP IT WORKING" );
	self:SetColor(Color(255, 150, 150, 255))
end

function ENT:Use(activator,caller)
	if activator:CanAfford(5) and activator==(self.Owner or self:GetOwner()) then
		timer.Destroy( tostring(self) .. "afkshutoff")
		timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
		timer.Destroy( tostring(self) .. "notifyoff")
		timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
		self.Inactive = false
		self:SetColor(Color(255, 255, 255, 255))
	end
end

function ENT:createDrug()
	local drugPos = self:GetPos()
	drug = ents.Create("item_drug")
	drug:SetPos(Vector(drugPos.x,drugPos.y,drugPos.z + 10))
	drug:Spawn()
	self:SetNWBool("sparking",false)
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	self:UpdateSockets()
	self:NextThink(CurTime()+1)
	return true
end

function ENT:OnRemove( )
	self:UnSocket()
	timer.Destroy(tostring(self))
	timer.Destroy(tostring(self) .. "afkshutoff")
	timer.Destroy(tostring(self) .. "notifyoff")
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxgenerator=ply:GetTable().maxgenerator - 1
	end
end

function ENT:UpdateSockets()
	if self.Inactive then
		self:UnSocket()
		for i=1,5,1 do
			self:SetNWEntity("socket"..tostring(i),ents.GetByIndex(0))
		end
	else
		for i=1,5,1 do
			if not IsValid(self:GetNWEntity("socket"..tostring(i))) then
				local newstructure = self:FindStructure()
				if IsValid(newstructure) then
					self:SetNWEntity("socket"..tostring(i), newstructure)
					newstructure:SetNWInt("power", newstructure:GetNWInt("power")+1)
				end
			end
		end
		for i=1,5,1 do
			if IsValid(self:GetNWEntity("socket"..tostring(i))) and self:GetNWEntity("socket"..tostring(i)):GetPos():Distance(self:GetPos())>self.Powdist then
				self:GetNWEntity("socket"..tostring(i)):SetNWInt("power", self:GetNWEntity("socket"..tostring(i)):GetNWInt("power")-1)

				self:SetNWEntity("socket"..tostring(i),ents.GetByIndex(0))
			end
		end
	end
end

function ENT:FindStructure()
	for k, v in pairs( ents.FindInSphere(self:GetPos(), self.Powdist)) do
		if v:GetTable().Structure and v:GetNWInt("power")<v:GetTable().Power and v:GetPos():Distance(self:GetPos())<=self.Powdist then
			return v
		end
	end
	return nil
end

function ENT:MakeScraps()
end

function ENT:UnSocket()
	for i=1,5,1 do
		if IsValid(self:GetNWEntity("socket"..tostring(i))) then
			self:GetNWEntity("socket"..tostring(i)):SetNWInt("power", self:GetNWEntity("socket"..tostring(i)):GetNWInt("power")-1)
		end
	end
end
