if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType			= "rpg"
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
end

if ( CLIENT ) then

	SWEP.PrintName			= "Worldslayer"
	SWEP.Author				= "HLTV Proxy"
	SWEP.Instructions	= "Portable Bigbomb. \n This weapon only has one shot."
	SWEP.Contact		= ""
	SWEP.Purpose		= ""
	SWEP.Slot				= 4
	SWEP.SlotPos			= 5
	SWEP.ViewModelFOV		= 70
	SWEP.ViewModelFlip		= false
	SWEP.IconLetter			= "i"

	surface.CreateFont( "HL2SelectIcons", { font = "HalfLife2", size = ScreenScale( 60 ), weight = 500, antialias = true, shadow = true } )
	killicon.AddFont( "shot_rocket", "HL2MPTypeDeath", "3", Color( 100, 100, 100, 255 ) )

	if (file.Exists( "materials/weapons/weapon_mad_rpg.vmt", "GAME" )) then
		SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_rpg")
	end
end

SWEP.Base				= "weapon_mad_base"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_RPG.Single" )
SWEP.Primary.Recoil			= 15
SWEP.Primary.Damage			= 4107
SWEP.Primary.NumShots		= 5
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.15
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector( 6.1, -14, 2.5 )
SWEP.IronSightsAng 		= Vector( 2.8, 0, 0 )

function SWEP:PrimaryAttack()

	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:EmitSound( self.Primary.Sound )
	if (SERVER) then
		self:FireRocket( self.Primary.Recoil )
	end
	if ( self:GetOwner():IsNPC() ) then return end

	self:GetOwner():ViewPunch( Angle( math.Rand(-0.2,0.2) * self.Primary.Recoil, math.Rand(-0.2,0.2) *self.Primary.Recoil, 0 ) )
	if ( (game.SinglePlayer() and SERVER) or CLIENT ) then
		self:SetNWFloat( "LastShootTime", CurTime() )
	end
	if (SERVER) then
		self:Remove()
	end
end

function SWEP:SecondaryAttack()

end

function SWEP:FireRocket( recoil )

	local object = ents.Create("worldslayer")

	if IsValid(object) then

		object:SetOwner(self:GetOwner())
		object.Owner = self:GetOwner()
		object:SetPos(self:GetOwner():GetShootPos()+self:GetOwner():EyeAngles():Right()*5)
		object:SetAngles(self:GetOwner():EyeAngles())
		object:Spawn()
		object:Activate()
		object:GetPhysicsObject():SetVelocity(self:GetOwner():GetAimVector()*400000)
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

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:PrintWeaponInfo( x, y, alpha )

	if (self.InfoMarkup == nil ) then
		local str
		local title_color = "<color=230,230,230,255>"
		local text_color = "<color=150,150,150,255>"

		str = "<font=HudSelectionText>"
		if ( self.Author ~= "" ) then str = str .. title_color .. "Author:</color>\t"..text_color..self.Author.."</color>\n" end
		if ( self.Contact ~= "" ) then str = str .. title_color .. "Contact:</color>\t"..text_color..self.Contact.."</color>\n\n" end
		if ( self.Purpose ~= "" ) then str = str .. title_color .. "Purpose:</color>\n"..text_color..self.Purpose.."</color>\n\n" end
		if ( self.Instructions ~= "" ) then str = str .. title_color .. "Instructions:</color>\n"..text_color..self.Instructions.."</color>\n" end
		str = str .. "</font>"

		self.InfoMarkup = markup.Parse( str, 250 )
	end

	surface.SetDrawColor( 60, 60, 60, alpha )
	surface.SetTexture( self.SpeechBubbleLid )

	surface.DrawTexturedRect( x, y - 64 - 5, 128, 64 )
	draw.RoundedBox( 8, x - 5, y - 6, 260, self.InfoMarkup:GetHeight() + 18, Color( 60, 60, 60, alpha ) )

	self.InfoMarkup:Draw( x+5, y+5, nil, nil, alpha )

end
