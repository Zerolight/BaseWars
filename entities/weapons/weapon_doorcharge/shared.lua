SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_slam.mdl"
SWEP.WorldModel			= "models/weapons/w_slam.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

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

SWEP.RunArmOffset 		= Vector (-0.5928, 0, 6.3399)
SWEP.RunArmAngle 			= Vector (-19.4462, -2.5193, 0)

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

	self:SetNextPrimaryFire(CurTime() + 0.5)
	self:SetNextSecondaryFire(CurTime() + 0.5)

	if not trace.Hit or trace.Entity:GetClass() ~= "prop_door_rotating" or trace.HitWorld then
		if (SERVER) then
			self:GetOwner():PrintMessage(HUD_PRINTTALK, "Explosive charge can only be installed on doors!")
		end

		return
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	self:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH)

	timer.Simple(0.5, function()
		if (not self:GetOwner():Alive() or self:GetOwner():GetActiveWeapon():GetClass() ~= "weapon_mad_charge" or not IsFirstTimePredicted()) then return end

		self:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH2)

		local tr = {}
		tr.start = self:GetOwner():GetShootPos()
		tr.endpos = self:GetOwner():GetShootPos() + 100 * self:GetOwner():GetAimVector()
		tr.filter = {self:GetOwner()}
		local trace = util.TraceLine(tr)

		if not trace.Hit or trace.Entity:GetClass() ~= "prop_door_rotating" or trace.HitWorld then
			timer.Simple(0.6, function()
				if self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
					self:Deploy()
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

		Charge = ents.Create("ent_mad_charge")
		Charge:SetPos(trace.HitPos + trace.HitNormal)

		trace.HitNormal.z = -trace.HitNormal.z

		Charge:SetAngles(trace.HitNormal:Angle() - Angle(270, 180, 180))

		Charge.Owner = self:GetOwner()
		Charge:Spawn()

		if trace.Entity and trace.Entity:IsValid() and trace.Entity:GetClass() == "prop_door_rotating" then
			if not trace.Entity:IsNPC() and not trace.Entity:IsPlayer() and trace.Entity:GetPhysicsObject():IsValid() then
				constraint.Weld(Charge, trace.Entity)
			end
		else
			Charge:SetMoveType(MOVETYPE_NONE)
		end

		timer.Simple(0.6, function()
			if (not self:GetOwner():Alive() or self:GetOwner():GetActiveWeapon():GetClass() ~= "weapon_mad_charge") or not IsFirstTimePredicted() then return end

			self:Deploy()
		end)
	end)
end

function SWEP:SecondaryAttack()
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

		self:SendWeaponAnim(ACT_SLAM_TRIPMINE_DRAW)

	self:SetNextPrimaryFire(CurTime() + self.DeployDelay)
	self:SetNextSecondaryFire(CurTime() + self.DeployDelay)
	self.ActionDelay = (CurTime() + self.DeployDelay)

	return true
end

function SWEP:Holster()

	if (CLIENT) and self.Ghost:IsValid() then
		self.Ghost:SetColor(Color(255, 255, 255, 0))
	end

	return true
end

function SWEP:OnRemove()

	if (CLIENT) and self.Ghost:IsValid() then
		self.Ghost:SetColor(Color(255, 255, 255, 0))
	end

	return true
end
