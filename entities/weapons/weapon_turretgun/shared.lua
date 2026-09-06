if ( CLIENT ) then
	SWEP.Author				= "HLTV Proxy"
	SWEP.Contact			= ""
	SWEP.Purpose			= ""
	SWEP.Instructions		= ""
	SWEP.PrintName			= "Sentry Turret's gun"
	SWEP.Instructions		= ""
	SWEP.Slot				= 3
	SWEP.SlotPos			= 15
	SWEP.ViewModelFlip		= false
	SWEP.IconLetter			= "a"
	SWEP.DrawCrosshair		= false
	surface.CreateFont( "HL2SelectIcons", { font = "HalfLife2", size = ScreenScale( 60 ), weight = 500, antialias = true, shadow = true } )
	killicon.AddFont("weapon_turretgun","HL2MPTypeDeath","/",Color(100,100,100,255))
end

if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_mad_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg1.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"
SWEP.HoldType = "smg"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_Pistol.Single")
SWEP.Primary.Recoil			= .5
SWEP.Primary.Unrecoil		= 3
SWEP.Primary.Damage			= 16
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= .01
SWEP.Primary.ClipSize		= 50
SWEP.Primary.Delay			= 0.3
SWEP.Primary.DefaultClip	= 50
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Recoil			= .125
SWEP.Secondary.Ammo			= "none"

SWEP.Secondary.Delay = 1
SWEP.Secondary.BurstDelay = .05
SWEP.Secondary.Cone = 0.010
SWEP.Secondary.Shots = 5
SWEP.Secondary.Counter = 0
SWEP.Secondary.Timer = 0

SWEP.IronSightsPos = Vector(0,0,0)

function SWEP:SecondaryAttack()
	if ( not self:CanPrimaryAttack() ) then
		return
	end

end

function SWEP:PrimaryAttack()

	if ( not self:CanPrimaryAttack() ) then
		return
	end
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	if self:GetOwner():GetNWBool("doubletapped") then
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay*drugeffect_doubletapmod )
	else
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	end

	self:EmitSound( self.Primary.Sound )

	local rcone = self.Primary.Cone
	if (self:GetOwner():GetNWBool("focused")) then
		rcone = rcone*0.5
	end
	local bullet = {}
		bullet.Attacker		= self:GetOwner()
		bullet.Num 		= 1
		bullet.Src 		= self:GetOwner():GetShootPos()
		bullet.Dir 		= self:GetOwner():GetAimVector()
		bullet.Spread 		= Vector( self.Primary.Cone, self.Primary.Cone, 0 )
		bullet.Tracer		= 1
		bullet.TracerName 	= "AirboatGunHeavyTracer"
		bullet.Force		= 50
		bullet.Damage		= self.Primary.Damage

		bullet.Callback		= function(attacker,tr,dmginfo)
						local dist = tr.HitPos:Distance(tr.StartPos)
						if dist>1000 then
							dmginfo:ScaleDamage(0)
						end
					end
	self:FireBullets(bullet)

	self:TakePrimaryAmmo( 1 )

	self:GetOwner():ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

	if ( (game.SinglePlayer() and SERVER) or CLIENT ) then
		self:SetNWFloat( "LastShootTime", CurTime() )
	end
	if ( (game.SinglePlayer() and SERVER) or ( not game.SinglePlayer() and CLIENT ) ) then

		local eyeang = self:GetOwner():EyeAngles()
		eyeang.pitch = eyeang.pitch - self.Primary.Recoil
		self:GetOwner():SetEyeAngles( eyeang )

	end

end

function SWEP:Think()
	if self.Secondary.Timer + self.Secondary.BurstDelay < CurTime() then
		if self.Secondary.Counter > 0 and self:Clip1()>0 then
			self.Secondary.Counter = self.Secondary.Counter - 1
			self.Secondary.Timer = CurTime()

			if self:CanPrimaryAttack() then
				self:EmitSound(self.Primary.Sound)
				local rcone = self.Secondary.Cone
				if (self:GetOwner():GetNWBool("focused")) then
					rcone = rcone*0.85
				end
				self:CSShootBullet( self.Primary.Damage, self.Secondary.Recoil, self.Primary.NumShots, rcone )

				self:TakePrimaryAmmo( 1 )

			end
		else
			self.Secondary.Counter = 0
		end
	end
end

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	draw.SimpleText( "a", "HL2SelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )

	if (self:GetNWBool("upgraded")) then
		draw.SimpleText("K", "CSKillIcons", x + wide-20, y + tall-25, Color(200,200, 200, 255), TEXT_ALIGN_CENTER )
	end
end

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )

	self.Secondary.Counter = 0
end

function SWEP:ShouldDropOnDie()
	return true
end
