AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.StartColor = Color(0, 0, 0)
ENT.EndColor = Color(0, 0, 0)
ENT.LifeTime = 10
ENT.DieTime = 15

function ENT:Initialize()
	self:SetModel( "models/props_junk/propane_tank001a.mdl" )

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)
	self:SetAngles( Angle(-180, 0, 0) )
	self.FuseTime = 2

	self:SetPos( self:GetPos() + Vector(0, 0, 5) )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	if WireAddon then
		self.Inputs = Wire_CreateInputs( self, { "Fire", "Start Fuse", "Explode Distance", "Force Explode", "Fuse Time"} )
		self.Outputs = Wire_CreateOutputs(self, { "Fuse Started", "Launched" })
	end

end

function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo )

end

function ENT:Launch()

	if(IsValid(self)) then

		if(not self.Fired) then

			local phys = self:GetPhysicsObject()

			if (phys:IsValid()) then
				phys:Wake()
			end

			local launchtracedata = {}
			launchtracedata.start =	self:GetPos()
			launchtracedata.endpos = self:GetUp()*-10000000000000
			launchtracedata.filter = self
			launchtracedata.mask = MASK_PLAYERSOLID_BRUSHONLY

			local launchtrace = util.TraceLine(launchtracedata)

			if(not self.OverrideExplodeLength) then
				self.ExplodeLength = launchtrace.HitPos:Distance(self:GetPos()) * 0.75
			else
				self.ExplodeLength = math.Clamp(self.OverrideExplodeLength, 1, math.huge)
			end

			self.FirePos = self:GetPos()
			self.Fired = true

			local firework_ignite_explosion = EffectData()
			firework_ignite_explosion:SetOrigin( self:GetPos() - self:GetUp()*-20 )
			util.Effect( "StunstickImpact", firework_ignite_explosion )

			local firework_trail = EffectData()
			firework_trail:SetEntity( self )
			firework_trail:SetOrigin( self:GetPos() )
			util.Effect( "firework_trail", firework_trail, true, true )
			if WireAddon then Wire_TriggerOutput(self, "Launched", true); end
		end

	end

end

function ENT:Explode()

	if(IsValid(self)) then

		local firework_explosion = EffectData()

		firework_explosion:SetOrigin( self:GetPos() )
		firework_explosion:SetStart( Vector(self.StartColor.r, self.StartColor.g, self.StartColor.b) )
		firework_explosion:SetAngle( Angle(self.EndColor.r, self.EndColor.g, self.EndColor.b) )
		firework_explosion:SetMagnitude( self.LifeTime )
		firework_explosion:SetScale( self.DieTime )

		util.Effect( "firework_explosion", firework_explosion )
		util.BlastDamage(self, (self.Owner or self:GetOwner()) or self, self:GetPos(), 256, 150)

		self:Remove()

	end

end

function ENT:StartFuse()

	if(not self.Fired and not self.Ignited) then

		local firework_ignite = EffectData()
		firework_ignite:SetEntity( self )
		firework_ignite:SetScale( self.FuseTime )
		util.Effect( "firework_trail_launch", firework_ignite, true, true )

		self.Ignited = true

		if WireAddon then Wire_TriggerOutput(self, "Fuse Started", true); end
		timer.Simple( self.FuseTime, function() if IsValid( self ) then self:Launch() end end )

	end

end

function ENT:PhysicsUpdate(phys)

	if(self.Fired) then

		if(self:GetPos():Distance(self.FirePos) > self.ExplodeLength) then

			self:Explode()

		end

		phys:AddVelocity(self:GetUp()*-50)

	end

end

function ENT:PhysicsCollide(data, phys)
	if(self.Fired) then

		if(data.Speed > 100) then

			self:Explode(data.HitNormal)

		end

	end

end

function ENT:Use( activator, caller )

	self:StartFuse()

end

function ENT:OnRemove()
	if WireAddon then Wire_Remove( self ); end
end

function ENT:OnRestore()
	if WireAddon then Wire_Restored( self ); end
end

function ENT:TriggerInput( iname, value )

	if ( iname == "Fire" and util.tobool( value )) then
		self:Launch()
	elseif ( iname == "Start Fuse" and util.tobool( value )) then
		self:StartFuse()
	elseif ( iname == "Explode Distance") then
		self.OverrideExplodeLength = tonumber(value)
	elseif ( iname == "Force Explode" and util.tobool( value )) then
		self:Explode()
	elseif ( iname == "Fuse Time" and value) then
		self.FuseTime = math.Clamp(value, 0.5, math.huge)
	end

end
