include('shared.lua')

function ENT:Initialize()

	self.Color = Color(255,255,255,255)

end

function ENT:Draw()

	local dodraw = dodraw or self:GetNWBool("dodraw")
	if not dodraw then return false end

	local issprite = issprite or self:GetNWBool("issprite")
	local doblur = doblur or self:GetNWBool("doblur")
	local model = model or self:GetNWString("model")
	local color = color or Color( self:GetNWInt("rcolor",255), self:GetNWInt("gcolor",255), self:GetNWInt("bcolor",255), self:GetNWInt("acolor",255) )
	local collisionsize = collisionsize or self:GetNWFloat("collisionsize")*2

	if issprite then

		local pos = self:GetPos()
		local vel = self:GetVelocity()
		render.SetMaterial(Material(model))

		if doblur then
			local lcolor = render.GetLightColor( pos ) * 2
			lcolor.x = color.r * math.Clamp( lcolor.x, 0, 1 )
			lcolor.y = color.g * math.Clamp( lcolor.y, 0, 1 )
			lcolor.z = color.b * math.Clamp( lcolor.z, 0, 1 )

			for i = 1, 7 do
				local col = Color( lcolor.x, lcolor.y, lcolor.z, 200 / i )
				render.DrawSprite( pos + vel*(i*-0.004), collisionsize, collisionsize, col )
			end
		end

		render.DrawSprite(pos, collisionsize, collisionsize, color)

	else

		self:DrawModel()

	end

	self:DrawShadow(false)

end
