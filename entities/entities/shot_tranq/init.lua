AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_c17/trappropeller_lever.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetKeyValue("physdamagescale", "9999")
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
	end
	self.DidHit = false
	self.lolHitPos = Vector(0,0,0)
	self.Blocked = false
	util.SpriteTrail(self, 0, Color(50,100,10), false, 3, 1, 0.1, 1/8.5, "trails/smoke.vmt")
	self:GetPhysicsObject():SetVelocity(self:GetRight()*50000)
	util.PrecacheSound("weapons/crossbow/bolt_skewer1.wav")

end

function ENT:Think()
	if (IsValid(self:GetOwner())==false) then
		self:Remove()
	end
end

function ENT:OnRemove()

	timer.Destroy(tostring(self) .. "clear")
end

function ENT:PhysicsCollide( data, physobj )
	if not self.DidHit then
		self:GetPhysicsObject():EnableMotion(false)
		self:SetKeyValue("solid", "0")
		self.lolHitPos = data.HitPos

  		self.DidHit = true
		self:GetPhysicsObject():SetVelocity(Angle(0,0,0))
		timer.Create( tostring(self) .. "clear", 20, 1, function() self:Remove() end)

		self:EmitSound("weapons/crossbow/bolt_skewer1.wav")
		if (data.HitEntity~=nil) then
			if (IsValid(data.HitEntity)) then
				self.Blocked=true
				if (data.HitEntity:IsPlayer()) then
					StunPlayer(data.HitEntity, 35)

					data.HitEntity:TakeDamage(10, self:GetOwner(), self)

					if (self.Poison) then
						PoisonPlayer(data.HitEntity, 30, self:GetOwner(), self:GetOwner():GetWeapon("weapon_tranqgun"))
					end
				else

					data.HitEntity:TakeDamage(30, self:GetOwner(), self)
				end
			end
		end
	end
end
function ENT:PhysicsUpdate()
	local trace = {}
		trace.start = self:GetPos()
		trace.endpos = self:GetPos()
		trace.filter = {self, self:GetOwner()}
	trace = util.TraceLine(trace)
	if trace.Hit then self.Blocked=true end
	if (self.DidHit == true) then
		self:SetPos(self.lolHitPos)
	end
	if (self.Blocked == true ) then
		self:Remove()
	end
end

function ENT:Poisonous()
	self.Poison = true
end
