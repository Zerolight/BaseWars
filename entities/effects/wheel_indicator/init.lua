EFFECT.Mat = Material( "effects/wheel_ring" )

local WheelEffects = {}

function EFFECT:Init( data )

	local size = 64
	self:SetCollisionBounds( Vector( -size,-size,-size ), Vector( size,size,size ) )

	self.Wheel 	= data:GetEntity()

	if (not self.Wheel:IsValid()) then return end

	local oldeffect = WheelEffects[ self.Wheel:EntIndex() ]
	if ( oldeffect and oldeffect:IsValid() ) then

		oldeffect:Remove()

	end

	self:SetAngles( data:GetNormal():Angle() + Angle( 0.01, 0.01, 0.01 ) )

	self:SetParent( self.Wheel )

	self.Pos = data:GetOrigin()
	self.Normal = self.Wheel:GetPos() - self.Pos
	self.Alpha = 1

	self.Direction = data:GetScale()
	self.Size = self.Wheel:BoundingRadius() + 8
	self.Axis = data:GetOrigin()
	self.Axis = self.Axis

	self:SetPos( self.Wheel:LocalToWorld( self.Axis ) )
	self:SetParent( self.Wheel )

	WheelEffects[ self.Wheel:EntIndex() ] = self

end

function EFFECT:Think( )

	if (not self.Wheel:IsValid()) then return end

	local speed = FrameTime()

	self.Alpha = self.Alpha - speed * 0.5

	if (self.Alpha < 0 ) then return false end
	return true

end

function EFFECT:Render( )

	if (not self.Wheel:IsValid()) then return end

	if (self.Alpha < 0 ) then return end

	render.SetMaterial( self.Mat )

	local Normal = self.Wheel:LocalToWorld( self.Axis ) - self.Wheel:GetPos()

	render.DrawQuadEasy( self.Wheel:GetPos() + Normal,
						 Normal:GetNormalized() * self.Direction,
						 self.Size, self.Size,
						 Color( 255, 255, 255, (self.Alpha ^ 1.1) * 255 ),
						 self.Alpha * 200 )

end
