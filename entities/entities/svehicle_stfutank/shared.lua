ENT.Type 		= "anim"
ENT.Base 		= "base_gmodentity"

ENT.PrintName	= "STFU Tank"
ENT.Author		= "HLTV Proxy"
ENT.Contact		= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

function ENT:Initialize()
	util.PrecacheSound( "d1_canals.diesel_generator" )
	util.PrecacheSound( "d1_town.CarTrapMotorLoop" )
	util.PrecacheSound( "Town.d1_town_04_metal_solid_strain4" )
	util.PrecacheSound( "coast.crane_metal_groan" )
	util.PrecacheSound( "Doors.FullClose2" )

	self.sound_idle = CreateSound(self, Sound("d1_canals.diesel_generator"))
	self.sound_move = CreateSound(self, Sound("d1_town.CarTrapMotorLoop"))
	self.sound_open = CreateSound(self, Sound("Town.d1_town_04_metal_solid_strain4"))
	self.sound_load = CreateSound(self, Sound("coast.crane_metal_groan"))
	self.sound_lock = CreateSound(self, Sound("Doors.FullClose2"))

	self:SetModel( "models/props_wasteland/laundry_dryer002.mdl" )
	self:SetMaterial("models/props_combine/metal_combinebridge001")
	self:SetAngles(Angle(-90.00,180.00,180.00))
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNWInt("damage",25000)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.Plates = {}
	self.Wheels = {}

	self.GunParts = {}
	self.Driver = nil
	self.GunAngles = Angle(0,0,0)

	local max = self:OBBMaxs()
	local min = self:OBBMins()

	self.ThrustOffset 	= Vector( 0, 0, max.z )
	self.ThrustOffsetR 	= Vector( 0, 0, min.z )
	self.TThrustOffset 	= Vector( 0, max.y, 0 )
	self.TThrustOffsetR 	= Vector( 0, min.y, 0 )
	self.force = 950

	self:SetForceF(0)
	self:SetForceT(0)
	self.GoFoward = 0
	self.GoTurn = 0
	self:StartMotionController()
	self.LastFired = CurTime()
	self.LoadStage = 3
	self.PlateCount = 8

	self.sound_idle:Play()
end
