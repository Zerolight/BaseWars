if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true

	surface.CreateFont( "CSKillIcons", { font = "csd", size = ScreenScale( 30 ), weight = 500, antialias = true, shadow = true } )
	surface.CreateFont( "CSSelectIcons", { font = "csd", size = ScreenScale( 60 ), weight = 500, antialias = true, shadow = true } )

end

SWEP.Author			= "Rickster"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Upgraded = false

function SWEP:Initialize()

	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end

	self:SetNWBool( "Ironsights", false )

end

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD );
	self:SetIronsights( false )
	self:GetOwner():SetFOV(self.ViewModelFOV,.3)
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()

	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	if self:GetOwner():GetNWBool("doubletapped") then
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay*drugeffect_doubletapmod )
	else
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	end

	if ( not self:CanPrimaryAttack() ) then
	return
	end

	self:EmitSound( self.Primary.Sound )

	local rcone = self.Primary.Cone
	if (self:GetOwner():GetNWBool("focused")) then
		rcone = rcone*0.5
	end
	if(self:GetIronsights() == true) then
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, rcone )
	else
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil + 3, self.Primary.NumShots, rcone + .05 )
	end

	self:TakePrimaryAmmo( 1 )

	if self:GetOwner():IsPlayer() then
		self:GetOwner():ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	end

	if ( (game.SinglePlayer() and SERVER) or CLIENT ) then
		self:SetNWFloat( "LastShootTime", CurTime() )
	end

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
	if self:GetOwner():GetTable().ShockWaved then
		bullet.Damage	= 0
		bullet.SDamage  = dmg
	else
		bullet.Damage 	= dmg
	end
	bullet.Attacker = self:GetOwner()
	if numbul==1 then
	bullet.Callback = function(attacker,tr,dmginfo)
		if attacker:GetTable().ShockWaved then
			local radius = bullet.SDamage*2
			if radius<32 then radius=32 elseif radius>64 then radius = 64 end
			util.BlastDamage(dmginfo:GetInflictor(),attacker,tr.HitPos, radius, bullet.SDamage*drugeffect_shockwavemultiplier)
			if SERVER then
				ShockWaveExplosion(tr.HitPos, self:GetOwner(), tr.HitNormal, radius)
			end
		end

		if attacker:GetTable().MagicBulleted and IsValid(tr.Entity) and math.random(0,1)==1 then
			if tr.Entity:IsPlayer() then
				local ply = tr.Entity
				local firedoneoff = false
				for k, v in pairs(player.GetAll()) do
					if not firedoneoff and ply:GetPos():Distance(v:GetPos())<2048 and attacker:GetPos():Distance(v:GetPos())>ply:GetPos():Distance(v:GetPos()) and v~=attacker and v~=ply and v:Alive() then
						local traceshit = {}
							traceshit.start = ply:GetPos()+Vector(0,0,25)
							traceshit.endpos = v:GetPos()+Vector(0,0,25)
							traceshit.filter = { ply, v, attacker }
							traceshit.mask = COLLISION_GROUP_PLAYER
						traceshit = util.TraceLine(traceshit)
						if traceshit.Fraction==1 then
							local shotdir = (v:GetPos()+Vector(0,0,30))-(ply:GetPos()+Vector(0,0,30))
							firedoneoff = true
							local magshot = {}
								magshot.Num = 1
								magshot.Src = ply:GetShootPos()
								magshot.Dir = shotdir:GetNormal()
								magshot.Spread = Vector( 0,0,0 )
								magshot.Tracer = 1
								magshot.Force = 5
								magshot.Damage = 0
								magshot.attacker = attacker
							ply:FireBullets(magshot)
							v:TakeDamage(dmginfo:GetDamage()*.5, attacker, attacker)
						end
					end
				end
			end
		end
	end
	else
	bullet.Callback = function(attacker,tr,dmginfo)
		if attacker:GetTable().ShockWaved then
			local radius = bullet.SDamage*2
			if radius<32 then radius=32 elseif radius>64 then radius = 64 end
			util.BlastDamage(dmginfo:GetInflictor(),attacker,tr.HitPos, radius, bullet.SDamage*1.5)
			if SERVER then
				ShockWaveExplosion(tr.HitPos, self:GetOwner(), tr.HitNormal, radius)
			end
		end
	end
	end
	self:FireBullets( bullet )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

	if ( (game.SinglePlayer() and SERVER) or ( not game.SinglePlayer() and CLIENT ) ) then

		local eyeang = self:GetOwner():EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self:GetOwner():SetEyeAngles( eyeang )

	end

end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )

	if (self:GetNWBool("upgraded")) then
		draw.SimpleText("K", "CSKillIcons", x + wide-20, y + tall-25, Color(200,200, 200, 255), TEXT_ALIGN_CENTER )
	end
end

local IRONSIGHT_TIME = 0.25

function SWEP:GetViewModelPosition( pos, ang )

	if ( not self.IronSightsPos ) then return pos, ang end

	local bIron = self:GetNWBool( "Ironsights" )

	if ( bIron ~= self.bLastIron ) then

		self.bLastIron = bIron
		self.fIronTime = CurTime()

		if ( bIron ) then
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end

	end

	local fIronTime = self.fIronTime or 0

	if ( not bIron and fIronTime < CurTime() - IRONSIGHT_TIME ) then
		return pos, ang
	end

	local Mul = 1.0

	if ( fIronTime > CurTime() - IRONSIGHT_TIME ) then

		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )

		if (not bIron) then Mul = 1 - Mul end

	end

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

function SWEP:SetIronsights( b )

	self:SetNWBool( "Ironsights", b )

end

function SWEP:GetIronsights()

	return self:GetNWBool( "Ironsights" )

end

SWEP.NextSecondaryAttack = 0

function SWEP:SecondaryAttack()

	if ( not self.IronSightsPos ) then return end
	if ( self.NextSecondaryAttack > CurTime() ) then return end

	bIronsights = not self:GetNWBool( "Ironsights", false )

	self:SetIronsights( bIronsights )

	self.NextSecondaryAttack = CurTime() + 0.3

end

function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	self:SetIronsights( false )

end

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
end

function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:DrawHUD()
	local rcone = .04
	if (self:GetOwner():GetNWBool("focused")) then
		rcone = rcone*0.5
	end

	if ( self:GetNWBool( "Ironsights" ) ) then return end

	local x = ScrW() / 2.0
	local y = ScrH() / 2.0
	local scale = 10 * rcone

	surface.SetDrawColor( 0, 255, 0, 255 )

	local gap = 30 * scale
	local length = gap + 10 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )

end

function SWEP:GetCapabilities()
	return bit.bor(CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1)
end
function SWEP:IdleAnim()
	self:SendWeaponAnim( ACT_VM_IDLE )
end
function SWEP:OnRemove()
	timer.Destroy(tostring(self).."idleanim")
end
