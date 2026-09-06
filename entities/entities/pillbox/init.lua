AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( "pillbox" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()
	self:SetModel( "models/props_c17/furniturefridge001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then

		phys:Wake()
	end
	self:SetNWBool("sparking",false)
	self:SetVar("damage",750)
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
	self:SetVar("damage",self:GetVar("damage") - damage)
	if(self:GetVar("damage") <= 0) then
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
			if (activator==ply) then
				self.Locked = true
			end

			net.Start("killpillboxgui");
				net.WriteInt( self:EntIndex() , 16)
			net.Send(activator)
			net.Start("pillboxgui");
				net.WriteString( table.concat(self.Guns, ",") )
				net.WriteInt( self:EntIndex() , 16)
			net.Send(activator)
		else
			Notify(activator,4,3,"This pill box is locked! use a lock pick to force it open.")
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
		self:DropGun(i, self, 20, true)
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

	local gun = string.gsub(gunt, "item_", "")
	local height = hgt

	if (gun=="steroid") then
		local weapon = ents.Create("item_steroid")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="regen") then
		local weapon = ents.Create("item_regen")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="painkiller") then
		local weapon = ents.Create("item_painkiller")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="reflect") then
		local weapon = ents.Create("item_reflect")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="focus") then
		local weapon = ents.Create("item_focus")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="antidote") then
		local weapon = ents.Create("item_antidote")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="armor") then
		local weapon = ents.Create("item_armor")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="buyhealth") then
		local weapon = ents.Create("item_buyhealth")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="snipeshield") then
		local weapon = ents.Create("item_snipeshield")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="amp") then
		local weapon = ents.Create("item_amp")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="helmet") then
		local weapon = ents.Create("item_helmet")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="random") then
		local weapon = ents.Create("item_random")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="drug") then
		local weapon = ents.Create("item_drug")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="booze") then
		local weapon = ents.Create("item_booze")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="food") then
		local weapon = ents.Create("item_food")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="superdrug") then
		local weapon = ents.Create("item_superdrug")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="scanner") then
		local weapon = ents.Create("item_scanner")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="toolkit") then
		local weapon = ents.Create("item_toolkit")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="adrenaline") then
		local weapon = ents.Create("item_adrenaline")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="a.piercer") then
		local weapon = ents.Create("item_armorpiercer")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="leech") then
		local weapon = ents.Create("item_leech")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="doublejump") then
		local weapon = ents.Create("item_doublejump")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="doubletap") then
		local weapon = ents.Create("item_doubletap")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="shockwave") then
		local weapon = ents.Create("item_shockwave")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="magicbullet") then
		local weapon = ents.Create("item_magicbullet")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="knockback") then
		local weapon = ents.Create("item_knockback")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="s.offense") then
		local weapon = ents.Create("item_superdrugoffense")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="s.defense") then
		local weapon = ents.Create("item_superdrugdefense")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="s.weapmod") then
		local weapon = ents.Create("item_superdrugweapmod")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
		weapon:Spawn();
	elseif (gun=="uberdrug") then
		local weapon = ents.Create("item_uberdrug")
		weapon:SetPos( self:GetPos()+Vector(0,0,height));
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
	if ((gun:GetClass()=="item_adrenaline" or gun:GetClass()=="item_armorpiercer" or gun:GetClass()=="item_leech" or gun:GetClass()=="item_doublejump" or gun:GetClass()=="item_shockwave" or gun:GetClass()=="item_doubletap" or gun:GetClass()=="item_magicbullet" or gun:GetClass()=="item_knockback" or gun:GetClass()=="item_uberdrug" or gun:GetClass()=="item_superdrugweapmod" or gun:GetClass()=="item_superdrugdefense" or gun:GetClass()=="item_superdrugoffense" or gun:GetClass()=="item_superdrug" or gun:GetClass()=="item_regen" or gun:GetClass()=="item_steroid" or gun:GetClass()=="item_painkiller" or gun:GetClass()=="item_amp" or gun:GetClass()=="item_armor" or gun:GetClass()=="item_buyhealth" or gun:GetClass()=="item_antidote" or gun:GetClass()=="item_helmet" or gun:GetClass()=="item_reflect" or gun:GetClass()=="item_focus" or gun:GetClass()=="item_random" or gun:GetClass()=="item_drug" or gun:GetClass()=="item_booze" or gun:GetClass()=="item_food" or gun:GetClass()=="item_scanner" or gun:GetClass()=="item_toolkit") and table.Count(self.Guns)<20 and gun:GetTime()<CurTime()-5) then
		local wepclass = string.gsub(gun:GetClass(), "item_", "")
		if wepclass=="armorpiercer" then wepclass= "a.piercer"
		elseif wepclass=="superdrugoffense" then wepclass="s.offense"
		elseif wepclass=="superdrugdefense" then wepclass="s.defense"
		elseif wepclass=="superdrugweapmod" then wepclass="s.weapmod"
		end
		table.insert(self.Guns, wepclass)
		gun:ResetTime()
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
