AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props_wasteland/gaspump001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(0, 0, 0, 1))

	self.Dish2 = ents.Create("prop_dynamic_override")
	self.Dish2:SetModel( "models/props_wasteland/gaspump001a.mdl" )
	self.Dish2:SetPos(self:GetPos()+self:GetAngles():Up())
	self.Dish2:SetAngles(Angle(0,0,0))
	self.Dish2:SetParent(self)
	self.Dish2:SetSolid(SOLID_NONE)
	self.Dish2:SetMoveType(MOVETYPE_NONE)

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end

	self.Dish = ents.Create("prop_dynamic_override")
	self.Dish:SetModel( "models/props_rooftop/roof_dish001.mdl" )
	self.Dish:SetPos(self:GetPos()+self:GetAngles():Forward()*-5+self:GetAngles():Up()*25)

	self.Dish:SetParent(self)
	self.Dish:SetSolid(SOLID_NONE)

	self.Dish:SetMoveType(MOVETYPE_NONE)

	timer.Create( tostring(self), 120, 0, function() if IsValid( self ) then self:giveMoney() end end )
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
	self:SetNWInt("damage",250)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxtower=ply:GetTable().maxtower + 1
	ply:GetTable().Tower = self
	self.Inactive = false
	self:SetNWInt("power",0)
	self.Payout={CfgVars["radartowercost"],"Radar Tower"}
	self.Scans = 1
	self:SetNWInt("scans", self.Scans)
	self.scrap = false
	self.BombNotify=false
end

function ENT:giveMoney()
	local ply = (self.Owner or self:GetOwner())
	if(ply:Alive() and not self.Inactive) then
		self.Scans = self.Scans + 1
		if self.Scans>10 then
			Notify( ply, 4, 3, "Radar tower is fully charged at 10 charges.")
			self.Scans = 10
		else

			if self.Scans~=1 then
				Notify( ply, 2, 3, "Radar tower is ready to scan. " .. self.Scans .. " Charges available.")
			else
				Notify( ply, 2, 3, "Radar tower is ready to scan. 1 Charge available.")
			end
		end
	elseif (self.Inactive) then
		Notify( ply, 4, 3, "A radar tower is inactive, press use on it for it to continue charging" );
	end
end

function ENT:shutOff()
	local ply = (self.Owner or self:GetOwner())
	self.Inactive = true
	Notify( ply, 1, 3, "NOTICE: A RADAR TOWER HAS GONE INACTIVE" );
	Notify( ply, 1, 3, "PRESS USE ON IT FOR IT TO BE ABLE TO KEEP CHARGING" );
	self.Dish:SetColor(Color(255, 0, 0, 255))
	self.Dish2:SetColor(Color(255, 0, 0, 255))
end

function ENT:notifypl()
	local ply = (self.Owner or self:GetOwner())
	Notify( ply, 4, 3, "NOTICE: A RADAR TOWER IS ABOUT TO GO INACTIVE" );
	Notify( ply, 4, 3, "PRESS USE ON IT TO KEEP IT CHARGING" );
	self.Dish:SetColor(Color(255, 150, 150, 255))
	self.Dish2:SetColor(Color(255, 150, 150, 255))
end

function ENT:MakeScraps()

end

function ENT:Use(activator,caller)
	timer.Destroy( tostring(self) .. "afkshutoff")
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Destroy( tostring(self) .. "notifyoff")
	timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
	self.Inactive = false
	self.Dish:SetColor(Color(255, 255, 255, 255))
	self.Dish2:SetColor(Color(255, 255, 255, 255))
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	self:NextThink(CurTime()+0.1)
	self:SetNWInt("scans", self.Scans)
	local pos = self:GetPos()
	local sawbomb=false
	for k,v in pairs(ents.FindByClass("bigbomb")) do
		if v:GetPos():Distance(pos)<2048 then
			sawbomb=true
			if not self.BombNotify then
				Notify((self.Owner or self:GetOwner()),1,3, "Radar tower has detected a Big Bomb")
				self.BombNotify=true
			end
		end
	end
	if not sawbomb then self.BombNotify=false end
	return true
end

function ENT:OnRemove( )
	timer.Destroy(tostring(self))
	timer.Destroy(tostring(self) .. "afkshutoff")
	timer.Destroy(tostring(self) .. "notifyoff")
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxtower=ply:GetTable().maxtower - 1
	end
end
