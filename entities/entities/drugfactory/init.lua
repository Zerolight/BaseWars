AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( "drugfactory" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()
	self:SetModel( "models/props_c17/furniturestove001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then

		phys:Wake()
	end
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",250)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxdrugfactory=ply:GetTable().maxdrugfactory + 1
	self.LastUsed = CurTime()
	self.Booze = 0
	self.Drugs = 0
	self.RandomDrugs = 0
	self.SOffense = 0
	self.SDefense = 0
	self.SWeapmod = 0
	self:SetNWInt("power",0)
	self.scrap = false
	self.Refmode = 0
end

function ENT:Use(activator,caller)
	if self.LastUsed>CurTime() then
		self.LastUsed = CurTime()+0.3
		return
	end
	self.LastUsed = CurTime()+0.3

	net.Start("killdrugfactorygui");
		net.WriteInt( self:EntIndex() , 16)
	net.Send(activator)
	net.Start("drugfactorygui");
		net.WriteInt( self:GetNWInt("upgrade") , 16)
		net.WriteInt( self:EntIndex() , 16)
		net.WriteInt( self.Booze , 16)
		net.WriteInt( self.Drugs , 16)
		net.WriteInt( self.RandomDrugs , 16)
		net.WriteInt( self.SDefense , 16)
		net.WriteInt( self.SOffense , 16)
		net.WriteInt( self.SWeapmod , 16)
		net.WriteInt( self.Refmode , 16)
	net.Send(activator)
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
end

function ENT:DropDrug()
	local drug = ents.Create("item_random")
	drug:SetPos( self:GetPos()+Vector(0,0,50));
	drug:Spawn();
end

function ENT:DropSuperDrug()
	if self.Refmode==0 then
		Notify((self.Owner or self:GetOwner()),2,3,"Paid $10000 from refining drugs")
		local owner = (self.Owner or self:GetOwner())
		owner:AddMoney(10000)
	else
		local stype = "offense"
		if self.Refmode==2 then stype="defense" elseif self.Refmode==3 then stype="weapmod" end
		local drug = ents.Create("item_superdrug"..stype)
		drug:SetPos( self:GetPos()+Vector(0,0,50));
		drug:Spawn();
	end
end

function ENT:EjectSuperDrugs()
	for i=1,self.SOffense,1 do
		local drug = ents.Create("item_superdrugoffense")
		drug:SetPos( self:GetPos()+Vector((i*10)-10,10,50));
		drug:Spawn();
	end
	self.SOffense=0
	for i=1,self.SDefense,1 do
		local drug = ents.Create("item_superdrugdefense")
		drug:SetPos( self:GetPos()+Vector((i*10)-10,0,50));
		drug:Spawn();
	end
	self.SDefense=0
	for i=1,self.SWeapmod,1 do
		local drug = ents.Create("item_superdrugweapmod")
		drug:SetPos( self:GetPos()+Vector((i*10)-10,-10,50));
		drug:Spawn();
	end
	self.SWeapmod=0
end

function ENT:DropUberDrug()
	local drug = ents.Create("item_uberdrug")
	drug:SetPos( self:GetPos()+Vector(0,0,50));
	drug:Spawn();
end

function ENT:OnRemove( )
	self:EjectSuperDrugs()
	timer.Destroy(tostring(self))
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxdrugfactory=ply:GetTable().maxdrugfactory - 1
	end
end

function ENT:Touch(gun)
	if self:IsPowered() then
		local upgrade = self:GetNWInt("upgrade")
		local drugamt = 25
		local randamt = 10
		local boozeamt = 25
		if (upgrade==1) then
			drugamt = 25
			boozeamt = 25
		elseif (upgrade==2) then
			drugamt = 15
			boozeamt = 15
		end
		if (gun:GetClass()=="item_booze" and gun:GetTime()<CurTime()-5) then
			self.Booze=self.Booze+1
			if (self.Booze>=boozeamt) then
				self.Booze = 0
				self.Drugs = self.Drugs+1
				if (self.Drugs>=drugamt) then
					self.Drugs = 0
					self:DropDrug()
				end
			end
			gun:ResetTime()
			gun:Remove()
		end
		if (gun:GetClass()=="item_drug" and gun:GetTime()<CurTime()-5) then
			self.Drugs=self.Drugs+1
			if (self.Drugs>=drugamt) then
				self.Drugs = 0
				self:DropDrug()
			end
			gun:ResetTime()
			gun:Remove()
		end
		if (gun:GetClass()=="item_random" and upgrade>=1 and gun:GetTime()<CurTime()-5) then
			self.RandomDrugs=self.RandomDrugs+1
			if (self.RandomDrugs>=randamt) then
				self.RandomDrugs = 0
				self:DropSuperDrug()
			end
			gun:ResetTime()
			gun:Remove()
		end
		if upgrade>=2 then
			if (gun:GetClass()=="item_superdrugoffense" and gun:GetTime()<CurTime()-5 and self.SOffense<3) then
				self.SOffense=self.SOffense+1
				gun:ResetTime()
				gun:Remove()
			end
			if (gun:GetClass()=="item_superdrugdefense" and gun:GetTime()<CurTime()-5 and self.SDefense<3) then
				self.SDefense=self.SDefense+1
				gun:ResetTime()
				gun:Remove()
			end
			if (gun:GetClass()=="item_superdrugweapmod" and gun:GetTime()<CurTime()-5 and self.SWeapmod<3) then
				self.SWeapmod=self.SWeapmod+1
				gun:ResetTime()
				gun:Remove()
			end
		end
	end
end

function ENT:MakeScraps()

end

function ENT:CanRefine(mode,ply)
	if ply~=(self.Owner or self:GetOwner()) and mode~="eject" then
		return "Only the owner of this Drug Refinery can change settings."
	end
	if not self:IsPowered() and mode=="uber" then
		return "Low power."
	end
	if mode=="eject" or mode=="money" then return true end
	if (mode=="offense" or mode=="defense" or mode=="weapmod") then
		if self:GetNWInt("upgrade")>=1 then
			return true
		else
			return "This Refinery is not upgraded enough."
		end
	end
	if mode=="uber" then
		if self:GetNWInt("upgrade")>=2 then
			if self.SOffense>=3 and self.SDefense>=3 and self.SWeapmod>=3 then
				return true
			else
				return "Not enough Superdrugs."
			end
		else
			return "This Refinery is not upgraded enough."
		end
	end
	return "You're doing it wrong."
end

function ENT:SetMode(mode)
	if mode=="eject" then
		self:EjectSuperDrugs()
	end
	if mode=="money" then
		self.Refmode=0
	elseif mode=="offense" then
		self.Refmode=1
	elseif mode=="defense" then
		self.Refmode=2
	elseif mode=="weapmod" then
		self.Refmode=3
	elseif mode=="uber" then
		self:DropUberDrug()
		self.SOffense=0
		self.SDefense=0
		self.SWeapmod=0
		UberDrugExists()
	end
end
