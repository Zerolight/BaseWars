SWEP.Base 				= "weapon_mad_base"

SWEP.ShellEffect			= "effect_mad_shell_shotgun"
SWEP.ShellDelay			= 0

SWEP.Pistol				= false
SWEP.Rifle				= false
SWEP.Shotgun			= true
SWEP.Sniper				= false

SWEP.Penetration			= false
SWEP.Ricochet			= false

function SWEP:Think()

	if self:Clip1() > self.Primary.ClipSize then
		self:SetClip1(self.Primary.ClipSize)
	end

	if self:GetNWBool("Reloading") == true then
		if self:GetNWInt("ReloadTime") < CurTime() then
			if (self:Clip1() >= self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0) then
				self:SetNextPrimaryFire(CurTime() + self.ShotgunFinish)
				self:SetNextSecondaryFire(CurTime() + self.ShotgunFinish)
				self:SetNWBool("Reloading", false)
				self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)

				if (IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()) then
					self:IdleAnimation(self:GetOwner():GetViewModel():SequenceDuration())
				end
			else
				self:SetNWInt("ReloadTime", CurTime() + 0.45)
				self:SendWeaponAnim(ACT_VM_RELOAD)
				self:GetOwner():RemoveAmmo(1, self.Primary.Ammo, false)
				self:SetClip1(self:Clip1() + 1)
				self:SetNextPrimaryFire(CurTime() + 0.5)
				self:SetNextSecondaryFire(CurTime() + 0.5)

				if (self:Clip1() >= self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0) then
					self:SetNextPrimaryFire(CurTime() + 1.5)
					self:SetNextSecondaryFire(CurTime() + 1.5)
				else
					self:SetNextPrimaryFire(CurTime() + 0.5)
					self:SetNextSecondaryFire(CurTime() + 0.5)
				end
			end
		end
	end

	if (self:GetOwner():KeyPressed(IN_ATTACK)) and (self:GetNWBool("Reloading", true)) then
		self:SetNextPrimaryFire(CurTime() + self.ShotgunFinish)
		self:SetNextPrimaryFire(CurTime() + self.ShotgunFinish)
		self:SetNWInt("ReloadTime", CurTime() + self.ShotgunFinish)
		self:SetNWBool("Reloading", false)

		timer.Simple(self:GetOwner():GetViewModel():SequenceDuration(), function()
			if not self:GetOwner() then return end
			self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)

			if (IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()) then
				self:IdleAnimation(self:GetOwner():GetViewModel():SequenceDuration())
			end
		end)
	end

	self:SecondThink()

	if self.IdleDelay < CurTime() and self.IdleApply and self:Clip1() > 0 then
		local WeaponModel = self:GetOwner():GetActiveWeapon():GetClass()

		if self:GetOwner():GetActiveWeapon():GetClass() == WeaponModel and self:GetOwner():Alive() then
			if self:GetDTBool(3) and self.Type == 2 then
				self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
			else
				self:SendWeaponAnim(ACT_VM_IDLE)
			end

			if self.AllowPlaybackRate and not self:GetDTBool(1) then
				self:GetOwner():GetViewModel():SetPlaybackRate(1)
			else
				self:GetOwner():GetViewModel():SetPlaybackRate(0)
			end
		end

		self.IdleApply = false
	elseif self:Clip1() <= 0 then
		self.IdleApply = false
	end

	if self:GetDTBool(2) and self:GetOwner():KeyDown(IN_SPEED) then
		self:SetIronsights(false)
	end

	if self:GetOwner():KeyDown(IN_SPEED) or self:GetDTBool(0) then
		if self.Rifle or self.Sniper or self.Shotgun then
			if (SERVER) then
				self:SetWeaponHoldType("passive")
			end
		elseif self.Pistol then
			if (SERVER) then
				self:SetWeaponHoldType("normal")
			end
		end
	else
		if (SERVER) then
			self:SetWeaponHoldType(self.HoldType)
		end
	end

	if self:GetDTBool(3) and self.Type == 3 then
		if self.BurstTimer + self.BurstDelay < CurTime() then
			if self.BurstCounter > 0 then
				self.BurstCounter = self.BurstCounter - 1
				self.BurstTimer = CurTime()

				if self:CanPrimaryAttack() then
					self:EmitSound(self.Primary.Sound)
					self:ShootBulletInformation()
					self:TakePrimaryAmmo(1)
				end
			end
		end
	end

	self:NextThink(CurTime())
end

function SWEP:Reload()

	if (self.ActionDelay > CurTime()) then return end

	if (self:GetNWBool("Reloading") or self.ShotgunReloading) then return end

	if (self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0) then
		self.ShotgunReloading = true
		self:SetNextPrimaryFire(CurTime() + self.ShotgunBeginReload + 0.1)
		self:SetNextSecondaryFire(CurTime() + self.ShotgunBeginReload + 0.1)
		self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)

		timer.Simple(self.ShotgunBeginReload, function()
			self.ShotgunReloading = false
			self:SetNWBool("Reloading", true)
			self:SetVar("ReloadTime", CurTime() + 1)
			self:SetNextPrimaryFire(CurTime() + 0.5)
			self:SetNextSecondaryFire(CurTime() + 0.5)
		end)

		if (SERVER) then
			self:GetOwner():SetFOV( 0, 0.15 )
			self:SetIronsights(false)
		end
	end
end

function SWEP:Deploy()

	self.ShotgunReloading = false
	self:SetNWBool("Reloading", false)

	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetNextPrimaryFire(CurTime() + self.DeployDelay)
	self:SetNextSecondaryFire(CurTime() + self.DeployDelay)
	self.ActionDelay = (CurTime() + self.DeployDelay)

	if (SERVER) then
		self:SetIronsights(false)
	end

	if (IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()) then
		self:IdleAnimation(self:GetOwner():GetViewModel():SequenceDuration())
	end

	return true
end
