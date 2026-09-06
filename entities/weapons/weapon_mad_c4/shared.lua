SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_c4.mdl"
SWEP.WorldModel			= "models/weapons/w_c4.mdl"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.Primary.Sound		= Sound("")
SWEP.Primary.Recoil		= 0
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Thumper"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "none"
SWEP.ShellDelay			= 0

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.Blacklist = {}
SWEP.Blacklist["ent_mad_c4"] 	= true

SWEP.Timer				= 30

function SWEP:Precache()

	util.PrecacheSound("weapons/c4/c4_disarm.wav")
	util.PrecacheSound("weapons/c4/c4_explode1.wav")
	util.PrecacheSound("weapons/c4/c4_click.wav")
	util.PrecacheSound("weapons/c4/c4_plant.wav")
	util.PrecacheSound("weapons/c4/c4_beep1.wav")
end

function SWEP:PrimaryAttack()

	if (not self:GetOwner():IsNPC() and self:GetOwner():KeyDown(IN_USE)) then
		bHolsted = not self:GetDTBool(0)
		self:SetHolsted(bHolsted)

		self:SetNextPrimaryFire(CurTime() + 0.3)
		self:SetNextSecondaryFire(CurTime() + 0.3)

		self:SetIronsights(false)

		return
	end

	if (not self:CanPrimaryAttack()) then return end

	local tr = {}
	tr.start = self:GetOwner():GetShootPos()
	tr.endpos = self:GetOwner():GetShootPos() + 100 * self:GetOwner():GetAimVector()
	tr.filter = {self:GetOwner()}
	local trace = util.TraceLine(tr)

	if not trace.Hit then return end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	timer.Simple(3, function()
		if (not self:GetOwner() or not self:GetOwner():Alive() or self:GetOwner():GetActiveWeapon():GetClass() ~= "weapon_mad_c4" or not IsFirstTimePredicted()) then return end

		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

		local tr = {}
		tr.start = self:GetOwner():GetShootPos()
		tr.endpos = self:GetOwner():GetShootPos() + 100 * self:GetOwner():GetAimVector()
		tr.filter = {self:GetOwner()}
		local trace = util.TraceLine(tr)

		if not trace.Hit then
			timer.Simple(0.6, function()
				if self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
					self:SendWeaponAnim(ACT_VM_DRAW)
				else
					self:Remove()
					self:GetOwner():ConCommand("lastinv")
				end
			end)

			return
		end

		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		self:TakePrimaryAmmo(1)

		if (CLIENT) then return end

		C4 = ents.Create("ent_mad_c4")
		C4:SetPos(trace.HitPos + trace.HitNormal)

		trace.HitNormal.z = -trace.HitNormal.z

		C4:SetAngles(trace.HitNormal:Angle() - Angle(90, 180))

		C4.Owner = self:GetOwner()
		C4.Timer = self.Timer
		C4:Spawn()

		if IsValid(trace.Entity) and trace.Entity ~= game.GetWorld()
			and not self.Blacklist[trace.Entity:GetClass()]
			and not trace.Entity:IsNPC() and not trace.Entity:IsPlayer()
			and IsValid(trace.Entity:GetPhysicsObject()) then

			C4:SetParent(trace.Entity)
			C4:SetMoveType(MOVETYPE_NONE)

			local phys = C4:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
				phys:Sleep()
			end
		else
			C4:SetMoveType(MOVETYPE_NONE)
		end

		timer.Simple(0.6, function()
			if (not self:GetOwner():Alive() or self:GetOwner():GetActiveWeapon():GetClass() ~= "weapon_mad_c4") or not IsFirstTimePredicted() then return end

			if self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
				self:SendWeaponAnim(ACT_VM_DRAW)
			else
				self:Remove()
				self:GetOwner():ConCommand("lastinv")
			end
		end)
	end)
end

function SWEP:SecondaryAttack()

	self:SetNextPrimaryFire(CurTime() + 0.1)
	self:SetNextSecondaryFire(CurTime() + 0.1)

	if self.Timer == 30 then
		if (SERVER) then
			self:GetOwner():PrintMessage(HUD_PRINTTALK, "60 Seconds.")
		end

		self.Timer = 60
		self:GetOwner():EmitSound("C4.PlantSound")
	elseif self.Timer == 60 then
		if (SERVER) then
			self:GetOwner():PrintMessage(HUD_PRINTTALK, "120 Seconds.")
		end

		self.Timer = 120
		self:GetOwner():EmitSound("C4.PlantSound")
	elseif self.Timer == 120 then
		if (SERVER) then
			self:GetOwner():PrintMessage(HUD_PRINTTALK, "300 Seconds.")
		end

		self.Timer = 300
		self:GetOwner():EmitSound("C4.PlantSound")
	elseif self.Timer == 300 then
		if (SERVER) then
			self:GetOwner():PrintMessage(HUD_PRINTTALK, "30 Seconds.")
		end

		self.Timer = 30
		self:GetOwner():EmitSound("C4.PlantSound")
	end
end

function SWEP:CanPrimaryAttack()

	if (self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0) or (self:GetOwner():WaterLevel() > 2) then
		self:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	if (not self:GetOwner():IsNPC()) and (self:GetOwner():KeyDown(IN_SPEED)) then
		self:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	return true
end

function SWEP:Deploy()

	if self:GetNWBool("Suppressor") then
		self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
	else
		self:SendWeaponAnim(ACT_VM_DRAW)
	end

	self:SetNextPrimaryFire(CurTime() + self.DeployDelay)
	self:SetNextSecondaryFire(CurTime() + self.DeployDelay)
	self.ActionDelay = (CurTime() + self.DeployDelay)

	return true
end

function SWEP:Holster()

	if (CLIENT) and IsValid(self.Ghost) then
		self.Ghost:Remove()
		self.Ghost = NULL
	end

	return true
end

function SWEP:OnRemove()

	if (CLIENT) and IsValid(self.Ghost) then
		self.Ghost:Remove()
		self.Ghost = NULL
	end

	return true
end
