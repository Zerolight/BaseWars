AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.PhysgunPickup = false

function ENT:GravGunPickup( ply, ent )
	return not self.Armed
end

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
	self:SetModel("models/props_c17/oildrum001.mdl")
	self:SetSkin(1)
	self.BombPanel = ents.Create("prop_dynamic_override")
	self.BombPanel:SetModel( "models/weapons/w_c4_planted.mdl" )
	self.BombPanel:SetPos(self:GetPos()+self:GetAngles():Forward()*10+self:GetAngles():Up()*25)
	self.BombPanel:SetAngles(Angle(0,90,90))
	self.BombPanel:SetParent(self)
	self.BombPanel:SetSolid(SOLID_NONE)

	self.BombPanel:SetMoveType(MOVETYPE_NONE)

	self.BombPanel2 = ents.Create("prop_dynamic_override")
	self.BombPanel2:SetModel( "models/dav0r/tnt/tnt.mdl" )
	self.BombPanel2:SetPos(self:GetPos()+self:GetAngles():Forward()*-6+self:GetAngles():Right()*-12+self:GetAngles():Up()*15)
	self.BombPanel2:SetAngles(Angle(0,45,0))
	self.BombPanel2:SetParent(self)
	self.BombPanel2:SetSolid(SOLID_NONE)

	self.BombPanel2:SetMoveType(MOVETYPE_NONE)

	self.BombPanel3 = ents.Create("prop_dynamic_override")
	self.BombPanel3:SetModel( "models/dav0r/tnt/tnt.mdl" )
	self.BombPanel3:SetPos(self:GetPos()+self:GetAngles():Forward()*-6+self:GetAngles():Right()*12+self:GetAngles():Up()*15)
	self.BombPanel3:SetAngles(Angle(0,-45,0))
	self.BombPanel3:SetParent(self)
	self.BombPanel3:SetSolid(SOLID_NONE)

	self.BombPanel3:SetMoveType(MOVETYPE_NONE)

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
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxBigBombs=ply:GetTable().maxBigBombs + 1
	self.Arming = 50
	self.Disarming = 60
	self.Tick = 0
	util.PrecacheSound("weapons/c4/c4_beep1.wav")
	util.PrecacheSound("weapons/c4/c4_disarm.wav")
	util.PrecacheSound("weapons/c4/c4_explode1.wav")
	util.PrecacheSound("weapons/c4/c4_exp_deb1.wav")
	self:SetNWBool("armed", false)
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	if (self.Armed==true) then
		if self.LastUsed+3<CurTime() and self.Disarming<60 then
			self.Disarming=self.Disarming+1
			self:SetColor(Color(self.Disarming*4, self.Disarming*4, self.Disarming*4, 255))
		end
		self:Beep()
		if (self.Time<CurTime()+5) then
			self:NextThink(CurTime()+0.125)
		elseif (self.Time<CurTime()+30) then
			self:NextThink(CurTime()+0.25)
		elseif (self.Time<CurTime()+60) then
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
	timer.Destroy(tostring(self) .. "checkpropshit2")
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

	for k,v in pairs(player.GetAll()) do
		if v:IsPlayer() and v:GetPos():Distance(self:GetPos())<1024 and v:GetNWBool("shielded")==true then
			v:SetNWBool("shielded", false)
			v:GetTable().Shieldon = false
			Notify(v, 1, 3, "The force of the Big Bomb shattered your shield!")
		end
	end
	util.BlastDamage( self, (self.Owner or self:GetOwner()), self:GetPos(), 1536, 2000 )

	local effectdata = EffectData()
		effectdata:SetStart(Vector(0,0,90))
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(3)
	util.Effect("cinematicexplosion", effectdata)
	self:EmitSound(Sound("weapons/c4/c4_explode1.wav"))
	self:EmitSound(Sound("weapons/c4/c4_exp_deb1.wav"))

	local owners,props = self:FindBreakables()
	for k, v in pairs(player.GetAll()) do
		local uid = v:UniqueID()
		local propnum = tonumber(owners[uid])
		if (propnum==nil) then propnum = 0 end
		if (tonumber(propnum)>0) then
			Notify(player.GetByUniqueID(uid), 1, 3, "A bigbomb has destroyed " .. tostring(owners[uid]) .. " of your props!")
			player.GetByUniqueID(uid):PrintMessage(HUD_PRINTTALK, "A bigbomb has destroyed " .. tostring(owners[uid]) .. " of your props!")
		end
	end
	for k, v in pairs(props) do
		local class = v:GetClass()
		if (class=="prop_physics_multiplayer" or class=="prop_physics_respawnable" or class=="prop_physics" or class=="phys_magnet" or class=="gmod_spawner" or class=="gmod_wheel" or class=="gmod_thruster" or class=="gmod_button" or class=="sent_keypad" or class=="auto_turret") then
			local entowner = player.GetByUniqueID(v:GetVar("PropProtection"))
			if (IsValid(entowner)) then
				entowner:GetTable().spamweldcount=entowner:GetTable().spamweldcount+1
				entowner:SetNWBool("spamwelding", true)

				timer.Destroy(tostring(v) .. "unweldamage")
				timer.Create( tostring(v) .. "unweldamage", 60, 1, function() WeldControl( v, player.GetByUniqueID(v:GetVar("PropProtection")) ) end )
			end
			v:Remove()
		end
	end

	for i=0, 15, 1 do
		local bomblet = ents.Create("bigbomb_fragment")
		local randpos = Vector(math.random(-5,5), math.random(-5,5), math.random(0,5))
		bomblet.Owner = (self.Owner or self:GetOwner())
		bomblet:SetPos(self:GetPos()+randpos)
		bomblet:Spawn()
		bomblet:Activate()
		bomblet:GetPhysicsObject():SetVelocity(randpos*65)

	end

	local pos = self:GetPos()

	local exp = ents.Create("env_physexplosion")
		exp:SetKeyValue("magnitude", 9999)
		exp:GetTable().attacker = (self.Owner or self:GetOwner())
		exp:SetKeyValue("radius", 1536)
		exp:SetPos(pos)
	exp:Spawn()
	exp:SetOwner((self.Owner or self:GetOwner()))
	exp:Fire("explode","",0)

	self:Remove()
end

function ENT:Use(activator,caller)
	if self.LastUsed>CurTime() then return end

	if (self.Armed) then
		if (self.LastUsed+0.3>CurTime() and self.Disarming==60) then
			self.LastUsed = CurTime()+0.1
		else
			self.LastUsed = CurTime()+0.1
			self.Disarming = self.Disarming-1
			if activator:GetTable().Tooled and self.Tick==1 then
				self.Disarming = self.Disarming-1
			end
			if self.Tick==1 then self.Tick=0 else self.Tick=1 end
			self:SetColor(Color(self.Disarming*4, self.Disarming*4, self.Disarming*4, 255))
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
		self.Time = CurTime()+120
		self:SetNWFloat("goofytiem",self.Time)
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
		timer.Create( tostring(self) .. "checkpropshit", 5, 18, function() if IsValid( self ) then self:PropCheck() end end )

		timer.Create( tostring(self) .. "checkblast", 89, 1, function() if IsValid( self ) then self:PropCheck() end end )
		timer.Create( tostring(self) .. "checkblast", 119, 1, function() if IsValid( self ) then self:PropCheck() end end )
		timer.Create( tostring(self) .. "goboom", 120, 1, function() if IsValid( self ) then self:Explode() end end )
		Notify(planter, 1, 3, "Bomb has been planted.")
	else
		self.Arming = 50
		Notify((self.Owner or self:GetOwner()), 4, 3, "Get your props away from the bomb for it to be usable.")
		Notify(planter, 4, 3, "Bomb owner's props are too close to arm.")
	end
end

function ENT:CheckPropObstruction()
	local propwallingbitch = false
	for k, v in pairs(ents.FindInSphere( self:GetPos(), 1536) ) do
		if (player.Owner~=false) then
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
		Notify((self.Owner or self:GetOwner()),1,3, "Your props are too close, Bomb will automatically disarm.")
		self:EmitSound(Sound("weapons/c4/c4_disarm.wav"))
		self:GetPhysicsObject():EnableMotion(true)
		self.Armed = false
		self:SetNWBool("armed", false)
		self.Time = false
		self:SetNWFloat("goofytiem","")
	timer.Destroy(tostring(self) .. "goboom")
	timer.Destroy(tostring(self) .. "checkblast" )
	end
end

function ENT:FindBreakables()
	local owners = {}
	local props = ents.FindInSphere(self:GetPos(), 512)
	for k, v in pairs(props) do
		local class = v:GetClass()
		if (class=="prop_physics_multiplayer" or class=="prop_physics_respawnable" or class=="prop_ragdoll" or class=="prop_physics" or class=="phys_magnet" or class=="gmod_spawner" or class=="gmod_wheel" or class=="gmod_thruster" or class=="gmod_button" or class=="auto_turret") then
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

function ENT:OnRemove()
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxBigBombs=ply:GetTable().maxBigBombs - 1
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
