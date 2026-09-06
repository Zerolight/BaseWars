SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_smg_ump45.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_ump45.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_UMP45.Single")
SWEP.Primary.Recoil		= 0.5
SWEP.Primary.Damage		= 22
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.019
SWEP.Primary.Delay 		= 0.09

SWEP.Primary.ClipSize		= 25
SWEP.Primary.DefaultClip	= 25
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SniperPenetratedRound"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "effect_mad_shell_pistol"

SWEP.Pistol				= false
SWEP.Rifle				= true
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.IronSightsPos 		= Vector(7.31, -2, 3.285)
SWEP.IronSightsAng 		= Vector(-1.4, .245, 2)
SWEP.RunArmOffset 		= Vector (-2.6657, 0, 2.5)
SWEP.RunArmAngle 			= Vector (-20.0824, -20.5693, 0)

function SWEP:Precache()

    	util.PrecacheSound("weapons/ump45/ump45-1.wav")
end

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
end
