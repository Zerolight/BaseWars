AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self.Owner = (self.Owner or self:GetOwner())

	if not IsValid(self.Owner) then
		self:Remove()
		return
	end

	self:SetModel("models/weapons/w_slam.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)

	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end

	self.Timer = CurTime() + 1

	self:EmitSound("C4.Plant")
end

function ENT:Use(activator, caller)
end

function ENT:Think()

	if self.Timer < CurTime() then
		self:Explosion()
	end
end

function ENT:Explosion()

	local doorentities = ents.FindInSphere(self:GetPos(), 10)

	for k, v in pairs(doorentities) do
		if IsValid(v) and v:GetClass() == "prop_door_rotating" then
			v:Fire("open", "", 0.1)
			v:Fire("unlock", "", 0.1)

			local pos = v:GetPos()
			local ang = v:GetAngles()
			local model = v:GetModel()
			local skin = v:GetSkin()

			v:SetNotSolid(true)
			v:SetNoDraw(true)

			local function ResetDoor(door, fakedoor)
				door:SetNotSolid(false)
				door:SetNoDraw(false)
				fakedoor:Remove()
			end

			local norm = pos - (self:GetPos() + self:GetRight() * 100 + self:GetUp() * 400)
			if norm.z < 0 then norm.z = 0 end
			norm:Normalize()

			local push = 40000 * norm

			local ent = ents.Create("prop_physics")

			ent:SetPos(pos)
			ent:SetAngles(ang)
			ent:SetModel(model)

			if(skin) then
				ent:SetSkin(skin)
			end

			ent:Spawn()

			timer.Simple( 0.01, function() ent.SetVelocity( ent, push ) end )
			timer.Simple( 0.01, function() ent:GetPhysicsObject().ApplyForceCenter( ent:GetPhysicsObject(), push ) end )
			timer.Simple( 25, function() ResetDoor( v, ent ) end )
		end
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("HelicopterMegaBomb", effectdata)

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("effect_mad_door", effectdata)

	local shake = ents.Create("env_shake")
		shake:SetOwner(self.Owner)
		shake:SetPos(self:GetPos())
		shake:SetKeyValue("amplitude", "500")
		shake:SetKeyValue("radius", "500")
		shake:SetKeyValue("duration", "2.5")
		shake:SetKeyValue("frequency", "255")
		shake:SetKeyValue("spawnflags", "4")
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)

	self:EmitSound("doors/vent_open1.wav")

	self:Remove()
end
