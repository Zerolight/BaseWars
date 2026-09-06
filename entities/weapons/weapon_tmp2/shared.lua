SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_smg_tmp.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_tmp.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_TMP.Single")
SWEP.Primary.Recoil		= 0.4
SWEP.Primary.Damage		= 12
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.022
SWEP.Primary.Delay 		= 0.07

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
	if bool then
		self.Primary.Delay = 0.035
	else
		self.Primary.Delay = 0.07
	end
end

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Battery"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "effect_mad_shell_pistol"

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.IronSightsPos 		= Vector (5.2307, -1.1257, 2.5274)
SWEP.IronSightsAng 		= Vector (0.6528, -0.031, 0)

SWEP.AllowPlaybackRate		= false

function SWEP:Precache()

    	util.PrecacheSound("weapons/tmp/tmp-1.wav")
end
