SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModel			= "models/weapons/v_rif_galil.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_galil.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_Galil.Single")
SWEP.Primary.Recoil		= 0.65
function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
	if bool then
		self.Primary.Recoil = 0.45
    else
        self.Primary.Recoil = 0.65
    end
end

SWEP.Primary.Damage		= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.017
SWEP.Primary.Delay 		= 0.09

SWEP.Primary.ClipSize		= 35
SWEP.Primary.DefaultClip	= 35
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "AirboatGun"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "effect_mad_shell_rifle"

SWEP.Pistol				= false
SWEP.Rifle				= true
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.IronSightsPos 		= Vector (-5.1505, -1.783, 2.3241)
SWEP.IronSightsAng 		= Vector (-0.2068, -0.0088, 0)

function SWEP:Precache()

    	util.PrecacheSound("weapons/galil/galil-1.wav")
end
