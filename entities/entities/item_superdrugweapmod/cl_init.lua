include('shared.lua')

function ENT:Initialize()
end

function ENT:Draw()
	if ( EyePos():Distance( self:GetPos() ) < 256 ) then

		if ( self.RenderGroup == RENDERGROUP_OPAQUE ) then
			self.OldRenderGroup = self.RenderGroup
			self.RenderGroup = RENDERGROUP_TRANSLUCENT
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

	if (  EyePos():Distance( self:GetPos() ) < 256 ) then

		self:DrawEntityOutline( 1.0 )

	end

	self:Draw()

end

function ENT:Think()
	self:SetColor(Color(math.random(1,255), math.random(1,155), math.random(1,55), 255))
end

local matOutlineWhite 	= Material( "Models/effects/comball_tape" )
local ScaleNormal		= Vector()
local ScaleOutline1		= Vector() * 1.25
local ScaleOutline2		= Vector() * 1.2
local matOutlineBlack 	= Material( "Models/effects/comball_sphere" )

function ENT:DrawEntityOutline( size )

	size = size or 1.0
	render.SuppressEngineLighting( true )
	render.SetAmbientLight( 1, 1, 1 )
	render.SetColorModulation( 1, 1, 1 )

	self:SetModelScale( ScaleOutline2 * size )
	self:SetupBones( matOutlineWhite)
	SetMaterialOverride( matOutlineBlack )
	self:DrawModel()

	self:SetModelScale( ScaleOutline1 )
	self:SetupBones()
	SetMaterialOverride( matOutlineWhite )
	self:DrawModel()

	SetMaterialOverride( nil )
	self:SetModelScale( ScaleNormal )
	self:SetupBones()

	render.SuppressEngineLighting( false )

	local _bwcol = self:GetColor()
	local r, g, b = _bwcol.r, _bwcol.g, _bwcol.b
	render.SetColorModulation( r/255, g/255, b/255 )
end
