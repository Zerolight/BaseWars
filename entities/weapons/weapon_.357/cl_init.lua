include('shared.lua')

SWEP.PrintName			= "#HL2_357Handgun"
SWEP.ClassName			= "weapon_.357"
SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true
SWEP.DrawWeaponInfoBox	= false
SWEP.BounceWeaponIcon   = false

SWEP.WepSelectFont		= "TitleFont"
SWEP.WepSelectLetter	= "e"
SWEP.IconFont			= "HL2MPTypeDeath"
SWEP.IconLetter			= "."

killicon.AddFont( SWEP.ClassName, SWEP.IconFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	surface.SetDrawColor( color_transparent )
	surface.SetTextColor( 255, 220, 0, alpha )
	surface.SetFont( self.WepSelectFont )
	local w, h = surface.GetTextSize( self.WepSelectLetter )

	surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
						y + ( tall / 2 ) - ( h / 2 ) )
	surface.DrawText( self.WepSelectLetter )

end
