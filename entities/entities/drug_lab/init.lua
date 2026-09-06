AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props_combine/combine_mine01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	timer.Create( tostring(self), 180, 0, function() if IsValid( self ) then self:giveMoney() end end )
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",250)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxDrug=ply:GetTable().maxDrug + 1
	self.Inactive = false
	self.unowned = false
	self:SetNWInt("power",0)
	self.Payout={CfgVars["druglabcost"],"Drug Lab"}
end

function ENT:giveMoney()
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		if (self.Inactive) then
			Notify( ply, 4, 3, "A drug lab is inactive, press use on it to make it active again." );
		end
		if not self.Inactive then
			if (self:GetNWInt("upgrade")==5) then
				ply:AddMoney( 2500 );
				Notify( ply, 2, 3, "Paid $2500 for selling drugs." );
			elseif (self:GetNWInt("upgrade")==4) then
				ply:AddMoney( 1000 );
				Notify( ply, 2, 3, "Paid $1000 for selling drugs." );
			elseif (self:GetNWInt("upgrade")==3) then
				ply:AddMoney( 500 );
				Notify( ply, 2, 3, "Paid $500 for selling drugs." );
			elseif (self:GetNWInt("upgrade")==2) then
				ply:AddMoney( 250 );
				Notify( ply, 2, 3, "Paid $250 for selling drugs." );
			elseif(self:GetNWInt("upgrade")==1) then
				ply:AddMoney( 100 );
				Notify( ply, 2, 3, "Paid $100 for selling drugs." );
			else
				ply:AddMoney( 50 );
				Notify( ply, 2, 3, "Paid $50 for selling drugs." );
			end
		end
	end
end

function ENT:shutOff()
	local ply = (self.Owner or self:GetOwner())
	self.Inactive = true
	if IsValid(ply) then
		Notify( ply, 1, 3, "NOTICE: A DRUG LAB HAS GONE INACTIVE" );
		Notify( ply, 1, 3, "PRESS USE ON IT TO CONTINUE GETTING MONEY" );
		self:SetColor(Color(255, 0, 0, 255))
	end
end
function ENT:notifypl()
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		Notify( ply, 4, 3, "NOTICE: A DRUG LAB IS ABOUT TO GO INACTIVE" );
		Notify( ply, 4, 3, "PRESS USE ON IT TO PREVENT THIS" );
		self:SetColor(Color(255, 150, 150, 255))
	end
end

function ENT:Use(activator,caller)
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		self:SetNWBool("sparking",true)
		if (self:GetNWInt("upgrade")==5) then
			timer.Create( tostring(self) .. "drug", 5, 1, function() if IsValid( self ) then self:createDrug() end end )
		end
		if (self:GetNWInt("upgrade")==4) then
			timer.Create( tostring(self) .. "drug", 10, 1, function() if IsValid( self ) then self:createDrug() end end )
		end
		if (self:GetNWInt("upgrade")==3) then
			timer.Create( tostring(self) .. "drug", 15, 1, function() if IsValid( self ) then self:createDrug() end end )
		end
		if (self:GetNWInt("upgrade")==2) then
			timer.Create( tostring(self) .. "drug", 20, 1, function() if IsValid( self ) then self:createDrug() end end )
		end
		if (self:GetNWInt("upgrade")==1) then
			timer.Create( tostring(self) .. "drug", 25, 1, function() if IsValid( self ) then self:createDrug() end end )
		end
		if (self:GetNWInt("upgrade")==0) then
			timer.Create( tostring(self) .. "drug", 30, 1, function() if IsValid( self ) then self:createDrug() end end )
		end
		timer.Destroy( tostring(self) .. "afkshutoff")
		timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
		timer.Destroy( tostring(self) .. "notifyoff")
		timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
		self.Inactive = false
		self:SetColor(Color(255, 255, 255, 255))
	end
end

function ENT:createDrug()
	local spos = self.SparkPos
	local ang = self:GetAngles()
	drug = ents.Create("item_drug")
	drug:SetPos(self:GetPos()+ang:Forward()*spos.x+ang:Right()*spos.y+ang:Up()*spos.z)
	drug:Spawn()
	self:SetNWBool("sparking",false)
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	self:NextThink(CurTime()+0.1)
	return true
end

function ENT:noOwner()
	self.Inactive = true
	self:SetColor(Color(0, 255, 0, 255))
	timer.Destroy(tostring(self) .. "drug")
	timer.Destroy(tostring(self) .. "afkshutoff")
	timer.Destroy(tostring(self) .. "notifyoff")
	timer.Create( tostring(self) .. "findowner", 10, 12, function() if IsValid( self ) then self:ownerTick() end end )
	timer.Create( tostring(self) .. "fail", 120, 1, function() if IsValid( self ) then self:Remove() end end )
end

function ENT:ownerTick()
	local ply = (self.Owner or self:GetOwner())
	if (IsValid(ply)) then
		self.unowned = false
		Notify(ply,0,3,"A Drug Lab is inactive where you left it")
		timer.Destroy(tostring(self) .. "findowner")
		timer.Destroy(tostring(self) .. "fail")
		self:SetColor(Color(255, 0, 0, 255))
		ply:GetTable().maxDrug=ply:GetTable().maxDrug + 1
	end
end

function ENT:OnRemove( )
	timer.Destroy(tostring(self) .. "findowner")
	timer.Destroy(tostring(self) .. "fail")
	timer.Destroy(tostring(self))
	timer.Destroy(tostring(self) .. "drug")
	timer.Destroy(tostring(self) .. "afkshutoff")
	timer.Destroy(tostring(self) .. "notifyoff")
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxDrug=ply:GetTable().maxDrug - 1
	end
end
