AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( "gunvault" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()
	self:SetModel( "models/props/cs_militia/footlocker01_closed.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:SetMass(250)
		phys:Wake()
	end
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",750)
	self:SetNWInt("upgrade", 0)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxvault=ply:GetTable().maxvault + 1
	self.Locked = true
	self.LastUsed = CurTime()
	self.Guns = {}
	self.Upgrades = {}
end

function ENT:OnTakeDamage(dmg)
	local damage = dmg:GetDamage()
	local attacker=dmg:GetAttacker()
	if not dmg:IsExplosionDamage() and IsValid(attacker) and attacker:IsPlayer() and attacker:GetTable().ArmorPiercered then
		damage = damage*drugeffect_armorpiercermod
	end
	self:SetNWInt("damage",self:GetNWInt("damage") - damage)
	if(self:GetNWInt("damage") <= 0) then
		self:DropAllGuns()
		self:Destruct()
		self:Remove()
	end
end

function ENT:Destruct()

	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart( vPoint )
	effectdata:SetOrigin( vPoint )
	effectdata:SetScale( 1 )
	util.Effect( "Explosion", effectdata )

end

function ENT:Use(activator,caller)
	if (self.LastUsed+0.5>CurTime()) then
		self.LastUsed = CurTime()
	else
		self.LastUsed = CurTime()
		local ply = (self.Owner or self:GetOwner())
		if (activator==ply or not self.Locked or activator:IsAllied(ply)) then
			if (activator==ply or activator:IsAllied(ply)) then
				self.Locked = true
			end

			net.Start("killgunvaultgui");
				net.WriteInt( self:EntIndex() , 16)
			net.Send(activator)
			net.Start("gunvaultgui");
				net.WriteString( table.concat(self.Guns, ",") )
				net.WriteInt( self:EntIndex() , 16)
				net.WriteString( table.concat(self.Upgrades, ",") )
			net.Send(activator)
		else
			Notify(activator,4,3,"This gun vault is locked! use a lock pick to force it open.")
		end
	end
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:DropAllGuns()
		self:Remove()
	end
end

function ENT:DropAllGuns()

	for i=1, table.Count(self.Guns), 1 do
		self:DropGun(i, self, 10, true)
	end
end
function ENT:CanDropGun(gunnum)
	local gunt = self.Guns[gunnum]
	if (gunt~=nil) then return true else return false end
end
function ENT:DropGun(gunnum, ply, hgt, bigdrop)
	local gunt = self.Guns[gunnum]
	if (bigdrop~=true) then
		local gunt = table.remove(self.Guns, tonumber(gunnum))
	end
	local upgrade = util.tobool(self.Upgrades[gunnum])
	if (not bigdrop) then
		local upgrade = util.tobool(table.remove(self.Upgrades, tonumber(gunnum)))
	end

	local gun = string.gsub(gunt, "weapon_", "")
	local height = hgt

	if (gun=="pipebomb") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/props_lab/pipesystem03b.mdl" );
		weapon:SetNWString("weaponclass", "weapon_pipebomb");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
		weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="tranqgun") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_crossbow.mdl" );
		weapon:SetNWString("weaponclass", "weapon_tranqgun");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetNWBool("upgraded", upgrade)
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="rocketlauncher") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_rocket_launcher.mdl" );
		weapon:SetNWString("weaponclass", "weapon_rocketlauncher");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="50cal2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_mach_m249para.mdl" );
		weapon:SetNWString("weaponclass", "weapon_50cal2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="molotov") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/props_junk/garbage_glassbottle003a.mdl" );
		weapon:SetNWString("weaponclass", "weapon_molotov");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="ls_sniper") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_snip_awp.mdl" );
		weapon:SetNWString("weaponclass", "ls_sniper");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="autosnipe") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_snip_g3sg1.mdl" );
		weapon:SetNWString("weaponclass", "weapon_autosnipe");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="ak472") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_rif_ak47.mdl" );
		weapon:SetNWString("weaponclass", "weapon_ak472");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="galil2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_rif_galil.mdl" );
		weapon:SetNWString("weaponclass", "weapon_galil2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="p902") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_smg_p90.mdl" );
		weapon:SetNWString("weaponclass", "weapon_p902");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="pumpshotgun2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_shot_m3super90.mdl" );
		weapon:SetNWString("weaponclass", "weapon_pumpshotgun2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="autoshotgun2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_shot_xm1014.mdl" );
		weapon:SetNWString("weaponclass", "weapon_autoshotgun2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="mp52") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_smg_mp5.mdl" );
		weapon:SetNWString("weaponclass", "weapon_mp52");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="tmp2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_smg_tmp.mdl" );
		weapon:SetNWString("weaponclass", "weapon_tmp2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="m42") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_rif_m4a1.mdl" );
		weapon:SetNWString("weaponclass", "weapon_m42");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="ump452") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_smg_ump45.mdl" );
		weapon:SetNWString("weaponclass", "weapon_ump452");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="mac102") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_smg_mac10.mdl" );
		weapon:SetNWString("weaponclass", "weapon_mac102");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="cse_eq_hegrenade") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_eq_fraggrenade.mdl" );
		weapon:SetNWString("weaponclass", "cse_eq_hegrenade");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="gasgrenade") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_eq_smokegrenade.mdl" );
		weapon:SetNWString("weaponclass", "weapon_gasgrenade");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="cse_eq_flashbang") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_eq_flashbang.mdl" );
		weapon:SetNWString("weaponclass", "cse_eq_flashbang");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="cse_eq_flashbang") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_eq_flashbang.mdl" );
		weapon:SetNWString("weaponclass", "cse_eq_flashbang");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="knife2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_knife_t.mdl" );
		weapon:SetNWString("weaponclass", "weapon_knife2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="p2282") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_pist_p228.mdl" );
		weapon:SetNWString("weaponclass", "weapon_p2282");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="aug2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_rif_aug.mdl" );
		weapon:SetNWString("weaponclass", "weapon_aug2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="deagle2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_pist_deagle.mdl" );
		weapon:SetNWString("weaponclass", "weapon_deagle2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="glock2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_pist_glock18.mdl" );
		weapon:SetNWString("weaponclass", "weapon_glock2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="fiveseven2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_pist_fiveseven.mdl" );
		weapon:SetNWString("weaponclass", "weapon_fiveseven2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="usp2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_pist_usp.mdl" );
		weapon:SetNWString("weaponclass", "weapon_usp2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="elites2") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_pist_elite_dropped.mdl" );
		weapon:SetNWString("weaponclass", "weapon_elites2");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="grenadegun") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_rif_sg552.mdl" );
		weapon:SetNWString("weaponclass", "weapon_grenadegun");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
		weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="worldslayer") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_rocket_launcher.mdl" );
		weapon:SetNWString("weaponclass", "weapon_worldslayer");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="flamethrower") then
			weapon.Ejected = true;
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_smg1.mdl" );
		weapon:SetNWString("weaponclass", "weapon_flamethrower");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
		weapon:Spawn();
	elseif (gun=="turretgun") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_smg1.mdl" );
		weapon:SetNWString("weaponclass", "weapon_turretgun");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="lasergun") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_irifle.mdl" );
		weapon:SetNWString("weaponclass", "weapon_lasergun");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="laserrifle") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_snip_scout.mdl" );
		weapon:SetNWString("weaponclass", "weapon_laserrifle");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="stickgrenade") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/magnusson_device.mdl" );
		weapon:SetNWString("weaponclass", "weapon_stickgrenade");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="stickgrenade") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_c4_planted.mdl" );
		weapon:SetNWString("weaponclass", "weapon_mad_c4");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	elseif (gun=="plasma") then
		local weapon = ents.Create("spawned_weapon")
		weapon:SetModel( "models/weapons/w_irifle.mdl" );
		weapon:SetNWString("weaponclass", "weapon_plasma");
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:SetUpgraded(upgrade)
				weapon.Ejected = true;
		weapon:Spawn();
	end
	if (ply~=nil) then
		if (ply:IsPlayer()) then
			net.Start("killgunvaultgui");
				net.WriteInt( self:EntIndex() , 16)
			net.Send(ply)
		end
	end
end
function ENT:OnRemove( )
	timer.Destroy(tostring(self))
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxvault=ply:GetTable().maxvault - 1
	end
	net.Start("killgunvaultgui");
		net.WriteInt( self:EntIndex() , 16)
	net.Broadcast()
end

function ENT:Touch(gun)
	if (gun:GetClass()=="spawned_weapon" and gun:GetNWString("weaponclass")~=nil and gun:GetNWString("weaponclass")~="weapon_physgun" and gun:GetNWString("weaponclass")~="" and not gun.Ejected and table.Count(self.Guns)<10) then
		local wepclass = gun:GetNWString("weaponclass")
		local upgraded = gun:IsUpgraded()

		if (upgraded) then
			upgraded = "1"
		else
			upgraded = "0"
		end
		table.insert(self.Guns, wepclass)
		table.insert(self.Upgrades, upgraded)

		gun:SetNWString("weaponclass", "weapon_physgun")
		gun:Remove()
	end
end

function ENT:IsLocked()
	return self.Locked
end

function ENT:SetUnLocked()
	self.Locked = false
	return true
end
