if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "rpg"

end

if ( CLIENT ) then

	SWEP.PrintName			= "Hammer Spammer"
	SWEP.Author				= "HLTV Proxy"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 5
	SWEP.ViewModelFOV		= 70
	SWEP.ViewModelFlip		= false
	SWEP.IconLetter			= "i"

	surface.CreateFont( "HL2SelectIcons", { font = "HalfLife2", size = ScreenScale( 60 ), weight = 500, antialias = true, shadow = true } )
	killicon.AddFont( "shot_rocket", "HL2MPTypeDeath", "3", Color( 100, 100, 100, 255 ) )
end

SWEP.Base				= "weapon_cs_base2"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_RPG.Single" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 70
SWEP.Primary.NumShots		= 5
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 50
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 1000
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "RPG_Round"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector( 6.1, -14, 2.5 )
SWEP.IronSightsAng 		= Vector( 2.8, 0, 0 )

function SWEP:PrimaryAttack()

	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if ( not self:CanPrimaryAttack() ) then return end

	self:EmitSound( self.Primary.Sound )
	if (SERVER) then
		self:FireRocket( self.Primary.Recoil )
	end
	self:TakePrimaryAmmo( 1 )

	if ( self:GetOwner():IsNPC() ) then return end

	self:GetOwner():ViewPunch( Angle( math.Rand(-0.2,0.2) * self.Primary.Recoil, math.Rand(-0.2,0.2) *self.Primary.Recoil, 0 ) )
	if ( (game.SinglePlayer() and SERVER) or CLIENT ) then
		self:SetNWFloat( "LastShootTime", CurTime() )
	end
	if (self:Clip1()<=0) then
		self:DefaultReload( ACT_VM_RELOAD )
	end
end

function SWEP:SecondaryAttack()

end

function SWEP:FireRocket( recoil )

	local object = ents.Create("shot_bhammer")

	if IsValid(object) then

		object:SetOwner(self:GetOwner())
		object:SetPos(self:GetOwner():GetPos()+self:GetOwner():GetAngles():Right()*40+Vector(0,0,65))

		object:SetVelocity(self:GetOwner():GetAimVector()*400)
		object:Spawn()
		if (self:GetNWBool("upgraded") and SERVER) then
			object:Upgrade()
			object:SetNWBool("upgraded", true)
		end
	end

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	if ( self:GetOwner():IsNPC() ) then return end

	if ( (game.SinglePlayer() and SERVER) or ( not game.SinglePlayer() and CLIENT ) ) then

		local eyeang = self:GetOwner():EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self:GetOwner():SetEyeAngles( eyeang )

	end

end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	draw.SimpleText( self.IconLetter, "HL2SelectIcons", x + wide/2, (y + tall*0.2)-10, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	if (self:GetNWBool("upgraded")) then
		draw.SimpleText("K", "CSKillIcons", x + wide-20, y + tall-25, Color(200,200, 200, 255), TEXT_ALIGN_CENTER )
	end
end

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
end

function SWEP:ShouldDropOnDie()
	return false
end
