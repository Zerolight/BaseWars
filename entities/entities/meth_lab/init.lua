AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props/de_train/processor_nobase.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	timer.Create( tostring(self), 60, 0, function() if IsValid( self ) then self:giveMoney() end end )
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
	self:SetNWInt("damage",50)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxmethlab=ply:GetTable().maxmethlab + 1
	self.Inactive = false
	self:SetNWInt("power",0)
	self.drugmaking = false
	self.Payout = {CfgVars["methlabcost"], "Meth Lab"}
end

function ENT:giveMoney()
	local ply = (self.Owner or self:GetOwner())
	local explodechance = 0.05
	if self.drugmaking then
		explodechance = 0.1
	end
	if math.Rand(0,1)<explodechance then
		util.BlastDamage( self, (self.Owner or self:GetOwner()), self:GetPos(), 384, 55 )

		local vPoint = self:GetPos()
			local effectdata = EffectData()
			effectdata:SetStart( vPoint )
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 1 )
		util.Effect( "Explosion", effectdata )
		self:Remove()
		Notify( ply, 1, 3, "A METH LAB HAS BLOWN UP!" );
	else
		if(ply:Alive() and not self.Inactive) then
			if (self:GetNWInt("upgrade")==2) then
				ply:AddMoney( 500 );
				Notify( ply, 2, 3, "Paid $500 for selling drugs." );
			elseif(self:GetNWInt("upgrade")==1) then
				ply:AddMoney( 250 );
				Notify( ply, 2, 3, "Paid $250 for selling drugs." );
			else
				ply:AddMoney( 100 );
				Notify( ply, 2, 3, "Paid $100 for selling drugs." );
			end
		elseif (self.Inactive) then
			Notify( ply, 4, 3, "A meth lab is inactive, press use on it to make it active again." );
		end
	end
end

function ENT:shutOff()
	local ply = (self.Owner or self:GetOwner())
	self.Inactive = true
	Notify( ply, 1, 3, "NOTICE: A METH LAB HAS GONE INACTIVE" );
	Notify( ply, 1, 3, "PRESS USE ON IT TO KEEP GETTING MONEY" );
	self:SetColor(Color(255, 0, 0, 255))
end
function ENT:notifypl()
	local ply = (self.Owner or self:GetOwner())
	Notify( ply, 4, 3, "NOTICE: A METH LAB IS ABOUT TO GO INACTIVE" );
	Notify( ply, 4, 3, "PRESS USE ON IT TO PREVENT THIS" );
	self:SetColor(Color(255, 150, 150, 255))
end

function ENT:Use(activator,caller)
	self:SetNWBool("sparking",true)
	self.drugmaking = true
	timer.Create( tostring(self) .. "drug", 30, 1, function() if IsValid( self ) then self:createDrug() end end )
	timer.Destroy( tostring(self) .. "afkshutoff")
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Destroy( tostring(self) .. "notifyoff")
	timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
	self.Inactive = false
	self:SetColor(Color(255, 255, 255, 255))
end

function ENT:createDrug()
	local spos=self.SparkPos
	local ang=self:GetAngles()
	self.drugmaking = false
	local drugPos = self:GetPos()
	drug = ents.Create("item_random")
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
		ply:GetTable().maxmethlab=ply:GetTable().maxmethlab - 1
	end
end
