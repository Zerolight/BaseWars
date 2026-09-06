AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end

end

function ENT:Think()

end
function ENT:OnRemove()
	if IsValid(self.Core) and not self.IsEngine and not self.IsPlate then

	end
end

function ENT:OnTakeDamage(dmg)
	if self.IsPlate==true or self.IsEngine==true then
		self:SetNWInt("damage", self:GetNWInt("damage")-dmg:GetDamage())
	end
	if self:GetNWInt("damage")<=0 and (self.IsPlate==true or self.IsEngine==true)then
		self:Explode()
		if self.IsEngine==true and IsValid(self.Core) then
			self.Core:EngineDied(dmg:GetAttacker())
		elseif self.IsPlate==true and IsValid(self.Core) then
			self.Core:PlateDied(self, dmg:GetAttacker())
		end
		self:Remove()
	end

end

function ENT:Explode()
	local effectdata = EffectData()
		effectdata:SetStart( self:GetPos() )
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 1 )
	util.Effect( "Explosion", effectdata )
end

function ENT:Plate()
	self:SetNWInt("damage", 500)
	self.IsPlate = true
end

function ENT:Engine()
	self:SetNWInt("damage", 1500)
	self.IsEngine = true
end

function ENT:TankWheel()
	local fakewheel = ents.Create( "svehicle_part_nosolid" )
	fakewheel:SetModel("models/props_wasteland/laundry_basket001.mdl")
	fakewheel:SetPos( self:GetPos() + self:GetAngles():Forward()*-5)
	fakewheel:SetAngles(self:GetAngles() + Angle(90,0,90))
	fakewheel:SetParent(self)
	fakewheel:Spawn()
	self.FakeWheel = fakewheel
end
