function ParticleTrace(partrace)
if ( SERVER ) then

	if not partrace.func
	or not partrace.startpos
	or not (partrace.ang or partrace.velocity)
	then return end

	partrace.speed 			= 	partrace.speed 			or 1024
	partrace.ang 			= 	partrace.ang  			or partrace.velocity:GetNormalized() or Vector(0,0,0)
	partrace.owner			= 	partrace.owner 			or 0
	partrace.name			= 	partrace.name 			or ""
	partrace.collisionsize 	= 	partrace.collisionsize 	or 1
	partrace.worldcollide	=	partrace.worldcollide	or true
	partrace.mask			= 	partrace.mask 			or 3
	partrace.killtime 		= 	partrace.killtime 		or 12
	partrace.runonkill 		= 	partrace.runonkill  	or false
	partrace.movetype 		= 	partrace.movetype 		or MOVETYPE_FLY
	partrace.model 			= 	partrace.model 			or "none"
	partrace.color 			= 	partrace.color  		or Color(255,255,255,255)
	partrace.doblur			= 	partrace.doblur	 		or false
	partrace.filter			=	partrace.filter			or {}

	partrace.starttime = CurTime()
	partrace.lasthit = 0
	partrace.dodraw = false
	partrace.issprite = false

	partrace.entid = ents.Create( "sent_traceparticle" )

		if partrace.model == "none" then

			partrace.entid:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
			partrace.entid:DrawShadow(false)
		elseif string.find(partrace.model,".mdl") ~= nil then
			partrace.entid:SetModel(partrace.model)
			partrace.dodraw = true
		else
			partrace.entid:SetModel("models/Items/combine_rifle_ammo01.mdl")
			partrace.dodraw = true
			partrace.issprite = true
			partrace.model = string.gsub(string.gsub(string.gsub(partrace.model, ".vmt", ""), ".vtf", ""), ".spr", "")
		end

	table.insert(partrace.filter,partrace.entid)

	if partrace.speed > 8192 then partrace.speed = 8192 end

	partrace.entid:SetVar("tracedata",partrace)

	partrace.entid:SetPos(partrace.startpos)
	partrace.entid:SetAngles(partrace.ang:Angle())
	partrace.entid:Spawn()
	partrace.entid:SetOwner(partrace.owner)
	partrace.entid:SetName(partrace.name)

	local physobj = partrace.entid:GetPhysicsObject()
	if partrace.velocity then
		partrace.ang = partrace.velocity:GetNormalized()
	else
		partrace.velocity = partrace.ang*partrace.speed
	end
	physobj:SetMass(1e-9)
	physobj:EnableGravity(partrace.gravity)
	physobj:SetVelocity(partrace.velocity)
	partrace.entid:SetVelocity(partrace.velocity)

	if partrace.initfunc then
	partrace.initfunc(partrace.entid)
	end

end

end
