SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_pist_p228.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_p228.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_P228.Single")
SWEP.Primary.Recoil		= 1
SWEP.Primary.Damage		= 11
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0125
SWEP.Primary.Delay 		= 0.12

SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 12

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
	if bool then
		self.Primary.ClipSize = 13
        self.Primary.DefaultClip = 13
	else
		self.Primary.ClipSize = 12
        self.Primary.DefaultClip = 12
	end
end

SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Battery"

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

SWEP.IronSightsPos 		= Vector (4.7529, 0, 2.9042)
SWEP.IronSightsAng 		= Vector (-0.4466, 0.0445, 0)

function SWEP:Precache()

    	util.PrecacheSound("weapons/p228/p228-1.wav")
end
