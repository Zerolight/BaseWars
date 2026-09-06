SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_Deagle.Single")
SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 25
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay 		= 0.3

SWEP.Primary.ClipSize		= 7
SWEP.Primary.DefaultClip	= 7
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "CombineCannon"

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

SWEP.IronSightsPos 		= Vector (5.1434, -1.75, 2.673)
SWEP.IronSightsAng 		= Vector (0.2494, -0.0121, 0)

function SWEP:Precache()

    	util.PrecacheSound("weapons/deagle/deagle-1.wav")
end

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
    if not self:GetNWBool("Ironsights") and self:GetNWBool("upgraded") then
		self:GetOwner():SetFOV(40,.3)
	else
		self:GetOwner():SetFOV(90,.3)
	end
end
