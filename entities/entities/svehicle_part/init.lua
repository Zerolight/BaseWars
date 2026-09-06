AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()

	end
end

function ENT:Think()

end
function ENT:OnRemove()
	if (IsValid(self.Core)) then

	end
end

function ENT:OnTakeDamage(dmg)

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

function ENT:Use(ply, caller)
	if IsValid(self.Core:GetPod()) then
		ply:EnterVehicle(self.Core:GetPod())
	end
end
