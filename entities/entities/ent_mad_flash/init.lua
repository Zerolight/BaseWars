AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local FLASH_INTENSITY = 3000

function ENT:Initialize()

	self.Owner = (self.Owner or self:GetOwner())
	self:SetNWBool("Explode", false)

	self:SetModel("models/weapons/w_eq_flashbang_thrown.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Explode()

	self:EmitSound(Sound("Flashbang.Explode"))

	for _, pl in pairs(player.GetAll()) do

		local ang = (self:GetPos() - pl:GetShootPos()):Normalize():Angle()

		local tracedata = {}

		tracedata.start = pl:GetShootPos()
		tracedata.endpos = self:GetPos()
		tracedata.filter = pl
		local tr = util.TraceLine(tracedata)

		if (not tr.HitWorld) then
			local dist = pl:GetShootPos():Distance(self:GetPos())
			local endtime = FLASH_INTENSITY / (dist * 2)

			if (endtime > 6) then
				endtime = 6
			elseif (endtime < 1) then
				endtime = 0
			end

			simpendtime = math.floor(endtime)
			tenthendtime = math.floor((endtime - simpendtime) * 10)

			pl:SetNWFloat("FLASHED_END", endtime + CurTime())

			pl:SetNWFloat("FLASHED_END_START", CurTime())
		end
	end

	self:Remove()
end

function ENT:OnTakeDamage()
end

function ENT:Use()
end

function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch()
end
