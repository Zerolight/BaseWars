SWEP.Base 				= "weapon_mad_base_sniper"

SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_snip_awp.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("Weapon_AWP.Single")
SWEP.Primary.Recoil		= 8
SWEP.Primary.Damage		= 95
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001
SWEP.Primary.Delay 		= 1

SWEP.Primary.ClipSize		= 10
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "StriderMinigun"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "effect_mad_shell_rifle"
SWEP.ShellDelay			= 0.6

SWEP.IronSightsPos 		= Vector (5.6111, -3, 2.092)
SWEP.IronSightsAng 		= Vector (0, 0, 0)
SWEP.RunArmOffset 		= Vector (-2.6657, 0, 3.5)
SWEP.RunArmAngle 			= Vector (-20.0824, -20.5693, 0)

SWEP.ScopeZooms			= {12}

SWEP.BoltActionSniper		= true

function SWEP:Precache()

    	util.PrecacheSound("weapons/awp/awp1.wav")
end

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
	if bool then
        if ( self:GetOwner():GetNWInt( "ScopeLevel", 0 ) > 0 ) then
            self.Primary.Damage = 100
        else
            self.Primary.Damage = 95
        end
	end
end
