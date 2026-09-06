include('shared.lua')

function ENT:Draw( )

	self:DrawModel()

	local Pos = self:GetPos()
	local Ang = Angle( 0, 0, 0)

	local upgrade = self:GetNWInt("upgrade")
	local owner = (self.Owner or self:GetOwner())
	owner = (IsValid(owner) and owner:Nick()) or "Unknown"

	surface.SetFont("HUDNumber5")
	local TextWidth = surface.GetTextSize("Spawn Point")

	Ang:RotateAroundAxis(Ang:Forward(), 90)
	local TextAng = Ang

	TextAng:RotateAroundAxis(TextAng:Right(), CurTime() * -180)
	local ply = LocalPlayer
	cam.Start3D2D(Pos + Ang:Right() * -75, TextAng, 0.2)

	cam.End3D2D()
end
