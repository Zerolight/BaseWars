local matRefract = Material( "models/spawn_effect" )
local matLight	 = Material( "models/spawn_effect2" )

function EFFECT:Init( data )

	self.Time = 1
	self.LifeTime = CurTime() + self.Time

	local ent = data:GetEntity()
	if ( ent == NULL ) then return end

	self.ParentEntity = ent
	self:SetModel( ent:GetModel() )
	self:SetPos( ent:GetPos() )
	self:SetAngles( ent:GetAngles() )
	self:SetParent( ent )

end

function EFFECT:Think( )

	if (not self.ParentEntity or not self.ParentEntity:IsValid()) then return false end

	return ( self.LifeTime > CurTime() )

end

function EFFECT:Render()

	local Fraction = (self.LifeTime - CurTime()) / self.Time
	Fraction = math.Clamp( Fraction, 0, 1 )

	self:SetColor(Color(255, 255, 255, 1 + math.sin( Fraction * math.pi ) * 100))

	local EyeNormal = self:GetPos() - EyePos()
	local Distance = EyeNormal:Length()
	EyeNormal:Normalize()

	local Pos = EyePos() + EyeNormal * Distance * 0.01

	cam.Start3D( Pos, EyeAngles() )

		SetMaterialOverride( matLight )
			self:DrawModel()
		SetMaterialOverride( 0 )

		if ( render.GetDXLevel() >= 80 ) then

			render.UpdateRefractTexture()

			matRefract:SetMaterialFloat( "$refractamount", Fraction ^ 2 )

			SetMaterialOverride( matRefract )
				self:DrawModel()
			SetMaterialOverride( 0 )

		end

	cam.End3D()

end
