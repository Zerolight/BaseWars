SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_usp.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_USP.Single")
SWEP.Primary.SuppressorSound	= Sound("Weapon_USP.SilencedShot")
SWEP.Primary.NoSuppressorSound= Sound("Weapon_USP.Single")
SWEP.Primary.Recoil		= 1.25
SWEP.Primary.Damage		= 16
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0155
SWEP.Primary.Delay 		= 0.12

SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 12
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "SniperPenetratedRound"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "effect_mad_shell_pistol"
SWEP.ShellDelay			= 0.05

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.IronSightsPos 		= Vector (4.4777, 0, 2.752)
SWEP.IronSightsAng 		= Vector (-0.2267, -0.0534, 0)

SWEP.Type				= 2
SWEP.Mode				= true

SWEP.data 				= {}
SWEP.data.NormalMsg		= ""
SWEP.data.ModeMsg			= ""
SWEP.data.Delay			= 3
SWEP.data.Cone			= 1.5
SWEP.data.Damage			= 0.75
SWEP.data.Recoil			= 0.5

function SWEP:Precache()

    	util.PrecacheSound("weapons/usp/usp1.wav")
end

function SWEP:ShootAnimation()

	if (self:Clip1() <= 0) then
		if self:GetDTBool(3) and self.Type == 2 then
			self:SendWeaponAnim(ACT_VM_DRYFIRE_SILENCED)
		else
			self:SendWeaponAnim(ACT_VM_DRYFIRE)
		end
	else
		if self:GetDTBool(3) and self.Type == 2 then
			self:SendWeaponAnim(ACT_VM_IDLE)
			local Animation = self:GetOwner():GetViewModel()
			Animation:SetSequence(Animation:LookupSequence("shoot1"))
		else
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		end
	end
end

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
end
