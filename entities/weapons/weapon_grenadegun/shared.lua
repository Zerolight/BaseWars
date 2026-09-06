if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "ar2"

end

if ( CLIENT ) then

	SWEP.PrintName			= "Grenade Launcher"
	SWEP.Author				= "HLTV Proxy"
	SWEP.Slot				= 4
	SWEP.SlotPos			= 5
	SWEP.ViewModelFOV		= 70
	SWEP.ViewModelFlip		= true
	SWEP.IconLetter			= "f"

	surface.CreateFont( "HL2SelectIcons", { font = "HalfLife2", size = ScreenScale( 60 ), weight = 500, antialias = true, shadow = true } )
	killicon.AddFont( "shot_glround", "HL2MPTypeDeath", "7", Color( 100, 100, 100, 255 ) )
end

SWEP.Base				= "weapon_cs_base2"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_sg552.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_sg552.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_SMG1.Double" )
SWEP.Primary.Recoil			= 10
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 6
SWEP.Primary.Delay			= .75
SWEP.Primary.DefaultClip	= 6
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
	if self:GetOwner():GetNWBool("doubletapped") then
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay*drugeffect_doubletapmod )
	else
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	end

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

	local object = ents.Create("shot_glround")

	if IsValid(object) then

		object.Owner = self:GetOwner()
		object:SetPos(self:GetOwner():GetShootPos()+self:GetOwner():EyeAngles():Right()*5+self:GetOwner():EyeAngles():Up()*-5)
		object:SetAngles(self:GetOwner():EyeAngles())
		object:Spawn()
		if self:GetNWBool("upgraded") then
			object:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector()*5000)
		else
			object:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector()*2000)
		end
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
	return true
end
