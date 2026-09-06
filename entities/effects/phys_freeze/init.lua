local effects_freeze = CreateClientConVar( "effects_freeze", "1", true, false )

function EFFECT:Init( data )

	if ( effects_freeze:GetBool() == false ) then return end

	local vOffset = data:GetOrigin()

	local emitter = ParticleEmitter( vOffset )

		local particle = emitter:Add( "effects/freeze_unfreeze", vOffset )
		if (particle) then

			particle:SetDieTime( 0.5 )

			particle:SetStartAlpha( 0 )
			particle:SetEndAlpha( 255 )

			particle:SetStartSize( 16 )
			particle:SetEndSize( 0 )

		end

end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end
