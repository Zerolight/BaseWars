AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_trainstation/trainstation_post001.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetKeyValue("physdamagescale", "9999")
	self:SetKeyValue("effects", "4")
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self.CollisionGroup = COLLISION_GROUP_WORLD
	self:SetMaterial("Models/effects/comball_tape")

	self.Hammar = ents.Create("prop_dynamic_override")
	self.Hammar:SetModel("models/props_junk/plasticbucket001a.mdl")
	self.Hammar:SetPos(self:GetPos()+self:GetAngles():Up()*50)
	self.Hammar:SetAngles(Angle(90,0,0))
	self.Hammar:SetParent(self)
	self.Hammar:SetSolid(SOLID_NONE)
	self.Hammar:SetMoveType(MOVETYPE_NONE)
	self.Hammar:SetMaterial("Models/effects/comball_tape")

	self.Hammar2 = ents.Create("prop_dynamic_override")
	self.Hammar2:SetModel("models/props_junk/plasticbucket001a.mdl")
	self.Hammar2:SetPos(self:GetPos()+self:GetAngles():Up()*50)
	self.Hammar2:SetAngles(Angle(-90,0,0))
	self.Hammar2:SetParent(self)
	self.Hammar2:SetSolid(SOLID_NONE)
	self.Hammar2:SetMoveType(MOVETYPE_NONE)

	self.Hammar2:SetMaterial("Models/effects/comball_tape")
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
	end
	self.DidHit = false
	self.GoofyTiem = CurTime()

	self.Upgraded = false
	self.trueangles = self:GetAngles()
end

function ENT:Think()

	if (IsValid(self:GetOwner())==false or CurTime()-self.GoofyTiem>20) then
		local effectdata = EffectData()
		effectdata:SetStart(self:GetPos())
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(1.5)
		util.Effect("cball_bounce", effectdata)
		self:Fire("kill", "", 0)
		self:EmitSound(Sound("weapons/explode3.wav"))
		self:Remove()
	end
	local ang = self:GetAngles()
	local desang = ang
	desang:RotateAroundAxis(ang:Up(), 20)
	desang:RotateAroundAxis(ang:Right(), 60)
	self:SetAngles(desang)
	self.trueangles = self.trueangles + Angle(0,30,0)
	self:GetPhysicsObject():SetVelocity(self.trueangles:Forward()*(150+(CurTime()-self.GoofyTiem)*50))
	local traceshit = {}
		traceshit.start = self:GetPos()
		traceshit.endpos = self:GetPos()+self:GetAngles():Up()*60
		traceshit.filter = { self, self.Hammar, self.Hammar2, self:GetOwner() }
	traceshit = util.TraceLine(traceshit)
	if IsValid(traceshit.Entity) then
		traceshit.Entity:TakeDamage(80, self:GetOwner(), self)
	end
end

function ENT:OnRemove()
end

function ENT:PhysicsCollide( data, physobj )
	data.HitNormal = data.HitNormal*-150
	local start = data.HitPos+data.HitNormal
	local endpos = data.HitPos+data.HitNormal*-1
	util.Decal("Scorch",start,endpos)

  	self.DidHit = true
	self:GetPhysicsObject():SetVelocity(Angle(0,0,0))
end
function ENT:PhysicsUpdate()
	local traceshit = {}
		traceshit.start = self:GetPos()
		traceshit.endpos = self:GetPos()+self:GetAngles():Up()*60
		traceshit.filter = { self, self.Hammar, self.Hammar2, self:GetOwner() }
	traceshit = util.TraceLine(traceshit)
	if IsValid(traceshit.Entity) then
		traceshit.Entity:TakeDamage(80, self:GetOwner(), self)
	end
	if (self.DidHit == true) then
		local effectdata = EffectData()
		effectdata:SetStart(self:GetPos())
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(1.5)
		util.Effect("cball_bounce", effectdata)
		self:Fire("kill", "", 0)
		self:EmitSound(Sound("weapons/explode3.wav"))
		self:Remove()
	end
end

function ENT:Upgrade()
	self.Upgraded = true
end
