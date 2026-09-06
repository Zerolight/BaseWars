SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_pist_fiveseven.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_fiveseven.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_FiveSeven.Single")
SWEP.Primary.Recoil		= 0.85
SWEP.Primary.Damage		= 11
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.Delay 		= 0.13

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "AlyxGun"

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

SWEP.IronSightsPos 		= Vector (4.5114, -0.7423, 3.3629)
SWEP.IronSightsAng 		= Vector (-0.4454, -0.0264, 0)

function SWEP:Precache()

    	util.PrecacheSound("weapons/fiveseven/fiveseven-1.wav")
end
