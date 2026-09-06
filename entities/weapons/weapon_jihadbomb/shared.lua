SWEP.Author			= "Stingwraith"
SWEP.Contact		= "stingwraith123@yahoo.com"
SWEP.Purpose		= "Sacrifice yourself for Allah."
SWEP.Instructions	= "Left Click to make yourself EXPLODE. Right click to taunt."
SWEP.DrawCrosshair		= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_jb.mdl"
SWEP.WorldModel			= "models/weapons/w_jb.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay			= 3

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Reload()
end

function SWEP:Initialize()
    util.PrecacheSound("siege/big_explosion.wav")
    util.PrecacheSound("siege/jihad.wav")
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
self:SetNextPrimaryFire(CurTime() + 3)

	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetOwner():GetPos() )
		effectdata:SetNormal( self:GetOwner():GetPos() )
		effectdata:SetMagnitude( 8 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 16 )
	util.Effect( "Sparks", effectdata )

	self.BaseClass.ShootEffects( self )

	if (SERVER) then
		timer.Simple(2, function() self:Asplode() end )
		self:GetOwner():EmitSound( "siege/jihad.wav" )
	end

end

function SWEP:Asplode()
local k, v

	local ent = ents.Create( "env_explosion" )
		ent:SetPos( self:GetOwner():GetPos() )
		ent:SetOwner( self:GetOwner() )
		ent:Spawn()
		ent:SetKeyValue( "iMagnitude", "250" )
		ent:Fire( "Explode", 0, 0 )
		ent:EmitSound( "siege/big_explosion.wav", 500, 500 )

		self:GetOwner():Kill( )
		self:GetOwner():AddFrags( -1 )

		for k, v in pairs( player.GetAll( ) ) do
		  v:ConCommand( "play siege/big_explosion.wav\n" )
		end

end

function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire( CurTime() + 1 )

	local TauntSound = Sound( "vo/npc/male01/overhere01.wav" )

	self:EmitSound( TauntSound )

	if (not SERVER) then return end

	self:EmitSound( TauntSound )

end
