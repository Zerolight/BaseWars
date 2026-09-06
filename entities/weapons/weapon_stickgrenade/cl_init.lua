include('shared.lua')

SWEP.PrintName			= "STICKY GRENADE"
SWEP.Slot				= 4
SWEP.SlotPos			= 1

if (file.Exists( "materials/weapons/weapon_mad_magnade.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_magnade")
end

function SWEP:DrawWorldModel()

	local hand, offset, rotate

	if not IsValid(self:GetOwner()) then
		self:DrawModel()
		return
	end

	hand = self:GetOwner():GetAttachment(self:GetOwner():LookupAttachment("anim_attachment_rh"))

	offset = hand.Ang:Right() * -4 + hand.Ang:Forward() * 1 + hand.Ang:Up() * 1

	hand.Ang:RotateAroundAxis(hand.Ang:Right(), 0)
	hand.Ang:RotateAroundAxis(hand.Ang:Forward(), 90)
	hand.Ang:RotateAroundAxis(hand.Ang:Up(), 0)

	self:SetRenderOrigin(hand.Pos + offset)
	self:SetRenderAngles(hand.Ang)

	self:DrawModel()
end
