include('shared.lua')

SWEP.PrintName			= "#GMOD_Camera"
SWEP.Slot				= 5
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/gmod_camera" )

function SWEP:DrawHUD() end
function SWEP:PrintWeaponInfo( x, y, alpha ) end

function SWEP:HUDShouldDraw( name )

	if (name == "CHudWeaponSelection") then return true end

	return false;

end

function SWEP:FreezeMovement()

	if ( self.m_fFreezeMovement ) then

		if ( self.m_fFreezeMovement > RealTime() ) then return true end

		self.m_fFreezeMovement = nil

	end

	if ( self:GetOwner():KeyDown( IN_ATTACK2 ) or self:GetOwner():KeyReleased( IN_ATTACK2 ) ) then return true end
	return false

end

function SWEP:CalcView( ply, origin, angles, fov )

	if ( self.Roll ~= 0 ) then
		angles.Roll = self.Roll
	end

	if (not self.TrackEntity or not self.TrackEntity:IsValid()) then return origin, angles, fov end

	local AimPos = self.TrackEntity:GetPos()

	self.LastAngles = self.LastAngles or angles

	if ( self.TrackOffset ) then

		local Distance = AimPos:Distance( self:GetOwner():GetShootPos() )

		AimPos = AimPos + Vector(0,0,1) * self.TrackOffset.y * 256
		AimPos = AimPos + self.LastAngles:Right() * self.TrackOffset.x * 256

	end

	local AimNormal = AimPos - self:GetOwner():GetShootPos()
	AimNormal:Normalize()

	angles = AimNormal:Angle()

	self:GetOwner():SetEyeAngles( Angle( angles.Pitch, angles.Yaw, 0 ) )

	self.LastAngles = angles

	if ( self.Roll ~= 0 ) then
		angles.Roll = self.Roll
	end

	return origin, angles, fov

end

function SWEP:DoRotateThink( cmd, fDelta )

	if ( self:GetOwner():KeyDown( IN_ATTACK2 ) ) then

		self.Roll = self.Roll + cmd:GetMouseX() * 0.5 * fDelta

	end

	if ( self:GetOwner():KeyReleased( IN_ATTACK2 ) ) then

		self.m_fFreezeMovement = RealTime() + 0.1

	end

	if ( self.TrackEntity and self.TrackEntity ~= NULL and not self:GetOwner():KeyDown( IN_ATTACK2 ) ) then

		self.TrackOffset = self.TrackOffset or Vector(0,0,0)

		local cmd = self:GetOwner():GetCurrentCommand()
		self.TrackOffset.x = math.Clamp( self.TrackOffset.x + cmd:GetMouseX() * 0.005 * fDelta, -0.5, 0.5 )
		self.TrackOffset.y = math.Clamp( self.TrackOffset.y - cmd:GetMouseY() * 0.005 * fDelta, -0.5, 0.5 )

	end

	if ( self:GetOwner():KeyDown( IN_USE ) and not self.TrackEntity ) then

		self.TrackEntity = self:GetOwner():GetEyeTrace().Entity
		if ( self.TrackEntity and not self.TrackEntity:IsValid() ) then

			self.TrackEntity = nil
			self.LastAngles = nil
			self.TrackOffset = nil

		end

	end

	if ( self:GetOwner():KeyReleased( IN_USE ) ) then

		self.TrackEntity = nil
		self.LastAngles = nil
		self.TrackOffset = nil

	end

	if ( self:GetOwner():KeyPressed( IN_RELOAD ) ) then

		self:Reload()

	end

end

function SWEP:TranslateFOV( current_fov )

	return self.CameraZoom

end

function SWEP:AdjustMouseSensitivity()

	if ( self:GetOwner():KeyDown( IN_ATTACK2 )  ) then return 1 end

	return 1 * ( self.CameraZoom / 80 )

end
