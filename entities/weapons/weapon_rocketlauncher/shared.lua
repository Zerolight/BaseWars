SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("NPC_Helicopter.FireRocket")
SWEP.Primary.Recoil		= 0
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 2

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "RPG_Round"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "none"
SWEP.ShellDelay			= 0

SWEP.Pistol				= false
SWEP.Rifle				= true
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.IronSightsPos 		= Vector (-15.5715, -30.8025, 2.9072)
SWEP.IronSightsAng 		= Vector (0, 0, 0)
SWEP.RunArmOffset 		= Vector (7.6581, -13.4056, 1.4333)
SWEP.RunArmAngle 			= Vector (-14.4149, 29.214, 0)

function SWEP:Precache()

    	util.PrecacheSound("weapons/stinger_fire1.wav")
end

function SWEP:Rocket()

	if (CLIENT) then return end

	local rocket = ents.Create("ent_mad_rocket")

	rocket:SetOwner(self:GetOwner())

	local pos = self:GetOwner():GetShootPos()
		pos = pos + self:GetOwner():GetForward() * 17.5
		pos = pos + self:GetOwner():GetRight() * 20
		pos = pos + self:GetOwner():GetUp() * 0
	rocket:SetPos(pos)

	rocket:SetAngles(self:GetOwner():GetAngles())
	rocket.Number = 1
	rocket:Spawn()
	rocket:Activate()
end

function SWEP:DoubleRocket()

	if (CLIENT) then return end

	local rocket = ents.Create("ent_mad_rocket")

	rocket:SetOwner(self:GetOwner())

	local pos = self:GetOwner():GetShootPos()
		pos = pos + self:GetOwner():GetForward() * 17.5
		pos = pos + self:GetOwner():GetRight() * 20
		pos = pos + self:GetOwner():GetUp() * 0
	rocket:SetPos(pos)

	rocket:SetAngles(self:GetOwner():GetAngles())
	rocket.Number = 2
	rocket:Spawn()
	rocket:Activate()
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

	self.ActionDelay = (CurTime() + self.Primary.Delay)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	self:SetIronsights(false)

	if self:Clip1() == 2 then
		self:TakePrimaryAmmo(1)

		timer.Simple(0.1, function()
			if not self:GetOwner() then return end
			if not IsFirstTimePredicted() then return end
			self:TakePrimaryAmmo(1)
			self:DoubleRocket()
			self:EmitSound(self.Primary.Sound)
			self:GetOwner():ViewPunch(Angle(math.Rand(-30, -35), math.Rand(0, 0), math.Rand(0, 0)))
		end)

		self:DoubleRocket()

		self:EmitSound(self.Primary.Sound)
		self:GetOwner():ViewPunch(Angle(math.Rand(-30, -35), math.Rand(0, 0), math.Rand(0, 0)))
	else
		self:TakePrimaryAmmo(1)
		self:Rocket()

		self:EmitSound(self.Primary.Sound)
		self:GetOwner():ViewPunch(Angle(math.Rand(-20, -35), math.Rand(0, 0), math.Rand(0, 0)))
	end

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self:SetNWFloat("LastShootTime", CurTime())
	end

	local WeaponModel = self:GetOwner():GetActiveWeapon():GetClass()

	if (self:Clip1() < 1) then
		timer.Simple(self.Primary.Delay + 0.1, function()
			if self:GetOwner() and self:GetOwner():GetActiveWeapon():GetClass() == WeaponModel and self:GetOwner():Alive() then
				self:Reload()
			end
		end)
	end
end

function SWEP:SecondaryAttack()

end
