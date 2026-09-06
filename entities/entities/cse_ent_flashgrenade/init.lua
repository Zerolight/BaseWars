AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self:SetModel("models/weapons/w_eq_flashbang.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Sleep()
	end

	self.timer = CurTime() + 1
	self.solidify = CurTime() + 1
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))==false) then
		self:Remove()
	end
	if (self.solidify<CurTime()) then
		self.SetOwner(self)
	end
	if self.timer < CurTime() then
		local pos = self:GetPos()
		local maxrange = 512
		local maxstun = 70
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
					v:ViewPunch( Angle( stunamount*((math.random()*4)-2), stunamount*((math.random()*4)-2), stunamount*((math.random()*2)-1) ) )
					StunPlayer(v, stunamount)
				end
			end
		end
		local exp = ents.Create("env_explosion")
			exp:SetKeyValue("spawnflags",461)
			exp:SetPos(pos)
		exp:Spawn()
		exp:Fire("explode","",0)
		self:EmitSound(Sound("Flashbang.Explode"))
		self:Remove()
	end
end
