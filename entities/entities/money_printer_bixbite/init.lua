AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_lab/citizenradio.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then phys:Wake() end
	timer.Create( tostring(self), 125, 0, function() if IsValid( self ) then self:giveMoney() end end )
	timer.Create( tostring(self) .. "afkshutoff", 1500, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Create( tostring(self) .. "notifyoff", 1400, 1, function() if IsValid( self ) then self:notifypl() end end )
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",1000)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxBixbitePrinter=ply:GetTable().maxBixbitePrinter + 1
	self.Inactive = false
	self.NearInact = false
	self:SetNWInt("power",0)
	self.Payout = {2000000, "Bixbite Printer"}
end

function ENT:giveMoney()
	local ply = (self.Owner or self:GetOwner())
	if(IsValid(ply) and not self.Inactive and self:IsPowered()) then

		local trace = { }

		trace.start = self:GetPos()+self:GetAngles():Up()*15;
		trace.endpos = trace.start + self:GetAngles():Forward() + self:GetAngles():Right()
		trace.filter = self

		local tr = util.TraceLine( trace );
		local amount = math.random( 150000, 150100 )
		if (self:GetNWInt("upgrade")==2) then
			amount = math.random( 400000, 400100 )
		elseif (self:GetNWInt("upgrade")==1) then
			amount = math.random( 200000, 200100 )
		end
		local moneybag = ents.Create( "prop_moneybag" );
		moneybag:SetModel( "models/props/cs_assault/Money.mdl" );
		moneybag:SetPos( tr.HitPos );
		moneybag:SetAngles(self:GetAngles())
		moneybag:Spawn();
		moneybag:SetColor(Color(200, 255, 200, 255))

		moneybag:SetMoveType( MOVETYPE_VPHYSICS )
		moneybag:GetTable().MoneyBag = true;
		moneybag:GetTable().Amount = amount

		Notify( ply, 0, 3, "Counterfeit money printer created $" .. amount );
	elseif (self.Inactive) then
		Notify( ply, 4, 3, "A money printer is inactive, press use on it to make it active again." );
	elseif not self:IsPowered() then
		Notify(ply, 4, 3, "A money printer does not have enough power. Get a power plant.")
	end
end

function ENT:shutOff()
	local ply = (self.Owner or self:GetOwner())
	self.Inactive = true
	Notify( ply, 1, 3, "NOTICE: A MONEY PRINTER HAS GONE INACTIVE" );
	Notify( ply, 1, 3, "PRESS USE ON IT TO CONTINUE GETTING MONEY" );
	self:SetColor(Color(255, 0, 0, 254))
end
function ENT:notifypl()
	self.NearInact = true
	local ply = (self.Owner or self:GetOwner())
	Notify( ply, 4, 3, "NOTICE: A MONEY PRINTER IS ABOUT TO GO INACTIVE" );
	Notify( ply, 4, 3, "PRESS USE ON IT TO PREVENT THIS" );
	self:SetColor(Color(255, 150, 150, 254))
end

function ENT:Use(activator,caller)
	local ply = (self.Owner or self:GetOwner())
	if (self.NearInact==true and activator==ply and self:GetNWBool("sparking")==false and ply:CanAfford(40)) then
		ply:AddMoney( -40 )
		self.NearInact = false
		self:SetNWBool("sparking",true)
		timer.Create( tostring(self) .. "resupply", 1, 1, function() if IsValid( self ) then self:Reload() end end )

	end
end

function ENT:Reload()
	Notify((self.Owner or self:GetOwner()), 0, 3, "Counterfeit money printer resupplied")
	timer.Destroy( tostring(self) .. "afkshutoff")
	timer.Create( tostring(self) .. "afkshutoff", 500, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Destroy( tostring(self) .. "notifyoff")
	timer.Create( tostring(self) .. "notifyoff", 400, 1, function() if IsValid( self ) then self:notifypl() end end )
	self.Inactive = false
	self.NearInact = false
	self:SetColor(Color(255, 200, 200, 255))
	local drugPos = self:GetPos()
	self:SetNWBool("sparking",false)
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
end

function ENT:OnRemove( )
	timer.Destroy(tostring(self))
	timer.Destroy(tostring(self) .. "afkshutoff")
	timer.Destroy(tostring(self) .. "notifyoff")
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxBixbitePrinter=ply:GetTable().maxBixbitePrinter - 1
	end
end
