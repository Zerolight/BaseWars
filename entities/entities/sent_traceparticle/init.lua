AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

local calculatedata = function(data,hitent)

	local lasthit = data.lasthit
	local collisionsize = data.collisionsize
	local speed = data.speed
	local curtime = CurTime()
	local filter = data.filter
	local ent = data.entid
	local entpos = ent:GetPos()
	local particleang = ent:GetVelocity():GetNormalized()

	if lasthit < curtime then
		data.lasthit = curtime + 7*collisionsize/speed
	else return end
	if hitent == Entity(0) then
		hitent = ent
	else

		if filter ~= {} then
			for k,v in pairs(filter) do
				if hitent == v then
				return
				end
			end
		end
	end

	local trace = {}
	local offsetvec = particleang*collisionsize

	trace.startpos = entpos - offsetvec*1.2
	trace.endpos = entpos + offsetvec*3
	trace.filter = filter
	trace.mask = data.mask

	local traceRes = util.TraceLine(trace)
		if not traceRes.Hit then
			for i=1,5 do
			trace.startpos = entpos - particleang*(collisionsize + 3*i)
			trace.endpos = entpos + particleang*(collisionsize + 18*i)
			traceRes = util.TraceLine(trace)
			if traceRes.Hit then break end
			end
		end

	traceRes.StartPos = data.startpos
	traceRes.particlepos = entpos
	traceRes.caller = ent
	traceRes.owner = data.owner
	traceRes.activator = hitent
	traceRes.tracedata = data
	traceRes.time = curtime - data.starttime

	data.func(traceRes)

end

function ENT:Initialize()

	local partent = self
	self.tracedata = partent:GetVar("tracedata",{couldnotfindtable = true})
	local data = self.tracedata

	if data.couldnotfindtable then return end

	partent:SetMoveType(data.movetype)
	partent:PhysicsInitSphere(data.collisionsize, "default_silent")
	partent:SetCollisionBounds(Vector()*data.collisionsize*-1, Vector()*data.collisionsize)

	local phys = partent:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	partent:SetTrigger(true)
	partent:SetNotSolid(true)
	partent:SetCollisionGroup(data.mask)

	if data.worldcollide then
		partent:SetMoveType(data.movetype)
	end

	if data.runonkill then
		timer.Create( tostring(self), data.killtime, 1, function() calculatedata( data, Entity(0) ) end )
	else
		partent:Fire("kill", "", data.killtime )
	end

end

function ENT:PhysicsCollide(physdata, physobj)

end

function ENT:Touch(hitEnt)

	calculatedata(self.tracedata,hitEnt)

end

function ENT:OnRemove()
	timer.Destroy(tostring(self))
end

function ENT:OnTakeDamage(dmginfo)

end

function ENT:Use(activator, caller)

end

include( 'shared.lua' )
