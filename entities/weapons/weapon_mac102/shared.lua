SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_smg_mac10.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mac10.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_MAC10.Single")
SWEP.Primary.Recoil		= 0.7
SWEP.Primary.Damage		= 20
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Delay 		= 0.055
function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
	if bool then
		self.Primary.Delay = 0.0252
    else
        self.Primary.Delay = 0.055
    end
end

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SniperPenetratedRound"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "effect_mad_shell_pistol"

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.IronSightsPos 		= Vector (6.8446, -1.0043, 2.8392)
SWEP.IronSightsAng 		= Vector (1.062, 5.3095, 7.0159)

function SWEP:Precache()

    	util.PrecacheSound("weapons/mac10/mac10-1.wav")
end
