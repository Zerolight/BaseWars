SWEP.Base				= "weapon_mad_base"

SWEP.ShellEffect			= "effect_mad_shell_rifle"
SWEP.ShellDelay			= 1

SWEP.Pistol				= false
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= true

SWEP.Penetration			= true
SWEP.Ricochet			= true

local sndZoomIn 		= Sound("Weapon_AR2.Special1")
local sndZoomOut 		= Sound("Weapon_AR2.Special2")
local sndCycleZoom 	= Sound("Default.Zoom")

function SWEP:Precache()

	util.PrecacheSound("weapons/sniper/sniper_zoomin.wav")
	util.PrecacheSound("weapons/sniper/sniper_zoomout.wav")
	util.PrecacheSound("weapons/zoom.wav")
end

function SWEP:Initialize()

	if (SERVER) then
		self:SetWeaponHoldType(self.HoldType)

		self:SetNPCMinBurst(30)
		self:SetNPCMaxBurst(30)
		self:SetNPCFireRate(self.Primary.Delay)
	end

	if (CLIENT) then
		local iScreenWidth 	= surface.ScreenWidth()
		local iScreenHeight 	= surface.ScreenHeight()

		self.ScopeTable 		= {}
		self.ScopeTable.l 	= iScreenHeight * self.ScopeScale
		self.ScopeTable.x1 	= 0.5 * (iScreenWidth + self.ScopeTable.l)
		self.ScopeTable.y1 	= 0.5 * (iScreenHeight - self.ScopeTable.l)
		self.ScopeTable.x2 	= self.ScopeTable.x1
		self.ScopeTable.y2 	= 0.5 * (iScreenHeight + self.ScopeTable.l)
		self.ScopeTable.x3 	= 0.5 * (iScreenWidth - self.ScopeTable.l)
		self.ScopeTable.y3 	= self.ScopeTable.y2
		self.ScopeTable.x4 	= self.ScopeTable.x3
		self.ScopeTable.y4 	= self.ScopeTable.y1

		self.ParaScopeTable 	= {}
		self.ParaScopeTable.x 	= 0.5 * iScreenWidth - self.ScopeTable.l
		self.ParaScopeTable.y 	= 0.5 * iScreenHeight - self.ScopeTable.l
		self.ParaScopeTable.w 	= 2 * self.ScopeTable.l
		self.ParaScopeTable.h 	= 2 * self.ScopeTable.l

		self.ScopeTable.l 	= (iScreenHeight + 1) * self.ScopeScale

		self.QuadTable 		= {}
		self.QuadTable.x1 	= 0
		self.QuadTable.y1 	= 0
		self.QuadTable.w1 	= iScreenWidth
		self.QuadTable.h1 	= 0.5 * iScreenHeight - self.ScopeTable.l
		self.QuadTable.x2 	= 0
		self.QuadTable.y2 	= 0.5 * iScreenHeight + self.ScopeTable.l
		self.QuadTable.w2 	= self.QuadTable.w1
		self.QuadTable.h2 	= self.QuadTable.h1
		self.QuadTable.x3 	= 0
		self.QuadTable.y3 	= 0
		self.QuadTable.w3 	= 0.5 * iScreenWidth - self.ScopeTable.l
		self.QuadTable.h3 	= iScreenHeight
		self.QuadTable.x4 	= 0.5 * iScreenWidth + self.ScopeTable.l
		self.QuadTable.y4 	= 0
		self.QuadTable.w4 	= self.QuadTable.w3
		self.QuadTable.h4 	= self.QuadTable.h3

		self.LensTable 		= {}
		self.LensTable.x 		= self.QuadTable.w3
		self.LensTable.y 		= self.QuadTable.h1
		self.LensTable.w 		= 2 * self.ScopeTable.l
		self.LensTable.h 		= 2 * self.ScopeTable.l

		self.CrossHairTable 	= {}
		self.CrossHairTable.x11 = 0
		self.CrossHairTable.y11 = 0.5 * iScreenHeight
		self.CrossHairTable.x12 = iScreenWidth
		self.CrossHairTable.y12 = self.CrossHairTable.y11
		self.CrossHairTable.x21 = 0.5 * iScreenWidth
		self.CrossHairTable.y21 = 0
		self.CrossHairTable.x22 = 0.5 * iScreenWidth
		self.CrossHairTable.y22 = iScreenHeight
	end

	self.ScopeZooms 			= self.ScopeZooms or {5}
	self.CurScopeZoom			= 1

	self:ResetVariables()
end

function SWEP:ResetVariables()

	self.bLastIron = false
	self:SetDTBool(1, false)

	self.CurScopeZoom 		= 1
	self.fLastScopeZoom 		= 1
	self.bLastScope 			= false

	self:SetDTBool(2, false)
	self:SetNWFloat("ScopeZoom", self.ScopeZooms[1])

	if (self:GetOwner()) then
		self.OwnerIsNPC 		= self:GetOwner():IsNPC()
	end
end

function SWEP:Reload()

	if (self.ActionDelay > CurTime()) then return end

	self:DefaultReload(ACT_VM_RELOAD)

	if (IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()) then
		self:IdleAnimation(self:GetOwner():GetViewModel():SequenceDuration())
	end

	if (self:Clip1() < self.Primary.ClipSize) and (self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0) then
		self:SetIronsights(false)
		self:ReloadAnimation()

		self:ResetVariables()

		if not (CLIENT) then
			self:GetOwner():DrawViewModel(true)
		end
	end
end

function SWEP:PrimaryAttack()

	if (not self:GetOwner():IsNPC() and self:GetOwner():KeyDown(IN_USE)) then
		bHolsted = not self:GetDTBool(0)
		self:SetHolsted(bHolsted)

		self:SetNextPrimaryFire(CurTime() + 0.3)
		self:SetNextSecondaryFire(CurTime() + 0.3)

		self:SetIronsights(false)

		return
	end

	if (not self:CanPrimaryAttack()) then return end

	self.ActionDelay = (CurTime() + self.Primary.Delay + 0.05)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	if self:GetNWBool("Burst") then
		self.BurstTimer 	= CurTime()
		self.BurstCounter = self.BurstShots - 1
		self:SetNextPrimaryFire(CurTime() + 0.5)
	end

	if (not self:GetOwner():IsNPC()) and (self.BoltActionSniper) and (self:GetDTBool(1)) then
		self:ResetVariables()
		self.ScopeAfterShoot = true

		timer.Simple(self.Primary.Delay, function()
			if not self:GetOwner() then return end

			if (self.ScopeAfterShoot) and (self:Clip1() > 0) then
				self:SetNextPrimaryFire(CurTime() + 0.2)
				self:SetNextSecondaryFire(CurTime() + 0.2)
				self:SetIronsights(true)
			end
		end)
	end

	self:EmitSound(self.Primary.Sound)

	self:TakePrimaryAmmo(1)

	self:ShootBulletInformation()
end

local LastViewAng = false

local function SimilarizeAngles(ang1, ang2)

	ang1.y = math.fmod (ang1.y, 360)
	ang2.y = math.fmod (ang2.y, 360)

	if math.abs (ang1.y - ang2.y) > 180 then
		if ang1.y - ang2.y < 0 then
			ang1.y = ang1.y + 360
		else
			ang1.y = ang1.y - 360
		end
	end
end

local function ReduceScopeSensitivity(uCmd)

	if LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():IsValid() then
		local newAng = uCmd:GetViewAngles()

		if LastViewAng then
			SimilarizeAngles (LastViewAng, newAng)

			local diff = newAng - LastViewAng

			diff = diff * (LocalPlayer():GetActiveWeapon().MouseSensitivity or 1)
			uCmd:SetViewAngles (LastViewAng + diff)
		end
	end

	LastViewAng = uCmd:GetViewAngles()
end
hook.Add ("CreateMove", "ReduceScopeSensitivity", ReduceScopeSensitivity)

local IRONSIGHT_TIME = 0.2

function SWEP:SetIronsights(b)

	if (CLIENT) then return end

	if (self) then
		self:SetDTBool(1, b)
	end

	if (b) then
		timer.Simple( IRONSIGHT_TIME, function() self.SetScope( self, true, player ) end )
	else
		self:SetScope(false, player)
	end
end

function SWEP:SetScope(b, player)

	if CLIENT then return end

	local PlaySound = b ~= self:GetDTBool(2)
	self.CurScopeZoom = 1
	self:SetNWFloat("ScopeZoom", self.ScopeZooms[self.CurScopeZoom])

	if (b) then
		if (PlaySound) then
			self:EmitSound(sndZoomIn)
		end
	else
		if PlaySound then
			self:EmitSound(sndZoomOut)
		end
	end

	self:SetDTBool(2, b)
end

function SWEP:Think()

	self:SecondThink()

	if self.IdleDelay < CurTime() and self.IdleApply and self:Clip1() > 0 then
		local WeaponModel = self:GetOwner():GetActiveWeapon():GetClass()

		if self:GetOwner():GetActiveWeapon():GetClass() == WeaponModel and self:GetOwner():Alive() then
			if self:GetNWBool("Suppressor") then
				self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
			else
				self:SendWeaponAnim(ACT_VM_IDLE)
			end

			if self.AllowPlaybackRate and not self:GetDTBool(1) then
				self:GetOwner():GetViewModel():SetPlaybackRate(1)
			else
				self:GetOwner():GetViewModel():SetPlaybackRate(0)
			end
		end

		self.IdleApply = false
	elseif self:Clip1() <= 0 then
		self.IdleApply = false
	end

	if (self:GetDTBool(1) or self:GetDTBool(2)) and self:GetOwner():KeyDown(IN_SPEED) then
		self:ResetVariables()
		self:GetOwner():SetFOV(0, 0.2)
	end

	if (self.BoltActionSniper) and (self:GetOwner():KeyPressed(IN_ATTACK2) or self:GetOwner():KeyPressed(IN_RELOAD)) then
		self.ScopeAfterShoot = false
	end

	if self:GetOwner():KeyDown(IN_SPEED) or self:GetDTBool(0) then
		if (self.BoltActionSniper) then
			self.ScopeAfterShoot = false
		end

		if self.Rifle or self.Sniper or self.Shotgun then
			if (SERVER) then
				self:SetWeaponHoldType("passive")
			end
		elseif self.Pistol then
			if (SERVER) then
				self:SetWeaponHoldType("normal")
			end
		end
	else
		if (SERVER) then
			self:SetWeaponHoldType(self.HoldType)
		end
	end

	if self:GetNWBool("Burst") then
		if self.BurstTimer + self.BurstDelay < CurTime() then
			if self.BurstCounter > 0 then
				self.BurstCounter = self.BurstCounter - 1
				self.BurstTimer = CurTime()

				if self:CanPrimaryAttack() then
					self:EmitSound(self.Primary.Sound)
					self:ShootBulletInformation()
					self:TakePrimaryAmmo(1)
				end
			end
		end
	end

	if (CLIENT) and (self:GetDTBool(2)) then
		self.MouseSensitivity = self:GetOwner():GetFOV() / 60
	else
		self.MouseSensitivity = 1
	end

	if not (CLIENT) and (self:GetDTBool(2)) and (self:GetDTBool(1)) then
		self:GetOwner():DrawViewModel(false)
	elseif not (CLIENT) then
		self:GetOwner():DrawViewModel(true)
	end

	self:NextThink(CurTime())
end

function SWEP:Holster()

	self:ResetVariables()

	return true
end

function SWEP:OnRemove()

	self:ResetVariables()

	return true
end

function SWEP:OwnerChanged()

	self:ResetVariables()

	return true
end
