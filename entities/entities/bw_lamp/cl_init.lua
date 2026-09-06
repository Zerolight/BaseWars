include('shared.lua')

local matLight 		= Material( "sprites/light_ignorez" )
local matBeam		= Material( "effects/lamp_beam" )

ENT.RenderGroup 	= RENDERGROUP_BOTH

function ENT:Initialize()

	self.PixVis = util.GetPixelVisibleHandle()

end

function ENT:Draw()

	self.BaseClass.Draw( self )

end

function ENT:DrawTranslucent()

	self.BaseClass.DrawTranslucent( self )

	if ( not self:GetOn() ) then return end

	local LightNrm = self:GetAngles():Up()
	local ViewNormal = self:GetPos() - EyePos()
	local Distance = ViewNormal:Length()
	ViewNormal:Normalize()
	local ViewDot = ViewNormal:Dot( LightNrm )
	local _bwcol = self:GetColor()
	local r, g, b, a = _bwcol.r, _bwcol.g, _bwcol.b, _bwcol.a
	local LightPos = self:GetPos() + LightNrm * -6

	if ( ViewDot >= 0 ) then

		render.SetMaterial( matLight )
		local Visibile	= util.PixelVisible( LightPos, 16, self.PixVis )

		if (not Visibile) then return end

		local Size = math.Clamp( Distance * Visibile * ViewDot * 2, 64, 512 )

		Distance = math.Clamp( Distance, 32, 800 )
		local Alpha = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 100 )
		local Col = Color( r, g, b, Alpha )

		render.DrawSprite( LightPos, Size, Size, Col, Visibile * ViewDot )
		render.DrawSprite( LightPos, Size*0.4, Size*0.4, Color(255, 255, 255, Alpha), Visibile * ViewDot )

	end

end

function ENT:GetOverlayText()

	return self:GetPlayerName()

end
