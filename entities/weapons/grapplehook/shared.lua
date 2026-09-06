SWEP.Author			= "Hxrmn, HOLOGRAPHICpizza"
SWEP.Contact		= "hello45044@gmail.com"
SWEP.Purpose		= "A Grappling Hook"
SWEP.Instructions	= "Left click to fire"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.PrintName			= "Grappling Hook"
SWEP.Slot				= 2
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModel			= "models/weapons/v_crossbow.mdl"
SWEP.WorldModel			= "models/weapons/w_crossbow.mdl"

local sndPowerUp		= Sound("weapons/crossbow/hit1.wav")
local sndPowerDown		= Sound("Airboat.FireGunRevDown")
local sndTooFar			= Sound("buttons/button10.wav")

function SWEP:Initialize()

	nextshottime = CurTime()
	self:SetWeaponHoldType( "smg" )

end

function SWEP:Think()

	if (not self:GetOwner() or self:GetOwner() == NULL) then return end

	if ( self:GetOwner():KeyPressed( IN_ATTACK ) ) then

		self:StartAttack()

	elseif ( self:GetOwner():KeyDown( IN_ATTACK ) and inRange ) then

		self:UpdateAttack()

	elseif ( self:GetOwner():KeyReleased( IN_ATTACK ) and inRange ) then

		self:EndAttack( true )

	end

	if ( self:GetOwner():KeyPressed( IN_ATTACK2 ) ) then

		self:Attack2()

	end

end

function SWEP:DoTrace( endpos )
	local trace = {}
		trace.start = self:GetOwner():GetShootPos()
		trace.endpos = trace.start + (self:GetOwner():GetAimVector() * 14096)
		if(endpos) then trace.endpos = (endpos - self.Tr.HitNormal * 7) end
		trace.filter = { self:GetOwner(), self }

	self.Tr = nil
	self.Tr = util.TraceLine( trace )
end

function SWEP:StartAttack()

	local gunPos = self:GetOwner():GetShootPos()
	local disTrace = self:GetOwner():GetEyeTrace()
	local hitPos = disTrace.HitPos

	local x = (gunPos.x - hitPos.x)^2;
	local y = (gunPos.y - hitPos.y)^2;
	local z = (gunPos.z - hitPos.z)^2;
	local distance = math.sqrt(x + y + z);

	local distanceCvar = GetConVarNumber("grapple_distance")
	inRange = false
	if distance <= distanceCvar then
		inRange = true
	end

	if inRange then
		if (SERVER) then

			if (not self.Beam) then

				self.Beam = ents.Create( "trace1" )
					self.Beam:SetPos( self:GetOwner():GetShootPos() )
				self.Beam:Spawn()
			end

			self.Beam:SetParent( self:GetOwner() )
			self.Beam:SetOwner( self:GetOwner() )

		end

		self:DoTrace()
		self.speed = 10000
		self.startTime = CurTime()
		self.endTime = CurTime() + self.speed
		self.dt = -1

		if (SERVER and self.Beam) then
			self.Beam:GetTable():SetEndPos( self.Tr.HitPos )
		end

		self:UpdateAttack()

		self:EmitSound( sndPowerDown )
	else

		self:EmitSound( sndTooFar )
	end
end

function SWEP:UpdateAttack()

	self:GetOwner():LagCompensation( true )

	if (not endpos) then endpos = self.Tr.HitPos end

	if (SERVER and self.Beam) then
		self.Beam:GetTable():SetEndPos( endpos )
	end

	lastpos = endpos

			if ( self.Tr.Entity:IsValid() ) then

					endpos = self.Tr.Entity:GetPos()
					if ( SERVER ) then
					self.Beam:GetTable():SetEndPos( endpos )
					end

			end

			local vVel = (endpos - self:GetOwner():GetPos())
			local Distance = endpos:Distance(self:GetOwner():GetPos())

			local et = (self.startTime + (Distance/self.speed))
			if(self.dt ~= 0) then
				self.dt = (et - CurTime()) / (et - self.startTime)
			end
			if(self.dt < 0) then
				self:EmitSound( sndPowerUp )
				self.dt = 0
			end

			if(self.dt == 0) then
			zVel = self:GetOwner():GetVelocity().z
			vVel = vVel:GetNormalized()*(math.Clamp(Distance,0,7))
				if( SERVER ) then
				local gravity = GetConVarNumber("sv_Gravity")
				vVel:Add(Vector(0,0,(gravity/100)*1.5))
				if(zVel < 0) then
					vVel:Sub(Vector(0,0,zVel/100))
				end
				self:GetOwner():SetVelocity(vVel)
				end
			end

	endpos = nil

	self:GetOwner():LagCompensation( false )

end

function SWEP:EndAttack( shutdownsound )

	if ( shutdownsound ) then
		self:EmitSound( sndPowerDown )
	end

	if ( CLIENT ) then return end
	if ( not self.Beam ) then return end

	self.Beam:Remove()
	self.Beam = nil

end

function SWEP:Attack2()

	if (CLIENT) then return end
		local CF = self:GetOwner():GetFOV()
		if CF == 90 then
			self:GetOwner():SetFOV(30,.3)
		elseif CF == 30 then
			self:GetOwner():SetFOV(90,.3)

	end
end

function SWEP:Holster()
	self:EndAttack( false )
	return true
end

function SWEP:OnRemove()
	self:EndAttack( false )
	return true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end
