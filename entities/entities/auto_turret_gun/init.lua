AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/weapons/w_smg1.mdl" )

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	local headshot = ents.Create("info_target")
	self.Aimtarg = headshot
	self.Firing 	= false
	self.NextShot 	= 0
	self.MaxRange = 1000
	self.SawShit = 0
	self.Beeptime = 0
	util.PrecacheSound("buttons/blip2.wav")

end

function ENT:FireShot(targ)

	if ( self.NextShot > CurTime() or self.Body:GetNWBool("ison")==false) then return end

	self.NextShot = CurTime() + 0.17

	self:EmitSound( "Weapon_Pistol.Single" )

	local Attachment = self:GetAttachment( 1 )

	local shootOrigin = Attachment.Pos
	local shootAngles = self:GetAngles()
	local shootDir = shootAngles:Forward()
	if (self.Body:GetNWInt("upgrade")>0) then
		targ:TakeDamage(15, self:GetOwner(), self)
	else
		targ:TakeDamage(10, self:GetOwner(), self)
	end

	local bullet = {}
		bullet.Num 		= 1
		bullet.Src 		= shootOrigin
		bullet.Dir 		= shootDir
		bullet.Spread 		= Vector( 0, 0, 0 )
		bullet.Tracer		= 1
		bullet.TracerName 	= "AirboatGunHeavyTracer"
		bullet.Force		= 50
		bullet.Damage		= 0
		bullet.Attacker 	= self:GetOwner()
	self:FireBullets( bullet )

	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngle( shootAngles )
		effectdata:SetScale( 1 )
	util.Effect( "MuzzleEffect", effectdata )

end

function ENT:Think()
	if (self.Body:IsBuilt()) then
		local nearesttarg = self
		local Attachment = self:GetAttachment( 1 )
		local shootOrigin = Attachment.Pos
		for k, v in pairs( ents.FindInSphere(self:GetPos(), self.MaxRange*1.25)) do

			if (v:GetClass() == "info_player_deathmatch" or v:GetClass() == "info_player_rebel" or v:GetClass() == "info_player_combine" or v:GetClass() == "gmod_player_start" or v:GetClass() == "info_player_start" or v:GetClass() == "info_player_allies" or v:GetClass() == "info_player_axis" or v:GetClass() == "info_player_counterterrorist" or v:GetClass() == "info_player_terrorist") then
				nearesttarg = self
				return;
			end

			local isally = false
			if v:IsPlayer() and self:GetOwner()~=v then
				if self:GetOwner():IsAllied(v) then
					isally = true
				end
			end

			local istarget = false
			if ((string.find(string.lower(v:GetName()), string.lower(self.Body:GetNWString("enemytarget"))) ~= nil and self.Body:GetNWString("enemytarget")~="")) then
				istarget = true
			end
			if ( (((v:GetClass()~="player" or not isally or istarget) and self.Body:GetNWBool("hatetarget")==false) or (v:GetClass()~="player" or (istarget and self.Body:GetNWBool("hatetarget")==true))) and ( (v:GetClass()=="player" and self:GetOwner()~=v) or (v:IsNPC() and v:GetClass() ~= "npc_heli_avoidsphere" and v:GetClass() ~= "npc_template_maker" and v:GetClass() ~= "npc_maker" and v:GetClass() ~= "npc_vehicledriver" and v:GetClass() ~= "npc_launcher" and v:GetClass() ~= "npc_heli_nobomb" and v:GetClass() ~= "npc_heli_avoidsphere" and v:GetClass() ~= "npc_heli_avoidbox" and v:GetClass() ~= "npc_furniture" and v:GetClass() ~= "npc_enemyfinder" and v:GetClass() ~= "npc_missiledefense" and v:GetClass() ~= "npc_bullseye" and v:GetClass() ~= "npc_apcdriver" and v:GetClass() ~= "monster_generic" and v:GetClass() ~= "info_npc_spawn_destination" and v:GetClass() ~= "generic_actor" and v:GetClass() ~= "cycler_actor" and v:GetClass() ~= "npc_antion_template_maker" and v:GetClass() ~= "npc_cranedriver" and v:GetClass() ~= "npc_sniper") ) ) then

				local tracerun = false
				local traceshit = {}
					traceshit.start = self:GetPos()
					traceshit.endpos = v:GetPos()
					traceshit.filter = { self.Body, v, self }

				traceshit = util.TraceLine(traceshit)
				if (IsValid(traceshit.Entity) and not traceshit.HitWorld) then
					if (traceshit.Entity:GetVar("PropProtection")~=false) then
						local entowner = player.GetByUniqueID(traceshit.Entity:GetVar("PropProtection"))
						if (entowner==v) then tracerun=true end
					elseif (traceshit.Fraction==1) then tracerun=true end
				elseif (not traceshit.HitWorld) then tracerun = true end

				local tracehrun = false
				local traceshith = {}
					traceshith.start = self:GetPos()
					traceshith.endpos = v:GetPos()+Vector(0, 0, 30)
					traceshith.filter = { self.Body, v, self }

				traceshith = util.TraceLine(traceshith)
				if (IsValid(traceshith.Entity) and not traceshith.HitWorld) then
					if (traceshith.Entity:GetVar("PropProtection")~=false) then
						local entowner = player.GetByUniqueID(traceshith.Entity:GetVar("PropProtection"))
						if (entowner==v) then tracehrun=true end
					elseif (traceshith.Fraction==1) then tracehrun=true end
				elseif (not traceshith.HitWorld) then  tracehrun = true end

				local tracebrun = false
				local traceshitb = {}
					traceshitb.start = self.Body:GetPos()+Vector(0,0,5)
					traceshitb.endpos = v:GetPos()
					traceshitb.filter = { self.Body, v, self }

				traceshitb = util.TraceLine(traceshitb)
				if (IsValid(traceshitb.Entity) and not traceshitb.HitWorld) then
					if (traceshitb.Entity:GetVar("PropProtection")~=false) then
						local entowner = player.GetByUniqueID(traceshitb.Entity:GetVar("PropProtection"))
						if (entowner==v) then tracebrun=true end
					elseif (traceshitb.Fraction==1) then tracebrun=true end
				elseif (not traceshitb.HitWorld) then  tracebrun = true end

				local tracebhrun = false
				local traceshitbh = {}
					traceshitbh.start = self.Body:GetPos()+Vector(0,0,5)
					traceshitbh.endpos = v:GetPos()+Vector(0, 0, 30)
					traceshitbh.filter = { self.Body, v, self }

				traceshitbh = util.TraceLine(traceshitbh)
				if (IsValid(traceshitbh.Entity) and not traceshitbh.HitWorld) then
					if (traceshitbh.Entity:GetVar("PropProtection")~=false) then
						local entowner = player.GetByUniqueID(traceshitbh.Entity:GetVar("PropProtection"))
						if (entowner==v) then tracebhrun=true end
					elseif (traceshitbh.Fraction==1) then tracebhrun=true end
				elseif (not traceshitbh.HitWorld) then  tracebhrun = true end

					local tracewrun = false
				local traceshitw = {}
					traceshitw.start = self:GetPos()
					traceshitw.endpos = v:GetPos()
					traceshitw.filter = { self.Body, v, self }
					traceshitw.mask = COLLISION_GROUP_PLAYER
				traceshitw = util.TraceLine(traceshitw)
				if (not traceshitw.HitWorld) then
					tracewrun=true
				end

				local tracewhrun = false
				local traceshitwh = {}
					traceshitwh.start = self:GetPos()
					traceshitwh.endpos = v:GetPos()
					traceshitwh.filter = { self.Body, v, self }
					traceshitwh.mask = COLLISION_GROUP_PLAYER
				traceshitwh = util.TraceLine(traceshitwh)
				if (not traceshitwh.HitWorld) then
					tracewhrun=true
				end

				if ( ( self:GetPos():Distance(v:GetPos()) < self:GetPos():Distance(nearesttarg:GetPos()) and (tracerun==true or tracehrun==true) and (tracebrun==true or tracebhrun==true) and (tracewrun==true or tracewhrun==true) and v:Health()>0) or nearesttarg == self and (tracerun==true or tracehrun==true) and (tracebrun==true or tracebhrun==true) and (tracewrun==true or tracewhrun==true) and v:Health()>0) then
					nearesttarg = v
				end
			end
		end

		if (nearesttarg==self) then
			self.SawShit = 0
		else
			local enemy = nearesttarg
			if( self.Firing ) then
				if (self.SawShit>=2) then
					self:FireShot(nearesttarg)
				else
					self.SawShit = self.SawShit + 1
					self:EmitSound(Sound("buttons/blip2.wav"))
				end
			end
			local pos = self:GetPos()
			local targpos = enemy:GetPos()
			local targdist = pos:Distance(targpos)
			local targ = enemy
			if (targdist<self.MaxRange) then
				local targhead = 10
				if (targ:GetClass() == "player" or targ:GetClass() == "npc_zombie" or targ:GetClass() == "npc_vortigaunt" or targ:GetClass() == "npc_stalker" or targ:GetClass() == "npc_poisonzombie" or targ:GetClass() == "npc_mossman" or targ:GetClass() == "npc_monk" or targ:GetClass() == "npc_metropolice" or targ:GetClass() == "npc_kleiner" or targ:GetClass() == "npc_gman" or targ:GetClass() == "npc_eli" or targ:GetClass() == "npc_dog" or targ:GetClass() == "npc_combine_s" or targ:GetClass() == "npc_citizen" or targ:GetClass() == "npc_breen" or targ:GetClass() == "npc_barney" or targ:GetClass() == "npc_antlionguard" or targ:GetClass() == "npc_alyx") then
					targhead = 40
				else
					if (targ:GetClass() == "npc_antion" or targ:GetClass() == "npc_fastzombie" ) then
						targhead = 30
					end
					if (targ:GetClass() == "npc_strider") then
						targhead = 80
					end
				end
				self.Aimtarg:SetPos(targ:GetPos() + Vector(0,0,targhead) )
				self:PointAtEntity(self.Aimtarg)
				if (self.SawShit>=2 or (self.SawShit>=1 and self.Body:GetNWInt("upgrade")==2)) then
					self:FireShot(nearesttarg)
				else
					self.SawShit = self.SawShit+1
					self:EmitSound(Sound("buttons/blip2.wav"))
				end
			end
		end

		if (self.Beeptime>=60) then
			self.Beeptime = 0
			self:EmitSound(Sound("buttons/blip2.wav"))
		elseif (self.Body:GetNWBool("ison")) then
			self.Beeptime = self.Beeptime + 1
		end
	else
		self:PointAtEntity(self.Body)
	end
	if self.Body:IsPowered() then
		self:NextThink(CurTime()+0.34)
	else

		self:NextThink(CurTime()+2)
	end
	return true
end
function ENT:OnRemove()
	self.Aimtarg:Remove()
end

function ENT:OnTakeDamage(dmg)
	self.Body:SetNWInt("damage",self.Body:GetNWInt("damage") - dmg:GetDamage())
	if(self.Body:GetNWInt("damage") <= 0) then
		self.Body:Explode()
		self.Body:Remove()

	end
end
