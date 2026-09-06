SWEP.Author		= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_camphone.mdl"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.ShootSound				= "NPC_CScanner.TakePhoto"

SWEP.CameraZoom				= 80
SWEP.Roll					= 0

function SWEP:Precache()
	util.PrecacheSound( self.ShootSound )
end

function SWEP:Reload()

	self:GetOwner():SetFOV( 80, 0 )
	self.CameraZoom = 80
	self.Roll = 0

end

function SWEP:DoShootEffect()

	self:EmitSound( self.ShootSound	)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:PrimaryAttack()

	self:DoShootEffect()

	if (not game.SinglePlayer() and SERVER) then return end
	if (CLIENT and not IsFirstTimePredicted()) then return end

	self:GetOwner():ConCommand( "jpeg" )

end

function SWEP:SecondaryAttack()

end

function SWEP:Think()

	local cmd = self:GetOwner():GetCurrentCommand()

	self.LastThink = self.LastThink or 0
	local fDelta = (CurTime() - self.LastThink)
	self.LastThink = CurTime()

	self:DoZoomThink( cmd, fDelta )
	self:DoRotateThink( cmd, fDelta )

end

function SWEP:DoZoomThink( cmd, fDelta )

	if ( not self:GetOwner():KeyDown( IN_ATTACK2 ) ) then return end

	self.CameraZoom = math.Clamp( self.CameraZoom + cmd:GetMouseY() * 3 * fDelta, 0.1, 175 )

	self:GetOwner():SetFOV( self.CameraZoom, 0 )

end
