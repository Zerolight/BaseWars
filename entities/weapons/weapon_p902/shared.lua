SWEP.Base 				= "weapon_mad_base_sniper"

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_smg_p90.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_p90.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_P90.Single")
SWEP.Primary.Recoil		= 0.5
function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
	if bool then
		self.Primary.Recoil = 0.35
    else
        self.Primary.Recoil = 0.5
    end
end
SWEP.Primary.Damage		= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.013
SWEP.Primary.Delay 		= 0.066

SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "AlyxGun"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "effect_mad_shell_pistol"
SWEP.ShellDelay			= 0

SWEP.IronSightsPos 		= Vector (4.5658, -10.4639, 2.0097)
SWEP.IronSightsAng 		= Vector (0, 0, 0)
SWEP.RunArmOffset 		= Vector (-1.3984, -2.3764, 1.7354)
SWEP.RunArmAngle 			= Vector (-13.3275, -20.4303, 0)

SWEP.ScopeZooms			= {2}
SWEP.RedDot				= true

function SWEP:Precache()

    	util.PrecacheSound("weapons/p90/p90-1.wav")
end
