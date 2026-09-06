SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_eq_fraggrenade.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_fraggrenade.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 1.5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Grenade"

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

SWEP.GrenadeType			= "ent_mad_grenade"
SWEP.GrenadeName			= "cse_eq_hegrenade"
SWEP.GrenadeTime			= "4.5"
SWEP.CookGrenade			= true

function SWEP:PrimaryAttack()

	if (not self:GetOwner():IsNPC() and self:GetOwner():KeyDown(IN_USE)) then
		bHolsted = not self:GetDTBool(0)
		self:SetHolsted(bHolsted)

		self:SetNextPrimaryFire(CurTime() + 0.3)
		self:SetNextSecondaryFire(CurTime() + 0.3)

		self:SetIronsights(false)

		return
	end

	if (self:GetOwner():GetNWInt("Throw") > CurTime() or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 or self:GetOwner():GetNWInt("Primed") ~= 0 or self:GetNWBool("Holsted")) then return end

	self:SendWeaponAnim(ACT_VM_PULLPIN)

	self:GetOwner():SetNWInt("Primed", 1)
	self:GetOwner():SetNWInt("Throw", CurTime() + 1)
	self:GetOwner():SetNWBool("Cooked", false)
end

function SWEP:SecondaryAttack()

	if not self.CookGrenade then return end
	if self:GetOwner():GetNWBool("Reloading") then return end
	if self:GetOwner():GetNWInt("Primed") == 0 then return end
	if self:GetOwner():GetNWInt("Primed") == 2 then return end

	self:GetOwner():SetNWBool("Reloading", true)
	timer.Simple(self.GrenadeTime + 0.1, function() if not self:GetOwner() then return end self:GetOwner():SetNWBool("Reloading", false) end)

	self:EmitSound("weapons/grenade/cook.wav", 60)

	self:GetOwner():SetNWBool("Cooked", true)
	self.NextExplode = CurTime() + self.GrenadeTime

	timer.Simple(self.GrenadeTime, function()
		if not self:GetOwner() then return end
		if  not IsFirstTimePredicted() then return end

		if self:GetOwner():GetNWBool("Cooked") and self:GetOwner():GetActiveWeapon():GetClass() == self.GrenadeName and self:GetOwner():Alive() then
			if self:GetOwner():GetNWInt("Primed") == 1 then
				local grenade = ents.Create(self.GrenadeType)

				local pos = self:GetOwner():GetShootPos()
					pos = pos + self:GetOwner():GetForward() * 1
					pos = pos + self:GetOwner():GetRight() * 7

					if self:GetOwner():KeyDown(IN_SPEED) then
						pos = pos + self:GetOwner():GetUp() * -4
					else
						pos = pos + self:GetOwner():GetUp() * 1
					end

				grenade:SetPos(pos)

				grenade:SetAngles(Angle(math.random(1, 100), math.random(1, 100), math.random(1, 100)))
				grenade:SetOwner(self:GetOwner())
				grenade:SetNWInt("Cook", 0)
				grenade:Spawn()

				self:GetOwner():SetNWInt("Primed", 0)
				self:GetOwner():SetNWBool("Cooked", false)

				timer.Simple(0.6, function()
					if not self:GetOwner() then return end

					if self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
						self:SendWeaponAnim(ACT_VM_DRAW)
						self:GetOwner():SetNWInt("Primed", 0)
					else
						self:GetOwner():SetNWInt("Primed", 0)
						self:GetOwner():ConCommand("lastinv")
					end
				end)
			end
		end
	end)
end

function SWEP:Think()

	self:SecondThink()

	if (self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():GetNWInt("Primed") == 0) or self:GetNWBool("Holsted") then
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

	if (self:GetOwner():GetNWInt("Primed") == 1 and not self:GetOwner():KeyDown(IN_ATTACK)) then
		if self:GetOwner():GetNWInt("Throw") < CurTime() then
			self:GetOwner():SetNWInt("Primed", 2)
			self:GetOwner():SetNWInt("Throw", CurTime() + 1.5)

			if not self:GetOwner():Crouching() then
				self:SendWeaponAnim(ACT_VM_THROW)
			end

			self:GetOwner():SetAnimation(PLAYER_ATTACK1)

			timer.Simple(0.35, function()	if not self:GetOwner() then return end self:ThrowGrenade() self:GetOwner():ViewPunch(Angle(math.Rand(1, 2), math.Rand(0, 0), math.Rand(0, 0))) end)
		end
	end

	if self:GetOwner():GetNWBool("Cooked") and self:GetOwner():GetNWBool("LastShootCook") < CurTime() then
		if ((game.SinglePlayer() and SERVER) or CLIENT) then
			self:SetNWFloat("LastShootTime", CurTime())
			self:GetOwner():EmitSound("NPC_CombineCamera.Click")
		end

		self:GetOwner():SetNWBool("LastShootCook", CurTime() + 1)
	end
end

function SWEP:Holster()

	self:GetOwner():SetNWInt("Primed", 0)
	self:GetOwner():SetNWInt("Throw", CurTime())

	return true
end

function SWEP:Deploy()

	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetNextPrimaryFire(CurTime() + self.DeployDelay)
	self:SetNextSecondaryFire(CurTime() + self.DeployDelay)
	self.ActionDelay 	= (CurTime() + self.DeployDelay)
	self:GetOwner():SetNWInt("Throw", CurTime() + self.DeployDelay)

	self:GetOwner():SetNWBool("LastShootCook", CurTime())

	return true
end

function SWEP:ThrowGrenade()

	if (self:GetOwner():GetNWInt("Primed") ~= 2 or CLIENT) then return end

	if self.CookGrenade and not self:GetOwner():GetNWBool("Cooked") then
		self.NextExplode = CurTime() + self.GrenadeTime
		self:EmitSound("weapons/grenade/cook.wav", 60)
	end

	local grenade = ents.Create(self.GrenadeType)

	if self.CookGrenade then
		self:GetOwner():SetNWBool("Cooked", false)

		local RemainingTime = self.NextExplode - CurTime()
		grenade:SetNWInt("Cook", CurTime() + RemainingTime)
	end

	local pos = self:GetOwner():GetShootPos()
		pos = pos + self:GetOwner():GetRight() * 7

		if self:GetOwner():KeyDown(IN_SPEED) and not self:GetOwner():Crouching() then
			pos = pos + self:GetOwner():GetUp() * -4
		elseif not self:GetOwner():Crouching() then
			pos = pos + self:GetOwner():GetForward() * -6
			pos = pos + self:GetOwner():GetUp() * 1
		else
			pos = pos + self:GetOwner():GetForward() * 1
			pos = pos + self:GetOwner():GetUp() * -24
		end

	grenade:SetPos(pos)
	grenade:SetAngles(Angle(math.random(1, 100), math.random(1, 100), math.random(1, 100)))
	grenade:SetOwner(self:GetOwner())
	grenade:Spawn()

	local phys = grenade:GetPhysicsObject()

	if self:GetOwner():KeyDown(IN_FORWARD) then
		self.Force = 3200
	elseif self:GetOwner():KeyDown(IN_BACK) then
		self.Force = 2100
	else
		self.Force = 2500
	end

	if not self:GetOwner():Crouching() then
		phys:ApplyForceCenter(self:GetOwner():GetAimVector() * self.Force * 1.2 + Vector(0, 0, 200))
	else
		phys:ApplyForceCenter(self:GetOwner():GetAimVector() * self.Force * 1.2 + Vector(0, 0, 0))
	end

	phys:AddAngleVelocity(Vector(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500)))

	self:GetOwner():RemoveAmmo(1, self.Primary.Ammo)

	timer.Simple(0.6, function()
		if not self:GetOwner() then return end

		if self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
			self:SendWeaponAnim(ACT_VM_DRAW)
			self:GetOwner():SetNWInt("Primed", 0)
		else
			self:GetOwner():SetNWInt("Primed", 0)

			self:GetOwner():ConCommand("lastinv")
		end
	end)
end
