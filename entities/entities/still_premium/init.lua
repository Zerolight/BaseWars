AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props/de_inferno/wine_barrel.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.Barrel1 = ents.Create("prop_dynamic_override")
	self.Barrel1:SetModel( "models/props/de_inferno/wine_barrel.mdl" )
	self.Barrel1:SetPos(self:GetPos()+self:GetAngles():Forward()*50+self:GetAngles():Right()+self:GetAngles():Up())
	self.Barrel1:SetAngles(Angle(0,0,90))
	self.Barrel1:SetParent(self)
	self.Barrel1:SetSolid(SOLID_NONE)
	self.Barrel1:SetMoveType(MOVETYPE_NONE)

	self.Barrel2 = ents.Create("prop_dynamic_override")
	self.Barrel2:SetModel( "models/props/de_inferno/wine_barrel.mdl" )
	self.Barrel2:SetPos(self:GetPos()+self:GetAngles():Forward()+self:GetAngles():Right()*50+self:GetAngles():Up())
	self.Barrel2:SetAngles(Angle(0,0,90))
	self.Barrel2:SetParent(self)
	self.Barrel2:SetSolid(SOLID_NONE)
	self.Barrel2:SetMoveType(MOVETYPE_NONE)

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	timer.Create( tostring(self), 60, 0, function() if IsValid( self ) then self:giveMoney() end end )
	timer.Create( tostring(self) .. "afkshutoff", 1800, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Create( tostring(self) .. "notifyoff", 1680, 1, function() if IsValid( self ) then self:notifypl() end end )
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",100)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxStill=ply:GetTable().maxStill + 1
	self.Inactive = false
	self:SetNWInt("power",0)
	self.Payout={CfgVars["stillcost"],"Still"}
end

function ENT:giveMoney()
	local ply = (self.Owner or self:GetOwner())
	if(ply:Alive() and not self.Inactive) then
		if (self:GetNWInt("upgrade")==2) then
			ply:AddMoney( 25 );
			Notify( ply, 2, 3, "Paid $25 for making moonshine." );
		elseif(self:GetNWInt("upgrade")==1) then
			ply:AddMoney( 15 );
			Notify( ply, 2, 3, "Paid $15 for making moonshine." );
		else
			ply:AddMoney( 10 );
			Notify( ply, 2, 3, "Paid $10 for making moonshine." );
		end
	elseif (self.Inactive) then
		Notify( ply, 4, 3, "A still is inactive, press use on it to make it active again." );
	end
end

function ENT:shutOff()
	local ply = (self.Owner or self:GetOwner())
	self.Inactive = true
	Notify( ply, 1, 3, "NOTICE: A STILL HAS GONE INACTIVE" );
	Notify( ply, 1, 3, "PRESS USE ON IT TO CONTINUE GETTING MONEY" );
	self:SetColor(Color(255, 0, 0, 255))
end
function ENT:notifypl()
	local ply = (self.Owner or self:GetOwner())
	Notify( ply, 4, 3, "NOTICE: A STILL IS ABOUT TO GO INACTIVE" );
	Notify( ply, 4, 3, "PRESS USE ON IT TO PREVENT THIS" );
	self:SetColor(Color(255, 150, 150, 255))
end

function ENT:Use(activator,caller)
	self:SetNWBool("sparking",true)
	timer.Create( tostring(self) .. "drug", 30, 1, function() if IsValid( self ) then self:createDrug() end end )
	timer.Destroy( tostring(self) .. "afkshutoff")
	timer.Create( tostring(self) .. "afkshutoff", 1800, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Destroy( tostring(self) .. "notifyoff")
	timer.Create( tostring(self) .. "notifyoff", 1680, 1, function() if IsValid( self ) then self:notifypl() end end )
	self.Inactive = false
	self:SetColor(Color(255, 255, 255, 255))
end

function ENT:createDrug()
	local ang = self:GetAngles()
	local spos = self.SparkPos
	drug = ents.Create("item_booze")
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

function ENT:OnRemove( )
	timer.Destroy(tostring(self))
	timer.Destroy(tostring(self) .. "drug")
	timer.Destroy(tostring(self) .. "afkshutoff")
	timer.Destroy(tostring(self) .. "notifyoff")
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxStill=ply:GetTable().maxStill - 1
	end
end
