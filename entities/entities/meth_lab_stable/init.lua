AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel("models/props_silo/processor.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(0, 0, 0, 1))

	self.Dish2 = ents.Create("prop_dynamic_override")
	self.Dish2:SetModel( "models/props_silo/processor.mdl" )
	self.Dish2:SetPos(self:GetPos()+self:GetAngles():Up())
	self.Dish2:SetAngles(Angle(0,0,0))
	self.Dish2:SetParent(self)
	self.Dish2:SetSolid(SOLID_NONE)
	self.Dish2:SetMoveType(MOVETYPE_NONE)

	self.Box = ents.Create("prop_dynamic_override")
	self.Box:SetModel( "models/props_junk/PlasticCrate01a.mdl" )
	self.Box:SetPos(self:GetPos()+self:GetAngles():Forward()*-43+self:GetAngles():Right()+self:GetAngles():Up()*12)
	self.Box:SetAngles(Angle(0,90,0))
	self.Box:SetParent(self)
	self.Box:SetSolid(SOLID_CUSTOM)
	self.Box:SetMoveType(MOVETYPE_NONE)

	self.Box = ents.Create("prop_dynamic_override")
	self.Box:SetModel( "models/props_junk/PlasticCrate01a.mdl" )
	self.Box:SetPos(self:GetPos()+self:GetAngles():Forward()+self:GetAngles():Right()*43+self:GetAngles():Up()*12)
	self.Box:SetAngles(Angle(0,0,0))
	self.Box:SetParent(self)
	self.Box:SetSolid(SOLID_CUSTOM)
	self.Box:SetMoveType(MOVETYPE_NONE)

	self.Box = ents.Create("prop_dynamic_override")
	self.Box:SetModel( "models/props_junk/PlasticCrate01a.mdl" )
	self.Box:SetPos(self:GetPos()+self:GetAngles():Forward()+self:GetAngles():Right()*-43+self:GetAngles():Up()*12)
	self.Box:SetAngles(Angle(0,0,0))
	self.Box:SetParent(self)
	self.Box:SetSolid(SOLID_CUSTOM)
	self.Box:SetMoveType(MOVETYPE_NONE)

	self.Box3 = ents.Create("prop_dynamic_override")
	self.Box3:SetModel( "models/props_junk/PlasticCrate01a.mdl" )
	self.Box3:SetPos(self:GetPos()+self:GetAngles():Forward()*43+self:GetAngles():Right()+self:GetAngles():Up()*12)
	self.Box3:SetAngles(Angle(0,90,0))
	self.Box3:SetParent(self)
	self.Box3:SetSolid(SOLID_CUSTOM)
	self.Box3:SetMoveType(MOVETYPE_NONE)

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	timer.Create( tostring(self), 50, 0, function() if IsValid( self ) then self:giveMoney() end end )
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
	self:SetNWInt("damage",250)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxstablemethlab=ply:GetTable().maxstablemethlab + 1
	self.Inactive = false
	self:SetNWInt("power",0)
	self.drugmaking = false
	self.Payout = {CfgVars["methlabstablecost"],"Stable Meth Lab"}
	self.Playsound = false
end

function ENT:giveMoney()
	local ply = (self.Owner or self:GetOwner())
	if self.drugmaking then
	end
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

function ENT:shutOff()
	local ply = (self.Owner or self:GetOwner())
	self.Inactive = true
	Notify( ply, 1, 3, "NOTICE: A METH LAB HAS GONE INACTIVE" );
	Notify( ply, 1, 3, "PRESS USE ON IT TO KEEP GETTING MONEY" );
	self.Dish2:SetColor(Color(255, 0, 0, 255))
end
function ENT:notifypl()
	local ply = (self.Owner or self:GetOwner())
	Notify( ply, 4, 3, "NOTICE: A METH LAB IS ABOUT TO GO INACTIVE" );
	Notify( ply, 4, 3, "PRESS USE ON IT TO PREVENT THIS" );
	self.Dish2:SetColor(Color(255, 150, 150, 255))
end

function ENT:Use(activator,caller)
	self.Playsound = true
		if self.Playsound and self.drugmaking then

		end
	self.drugmaking = true
	timer.Create( tostring(self) .. "drug", 200, 1, function() if IsValid( self ) then self:createDrug() end end )
	timer.Destroy( tostring(self) .. "afkshutoff")
	timer.Create( tostring(self) .. "afkshutoff", 1200, 1, function() if IsValid( self ) then self:shutOff() end end )
	timer.Destroy( tostring(self) .. "notifyoff")
	timer.Create( tostring(self) .. "notifyoff", 1080, 1, function() if IsValid( self ) then self:notifypl() end end )
	self.Inactive = false
	self.Dish2:SetColor(Color(255, 255, 255, 255))
end

function ENT:createDrug()
	local spos=self.SparkPos
	local spos2=self.SparkPos2
	local spos3=self.SparkPos3
	local spos4=self.SparkPos4
	local ang=self:GetAngles()
	self.drugmaking = false
	self.Playsound = false
	local drugPos = self:GetPos()

	drug = ents.Create("item_random")
	drug:SetPos(self:GetPos()+ang:Forward()*spos.x+ang:Right()*spos.y+ang:Up()*spos.z)
	drug:Spawn()
	self:SetNWBool("sparking",false)

	drug2 = ents.Create("item_random")
	drug2:SetPos(self:GetPos()+ang:Forward()*spos2.x+ang:Right()*spos2.y+ang:Up()*spos2.z)
	drug2:Spawn()

	drug3 = ents.Create("item_random")
	drug3:SetPos(self:GetPos()+ang:Forward()*spos3.x+ang:Right()*spos3.y+ang:Up()*spos3.z)
	drug3:Spawn()

	drug4 = ents.Create("item_random")
	drug4:SetPos(self:GetPos()+ang:Forward()*spos4.x+ang:Right()*spos4.y+ang:Up()*spos4.z)
	drug4:Spawn()

end

function ENT:Think()
	if self.Playsound then
		if self.drugmaking then
			self:EmitSound("ambient/levels/labs/machine_moving_loop4.wav", 50, 100)
			else
			self:StopSound("ambient/levels/labs/machine_moving_loop4.wav")
			end
		end
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	self:NextThink(CurTime()+0.1)
	return true
end

function ENT:OnRemove( )
	self:StopSound("ambient/levels/labs/machine_moving_loop4.wav")
	timer.Destroy(tostring(self))
	timer.Destroy(tostring(self) .. "drug")
	timer.Destroy(tostring(self) .. "afkshutoff")
	timer.Destroy(tostring(self) .. "notifyoff")
	self.Playsound = false
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxstablemethlab=ply:GetTable().maxstablemethlab - 1
	end
end
