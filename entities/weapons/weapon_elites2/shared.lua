SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip		= true
SWEP.ViewModel 			= "models/weapons/v_pist_elite.mdl"
SWEP.WorldModel 			= "models/weapons/w_pist_elite.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_Elite.Single")
SWEP.Primary.Recoil		= 0.5
SWEP.Primary.Damage		= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.016
SWEP.Primary.Delay 		= 0.125

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Battery"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "effect_mad_shell_pistol"
SWEP.ShellDelay			= 0

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.DualRightSeq			= 5
SWEP.DualLeftSeq			= 2

SWEP.DeployDelay			= 1.25

function SWEP:Precache()

    	util.PrecacheSound("weapons/elite/elite-1.wav")
end

function SWEP:SecondaryAttack()
end

SWEP.ShootPos = 0

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone)

	num_bullets 		= num_bullets or 1
	aimcone 			= aimcone or 0

	local isright = self:GetNWBool("RightGun", false)
	local attach = self:GetOwner():GetViewModel():LookupAttachment("1")

	if (not isright) then
		if (self:Clip1() <= 2) then
			attach = self:GetOwner():GetViewModel():LookupAttachment("2")
			self:GetOwner():GetViewModel():SetSequence("shoot_leftlast")
		else
			attach = self:GetOwner():GetViewModel():LookupAttachment("2")
			self:GetOwner():GetViewModel():SetSequence(self.DualLeftSeq)
		end
	else
		if (self:Clip1() < 2) then
			attach = self:GetOwner():GetViewModel():LookupAttachment("1")
			self:GetOwner():GetViewModel():SetSequence("shoot_rightlast")
		else
			attach = self:GetOwner():GetViewModel():LookupAttachment("1")
			self:GetOwner():GetViewModel():SetSequence(self.DualRightSeq)
		end
	end

	if (self:Clip1() < 2) then
		local WeaponModel = self:GetOwner():GetActiveWeapon():GetClass()

		timer.Simple(self.Primary.Delay + 0.1, function()
			if self:GetOwner():GetActiveWeapon():GetClass() == WeaponModel and self:GetOwner():Alive() then
				self:Reload()
			end
		end)
	end

	local shootpos = self:GetOwner():GetViewModel():GetAttachment(attach).Pos
	self.ShootPos = attach

	self:SetNWBool("RightGun", not isright)

	local bullet = {}
		bullet.Num 		= num_bullets
		bullet.Src 		= self:GetOwner():GetShootPos()
		bullet.Dir 		= self:GetOwner():GetAimVector()
		bullet.Spread 	= Vector(aimcone, aimcone, 0)
		bullet.Tracer	= 1
		bullet.Force	= damage * 0.5
		bullet.Damage	= damage
		bullet.Callback	= function(attacker, tr, dmginfo)
						if not self:GetOwner():IsNPC() and self:GetOwner():GetNWInt("Fuel") > 0 then
							self:ShootFire(attacker, tr, dmginfo)
						end

						return self:RicochetCallback_Redirect(attacker, tr, dmginfo)
					  end

	self:GetOwner():FireBullets(bullet)

	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	local effectdata = EffectData()
		effectdata:SetOrigin(shootpos)
		effectdata:SetEntity(self)
		effectdata:SetStart(shootpos)
		effectdata:SetNormal(self:GetOwner():GetAimVector())
		effectdata:SetAttachment(attach)

	if (self.Shotgun) then
		util.Effect("effect_mad_shotgunsmoke", effectdata)
	else
		util.Effect("effect_mad_gunsmoke", effectdata)
	end

	timer.Simple(self.ShellDelay, function()
		if not IsFirstTimePredicted() then return end
		if not self:GetOwner():IsNPC() and not self:GetOwner():Alive() then return end

		local effectdata = EffectData()
			effectdata:SetEntity(self)
			effectdata:SetNormal(self:GetOwner():GetAimVector())
			effectdata:SetAttachment(attach)
		util.Effect(self.ShellEffect, effectdata)
	end)

	if (not self:GetOwner():IsNPC()) and ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
		local eyeangle 	= self:GetOwner():EyeAngles()
		eyeangle.pitch 	= eyeangle.pitch - recoil
		self:GetOwner():SetEyeAngles(eyeangle)
	end
end

local pos

function SWEP:GetTracerOrigin()

	local isright = self:GetNWBool("RightGun", true)

	if (not isright) then
		pos = self:GetOwner():GetShootPos() + self:GetOwner():EyeAngles():Right() * -5 + self:GetOwner():EyeAngles():Up() * -3.5
	else
		pos = self:GetOwner():GetShootPos() + self:GetOwner():EyeAngles():Right() * 5 + self:GetOwner():EyeAngles():Up() * -3.5
	end

	return pos
end
