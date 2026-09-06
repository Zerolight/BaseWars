AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props/de_train/Barrel.mdl")

	self.Panel = ents.Create("prop_dynamic_override")
	self.Panel:SetModel( "models/props_lab/crematorcase.mdl" )
	self.Panel:SetPos(self:GetPos()+self:GetAngles():Forward()+self:GetAngles():Up()*45)
	self.Panel:SetAngles(Angle(0,0,0))
	self.Panel:SetParent(self)
	self.Panel:SetSolid(SOLID_NONE)
	self.Panel:SetMoveType(MOVETYPE_NONE)
	self.Panel:SetColor(Color(0, 255, 85, 255))

	self.Panel1 = ents.Create("prop_dynamic_override")
	self.Panel1:SetModel( "models/props_lab/reciever01a.mdl" )
	self.Panel1:SetPos(self:GetPos()+self:GetAngles():Forward()*0+self:GetAngles():Right()*-15+self:GetAngles():Up()*15)
	self.Panel1:SetAngles(Angle(0,0,90))
	self.Panel1:SetParent(self)
	self.Panel1:SetSolid(SOLID_NONE)
	self.Panel1:SetMoveType(MOVETYPE_NONE)
	self.Panel1:SetColor(Color(0, 255, 85, 255))
	self.Panel1:SetMaterial( "models/shiny" )

	self.Panel2 = ents.Create("prop_dynamic_override")
	self.Panel2:SetModel( "models/props_lab/reciever01a.mdl" )
	self.Panel2:SetPos(self:GetPos()+self:GetAngles():Forward()*0+self:GetAngles():Right()*15+self:GetAngles():Up()*15)
	self.Panel2:SetAngles(Angle(0,0,90))
	self.Panel2:SetParent(self)
	self.Panel2:SetSolid(SOLID_NONE)
	self.Panel2:SetMoveType(MOVETYPE_NONE)
	self.Panel2:SetColor(Color(0, 255, 85, 255))
	self.Panel2:SetMaterial( "models/shiny" )

	self.Panel3 = ents.Create("prop_dynamic_override")
	self.Panel3:SetModel( "models/props_lab/reciever01a.mdl" )
	self.Panel3:SetPos(self:GetPos()+self:GetAngles():Forward()*15+self:GetAngles():Right()*0+self:GetAngles():Up()*15)
	self.Panel3:SetAngles(Angle(0,90,90))
	self.Panel3:SetParent(self)
	self.Panel3:SetSolid(SOLID_NONE)
	self.Panel3:SetMoveType(MOVETYPE_NONE)
	self.Panel3:SetColor(Color(0, 255, 85, 255))
	self.Panel3:SetMaterial( "models/shiny" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	timer.Create( tostring(self), 23, 0, function() if IsValid( self ) then self:giveMoney() end end )
	timer.Create( tostring(self) .. "afkshutoff", 60, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Create( tostring(self) .. "notifyoff", 50, 1, function() if IsValid( self ) then self:notifypl() end end )
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",1000)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxNuclearPrinter=ply:GetTable().maxNuclearPrinter + 1
	self.Inactive = false
	self.NearInact = false
	self:SetNWInt("power",0)
	self.Payout = {10000000, "Printer"}
end

function ENT:giveMoney()
	local ply = (self.Owner or self:GetOwner())
	if(IsValid(ply) and not self.Inactive and self:IsPowered()) then

		local trace = { }

		trace.start = self:GetPos()+self:GetAngles():Up()*15;
		trace.endpos = trace.start + self:GetAngles():Forward() + self:GetAngles():Right()
		trace.filter = self

		local tr = util.TraceLine( trace );
		local amount = math.random( 1000000, 1001000 )
		if (self:GetNWInt("upgrade")==2) then
			amount = math.random( 2500000, 2501000 )
		elseif (self:GetNWInt("upgrade")==1) then
			amount = math.random( 1250000, 1250000 )
		end
		local moneybag = ents.Create( "prop_moneybag" );
		moneybag:SetModel( "models/props/cs_assault/Money.mdl" );
		moneybag:SetPos(self:GetPos()+self:GetAngles():Forward()*17+self:GetAngles():Right()*0+self:GetAngles():Up()*15)
		moneybag:SetAngles(Angle(0,90,90))
		moneybag:Spawn();
		moneybag:SetColor(Color(200, 255, 200, 255))
			moneybag:SetMoveType( MOVETYPE_VPHYSICS )

		moneybag:GetTable().MoneyBagN = true;
		moneybag:GetTable().Amount = amount

		local moneybag2 = ents.Create( "prop_moneybag" );
		moneybag2:SetModel( "models/props/cs_assault/Money.mdl" );
		moneybag2:SetPos(self:GetPos()+self:GetAngles():Forward()*0+self:GetAngles():Right()*17+self:GetAngles():Up()*15)
		moneybag2:SetAngles(Angle(0,0,90))
		moneybag2:Spawn();
		moneybag2:SetColor(Color(200, 255, 200, 255))
			moneybag2:SetMoveType( MOVETYPE_VPHYSICS )

		moneybag2:GetTable().MoneyBagN = true;
		moneybag2:GetTable().Amount = amount

		local moneybag3 = ents.Create( "prop_moneybag" );
		moneybag3:SetModel( "models/props/cs_assault/Money.mdl" );
		moneybag3:SetPos(self:GetPos()+self:GetAngles():Forward()*0+self:GetAngles():Right()*-17+self:GetAngles():Up()*15)
		moneybag3:SetAngles(Angle(0,0,90))
		moneybag3:Spawn();
		moneybag3:SetMoveType( MOVETYPE_VPHYSICS )
		moneybag3:SetColor(Color(200, 255, 200, 255))

		moneybag3:GetTable().MoneyBagN = true;
		moneybag3:GetTable().Amount = amount

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
	timer.Create( tostring(self) .. "afkshutoff", 60, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Destroy( tostring(self) .. "notifyoff")
	timer.Create( tostring(self) .. "notifyoff", 50, 1, function() if IsValid( self ) then self:notifypl() end end )
	self.Inactive = false
	self.NearInact = false
	self:SetColor(Color(229, 228, 226, 254))
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
		ply:GetTable().maxNuclearPrinter=ply:GetTable().maxNuclearPrinter - 1
	end
end
