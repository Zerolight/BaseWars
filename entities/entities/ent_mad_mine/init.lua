AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self:SetDTEntity(0, (self.Owner or self:GetOwner()))
	self.Owner = self:GetDTEntity(0)

	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	self:SetDTBool(0, self.Activated or false)
	self.Boom = false

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end

	self.NextUse = CurTime()
	self:EmitSound(Sound("npc/roller/mine/combine_mine_deploy1.wav", 50, 100))

	undo.Create("Anti-Personal Mine")
		undo.AddEntity(self)
		undo.SetPlayer(self.Owner)
	undo.Finish()
end

function ENT:Use(activator, caller)

	local trace = activator:GetEyeTrace()

	local tracedata = {}
	tracedata.start = trace.Entity:GetPos()
	tracedata.endpos = Vector(trace.Entity:GetPos().x, trace.Entity:GetPos().y, trace.Entity:GetPos().z - 2)
	tracedata.filter = trace.Entity
	local tr = util.TraceLine(tracedata)

	local phys = self:GetPhysicsObject()

	if self.NextUse < CurTime() and activator == self.Owner then
		if not self:GetDTBool(0) then
			if tr.HitWorld then
				self:SetDTBool(0, true)
				self:EmitSound(Sound("npc/roller/mine/rmine_blip1.wav", 40, 100))
				phys:EnableMotion(false)
				phys:Sleep()

				activator:PrintMessage(HUD_PRINTTALK, "Mine activated.")
			else
				activator:PrintMessage(HUD_PRINTTALK, "You can't activate a mine which is not on the ground!")
				self:EmitSound(Sound("npc/roller/mine/rmine_blip3.wav", 40, 100))
			end
		else
			self:SetDTBool(0, false)
			self:EmitSound(Sound("npc/roller/mine/rmine_blip3.wav", 40, 100))
			phys:EnableMotion(true)
			phys:Wake()

			activator:PrintMessage(HUD_PRINTTALK, "Mine desactivated.")
		end

		self.NextUse = CurTime() + 1
	end
end

function ENT:Think()

	if self.Boom then
		self:Explosion()
	end

	for _, v in pairs(ents.FindInSphere(self:GetPos(), 14)) do
		if (v:IsPlayer() or v:IsNPC() or v:IsVehicle()) and self:GetDTBool(0) then

			if v:IsVehicle() then
				if v:GetDriver():IsValid() == false then return false end

				v:GetPhysicsObject():SetVelocity(Vector(0, 500, 750))
			end

			self:Explosion()
		end
	end
end

function ENT:Explosion()

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("HelicopterMegaBomb", effectdata)

	local explo = ents.Create("env_explosion")
		explo:SetOwner(self.Owner)
		explo:SetPos(self:GetPos())
		explo:SetKeyValue("iMagnitude", "150")
		explo:SetKeyValue("spawnflags", "66")
		explo:Spawn()
		explo:Activate()
		explo:Fire("Explode", "", 0)

	local shake = ents.Create("env_shake")
		shake:SetOwner(self.Owner)
		shake:SetPos(self:GetPos())
		shake:SetKeyValue("amplitude", "2000")
		shake:SetKeyValue("radius", "250")
		shake:SetKeyValue("duration", "2.5")
		shake:SetKeyValue("frequency", "255")
		shake:SetKeyValue("spawnflags", "4")
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)

	self:EmitSound(Sound("NPC_RollerMine.Shock"))

	self:Remove()
end
