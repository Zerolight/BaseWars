include('shared.lua')

surface.CreateFont( "SandboxLabel", { font = "coolvetica", size = 64, weight = 500, antialias = true, shadow = false } )

ENT.LabelColor = Color( 255, 255, 255, 255 )

function ENT:Draw( flags )

	if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 256 ) then

		if ( self.RenderGroup == RENDERGROUP_OPAQUE ) then
			self.OldRenderGroup = self.RenderGroup
			self.RenderGroup = RENDERGROUP_TRANSLUCENT
		end

		if ( self:GetOverlayText() ~= "" ) then
			AddWorldTip( self:EntIndex(), self:GetOverlayText(), 0.5, self:GetPos(), self  )
		end

	else

		if ( self.OldRenderGroup ~= nil ) then

			self.RenderGroup = self.OldRenderGroup
			self.OldRenderGroup = nil

		end

	end

	self:DrawModel()

end

function ENT:DrawTranslucent( flags )

	if (  LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 256 ) then

		self:DrawEntityOutline( 1.0 )

	end

	self:Draw()

end

function ENT:DrawOverlayText()

	if ( not self:SetLabelVariables() ) then return end

	self:DrawLabel()

end

function ENT:DrawFlatLabel( size )

	local TargetAngle 	= self:GetAngles()
	local TargetPos 	= self:GetPos() - TargetAngle:Forward() * 16

	TargetAngle:RotateAroundAxis( TargetAngle:Up(), 90 )

	cam.Start3D2D( TargetPos, TargetAngle, 0.05 * size * self.LabelScale )

		local Shadow = Color( 0, 0, 0, self.LabelAlpha * 255 )
		draw.DrawText( self.LabelText, self.LabelFont,  3,  3, Shadow, TEXT_ALIGN_CENTER )

		self.LabelColor.a = self.LabelAlpha * 255
		draw.DrawText( self.LabelText, self.LabelFont, 0, 0, self.LabelColor, TEXT_ALIGN_CENTER )

	cam.End3D2D()

end

function ENT:SetLabelVariables()

	self.LabelText = self:GetOverlayText()
	if ( self.LabelText == "" ) then return false end

	self.LabelDistance = EyePos():Distance( self:GetPos() )
	if ( self.LabelDistance > 256 ) then return false end

	self.LabelAngles = self:GetAngles()
	self.LabelAngles:RotateAroundAxis( self.LabelAngles:Right(), 90 )

	local ViewNormal = EyePos() - self:GetPos()
	ViewNormal:Normalize()
	local ViewDot = ViewNormal:Dot( self.LabelAngles:Forward() )
	if ( ViewDot < 0 ) then return false end

	self.LabelPos = self:GetPos() + self.LabelAngles:Forward() + self.LabelAngles:Up() * 4

	self.LabelAlpha = (1 - self.LabelDistance / 256)^0.4

	self.LabelFont 	= "SandboxLabel"
	self.LabelScale = 1

	return true

end

local matOutlineWhite 	= Material( "white_outline" )
local ScaleNormal		= Vector()
local ScaleOutline1		= Vector() * 1.05
local ScaleOutline2		= Vector() * 1.1
local matOutlineBlack 	= Material( "black_outline" )

function ENT:DrawEntityOutline( size )

	size = size or 1.0
	render.SuppressEngineLighting( true )
	render.SetAmbientLight( 1, 1, 1 )
	render.SetColorModulation( 1, 1, 1 )

		self:SetModelScale( ScaleOutline2 * size )
		SetMaterialOverride( matOutlineBlack )
		self:DrawModel()

		self:SetModelScale( ScaleOutline1 * size )
		SetMaterialOverride( matOutlineWhite )
		self:DrawModel()

		SetMaterialOverride( nil )
		self:SetModelScale( ScaleNormal )

	render.SuppressEngineLighting( false )

	local _bwcol = self:GetColor()
	local r, g, b = _bwcol.r, _bwcol.g, _bwcol.b
	render.SetColorModulation( r/255, g/255, b/255 )

end
