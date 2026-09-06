function ccSWEPSpawn( ply, cmd, args )

		if( not Admins[ply:SteamID()] and not ply:IsAdmin() and not ply:IsSuperAdmin() ) then
			Notify( ply, 4, 2, "Admin-Only!" );
			return;
		end

	local class = args[1]
	if( not isstring( class ) or class == "" ) then return end
	if( not weapons.GetStored( class ) ) then return end

	PrintMessageAll( HUD_PRINTCONSOLE, ply:GetName().." spawned weapon "..class.."\n" )
	ply:Give( class )

end
concommand.Add( "gm_giveswep", ccSWEPSpawn );
concommand.Add( "gm_spawnswep", ccSWEPSpawn );

function ccSENTSPawn( ply, cmd, args )

		if( not Admins[ply:SteamID()] and not ply:IsAdmin() and not ply:IsSuperAdmin() ) then
			Notify( ply, 4, 2, "Admin-Only!" );
			return;
		end

	local class = args[1]
	if( not isstring( class ) or class == "" ) then return end
	if( not scripted_ents.GetStored( class ) ) then return end

	local tr = util.TraceLine({
		start = ply:GetShootPos(),
		endpos = ply:GetShootPos() + ply:GetAimVector() * 4096,
		filter = ply
	})

	local ent = ents.Create( class )
	if( not IsValid( ent ) ) then return end
	ent:SetPos( tr.HitPos )
	ent:SetAngles( Angle( 0, ply:EyeAngles().y + 180, 0 ) )
	ent:Spawn()
	ent:Activate()

	undo.Create( class )
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
	undo.Finish()

end
concommand.Add( "gm_spawnsent", ccSENTSPawn )

function Magnet( pl, pos, angle, model, material, key, maxobjects, strength, nopull, allowrot, alwayson, toggle, Vel, aVel, frozen )
	if ( not gamemode.Call( "PlayerSpawnMagnet", pl, Model ) ) then return end
	local magnet = ents.Create("phys_magnet")
	magnet:SetPos(pos)
	magnet:SetAngles(angle)
	magnet:SetModel( model )
	magnet:SetMaterial( material )

	local spawnflags = 4
	if (nopull > 0) then		spawnflags = spawnflags - 4		end
	if (allowrot > 0) then		spawnflags = spawnflags + 8		end

	magnet:SetKeyValue( "maxobjects", maxobjects )
	magnet:SetKeyValue( "forcelimit", strength )
	magnet:SetKeyValue( "spawnflags", spawnflags )
	magnet:SetKeyValue( "overridescript", "surfaceprop,metal")
	magnet:SetKeyValue( "massScale", 0 )

	magnet:Activate()
	magnet:Spawn()

	if magnet:GetPhysicsObject():IsValid() then
		Phys = magnet:GetPhysicsObject()
		if Vel then Phys:SetVelocity(Vel) end
		if Vel then Phys:AddAngleVelocity(aVel) end
		Phys:EnableMotion(frozen ~= true)
	end

	if (alwayson > 0) then
		magnet:Input("TurnOn", nil, nil, nil)
	else
		magnet:Input("TurnOff", nil, nil, nil)
	end

	local mtable = {
		model = model,
		material = material,
		key = key,
		maxobjects = maxobjects,
		strength = strength,
		nopull = nopull,
		allowrot = allowrot,
		alwayson = alwayson,
		toggle = toggle
	}

	magnet:SetTable( mtable )

	numpad.OnDown( 	 pl, 	key, 	"MagnetOn", 	magnet )
	numpad.OnUp( 	 pl, 	key, 	"MagnetOff", 	magnet )

	gamemode.Call( "PlayerSpawnedMagnet", pl, model, magnet )
	return magnet

end

duplicator.RegisterEntityClass( "phys_magnet", Magnet, "pos", "angle", "model", "material", "key", "maxobjects", "strength", "nopull", "allowrot", "alwayson", "toggle", "Vel", "aVel", "frozen" )
