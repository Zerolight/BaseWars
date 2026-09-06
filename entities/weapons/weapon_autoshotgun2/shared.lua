SWEP.Base 				= "weapon_mad_base_shotgun"

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_shot_xm1014.mdl"
SWEP.WorldModel			= "models/weapons/w_shot_xm1014.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_XM1014.Single")
SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 11
SWEP.Primary.NumShots		= 8
SWEP.Primary.Cone			= 0.05
SWEP.Primary.Delay 		= 0.25

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Buckshot"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellDelay			= 0.1

SWEP.IronSightsPos 		= Vector (5.1536, -3.817, 2.1621)
SWEP.IronSightsAng 		= Vector (-0.1466, 0.7799, 0)
SWEP.RunArmOffset 		= Vector (-2.6657, 0, 3.5)
SWEP.RunArmAngle 			= Vector (-20.0824, -20.5693, 0)

SWEP.ShotgunReloading		= false
SWEP.ShotgunFinish		= 0.3
SWEP.ShotgunBeginReload		= 0.5

function SWEP:Precache()

    	util.PrecacheSound("weapons/xm1014/xm1014-1.wav")
end
