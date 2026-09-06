AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self.Position = self:GetPos()
	self.Velocity = self:GetVar("Velocity",false)
	self.Acceleration = self:GetVar("Acceleration",false)
	self.Bullet = self:GetVar("Bullet",false)
	self.Trace = self:GetVar("Trace",false)

	if not (self.Position and self.Velocity and self.Acceleration and self.Bullet and self.Trace) then
		Msg("sent_bullt: Error! Insufficient data to spawn.\n")
		self:Remove()
		return
	end

	self.Owner = self.Owner or self
	self.LastThink = CurTime()
	self.Trace.endpos = self.Position

	self.Bullet.Spread = Vector(0,0,0)
	self.Bullet.Num = 1
	self.Bullet.Tracer = 0

	self:Fire("kill","",7)

end

function ENT:Think()

	local fTime = CurTime()
	local DeltaTime = fTime - self.LastThink
	self.LastThink = fTime

	self.Position = self.Position + self.Velocity*DeltaTime
	self.Velocity = self.Velocity + self.Acceleration*DeltaTime

	self.Trace.start = self.Trace.endpos
	self.Trace.endpos = self.Position

	local TraceRes = util.TraceLine(self.Trace)

	if TraceRes.Hit then
		self.Bullet.Src = self.Trace.start
		self.Bullet.Dir = (TraceRes.HitPos - self.Trace.start)
		self.Owner:FireBullets(self.Bullet)

		self:Remove()
		return false
	end

end
