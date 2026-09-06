AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	self:SetModel( "models/props/de_prodigy/transformer.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",200)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxgunfactory=ply:GetTable().maxgunfactory + 1
	self.Ready = true
	self:SetNWInt("power",0)
	self.GunType = nil
	self.LastUsed = CurTime()
	self.User = (self.Owner or self:GetOwner())
end

function ENT:Use( activator )
	if self.LastUsed>CurTime() then
		self.LastUsed = CurTime()+0.3
		return
	end
	self.LastUsed = CurTime()+0.3
	if (not self.Ready) then
		net.Start("killgunfactorygui");
			net.WriteInt( self:EntIndex() , 16)
		net.Send(activator)
		net.Start("gunfactorygui");
			net.WriteInt( self:GetNWInt("upgrade") , 16)
			net.WriteInt( self:EntIndex() , 16)
			net.WriteBool(true)
		net.Send(activator)
		return
	end

	net.Start("killgunfactorygui");
		net.WriteInt( self:EntIndex() , 16)
	net.Send(activator)
	net.Start("gunfactorygui");
		net.WriteInt( self:GetNWInt("upgrade") , 16)
		net.WriteInt( self:EntIndex() , 16)
		net.WriteBool(false)
	net.Send(activator)
end

function ENT:StartProduction(ply,guntype)
	local time = 120
	if guntype=="grenadegun" then time=180
		elseif guntype=="worldslayer" then time = 600
		elseif guntype=="plasma" then time = 180
		elseif guntype=="rocketlauncher" then time = 200
		elseif guntype=="minigun" then time = 680
	end
	self.User = ply
	if guntype=="resetbutton" then
		self:SetNWBool("sparking",false)
		timer.Destroy( tostring(self) .. "spawned_weapon")
		timer.Destroy( tostring(self) .. "dostuff")
		self.Ready = true
		self.GunType = nil
		Notify(ply, 2, 3, "Gun production stopped." )
		net.Start("gunfactoryget")
			net.WriteFloat(0)
			net.WriteEntity(self)
		net.Send(ply)
	else
		self:SetNWBool("sparking",true)
		timer.Create( tostring(self) .. "spawned_weapon", time, 1, function() if IsValid( self ) then self:createGun() end end )
		timer.Create( tostring(self) .. "dostuff", 60, time/60, function() if IsValid( self ) then self:DoStuff() end end )
		self.Ready = false
		self.GunType = guntype
		Notify(ply, 2, 3, "Producing a " .. self.GunType )
		net.Start("gunfactoryget")
			net.WriteFloat(time+CurTime())
			net.WriteEntity(self)
		net.Send(ply)
	end
	net.Start("killgunfactorygui");
		net.WriteInt( self:EntIndex() , 16)
	net.Send(ply)
end

function ENT:DoStuff()
	local owner = self.User
	local productioncost = 150
	if owner~=(self.Owner or self:GetOwner()) then
		productioncost = 250
	end
	if not self:IsPowered() then
		Notify(owner, 4, 3, "Failed to create weapon. Low power")
		self:SetNWBool("sparking",false)
		timer.Destroy(tostring(self) .. "dostuff")
		timer.Destroy(tostring(self) .. "spawned_weapon")
		self.Ready = true
		net.Start("gunfactoryget")
			net.WriteFloat(time+CurTime())
			net.WriteEntity(self)
		net.Send(ply)
		return
	end
	if not owner:CanAfford(productioncost) then
		Notify(owner, 4, 3, "Failed to create weapon. Not enough money")
		self:SetNWBool("sparking",false)
		timer.Destroy(tostring(self) .. "dostuff")
		timer.Destroy(tostring(self) .. "spawned_weapon")
		self.Ready = true
		net.Start("gunfactoryget")
			net.WriteFloat(time+CurTime())
			net.WriteEntity(self)
		net.Send(ply)
		return
	end
	owner:AddMoney(-productioncost)
	Notify(owner,3,3, "Used $"..tostring(productioncost).." creating a weapon in gun factory")
end

function ENT:createGun()
	self:SetNWBool("sparking",false)
	self.Ready = true
	local gun = ents.Create("spawned_weapon")
	if self.GunType=="laserbeam" then
		gun:SetModel( "models/weapons/w_irifle.mdl" );
		gun:SetNWString("weaponclass", "weapon_lasergun")
	elseif self.GunType=="laserrifle" then
		gun:SetModel("models/weapons/w_snip_scout.mdl")
		gun:SetNWString("weaponclass","weapon_laserrifle")
	elseif self.GunType=="worldslayer" then
		gun:SetModel("models/weapons/w_rocket_launcher.mdl")
		gun:SetNWString("weaponclass","weapon_worldslayer")
	elseif self.GunType=="grenadegun" then
		gun:SetModel("models/weapons/w_rif_sg552.mdl")
		gun:SetNWString("weaponclass","weapon_grenadegun")
	elseif self.GunType=="plasma" then
		gun:SetModel("models/weapons/w_irifle.mdl")
		gun:SetNWString("weaponclass","weapon_plasma")
	elseif self.GunType=="minigun" then
		gun:SetModel("models/weapons/w_minigun.mdl")
		gun:SetNWString("weaponclass","weapon_minigun")
	end
	local trace = { }
		trace.start = self:GetPos()+self:GetAngles():Up()*15;
		trace.endpos = trace.start + self:GetAngles():Forward()*-30 + self:GetAngles():Right()*-30 + self:GetAngles():Up()*60
		trace.filter = self
	local tr = util.TraceLine( trace );
	gun:SetPos(tr.HitPos)
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90)
	gun:SetAngles(ang)
	gun:GetTable().spawner = self.User
	gun:Spawn()
	Notify(self.User,3,3,"Gun Factory weapon production complete.")
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	if(self:GetNWBool("sparking") == true) then
		local ang = self:GetAngles()
	end

end

function ENT:OnRemove( )
	timer.Destroy(tostring(self) .. "spawned_weapon")
	timer.Destroy(tostring(self) .. "dostuff")
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxgunfactory=ply:GetTable().maxgunfactory - 1
	end
end

function ENT:MakeScraps()

end
