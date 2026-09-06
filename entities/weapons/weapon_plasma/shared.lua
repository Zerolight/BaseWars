SWEP.Base 				= "weapon_mad_base_sniper"

SWEP.ViewModelFlip		= false
SWEP.ViewModel 			= "models/weapons/v_irifle.mdl"
SWEP.WorldModel 			= "models/weapons/w_irifle.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_AR2.Single")
SWEP.Primary.Reload 		= Sound("Weapon_AR2.Reload")
SWEP.Primary.Recoil		= 0.6
SWEP.Primary.Damage		= 20
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.014
SWEP.Primary.Delay 		= 0.1

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "AR2"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "effect_mad_shell_rifle"
SWEP.ShellDelay			= 0

SWEP.IronSightsPos 		= Vector (-5.8777, -11.2377, 2.1921)
SWEP.IronSightsAng 		= Vector (6.1388, -0.2003, 0)
SWEP.RunArmOffset 		= Vector (7.3723, 0, 2.0947)
SWEP.RunArmAngle 			= Vector (-12.9765, 26.8708, 0)

SWEP.ScopeZooms			= {2}
SWEP.RedDot				= true

SWEP.Tracer				= 1

function SWEP:Precache()

    	util.PrecacheSound("weapons/ar2/fire1.wav")
end
