ENT.Base = "base_gmodentity"
ENT.Type = "anim"

local DebugWC = false

local CrawlBoxMin = Vector(-1, -1, -1)
local CrawlBoxMax = Vector(1, 1, 1)

function ENT:Initialize()
  self:SetNWBool("WCActive",false)
  self:SetMoveType(MOVETYPE_CUSTOM)
  self:SetModel( "models/props_junk/sawblade001a.mdl" )
  self:PhysicsInitBox(CrawlBoxMin, CrawlBoxMax)
  self:SetMoveType( MOVETYPE_VPHYSICS )
  self:SetSolid( SOLID_VPHYSICS )
  self:DrawShadow(false)

  local phys = self:GetPhysicsObject()
  if (phys:IsValid()) then
    phys:Wake()
    phys:EnableCollisions(false)
    phys:EnableGravity(false)
  else
    print("Error: NonValid WCam PhysObj")
  end
end

function ENT:IsActivated()
  return self:GetNWBool("WCActive")
end

function ENT:Toggle()
  if self:IsActivated() then
    self:FinishWallCrawling()
  else
    self:InitWallCrawling()
  end
end

function ENT:IsValidCrawlSpace(ply)

  local trace = ply:GetEyeTrace()

  if trace.HitNonWorld then
    if DebugWC then
      print('Hit non world')
    end
    return false
  end

  if trace.StartPos:Distance(trace.HitPos) > 82 then
    if DebugWC then
      print('Too far away')
      print(trace.StartPos:Distance(trace.HitPos))
    end
    return false
  end

  if trace.HitNormal:DotProduct(Vector(0,0,1)) > 0.3 then
    if DebugWC then
      print('You can walk this')
      print(trace.HitNormal)
    end
    return false
  end

  return trace
end

function ENT:GetInvWallNormal()
  return self:GetNWVector("wallinvnormal")
end

function ENT:GetWallAngle()
  return self:GetNWAngle("wall")
end

function ENT:InitWallCrawling()
  local ply = self:GetOwner()
  local walltrace = self:IsValidCrawlSpace(ply)

  if not walltrace then
    self:SetNWBool("WCActive", false)
    return false
  end

  self:GetPhysicsObject():EnableMotion(false)
  self:GetPhysicsObject():EnableMotion(true)

  if (ply:GetActiveWeapon():GetTable().WebIsAttached) then
    ply:GetActiveWeapon():GetTable():RemoveWeb()
  end
  if SERVER then
    ply:SetMoveType(MOVETYPE_NONE)
    ply:SetLocalVelocity(Vector(0,0,0))
  end
  local wallpos = walltrace.HitPos
  self:SetPos(ply:GetShootPos())

  local wallinvnormal = walltrace.HitNormal * -1
  self:SetNWVector("wallinvnormal", wallinvnormal)
  self:SetNWAngle("wall", wallinvnormal:Angle())

  local newangle = self:GetWallAngle()

  ply:SetParent(self)
  newangle:RotateAroundAxis(newangle:Forward(), newangle.y)
  newangle:RotateAroundAxis(newangle:Right(), 90)

  if DebugWC then
    ply:PrintMessage(HUD_PRINTCENTER, tostring(walltrace.HitNormal))
  end
  self:SetAngles(newangle)

  self:SetPos(wallpos)

  if SERVER then
    self:StartMotionController()
    self:GetPhysicsObject():Wake()
  end

  self:SetNWBool("WCActive", true)
  return true
end

function ENT:FinishWallCrawling()

  if (not self:IsActivated()) then return false end

  local phys = self:GetPhysicsObject()
  local savedvel = Vector(0,0,0)
  if (phys) and (phys ~= NULL) then
    savedvel = phys:GetVelocity()
  end
  local ply = self:GetOwner()

  local trace = ply:GetEyeTrace()
  if SERVER then
    ply:SetScriptedVehicle(NULL)
    ply:SetClientsideVehicle(NULL)
    ply:SetMoveType(MOVETYPE_WALK)
    self:StopMotionController()
  end
  ply:SetParent(NULL)

  local ang = (trace.HitPos - ply:GetShootPos()):Angle()
  if SERVER then
    ply:SetEyeAngles(ang)
  end

  ply:SetVelocity(savedvel)

  self:SetNWBool("WCActive", false)
end

function ENT:GetCrawlOk(direction)

  local peekpos = Vector(0,0,0)
  peekpos = self:GetPos() - self:GetInvWallNormal();
  local movedir = Vector(0,0,0)
  movedir = direction * 10
  peekpos = peekpos + movedir;

  local tracedata = {}
  tracedata.start = peekpos
  tracedata.endpos = peekpos + (self:GetInvWallNormal() * 2)
  tracedata.filter = {self, self:GetOwner().Entity}
  local trace = {}
  trace = util.TraceLine(tracedata)

  if DebugWC then
    print('MovDir:'..tostring(movedir))
    print('MyPos:'..tostring(self:GetPos()))
    self:SetNWVector("sensor1_start", trace.StartPos)
    self:SetNWVector("sensor1_end", tracedata.endpos)
    self:SetNWVector("sensor1_hit", trace.HitPos)
  end
  if (tracedata.endpos == trace.HitPos) then

    return false
  else

    local tracedata2 = {}
    tracedata2.start = self:GetOwner():GetShootPos();
    tracedata2.endpos = tracedata2.start + (movedir * 7.3)
    tracedata2.filter = {self, self:GetOwner().Entity}
    local trace2 = util.TraceLine(tracedata2)
    if (tracedata2.endpos == trace2.HitPos) then

      return true
    else

      return false
    end
  end
end

function ENT:GetCrawlDirection(crawlKey)
  local ply = self:GetOwner()
  local newvec = self:GetUp()
  local aimrot = ply:GetAimVector()
  newvec = newvec:Cross(aimrot)

  if (crawlKey == IN_FORWARD) or (crawlKey == IN_BACK) then
    local leftangle = newvec:Angle()
    leftangle:RotateAroundAxis(self:GetUp(), -90)

    newvec = leftangle:Forward()
  end

  newvec = newvec:GetNormalized()

  if (crawlKey == IN_BACK) or (crawlKey == IN_MOVERIGHT) then

    newvec = newvec * -1
  end

  return newvec
end

function ENT:GetCrawlVector()
  local fwdDirection = Vector(0,0,0)
  local rightDirection = Vector(0,0,0)
  local ply = self:GetOwner()

  if (ply:KeyDown(IN_FORWARD)) then    fwdDirection = self:GetCrawlDirection(IN_FORWARD)
  elseif (ply:KeyDown(IN_BACK)) then
    fwdDirection = self:GetCrawlDirection(IN_BACK)
  end

  if (ply:KeyDown(IN_MOVELEFT)) then
    rightDirection = self:GetCrawlDirection(IN_MOVELEFT)
  elseif (ply:KeyDown(IN_MOVERIGHT)) then
    rightDirection = self:GetCrawlDirection(IN_MOVERIGHT)
  end

  return (fwdDirection + rightDirection):GetNormalized()
end

function ENT:PhysicsSimulate(phys, deltatime)
  local forceLinear = Vector(0,0,0)
  local forceAngle = Vector(0,0,0)
  local newDirection = Vector(0,0,0)
  local notAtEdge = true
  if self:IsActivated() then

    newDirection = self:GetCrawlVector()

    notAtEdge = self:GetCrawlOk(newDirection)
    forceLinear = newDirection * 30000 * deltatime
  end

  local additionalmax = 0

  if self:GetOwner():KeyDown(IN_SPEED) then
    forceLinear = forceLinear * 2
    additionalmax = 200
  end

  if not notAtEdge then
    forceLinear = Vector(0,0,0)
    phys:SetVelocity(forceLinear)
  end

  if (phys:GetVelocity():Length() > (1000 + additionalmax)) then
    forceLinear = Vector(0,0,0)
  end

  return forceAngle, forceLinear, SIM_GLOBAL_ACCELERATION
end

function ENT:WSADing()
  local ply = self:GetOwner()
  return ply:KeyDown(IN_FORWARD)
      or ply:KeyDown(IN_BACK)
      or ply:KeyDown(IN_MOVELEFT)
      or ply:KeyDown(IN_MOVERIGHT)
end

function ENT:PhysicsUpdate(phys)
  local ply = self:GetOwner()

  local newDirection = self:GetCrawlVector()

  if (self.LastDirection ~= newDirection) then
    local savevel = phys:GetVelocity()
    local vellen = savevel:Length()

    if (self.LastDirection == (newDirection * -1)) then
      vellen = vellen / 3
    end
    phys:SetVelocityInstantaneous(newDirection * vellen)
  end
  self.LastDirection = newDirection

  if not self:WSADing() then
    phys:SetVelocity(Vector(0,0,0))
  end

  if self:IsActivated() then
    ply:SetPos(self:GetPos() + (self:GetNWVector("wallinvnormal") * -73))
  end
end
