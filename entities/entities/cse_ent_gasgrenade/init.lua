AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self:SetModel("models/weapons/w_eq_smokegrenade.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Sleep()
	end

	self.timer = CurTime() + 6
	self.solidify = CurTime() + 1
	self.Bastardgas = nil
	self.Spammed = false
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	if (self.solidify<CurTime()) then
		self.SetOwner(self)
	end
	if self.timer < CurTime() then
		if not IsValid(self.Bastardgas) and not self.Spammed then
			self.Spammed = true
			self.Bastardgas = ents.Create("env_smoketrail")
			self.Bastardgas:SetPos(self:GetPos())
			self.Bastardgas:SetKeyValue("spawnradius","256")
			self.Bastardgas:SetKeyValue("minspeed","0.5")
			self.Bastardgas:SetKeyValue("maxspeed","2")
			self.Bastardgas:SetKeyValue("startsize","16536")
			self.Bastardgas:SetKeyValue("endsize","256")
			self.Bastardgas:SetKeyValue("endcolor","170 205 70")
			self.Bastardgas:SetKeyValue("startcolor","150 205 70")
			self.Bastardgas:SetKeyValue("opacity","4")
			self.Bastardgas:SetKeyValue("spawnrate","60")
			self.Bastardgas:SetKeyValue("lifetime","10")
			self.Bastardgas:SetParent(self)
			self.Bastardgas:Spawn()
			self.Bastardgas:Activate()
			self.Bastardgas:Fire("turnon","", 0.1)
			local exp = ents.Create("env_explosion")
			exp:SetKeyValue("spawnflags",461)
			exp:SetPos(self:GetPos())
			exp:Spawn()
			exp:Fire("explode","",0)
			self:EmitSound(Sound("BaseSmokeEffect.Sound"))
		end

		local pos = self:GetPos()
		local maxrange = 512
		local maxstun = 4
		for k,v in pairs(player.GetAll()) do
			local plpos = v:GetPos()
			local dist = -pos:Distance(plpos)+maxrange
			if (pos:Distance(plpos)<=maxrange) then
				local trace = {}
					trace.start = self:GetPos()
					trace.endpos = v:GetPos()+Vector(0,0,24)
					trace.filter = { v, self }
					trace.mask = COLLISION_GROUP_PLAYER
				tr = util.TraceLine(trace)
				if (tr.Fraction==1) then
					local stunamount = math.ceil(dist/(maxrange/maxstun))

					PoisonPlayer(v, stunamount, (self.Owner or self:GetOwner()), (self.Owner or self:GetOwner()):GetWeapon("weapon_gasgrenade"))
				end
			end
		end
		if (self.timer+5<CurTime()) then
			if IsValid(self.Bastardgas) then
				self.Bastardgas:Remove()
			end
		end
		if (self.timer+7<CurTime()) then
			self:Remove()
		end
		self:NextThink(CurTime()+0.5)
		return true
	end
end
