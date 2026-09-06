include('shared.lua')

function SWEP:DrawHUD()

	if( LocalPlayer():KeyDown(1)) then
			local trace = self:GetOwner():GetEyeTrace()
			if (trace.Entity:GetNWInt("welddamage")~=nil and trace.HitPos:Distance(LocalPlayer():GetShootPos()) <= 128 and (trace.Entity:GetClass()=="prop_physics_multiplayer" or trace.Entity:GetClass()=="prop_physics_respawnable" or trace.Entity:GetClass()=="prop_physics" or trace.Entity:GetClass()=="phys_magnet" or trace.Entity:GetClass()=="gmod_spawner" or trace.Entity:GetClass()=="gmod_wheel" or trace.Entity:GetClass()=="gmod_thruster" or trace.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trace.Entity:IsValid()) then
				draw.RoundedBox( 2, ScrW()/2+10, ScrH()/2+25, 100, 33, Color(0,0,0,50) )
				local weldpercent = -((tonumber(trace.Entity:GetNWInt("welddamage"))/255)*100)+100
				draw.RoundedBox( 1, ScrW()/2+11, ScrH()/2+26, weldpercent, 6, Color(150,150,0,100) )
			end

			local tr = {}
				tr.start = trace.HitPos
				tr.endpos = trace.HitPos + (self:GetOwner():GetAimVector() * 128.0)
				tr.filter = { self:GetOwner(), trace.Entity }
			local trtwo = util.TraceLine( tr )

			if (not trtwo.Hit) then return end

			if (trtwo.Entity:GetNWInt("welddamage")~=nil and trtwo.HitPos:Distance(LocalPlayer():GetShootPos()) <= 256 and (trtwo.Entity:GetClass()=="prop_physics_multiplayer" or trtwo.Entity:GetClass()=="prop_physics_respawnable" or trtwo.Entity:GetClass()=="prop_physics" or trtwo.Entity:GetClass()=="phys_magnet" or trtwo.Entity:GetClass()=="gmod_spawner" or trtwo.Entity:GetClass()=="gmod_wheel" or trtwo.Entity:GetClass()=="gmod_thruster" or trtwo.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trtwo.Entity:IsValid()) then
				local weldpercenttwo = -((tonumber(trtwo.Entity:GetNWInt("welddamage"))/255)*100)+100
				draw.RoundedBox( 1, ScrW()/2+11, ScrH()/2+32, weldpercenttwo, 6, Color(120,120,0,100) )
			end

			local trx = {}
				trx.start = trtwo.HitPos
				trx.endpos = trtwo.HitPos + (self:GetOwner():GetAimVector() * 128.0)
				trx.filter = { self:GetOwner(), trace.Entity, trtwo.Entity }
			local trthree = util.TraceLine( trx )

			if (not trthree.Hit) then return end

			if (trthree.Entity:GetNWInt("welddamage")~=nil and trthree.HitPos:Distance(LocalPlayer():GetShootPos()) <= 384 and (trthree.Entity:GetClass()=="prop_physics_multiplayer" or trthree.Entity:GetClass()=="prop_physics_respawnable" or trthree.Entity:GetClass()=="prop_physics" or trthree.Entity:GetClass()=="phys_magnet" or trthree.Entity:GetClass()=="gmod_spawner" or trthree.Entity:GetClass()=="gmod_wheel" or trthree.Entity:GetClass()=="gmod_thruster" or trthree.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trthree.Entity:IsValid()) then
				local weldpercentthree = -((tonumber(trthree.Entity:GetNWInt("welddamage"))/255)*100)+100
				draw.RoundedBox( 1, ScrW()/2+11, ScrH()/2+38, weldpercentthree, 6, Color(150,150,0,100) )
			end

			local try = {}
				try.start = trthree.HitPos
				try.endpos = trthree.HitPos + (self:GetOwner():GetAimVector() * 128.0)
				try.filter = { self:GetOwner(), trace.Entity, trtwo.Entity, trthree.Entity }
			local trfour = util.TraceLine( try )

			if (not trfour.Hit) then return end

			if (trfour.Entity:GetNWInt("welddamage")~=nil and trfour.HitPos:Distance(LocalPlayer():GetShootPos()) <= 512 and (trfour.Entity:GetClass()=="prop_physics_multiplayer" or trfour.Entity:GetClass()=="prop_physics_respawnable" or trfour.Entity:GetClass()=="prop_physics" or trfour.Entity:GetClass()=="phys_magnet" or trfour.Entity:GetClass()=="gmod_spawner" or trfour.Entity:GetClass()=="gmod_wheel" or trfour.Entity:GetClass()=="gmod_thruster" or trfour.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trfour.Entity:IsValid()) then
				local weldpercentfour = -((tonumber(trfour.Entity:GetNWInt("welddamage"))/255)*100)+100
				draw.RoundedBox( 1, ScrW()/2+11, ScrH()/2+44, weldpercentfour, 6, Color(120,120,0,100) )
			end

			local trz = {}
				trz.start = trfour.HitPos
				trz.endpos = trfour.HitPos + (self:GetOwner():GetAimVector() * 128.0)
				trz.filter = { self:GetOwner(), trace.Entity, trtwo.Entity, trthree.Entity, trfour.Entity }
			local trfive = util.TraceLine( trz )

			if (not trfive.Hit) then return end

			if (trfive.Entity:GetNWInt("welddamage")~=nil and trfive.HitPos:Distance(LocalPlayer():GetShootPos()) <= 768 and (trfive.Entity:GetClass()=="prop_physics_multiplayer" or trfive.Entity:GetClass()=="prop_physics_respawnable" or trfive.Entity:GetClass()=="prop_physics" or trfive.Entity:GetClass()=="phys_magnet" or trfive.Entity:GetClass()=="gmod_spawner" or trfive.Entity:GetClass()=="gmod_wheel" or trfive.Entity:GetClass()=="gmod_thruster" or trfive.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trfive.Entity:IsValid()) then
				local weldpercentfive = -((tonumber(trfive.Entity:GetNWInt("welddamage"))/255)*100)+100
				draw.RoundedBox( 1, ScrW()/2+11, ScrH()/2+50, weldpercentfive, 6, Color(150,150,0,100) )
			end
	end

end
