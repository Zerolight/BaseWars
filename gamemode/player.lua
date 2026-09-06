function GM:PlayerSetModel( pl )

	local cl_playermodel = pl:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	pl:SetModel( modelname )

end

local meta = FindMetaTable( "Player" );

function meta:NewData()

	self:GetTable().Money = 5000
	self:GetTable().Pay = 1;
	self:GetTable().LastPayDay = CurTime();

	self:GetTable().Owned = { }
	self:GetTable().OwnedNum = 0;

	self:GetTable().LastLetterMade = CurTime();
	self:GetTable().LastVoteCop = CurTime();

	self:SetTeam( 1 );

end

function meta:IsAllied(ply)
	if tonumber(self:GetInfo("bw_ally_pl"..ply:EntIndex()))==1 then
		return true
	else
		return false
	end
end

function meta:NPCControl()
	for k,v in pairs(self.NPCs) do
		if IsValid(v) then
			if not v:HasCondition(COND_SEE_HATE) and not v:HasCondition(COND_SEE_ENEMY) then
				v:SetNPCState(1)
			end
			if (v:GetNPCState()~=3 or self:GetPos():Distance(v:GetPos())>1024) and self:GetPos():Distance(v:GetPos())>256 then
				local newpos = v:GetPos() + ((self:GetPos()-v:GetPos()):Normalize()*256)
				v:SetLastPosition(newpos)
				v:SetArrivalSpeed(1024)
				v:SetSchedule(SCHED_FORCED_GO_RUN)

			end
		end
	end
end

function meta:UpgradeGun( gun, bool)
	local weapon = self:GetWeapon(gun)
	if not IsValid(weapon) then return end
	weapon:Upgrade(bool)
end

function meta:CanAfford( amount )

	if( amount < 0 ) then return false; end

	if( self:GetTable().Money - amount < 0 ) then
		return false;
	end

	return true;

end

function meta:AddMoney( amount )

	local oldamount = self:GetTable().Money

	if (self:GetNWBool("AFK") and amount>0) then
		amount = -amount
		Notify(self,1,3,"You are AFK!, you just lost $" .. -amount .. "!!!")
	end
	self:GetTable().Money = oldamount + amount
	setMoney(self, amount);
	local plmoney = self:GetTable().Money

	if (self:GetTable().Money>2147483647) then
		plmoney = 1000000000
	end
	net.Start("MoneyChange")
		net.WriteInt(amount, 16)
		net.WriteInt(plmoney, 32)
	net.Send(self)
end

function meta:UpdateJob( job )

	self:SetNWString( "job", job );

	if( string.lower( job ) ~= "mingebag") then

		self:GetTable().Pay = 1;
		self:GetTable().LastPayDay = CurTime();

		timer.Create( self:SteamID() .. "jobtimer", CfgVars["paydelay"], 0, function() self.PayDay( self ) end );

	else

		timer.Destroy( self:SteamID() .. "jobtimer" );

	end

end

function meta:CheckOverdose()
	local drugnum = 0
	if(not self:GetNWBool("superdrug")) then
		if (self:GetNWBool("regened")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("roided")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("amped")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("painkillered")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("mirrored")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("antidoted")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("focused")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("magicbulleted")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("shockwaved")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("leeched")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("doubletapped")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("doublejumped")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("adrenalined")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("knockbacked")==true) then
			drugnum = drugnum+1
		end
		if (self:GetNWBool("armorpiercered")==true) then
			drugnum = drugnum+1
		end
		if (drugnum>=5 and math.random(1,10)>2) then
			self:SetNWBool("shielded", false)
			self.Shielded = false
			self:TakeDamage(150,self)
			PoisonPlayer(self, 50, self, self)
			Notify(self, 1, 3, "You have overdosed!")
		elseif (drugnum==4 and math.random(1,10)>4) then
			self:SetNWBool("shielded", false)
			self.Shielded = false
			self:TakeDamage(90,self)
			PoisonPlayer(self, 40, self, self)
			Notify(self, 1, 3, "You have overdosed!")
		elseif drugnum==3 and math.random(1,10)>5 then
			PoisonPlayer(self, 40, self, self)
			self:TakeDamage(60, self)
			Notify(self, 1, 3, "You are overdosing!")
		elseif drugnum==2 and math.random(1,10)>9 then
			PoisonPlayer(self, 30, self, self)
			self:TakeDamage(30, self)
			Notify(self, 1, 3, "You are overdosing!")
		end
	end
end

function meta:UnownAllShit()

	for k, v in pairs( self:GetTable().Owned ) do

		v:UnOwn( self );
		self:GetTable().Owned[v:EntIndex()] = nil;

	end

	for k, v in pairs( player.GetAll() ) do

		for n, m in pairs( v:GetTable().Owned ) do

			if( m:AllowedToOwn( self ) ) then
				m:RemoveAllowed( self );
			end

		end

	end

	self:GetTable().OwnedNum = 0;

end

function GM:DoPlayerDeath( ply, attacker, dmginfo )

	ply:CreateRagdoll()

	ply:AddDeaths( 1 )

	ply:SetWalkSpeed(250)
	ply:SetRunSpeed(500)

	if ( attacker:IsValid() and attacker:IsPlayer() ) then

		if ( attacker == ply ) then
			attacker:AddFrags( -1 )
		else
			attacker:AddFrags( 1 )
		end

	end

end

function UpdateDrugs(ply)
	ply:GetTable().Roided = false
	ply:GetTable().Regened = false
	ply:GetTable().Shielded = false
	ply:GetTable().Tooled = false
	ply:GetTable().Focus = false
	ply:GetTable().Mirror = false
	ply:GetTable().Antidoted = false
	ply:GetTable().Poisoned = false
	ply:GetTable().Shielded = false
	ply:GetTable().Shieldon = false
	ply:GetTable().Stunned = false
	ply:GetTable().StunDuration = 0
	ply:GetTable().PoisonDuration = 0
	ply:GetTable().BurnDuration = 0
	ply:GetTable().Amp = false
	ply:GetTable().PainKillered = false
	ply:GetTable().MagicBulleted = false
	ply:GetTable().Adrenalined = false
	ply:GetTable().DoubleJumped = false
	ply:GetTable().ShockWaved = false
	ply:GetTable().DoubleTapped = false
	ply:GetTable().Leeched = false
	ply:GetTable().Knockbacked = false
	ply:GetTable().ArmorPiercered = false
	ply:GetTable().Superdrugoffense = false
	ply:GetTable().Superdrugdefense = false
	ply:GetTable().Superdrugweapmod = false
	ply:GetTable().Burned = false

	ply:SetNWBool("shielded", false)
	ply:SetNWBool("tooled", false)
	ply:SetNWBool("scannered", false)
	ply:SetNWBool("helmeted", false)
	ply:SetNWBool("roided", false)
	ply:SetNWBool("regened", false)
	ply:SetNWBool("amped", false)
	ply:SetNWBool("painkillered", false)
	ply:SetNWBool("magicbulleted", false)
	ply:SetNWBool("poisoned", false)
	ply:SetNWBool("focused", false)
	ply:SetNWBool("antidoted", false)
	ply:SetNWBool("mirrored", false)
	ply:SetNWBool("shockwaved", false)
	ply:SetNWBool("doubletapped", false)
	ply:SetNWBool("leeched", false)
	ply:SetNWBool("adrenalined", false)
	ply:SetNWBool("doublejumped", false)
	ply:SetNWBool("knockbacked", false)
	ply:SetNWBool("armorpiercered", false)
	ply:SetNWBool("burned", false)

	local IDSteam = string.gsub(ply:SteamID(), ":", "")
	timer.Destroy(IDSteam .. "ROID")
	timer.Destroy(IDSteam .. "REGEN")
	timer.Destroy(IDSteam .. "REGENTICK")
	timer.Destroy(IDSteam .. "AMP")
	timer.Destroy(IDSteam .. "PAINKILLER")
	timer.Destroy(IDSteam .. "MAGICBULLET")
	timer.Destroy(IDSteam .. "STUN")
	timer.Destroy(IDSteam .. "REFLECT")
	timer.Destroy(IDSteam .. "POISON")
	timer.Destroy(IDSteam .. "POISONTICK")
	timer.Destroy(IDSteam .. "BURN")
	timer.Destroy(IDSteam .. "ANTIDOTE")
	timer.Destroy(IDSteam .. "FOCUS")
	timer.Destroy(IDSteam .. "DOUBLETAP")
	timer.Destroy(IDSteam .. "LEECH")
	timer.Destroy(IDSteam .. "SHOCKWAVE")
	timer.Destroy(IDSteam .. "DOUBLEJUMP")
	timer.Destroy(IDSteam .. "ADRENALINE")
	timer.Destroy(IDSteam .. "KNOCKBACK")
	timer.Destroy(IDSteam .. "ARMORPIERCER")
	timer.Destroy(IDSteam .. "SUPERDRUGOFFENSE")
	timer.Destroy(IDSteam .. "SUPERDRUGDEFENSE")
	timer.Destroy(IDSteam .. "SUPERDRUGWEAPMOD")
end

function GM:PlayerDeath( ply, weapon, killer )
	ply:Ignite(0.001,0)
	ply:Extinguish()
	UpdateDrugs(ply)
	ply:ConCommand("pp_motionblur 0")
	ply:ConCommand("pp_dof 0")
	local IDSteam = string.gsub(ply:SteamID(), ":", "")
		local team = ply:Team()
		if (team == 19 ) then
			ply:RunConsoleCommand("stopsounds")
				timer.Destroy("SonicTimer")
		end

	self:PlayerDeathNotify(ply,weapon,killer)

	ply:GetTable().DeathPos = ply:GetPos();

	if( ply ~= killer or ply:GetTable().Slayed ) then

		ply:GetTable().DeathPos = nil;

		ply:GetTable().Slayed = false;
	end
	for k, v in pairs(ply:GetWeapons()) do
		local class = v:GetClass()
		if (class~="weapon_p2282" and class~="weapon_molotov" and class~="weapon_gasgrenade" and class~="cse_eq_flashbang" and class~="cse_eq_hegrenade" and class~="weapon_pipebomb" and class~="weapon_physgun" and class~="weapon_physcannon" and class~="gmod_tool" and class~="gmod_camera" and class~="keys" and class~="weapon_firestorm" and class~="weapon_welder" and class~="welder" and class~="arrest_stick" and class~="weapon_lightninggun" and class~="weapon_icegun" and class~="weapon_dead_ringer" and class~="vuvuzela_small" and class~="vuvuzela_normal" and class~="vuvuzela_big" and class~="weapon_moneycannon" and class~="Weapon_Sonic_SWEP") then

			local gun = ents.CreateEx("spawned_weapon")
			gun:SetModel(v:GetTable().WorldModel)
			gun:SetNWString("weaponclass", class)
			gun:SetPos(ply:GetPos()+Vector(math.random(-10,10),math.random(-10,10),math.random(10,40)))
			gun:SetUpgraded(v:GetNWBool("upgraded"))
			gun:Spawn()

			timer.Create( "Gun timer", 10, 1, function()
				if gun:IsValid() then
					gun:Remove()
				end
			end )

			v:Remove()
		end
	end

end

function GM:PlayerCanPickupWeapon( ply, wep )

	if wep:GetClass()=="weapon_worldslayer" and IsValid(ply:GetWeapon("weapon_worldslayer")) then return false end

	return true;

end

function GM:PlayerSpawn( ply )
	ply:Extinguish()
	GAMEMODE:PlayerSetModel(ply)
	UpdateDrugs(ply)

	ply:GetTable().Jump2 = false

	ply:ConCommand("pp_motionblur 0")
	ply:ConCommand("pp_dof 0")

	local IDSteam = string.gsub(ply:SteamID(), ":", "")

	ply:GetTable().Headshot = false

	ply:UnSpectate()
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	GAMEMODE:PlayerLoadout( ply )

	ply:CrosshairEnable();

	if( CfgVars["crosshair"] == 0 ) then

		ply:CrosshairDisable();

	end

	if( CfgVars["strictsuicide"] == 1 and ply:GetTable().DeathPos ) then

		ply:SetPos( ply:GetTable().DeathPos );

	end

	if ( IsValid(ply:GetTable().Spawnpoint )  ) then
    		local cspawnpos = ply:GetTable().Spawnpoint:GetPos()
		local trace = { }
    			trace.start = cspawnpos+Vector(0,0,2)
			trace.endpos = trace.start+Vector(0,0,16)
			trace.filter = ply:GetTable().Spawnpoint
		trace = util.TraceLine(trace)
		if IsValid(trace.Entity) then
			local minge = player.GetByUniqueID(trace.Entity:GetVar("PropProtection"))

					if (tobool(trace.Entity:GetVar("PropProtection"))) then
						trace.Entity:Remove()
					end
					ply:SetPos(cspawnpos+Vector(0,0,16))
			else
				ply:SetPos(cspawnpos+Vector(0,0,16))
		end

    end

end

function GM:PlayerLoadout( ply, tr )

	local team = ply:Team();
	ply:Give( "keys" );
	ply:Give( "weapon_physcannon" );
	ply:Give( "gmod_camera" );
	ply:Give( "gmod_tool" );
	ply:Give( "weapon_physgun" );
	ply:Give( "weapon_p2282" );
	ply:GiveAmmo(12, "Pistol")
end

function GM:PlayerInitialSpawn( ply )

	ply:SetNWBool("OrginCam", true)
	self.BaseClass:PlayerInitialSpawn( ply );

	ply:NewData();

	ply:SetNWBool("helpMenu",false)
	ply:GetTable().LastBuy=CurTime()
	ply:GetTable().maxDrug= 0
	ply:GetTable().maxmoneyvault= 0
	ply:GetTable().maxMicrowaves=0
	ply:GetTable().maxsupplytable=0
	ply:GetTable().maxgunlabs=0
	ply:GetTable().maxdrugfactory=0
	ply:GetTable().maxvault=0
	ply:GetTable().maxgenerator=0
	ply:GetTable().maxsupergenerator=0
	ply:GetTable().maxgunfactory=0
	ply:GetTable().maxweed=0
	ply:GetTable().maxturret=0
	ply:GetTable().maxdispensers= 0
    ply:GetTable().maxhealthdispensers= 0
    ply:GetTable().maxarmordispensers= 0
	ply:GetTable().maxspawn= 0
	ply:GetTable().maxPrinter= 0
	ply:GetTable().maxBronzePrinter= 0
	ply:GetTable().maxMoneyVault= 0
	ply:GetTable().maxAdminPrinter= 0
	ply:GetTable().maxSilverPrinter= 0
	ply:GetTable().maxGoldPrinter= 0
	ply:GetTable().maxPlatinumPrinter= 0
	ply:GetTable().maxDiamondPrinter= 0
	ply:GetTable().maxBixbitePrinter= 0
	ply:GetTable().maxNuclearPrinter= 0
	ply:GetTable().maxWashingMachinePrinter= 0
	ply:GetTable().maxmethlab= 0
	ply:GetTable().maxstablemethlab= 0
	ply:GetTable().maxStill= 0
	ply:GetTable().maxBigBombs= 0
	ply:GetTable().maxtower = 0
	ply:GetTable().maxsign = 0
	ply:GetTable().maxlamp = 0
	ply:GetTable().maxlocker = 0
	ply:SetNWBool("FactionLeader", false)
	ply:SetNWBool("spamwelding", false)
	ply:GetTable().spamweldcount = 0
	ply:SetNWBool("AFK", false)
	getMoney(ply);
	ply:GetTable().StunDuration = 0
	ply:GetTable().tickets = { }
	ply:PrintMessage( HUD_PRINTTALK, "This server is running BaseWars" )
	ply:PrintMessage( HUD_PRINTTALK, "Build Bases, Make Enemies. Have fun!" )
	ply:PrintMessage( HUD_PRINTTALK, "Help is here ask players or press F1." )
	ply:PrintMessage( HUD_PRINTTALK, "Basing with friends is the best way to base, But basing with your self is a good way to learn." )
    ply:ConCommand( "helpmenu" )
end

function GM:PlayerDisconnected( ply )

	self.BaseClass:PlayerDisconnected( ply );

	ply:UnownAllShit();

	timer.Destroy( ply:SteamID() .. "jobtimer" );

	local IDSteam = string.gsub(ply:SteamID(), ":", "")
	timer.Destroy(IDSteam .. "ROID")
	timer.Destroy(IDSteam .. "REGEN")
	timer.Destroy(IDSteam .. "REGENTICK")
	timer.Destroy(IDSteam .. "AMP")
	timer.Destroy(IDSteam .. "PAINKILLER")
	timer.Destroy(IDSteam .. "MAGICBULLET")
	timer.Destroy(IDSteam .. "STUN")
	timer.Destroy(IDSteam .. "MIRROR")
	timer.Destroy(IDSteam .. "BURN")
	timer.Destroy(IDSteam .. "POISON")
	timer.Destroy(IDSteam .. "POISONTICK")
	timer.Destroy(IDSteam .. "ANTIDOTE")
	timer.Destroy(IDSteam .. "FOCUS")
	timer.Destroy(IDSteam .. "DOUBLETAP")
	timer.Destroy(IDSteam .. "LEECH")
	timer.Destroy(IDSteam .. "SHOCKWAVE")
	timer.Destroy(IDSteam .. "AFK")
	timer.Destroy(IDSteam .. "ADRENALINE")
	timer.Destroy(IDSteam .. "DOUBLEJUMP")
	timer.Destroy(IDSteam .. "KNOCKBACK")
	timer.Destroy(IDSteam .. "ARMORPIERCER")
	timer.Destroy(IDSteam .. "SUPERDRUGOFFENSE")
	timer.Destroy(IDSteam .. "SUPERDRUGDEFENSE")
	timer.Destroy(IDSteam .. "SUPERDRUGWEAPMOD")
	for k, v in pairs(player.GetAll()) do
		if IsValid(v) then
			v:ConCommand("bw_ally_pl"..ply:EntIndex().." 0\n")
		end
	end
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	ply:GetTable().Headshot = false
	if (ply:Team()==1) then
		dmginfo:ScaleDamage( 0.9 )
	end
	if ( hitgroup == HITGROUP_HEAD ) then

		ply:GetTable().Headshot = true
	 	if ply:GetNWBool("helmeted") then
			if (ply:Team()==1) then
				dmginfo:ScaleDamage( 0.18 )
			else
				dmginfo:ScaleDamage( 0.2 )
			end
			local effectdata = EffectData()
				effectdata:SetOrigin( ply:GetPos()+Vector(0,0,60) )
				effectdata:SetMagnitude( 1 )
				effectdata:SetScale( 1 )
				effectdata:SetRadius( 2 )
			util.Effect( "Sparks", effectdata )
		else
			if (ply:Team()==1) then
				dmginfo:ScaleDamage( 1.5 )
			else
				dmginfo:ScaleDamage( 1.75 )
			end
	 	end
	 end

	if ( hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM or hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_GEAR ) then

		if (ply:Team()==1) then
			dmginfo:ScaleDamage( 0.45 )
		else
			dmginfo:ScaleDamage( 0.5 )
		end

	 end

end

PrecacheParticleSystem("bday_confetti")
function Confettis( ply, hitgroup, dmginfo )
    if hitgroup == HITGROUP_HEAD and ply:Health() - dmginfo:GetDamage() <= 0 then
        local HeadIndex = ply:LookupBone( "ValveBiped.Bip01_Head1" )
        local HeadPos, HeadAng = ply:GetBonePosition( HeadIndex )
        ParticleEffect("bday_confetti",HeadPos,HeadAng,nil)
        ply:EmitSound("misc/happy_birthday.wav")
    end
end

hook.Add("ScalePlayerDamage","Confettis",Confettis)

function meta:SetAFK()
	self:SetNWBool("AFK", true)
end

function meta:ClearAFK()
	if (self:GetNWBool("AFK")) then
		self:SetNWBool("AFK", false)
	end
	timer.Create( self:SteamID() .. "AFK", CfgVars["afktime"], 1, function() self.SetAFK( self ) end );
end

function GM:PlayerDeathNotify( Victim, Inflictor, Attacker )
	if (Inflictor:GetClass()=="env_physexplosion" or Inflictor:GetClass()=="env_fire") and IsValid(Inflictor:GetTable().attacker) then
		Attacker = Inflictor:GetTable().attacker
	end

	if Inflictor==Victim and Attacker==Victim then
		Victim.NextSpawnTime = CurTime() + 5
	else
		Victim.NextSpawnTime = CurTime() + 3
	end

	if ( Inflictor and Inflictor == Attacker and ( Inflictor:IsNPC() or Inflictor:IsPlayer()) ) then
		local weap = Inflictor:GetActiveWeapon()
		if IsValid(weap) then
			local class=weap:GetClass()
			if class=="weapon_stunstick" or class=="weapon_crowbar" or class=="weapon_pistol" or class=="weapon_357" or class=="weapon_smg1" or class=="weapon_ar2" or class=="weapon_shotgun" then

				Inflictor = Inflictor:GetActiveWeapon()
				if ( not Inflictor or Inflictor == NULL ) then Inflictor = Attacker end
			end
		end

	end

	if (Attacker == Victim) then
		if not IsValid(Inflictor) then Inflictor = Victim end
		net.Start( "PlrKilledSelf" )
			net.WriteEntity( Victim )
			net.WriteEntity( Inflictor )
			net.WriteString( Inflictor:GetClass() )
			net.WriteBool( Victim:GetTable().Headshot )
		net.Broadcast()

		MsgAll( Attacker:Nick() .. " suicided using " .. Inflictor:GetClass() .. "!\n" )

	return end

	if ( Attacker:IsPlayer() ) then

		net.Start( "PlrKilledPlr" )

			net.WriteEntity( Victim )
			net.WriteEntity( Inflictor )
			net.WriteEntity( Attacker )
			net.WriteString( Inflictor:GetClass() )
			net.WriteBool( Victim:GetTable().Headshot )

		net.Broadcast()

		MsgAll( Attacker:Nick() .. " killed " .. Victim:Nick() .. " using " .. Inflictor:GetClass() .. "\n" )

	return end

	net.Start( "PlrKilled" )

		net.WriteEntity( Victim )
		net.WriteEntity( Inflictor )
		net.WriteString( Attacker:GetClass() )
		net.WriteString( Inflictor:GetClass() )
		net.WriteBool( Victim:GetTable().Headshot )

	net.Broadcast()

	MsgAll( Victim:Nick() .. " was killed by " .. Attacker:GetClass() .. "\n" )

end

local function LimitReachedProcess( ply, str )

	if (game.SinglePlayer()) then return true end

	local cvar = GetConVar( "sbox_max"..str )
	local c = cvar and cvar:GetInt() or 0

	if ( ply:GetCount( str ) < c or c < 0 ) then return true end

	ply:LimitHit( str )
	return false

end

function GM:SetupPlayerVisibility(ply)
	for k,v in pairs(ents.FindByClass("bigbomb")) do
		if v:GetNWBool("armed") then
			AddOriginToPVS(v:GetPos())
		end
	end
end

function GM:PlayerSpawnMagnet( ply, model )

	return LimitReachedProcess( ply, "magnets" )

end

function GM:PlayerSpawnedMagnet( ply, model, ent )

	ply:AddCount( "magnets", ent )

end
