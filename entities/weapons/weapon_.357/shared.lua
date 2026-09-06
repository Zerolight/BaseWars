SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_357.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"
SWEP.AnimPrefix		= "python"
SWEP.HoldType		= "pistol"

SWEP.m_bFiresUnderwater	= false

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Empty			= Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Sound			= Sound( "Weapon_357.Single" )
SWEP.Primary.Damage			= 75
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vec3_origin
SWEP.Primary.ClipSize		= 6
SWEP.Primary.Delay			= 0.75
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "357"
SWEP.Primary.Tracer			= 4
SWEP.Primary.TracerName		= "Tracer"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "None"

function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 0 )
		self:SetNPCMaxBurst( 0 )
		self:SetNPCFireRate( self.Primary.Delay )
	end

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:PrimaryAttack()

	local pPlayer = self:GetOwner();

	if ( not pPlayer ) then
		return;
	end

	if ( not self:CanPrimaryAttack() ) then return end

	if ( self:Clip1() <= 0 and self.Primary.ClipSize > -1 ) then
		if ( self:Ammo1() > 0 ) then
			self:EmitSound( self.Primary.Empty );
			self:Reload();
		else
			self:EmitSound( self.Primary.Empty );
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		end

		return;
	end

	if ( self.m_bIsUnderwater and not self.m_bFiresUnderwater ) then
		self:EmitSound( self.Primary.Empty );
		self:SetNextPrimaryFire( CurTime() + 0.2 );

		return;
	end

	self:EmitSound( self.Primary.Sound );
	pPlayer:MuzzleFlash();

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

	self:TakePrimaryAmmo( self.Primary.NumAmmo );

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone );

	local angles = pPlayer:EyeAngles();

	angles.pitch = angles.pitch + math.random( -1, 1 );
	angles.yaw   = angles.yaw   + math.random( -1, 1 );
	angles.roll  = 0;

	if ( pPlayer:IsNPC() ) then return end

if ( not CLIENT ) then
	pPlayer:SetEyeAngles( angles );
end

	pPlayer:ViewPunch( Angle( -8, math.Rand( -2, 2 ), 0 ) );

end

function SWEP:SecondaryAttack()
	return false
end

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD );
end

function SWEP:PreThink()
end

function SWEP:Think()

	local pPlayer = self:GetOwner();

	if ( not pPlayer ) then
		return;
	end

	self:PreThink();

	if ( pPlayer:WaterLevel() >= 3 ) then
		self.m_bIsUnderwater = true;
	else
		self.m_bIsUnderwater = false;
	end

end

function SWEP:Deploy()

	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self:SequenceDuration() )

	return true

end

function SWEP:ShootBullet( damage, num_bullets, aimcone )

	local pPlayer = self:GetOwner();

	if ( not pPlayer ) then
		return;
	end

	local vecSrc		= pPlayer:GetShootPos();
	local vecAiming		= pPlayer:GetAimVector();

	local info = { Num = num_bullets, Src = vecSrc, Dir = vecAiming, Spread = aimcone, Tracer = self.Primary.Tracer, Damage = damage };
	info.Attacker = pPlayer;
	info.TracerName = self.Primary.TracerName;

	info.Owner = self:GetOwner()
	info.Weapon = self

	info.ShootCallback = self.ShootCallback;

	info.Callback = function( attacker, trace, dmginfo )
		return info:ShootCallback( attacker, trace, dmginfo );
	end

	pPlayer:FireBullets( info );

end

function SWEP:ShootCallback( attacker, trace, dmginfo )
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:SetDeploySpeed( speed )

	self.m_WeaponDeploySpeed = tonumber( speed / GetConVarNumber( "phys_timescale" ) )

	self:SetNextPrimaryFire( CurTime() + speed )
	self:SetNextSecondaryFire( CurTime() + speed )

end
