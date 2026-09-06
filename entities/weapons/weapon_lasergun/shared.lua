if ( SERVER ) then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "ar2"

end

if ( CLIENT ) then

	SWEP.ViewModelFlip		= false
	SWEP.PrintName			= "Laser Gun"
	SWEP.Author				= "HLTV Proxy"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 14
	SWEP.IconLetter			= ","
	SWEP.ViewModelFlip		= true

	killicon.AddFont( "weapon_laserrifle", "HL2MPTypeDeath", SWEP.IconLetter, Color( 100, 100, 100, 255 ) )

end

SWEP.Base				= "weapon_mad_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_irifle.mdl"
SWEP.WorldModel			= "models/weapons/w_irifle.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_AR2.Single" )
SWEP.Primary.Recoil			= 0.00000000001
SWEP.Primary.Damage			= 2
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.005
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Battery		= 100
SWEP.Primary.Chargerate		= .1

SWEP.Secondary.Sound			= Sound( "Weapon_AR2.Single" )
SWEP.Secondary.Recoil			= 1
SWEP.Secondary.Damage			= 40
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0.0001
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.Delay			= 1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector( -2.7, -8, 2.225 )
SWEP.IronSightsAng 		= Vector( 0, -4, 0 )

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
end

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD );
	self:SetIronsights( false )
	self:GetOwner():SetFOV(90,.3)
end

function SWEP:Think()
	if self.LastCharge<CurTime()-self.Primary.Chargerate and self.Primary.Battery<100 then
		self.Primary.Battery=self.Primary.Battery+1
		self.LastCharge = CurTime()
	end
end

function SWEP:PrimaryAttack()

	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.LastCharge = CurTime()+self.Primary.Chargerate*3
	if ( self.Primary.Battery<=0 ) then
		return
	end

	self:CSShootBullet( self.Primary.Damage, 0, self.Primary.NumShots, 0 )
	local beamorigin = self:GetOwner():GetShootPos()+self:GetOwner():EyeAngles():Right()*5+self:GetOwner():EyeAngles():Up()*-5
	local beamstart = self:GetOwner():GetEyeTrace()
	local effectdata = EffectData()
		effectdata:SetStart(beamstart.HitPos)
		effectdata:SetOrigin(beamorigin)
		effectdata:SetAngle(Angle(tonumber(self:GetOwner():GetInfo("bw_clcolor_r")),tonumber(self:GetOwner():GetInfo("bw_clcolor_g")),tonumber(self:GetOwner():GetInfo("bw_clcolor_b"))))
	util.Effect("laserbeam", effectdata)

	if self:GetNWBool("upgraded") then
		if self.Halfcharge then
			self.Primary.Battery=self.Primary.Battery-1
		end
		self.Halfcharge = not self.Halfcharge
	else
		self.Primary.Battery=self.Primary.Battery-1
	end

	if ( (game.SinglePlayer() and SERVER) or CLIENT ) then
		self:SetNWFloat( "LastShootTime", CurTime() )
	end

end

function SWEP:Initialize()

	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end

	self:SetNWBool( "Ironsights", false )
	self.LastCharge = CurTime()
	self.Halfcharge = false
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self:GetOwner():GetShootPos()
	bullet.Dir 		= self:GetOwner():GetAimVector()
	bullet.Spread 	= Vector( cone, cone, 0 )
	bullet.Tracer	= 4
	bullet.Force	= 5
	bullet.Damage	= dmg
	bullet.Attacker = self:GetOwner()
	self:FireBullets( bullet )
	self:SendWeaponAnim( ACT_VM_RELOAD )

	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	if ( (game.SinglePlayer() and SERVER) or ( not game.SinglePlayer() and CLIENT ) ) then

		local eyeang = self:GetOwner():EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self:GetOwner():SetEyeAngles( eyeang )

	end

end

function SWEP:GetViewModelPosition( pos, ang )
	local Mul = 1.0
	local Offset	= self.IronSightsPos
	if ( self.IronSightsAng ) then

		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )

	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang

end

function SWEP:SecondaryAttack()

end
