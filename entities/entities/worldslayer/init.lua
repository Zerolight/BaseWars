AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( "bigbomb" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()
	self:SetModel("models/props_wasteland/light_spotlight01_lamp.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.Armed = false
	self.Time = CurTime()
	self.LastUsed = CurTime()
	self.Arming = 50
	self.Disarming = 50
	util.PrecacheSound("weapons/c4/c4_beep1.wav")
	util.PrecacheSound("weapons/c4/c4_disarm.wav")
	util.PrecacheSound("weapons/c4/c4_explode1.wav")
	util.PrecacheSound("weapons/c4/c4_exp_deb1.wav")
	self:SetNWBool("armed", false)
	self.DidHit=false
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	if (self.Armed==true) then
		self:Beep()
		if (self.Time<CurTime()+5) then
			self:NextThink(CurTime()+0.125)
		elseif (self.Time<CurTime()+20) then
			self:NextThink(CurTime()+0.25)
		elseif (self.Time<CurTime()+40) then
			self:NextThink(CurTime()+0.5)
		else
			self:NextThink(CurTime()+1)
		end
		return true
	end
end

function ENT:OnRemove()
	timer.Destroy(tostring(self) .. "goboom")
	timer.Destroy(tostring(self) .. "checkpropshit")
	timer.Destroy(tostring(self) .. "checkblast" )
end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:Touch()

end

function ENT:PhysicsUpdate()

end

function ENT:HitShit()
	self:GetPhysicsObject():Wake()
	self.DidHit = true
end
function ENT:Beep()
	self:EmitSound(Sound("weapons/c4/c4_beep1.wav"))
end
function ENT:Explode()
	util.BlastDamage( self, (self.Owner or self:GetOwner()), self:GetPos(), 768, 700 )

	local effectdata = EffectData()
		effectdata:SetStart(Vector(0,0,90))
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(3)
	util.Effect("cinematicexplosion", effectdata)

	self:EmitSound(Sound("weapons/c4/c4_explode1.wav"))
	self:EmitSound(Sound("weapons/c4/c4_explode1.wav"))
	self:EmitSound(Sound("weapons/c4/c4_exp_deb1.wav"))
	for i=0, 10, 1 do
		local bomblet = ents.Create("bigbomb_fragment")
		local randpos = Vector(math.random(-5,5), math.random(-5,5), math.random(0,5))
		bomblet.Owner = (self.Owner or self:GetOwner())
		bomblet:SetPos(self:GetPos()+randpos)
		bomblet:Spawn()
		bomblet:Activate()
		bomblet:GetPhysicsObject():SetVelocity(randpos*50)

	end
	self:Remove()
end

function ENT:Use(activator,caller)
	if self.LastUsed>CurTime() then return end

	if (self.Armed) then
		if (self.LastUsed+0.3>CurTime() and self.Disarming==50) then
			self.LastUsed = CurTime()+0.1
		else
		self.LastUsed = CurTime()+0.1
		self.Disarming = self.Disarming-1
		self:SetColor(Color(self.Disarming*5, self.Disarming*5, self.Disarming*5, 255))
		if (self.Disarming%5==0) then
			self:Beep()
		end
		if (self.Disarming<=0) then
			Notify(activator,1,3, "Bomb defused!")
			Notify((self.Owner or self:GetOwner()),1,3, "Bomb has been defused.")
			self:EmitSound(Sound("weapons/c4/c4_disarm.wav"))
            self:Remove()
		end
	end

	else
		if (self.LastUsed+0.3<CurTime()) then
			self.LastUsed = CurTime()-0.1
			self.Arming = 50
		end
		self.LastUsed = CurTime()+0.1
		self.Arming = self.Arming-1
		if (self.Arming%5==0) then
			self:Beep()
		end
		if (self.Arming<=0) then
			self:Armbomb(activator)
		end
	end
end

function ENT:Armbomb(planter)

	if (self:CheckPropObstruction()==false) then

		self:GetPhysicsObject():EnableMotion(false)
		self.Armed = true
		self:SetNWBool("armed", true)
		self.Time = CurTime()+60
		self.Arming = 50

		local owners,props = self:FindBreakables()
		for k, v in pairs(player.GetAll()) do
			local uid = v:UniqueID()
			local propnum = tonumber(owners[uid])
			if (propnum==nil) then propnum = 0 end
			if (tonumber(propnum)>0) then
				Notify(player.GetByUniqueID(uid), 1, 3, "A bigbomb has been planted near " .. tostring(owners[uid]) .. " of your props!")
				player.GetByUniqueID(uid):PrintMessage(HUD_PRINTTALK, "A bigbomb has been planted near " .. tostring(owners[uid]) .. " of your props!")
			end
		end
		timer.Create( tostring(self) .. "checkpropshit", 10, 5, function() if IsValid( self ) then self:PropCheck() end end )
		timer.Create( tostring(self) .. "checkblast", 59, 1, function() if IsValid( self ) then self:PropCheck() end end )
		timer.Create( tostring(self) .. "goboom", 60, 1, function() if IsValid( self ) then self:Explode() end end )
		Notify(planter, 1, 3, "Bomb has been planted.")
	else
		self.Arming = 50
		Notify((self.Owner or self:GetOwner()), 1, 3, "Get your props away from the bomb for it to be usable.")
		Notify(planter, 1, 3, "bomb owner's props are too close.")
	end
end

function ENT:CheckPropObstruction()
	local propwallingbitch = false
	for k, v in pairs(ents.FindInSphere( self:GetPos(), 512) ) do
		if (player.GetByUniqueID(v:GetVar("PropProtection"))~=false) then
			local entowner = player.GetByUniqueID(v:GetVar("PropProtection"))
			if (self.Owner or self:GetOwner())==entowner then

				propwallingbitch = true
			end
		end
	end
	return propwallingbitch
end

function ENT:PropCheck()
	if (self:CheckPropObstruction()==true) then
		Notify((self.Owner or self:GetOwner()),1,3, "Your props are too close! Bomb has self-defused.")
		self:EmitSound(Sound("weapons/c4/c4_disarm.wav"))
		self:Remove()
	end
end

function ENT:FindBreakables()
	local owners = {}
	local props = ents.FindInSphere(self:GetPos(), 192)
	for k, v in pairs(props) do
		local class = v:GetClass()
		if (class=="prop_physics_multiplayer" or class=="prop_physics_respawnable" or class=="prop_physics" or class=="phys_magnet" or class=="gmod_spawner" or class=="gmod_wheel" or class=="gmod_thruster" or class=="gmod_button") then
			local ownerid = v:GetVar("PropProtection")
			if (ownerid~=nil and ownerid~=false) then
				if (owners[ownerid]==nil) then
					owners[ownerid]=0

				end
				owners[ownerid] = owners[ownerid]+1
			end
		end
	end
	return owners,props
end

function ENT:Touch()
	self.DidHit = true
end

function ENT:PhysicsUpdate()
	if (self.DidHit == true) then
		self:Explode()
	end
end

function ENT:PhysicsCollide( data, physobj )
	self.DidHit = true
end
