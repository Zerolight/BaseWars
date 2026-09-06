if( SERVER ) then

	AddCSLuaFile( "shared.lua" );
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if( CLIENT ) then

	SWEP.PrintName = "Stunstick";
	SWEP.Slot = 0;
	SWEP.SlotPos = 7;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = false;
	surface.CreateFont( "HL2SelectIcons", { font = "HalfLife2", size = ScreenScale( 60 ), weight = 500, antialias = true, shadow = true } )
	killicon.AddFont( "stunstick", "HL2MPTypeDeath", "!", Color( 100, 100, 100, 255 ) )
end

SWEP.Author			= "Rickster"
SWEP.Instructions	= "Left click to stun more, with less damage\n Right click to beat the crap out of them, with less stun effect"
SWEP.Contact		= ""
SWEP.Purpose		= ""

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.AnimPrefix		= "stunstick"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.NextStrike = 0;

SWEP.ViewModel = Model( "models/weapons/v_stunstick.mdl" );
SWEP.WorldModel = Model( "models/weapons/w_stunbaton.mdl" );

SWEP.Sound = Sound( "weapons/stunstick/stunstick_swing1.wav" );

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ""

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= ""

function SWEP:Initialize()

	if( SERVER ) then

		self:SetWeaponHoldType( "melee" );

	end

	self.Hit = {
	Sound( "weapons/stunstick/stunstick_impact1.wav" ),
  	Sound( "weapons/stunstick/stunstick_impact2.wav" ) };

	self.FleshHit = {
  	Sound( "weapons/stunstick/stunstick_fleshhit1.wav" ),
  	Sound( "weapons/stunstick/stunstick_fleshhit2.wav" ) };

end

function SWEP:Precache()
end

  function SWEP:PrimaryAttack()

  	if( CurTime() < self.NextStrike ) then return; end
 	self:GetOwner():LagCompensation( true )
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 );
	self:EmitSound( self.Sound );
	self:SendWeaponAnim( ACT_VM_HITCENTER );

	self.NextStrike = ( CurTime() + .3 );
	self:GetOwner():LagCompensation( false )
	if( CLIENT ) then return; end

 	local trace = self:GetOwner():GetEyeTrace();

 	if( not IsValid(trace.Entity) ) then
 		return;
	end

	if( self:GetOwner():EyePos():Distance( trace.Entity:GetPos() ) > 130 ) then
		return;
	end

	if( SERVER ) then

		trace.Entity:TakeDamage(25, self:GetOwner(), self)

		if( not trace.Entity:IsDoor() ) then
			trace.Entity:SetVelocity( ( trace.Entity:GetPos() - self:GetOwner():GetPos() ) * 7 );
		end

		if( trace.Entity:IsPlayer() ) then
			local stunamount = 50
			trace.Entity:ViewPunch( Angle( stunamount*((math.random()*4)-2), stunamount*((math.random()*4)-2), stunamount*((math.random()*2)-1) ) )
			StunPlayer(trace.Entity, stunamount)
			self:GetOwner():EmitSound( self.FleshHit[math.random(1,#self.FleshHit)] );
		else
			self:GetOwner():EmitSound( self.Hit[math.random(1,#self.Hit)] );
		end

	end

  end

  function SWEP:SecondaryAttack()

  	if( CurTime() < self.NextStrike ) then return; end

  	self:GetOwner():SetAnimation( PLAYER_ATTACK1 );
	self:EmitSound( self.Sound );
	self:SendWeaponAnim( ACT_VM_HITCENTER );

	self.NextStrike = ( CurTime() + 1 );

	if( CLIENT ) then return; end

 	local trace = self:GetOwner():GetEyeTrace();

 	if( not IsValid(trace.Entity) ) then
 		return;
	end

	if( self:GetOwner():EyePos():Distance( trace.Entity:GetPos() ) > 100 ) then
		return;
	end

	if( SERVER ) then
		trace.Entity:TakeDamage(60, self:GetOwner(), self)
		if( not trace.Entity:IsDoor() ) then
			trace.Entity:SetVelocity( ( trace.Entity:GetPos() - self:GetOwner():GetPos() ) * 7 );
		end

		if( trace.Entity:IsPlayer() ) then
			local stunamount = 15
			trace.Entity:ViewPunch( Angle( stunamount*((math.random()*4)-2), stunamount*((math.random()*4)-2), stunamount*((math.random()*2)-1) ) )
			StunPlayer(trace.Entity, stunamount)
			self:GetOwner():EmitSound( self.FleshHit[math.random(1,#self.FleshHit)] );
		else
			self:GetOwner():EmitSound( self.Hit[math.random(1,#self.Hit)] );
		end

	end

  end

function SWEP:ShouldDropOnDie()
	return true
end
