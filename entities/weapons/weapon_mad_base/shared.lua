local RecoilMul = CreateConVar ("mad_recoilmul", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local DamageMul = CreateConVar ("mad_damagemul", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

SWEP.Category			= "Mad Cows Weapons"

SWEP.Author				= "Worshipper"
SWEP.Contact			= "Josephcadieux@hotmail.com"

SWEP.Purpose			= ""
SWEP.Instructions			= ""

SWEP.ViewModelFOV			= 60
SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.AnimPrefix			= "python"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound		= Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil		= 10
SWEP.Primary.Damage		= 10
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay 		= 0

SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ActionDelay			= CurTime()

SWEP.DeployDelay			= 1

SWEP.ShellEffect			= "effect_mad_shell_pistol"
SWEP.ShellDelay			= 0

SWEP.Pistol				= false
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.IronSightsPos 		= Vector (0, 0, 0)
SWEP.IronSightsAng 		= Vector (0, 0, 0)
SWEP.RunArmOffset 		= Vector (0, 0, 5.5)
SWEP.RunArmAngle 			= Vector (-35, -3, 0)

SWEP.Burst				= false
SWEP.BurstShots			= 3
SWEP.BurstDelay			= 0.05
SWEP.BurstCounter			= 0
SWEP.BurstTimer			= 0

SWEP.Type				= 1
SWEP.Mode				= false

SWEP.data 				= {}
SWEP.data.NormalMsg		= "Switched to semi-automatic."
SWEP.data.ModeMsg			= "Switched to automatic."
SWEP.data.Delay			= 0.5
SWEP.data.Cone			= 1
SWEP.data.Damage			= 1
SWEP.data.Recoil			= 1
SWEP.data.Automatic		= false

SWEP.ConstantAccuracy		= false

SWEP.Penetration			= true
SWEP.Ricochet			= true
SWEP.MaxRicochet			= 1

SWEP.Tracer				= 0

SWEP.IdleDelay			= 0
SWEP.IdleApply			= false
SWEP.AllowIdleAnimation		= true
SWEP.AllowPlaybackRate		= true

SWEP.BoltActionSniper		= false
SWEP.ScopeAfterShoot		= false

SWEP.IronSightZoom 		= 1.5
SWEP.ScopeZooms			= {10}
SWEP.ScopeScale 			= 0.4

SWEP.ShotgunReloading		= false
SWEP.ShotgunFinish		= 0.5
SWEP.ShotgunBeginReload		= 0.3

function SWEP:Initialize()

	if (SERVER) then
		self:SetWeaponHoldType(self.HoldType)

		self:SetNPCMinBurst(30)
		self:SetNPCMaxBurst(30)
		self:SetNPCFireRate(self.Primary.Delay)
	end
end

function SWEP:Precache()

	util.PrecacheSound("weapons/clipempty_pistol.wav")
end

function SWEP:SetupDataTables()

	self:DTVar("Bool", 0, "Holsted")
	self:DTVar("Bool", 1, "Ironsights")
	self:DTVar("Bool", 2, "Scope")
	self:DTVar("Bool", 3, "Mode")
end

function SWEP:IdleAnimation(time)

	if not self.AllowIdleAnimation then return false end

	self.IdleApply = true
	self.ActionDelay = CurTime() + time
	self.IdleDelay = CurTime() + time
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
    if self:GetOwner():GetNWBool("doubletapped") then
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay*drugeffect_doubletapmod )
	else
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	end
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	if self:GetDTBool(3) and self.Type == 3 then
		self.BurstTimer 	= CurTime()
		self.BurstCounter = self.BurstShots - 1
		self:SetNextPrimaryFire(CurTime() + 0.5)
	end

	self:EmitSound(self.Primary.Sound)

	self:TakePrimaryAmmo(1)

	self:ShootBulletInformation()
end

function SWEP:SecondaryAttack()

	if self:GetOwner():IsNPC() then return end
	if not IsFirstTimePredicted() then return end

	if (self:GetOwner():KeyDown(IN_USE) and (self.Mode)) then
		bMode = not self:GetDTBool(3)
		self:SetMode(bMode)
		self:SetIronsights(false)

		self:SetNextPrimaryFire(CurTime() + self.data.Delay)
		self:SetNextSecondaryFire(CurTime() + self.data.Delay)

		return
	end

	if (not self.IronSightsPos) or (self:GetOwner():KeyDown(IN_SPEED) or self:GetDTBool(0)) then return end

	bIronsights = not self:GetDTBool(1)
	self:SetIronsights(bIronsights)

	self:SetNextPrimaryFire(CurTime() + 0.2)
	self:SetNextSecondaryFire(CurTime() + 0.2)
end

function SWEP:SetHolsted(b)

	if (self:GetOwner()) then
		if (b) then
			self:EmitSound("weapons/universal/iron_in.wav")
		else
			self:EmitSound("weapons/universal/iron_out.wav")
		end
	end

	if (self) then
		self:SetDTBool(0, b)
	end
end

function SWEP:SetIronsights(b)

	if (self:GetOwner()) then
		if (b) then
			if (SERVER) then
				self:GetOwner():SetFOV(65, 0.2)
			end

			if self.AllowIdleAnimation then
				if self:GetDTBool(3) and self.Type == 2 then
					self:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
				else
					self:SendWeaponAnim(ACT_VM_IDLE)
				end

				self:GetOwner():GetViewModel():SetPlaybackRate(0)
			end

			self:EmitSound("weapons/universal/iron_in.wav")
		else
			if (SERVER) then
				self:GetOwner():SetFOV(0, 0.2)
			end

			if self.AllowPlaybackRate and self.AllowIdleAnimation then
				self:GetOwner():GetViewModel():SetPlaybackRate(1)
			end

			self:EmitSound("weapons/universal/iron_out.wav")
		end
	end

	if (self) then
		self:SetDTBool(1, b)
	end
end

function SWEP:SetMode(b)

	if (self:GetOwner()) then
		if (b) then
			if self.Type == 1 then
				self.Primary.Automatic = self.data.Automatic
				self:EmitSound("weapons/smg1/switch_burst.wav")
			elseif self.Type == 2 then
				self:SendWeaponAnim(ACT_VM_ATTACH_SILENCER)
				self.Primary.Sound = Sound(self.Primary.SuppressorSound)

				if (IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()) then
					self:IdleAnimation(self:GetOwner():GetViewModel():SequenceDuration())
				end
			elseif self.Type == 3 then
				self:EmitSound("weapons/smg1/switch_burst.wav")
			end

			if (SERVER) then
				self:GetOwner():PrintMessage(HUD_PRINTTALK, self.data.ModeMsg)
			end
		else
			if self.Type == 1 then
				self.Primary.Automatic = not self.data.Automatic
				self:EmitSound("weapons/smg1/switch_single.wav")
			elseif self.Type == 2 then
				self:SendWeaponAnim(ACT_VM_DETACH_SILENCER)
				self.Primary.Sound = Sound(self.Primary.NoSuppressorSound)

				if (IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()) then
					self:IdleAnimation(self:GetOwner():GetViewModel():SequenceDuration())
				end
			elseif self.Type == 3 then

				self:EmitSound("weapons/smg1/switch_single.wav")
			end

			if (SERVER) then
				self:GetOwner():PrintMessage(HUD_PRINTTALK, self.data.NormalMsg)
			end
		end
	end

	if (self) then
		self:SetDTBool(3, b)
	end
end

function SWEP:CheckReload()
end

function SWEP:Reload()

	if (self.ActionDelay > CurTime()) then return end

	self:DefaultReload(ACT_VM_RELOAD)

	if (self:Clip1() < self.Primary.ClipSize) and (self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0) then
		self:SetIronsights(false)
		self:ReloadAnimation()
	end
end

function SWEP:ReloadAnimation()

	if self:GetDTBool(3) and self.Type == 2 then
		self:DefaultReload(ACT_VM_RELOAD_SILENCED)
	else
		self:DefaultReload(ACT_VM_RELOAD)
	end

	if (IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()) then
		self:IdleAnimation(self:GetOwner():GetViewModel():SequenceDuration())
	end
end

function SWEP:SecondThink()
end

function SWEP:Think()

	self:SecondThink()

	if self:Clip1() > 0 and self.IdleDelay < CurTime() and self.IdleApply then
		local WeaponModel = self:GetOwner():GetActiveWeapon():GetClass()

		if self:GetOwner() and self:GetOwner():GetActiveWeapon():GetClass() == WeaponModel and self:GetOwner():Alive() then
			if self:GetDTBool(3) and self.Type == 2 then
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

	if self:GetDTBool(1) and self:GetOwner():KeyDown(IN_SPEED) then
		self:SetIronsights(false)
	end

	if self:GetOwner():KeyDown(IN_SPEED) or self:GetDTBool(0) then
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

	if self:GetDTBool(3) and self.Type == 3 then
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

	self:NextThink(CurTime())
end

function SWEP:Holster()

	return true
end

function SWEP:Deploy()

	self:DeployAnimation()

	if (IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()) then
		self:IdleAnimation(self:GetOwner():GetViewModel():SequenceDuration())
	end

	self:SetNextPrimaryFire(CurTime() + self.DeployDelay + 0.05)
	self:SetNextSecondaryFire(CurTime() + self.DeployDelay + 0.05)
	self.ActionDelay = (CurTime() + self.DeployDelay + 0.05)

	self:SetIronsights(false)

	return true
end

function SWEP:DeployAnimation()

	if self:GetDTBool(3) and self.Type == 2 then
		self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
	else
		self:SendWeaponAnim(ACT_VM_DRAW)
	end
end

SWEP.SprayTime 		= 0.1
SWEP.SprayAccuracy 	= 0.2

function SWEP:CrosshairAccuracy()

	if (self.ConstantAccuracy) or (self:GetOwner():IsNPC()) then
		return 1.0
	end

	local LastAccuracy 	= self.LastAccuracy or 0
	local Accuracy 		= 1.0
	local LastShoot 		= self:GetNWFloat("LastShootTime", 0)

	local Speed 		= self:GetOwner():GetVelocity():Length()

	local SpeedClamp = math.Clamp(math.abs(Speed / 705), 0, 1)

    if (self:GetOwner():GetNWBool("focused")) then
		Accuracy = Accuracy * 5
	end

	if (CurTime() <= LastShoot + self.SprayTime) then
		Accuracy = Accuracy * self.SprayAccuracy
	end

	if (not self:GetOwner():IsOnGround()) then
		Accuracy = Accuracy * 0.1
	elseif (Speed > 10) then
		Accuracy = Accuracy * (((1 - SpeedClamp) + 0.1) / 2)
	end

	if (LastAccuracy ~= 0) then
		if (Accuracy > LastAccuracy) then
			Accuracy = math.Approach(self.LastAccuracy, Accuracy, FrameTime() * 2)
		else
			Accuracy = math.Approach(self.LastAccuracy, Accuracy, FrameTime() * -2)
		end
	end

	self.LastAccuracy = Accuracy
	return math.Clamp(Accuracy, 0.2, 1)
end

function SWEP:ShootBulletInformation()

	local CurrentDamage
	local CurrentRecoil
	local CurrentCone

	if self:GetDTBool(3) then
		CurrentDamage = self.Primary.Damage * self.data.Damage * DamageMul:GetFloat()
		CurrentRecoil = self.Primary.Recoil * self.data.Recoil * RecoilMul:GetFloat()
		CurrentCone = self.Primary.Cone * self.data.Cone
	else
		CurrentDamage = self.Primary.Damage * DamageMul:GetFloat()
		CurrentRecoil = self.Primary.Recoil * RecoilMul:GetFloat()
		CurrentCone = self.Primary.Cone
	end

	if self:GetOwner():IsNPC() then
		self:ShootBullet(CurrentDamage, CurrentRecoil, self.Primary.NumShots, self.Primary.Cone)
		return
	end

	if self:GetOwner():GetNWInt("Fuel") > 0 then
		CurrentDamage = CurrentDamage * 1.25
	end

	if not self:GetOwner():IsOnGround() then

		if (self:GetDTBool(1)) then
			self:ShootBullet(CurrentDamage, CurrentRecoil, self.Primary.NumShots, CurrentCone)
			self:GetOwner():ViewPunch(Angle(math.Rand(-0.75, -1.0) * (CurrentRecoil), math.Rand(-1, 1) * (CurrentRecoil), 0))

		else
			self:ShootBullet(CurrentDamage, CurrentRecoil * 2.5, self.Primary.NumShots, CurrentCone)
			self:GetOwner():ViewPunch(Angle(math.Rand(-0.75, -1.0) * (CurrentRecoil * 2.5), math.Rand(-1, 1) * (CurrentRecoil * 2.5), 0))
		end

	elseif self:GetOwner():KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) then

		if (self:GetDTBool(1)) then
			self:ShootBullet(CurrentDamage, CurrentRecoil / 2, self.Primary.NumShots, CurrentCone)
			self:GetOwner():ViewPunch(Angle(math.Rand(-0.75, -1.0) * (CurrentRecoil / 1.5), math.Rand(-1, 1) * (CurrentRecoil / 1.5), 0))

		else
			self:ShootBullet(CurrentDamage, CurrentRecoil * 1.5, self.Primary.NumShots, CurrentCone)
			self:GetOwner():ViewPunch(Angle(math.Rand(-0.75, -1.0) * (CurrentRecoil * 1.5), math.Rand(-1, 1) * (CurrentRecoil * 1.5), 0))
		end

	elseif self:GetOwner():Crouching() then

		if (self:GetDTBool(1)) then
			self:ShootBullet(CurrentDamage, 0, self.Primary.NumShots, CurrentCone)
			self:GetOwner():ViewPunch(Angle(math.Rand(-0.75, -1.0) * (CurrentRecoil / 3), math.Rand(-1, 1) * (CurrentRecoil / 3), 0))

		else
			self:ShootBullet(CurrentDamage, CurrentRecoil / 2, self.Primary.NumShots, CurrentCone)
			self:GetOwner():ViewPunch(Angle(math.Rand(-0.75, -1.0) * (CurrentRecoil / 2), math.Rand(-1, 1) * (CurrentRecoil / 2), 0))
		end

	else

		if (self:GetDTBool(1)) then
			self:ShootBullet(CurrentDamage, CurrentRecoil / 6, self.Primary.NumShots, CurrentCone)
			self:GetOwner():ViewPunch(Angle(math.Rand(-0.75, -1.0) * (CurrentRecoil / 2), math.Rand(-1, 1) * (CurrentRecoil / 2), 0))

		else
			self:ShootBullet(CurrentDamage, CurrentRecoil, self.Primary.NumShots, CurrentCone)
			self:GetOwner():ViewPunch(Angle(math.Rand(-0.75, -1.0) * CurrentRecoil, math.Rand(-1, 1) * CurrentRecoil, 0))
		end
	end
end

function SWEP:ShootEffects()

	if not self:GetOwner():IsNPC() then
		self:ShootAnimation()
	end

	if (IsValid(self:GetOwner()) and self:GetOwner():GetViewModel()) then
		self:IdleAnimation(self:GetOwner():GetViewModel():SequenceDuration())
	end

	local WeaponModel = self:GetOwner():GetActiveWeapon():GetClass()

	if (not self:GetOwner():IsNPC() and self:Clip1() < 1) then
		timer.Simple(self:GetOwner():GetViewModel():SequenceDuration(), function()
			if self:GetOwner() and self:GetOwner():Alive() and self:GetOwner():GetActiveWeapon():GetClass() == WeaponModel then
				self.ActionDelay = CurTime()
				self:Reload()
			end
		end)
	end

	self:GetOwner():MuzzleFlash()
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetOwner():GetShootPos())
		effectdata:SetEntity(self)
		effectdata:SetStart(self:GetOwner():GetShootPos())
		effectdata:SetNormal(self:GetOwner():GetAimVector())
		effectdata:SetAttachment(1)

	timer.Simple(0, function()
		if not self:GetOwner() then return end
		if not IsFirstTimePredicted() then return end

		if (self.Shotgun) then
			util.Effect("effect_mad_shotgunsmoke", effectdata)
		else
			util.Effect("effect_mad_gunsmoke", effectdata)
		end
	end)

	timer.Simple(self.ShellDelay, function()
		if not self:GetOwner() then return end
		if not IsFirstTimePredicted() then return end
		if not self:GetOwner():IsNPC() and not self:GetOwner():Alive() then return end

		local effectdata = EffectData()
			effectdata:SetEntity(self)
			effectdata:SetNormal(self:GetOwner():GetAimVector())
			effectdata:SetAttachment(2)
		util.Effect(self.ShellEffect, effectdata)
	end)

	if self:GetOwner():IsNPC() then return end

	local trace = self:GetOwner():GetEyeTrace()

	if trace.HitPos:Distance(self:GetOwner():GetShootPos()) < 250 and self.Shotgun then
		if trace.Entity:GetClass() == "prop_door_rotating" and (SERVER) then

			trace.Entity:Fire("open", "", 0.1)
			trace.Entity:Fire("unlock", "", 0.1)

			local pos = trace.Entity:GetPos()
			local ang = trace.Entity:GetAngles()
			local model = trace.Entity:GetModel()
			local skin = trace.Entity:GetSkin()

			trace.Entity:SetNotSolid(true)
			trace.Entity:SetNoDraw(true)

			local function ResetDoor(door, fakedoor)
				if IsValid(door) then
					door:SetNotSolid(false)
					door:SetNoDraw(false)
				end
				if IsValid(fakedoor) then fakedoor:Remove() end
			end

			local norm = (pos - self:GetOwner():GetPos()):GetNormalized()
			local push = 10000 * norm
			local ent = ents.Create("prop_physics")

			ent:SetPos(pos)
			ent:SetAngles(ang)
			ent:SetModel(model)

			if(skin) then
				ent:SetSkin(skin)
			end

			ent:Spawn()

			timer.Simple( 0.01, function() if IsValid(ent) then ent:SetVelocity( push ) end end )
			timer.Simple( 0.01, function()
				if not IsValid(ent) then return end
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then phys:ApplyForceCenter( push ) end
			end )
			timer.Simple( 25, function() ResetDoor( trace.Entity, ent ) end )
		end
	end

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self:SetNWFloat("LastShootTime", CurTime())
	end
end

function SWEP:ShootFire(attacker, tr, dmginfo)

	self:GetOwner():SetNWInt("Fuel", math.Clamp(self:GetOwner():GetNWInt("Fuel") - (math.random(1, 3) / self.Primary.NumShots), 0, 100))

	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos)
	effectdata:SetNormal(tr.HitNormal)
	effectdata:SetScale(20)
	util.Effect("effect_mad_firehit", effectdata)

	util.Decal("FadingScorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

	local random = (1 / self.Primary.Delay) * (self.Primary.NumShots * (self.Primary.NumShots / 4))

	if math.random(0, random) < 1 then
		if tr.Entity:GetPhysicsObject():IsValid() and not tr.Entity:IsPlayer() then
			tr.Entity:Ignite(math.random(5, 20), 0)

			local tracedata = {}
			tracedata.start = tr.HitPos
			tracedata.endpos = Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z - 10)
			tracedata.filter = tr.HitPos
			local tracedata = util.TraceLine(tracedata)

			if tracedata.HitWorld then
				local fire = ents.Create("env_fire")
				fire:SetPos(tr.HitPos)
				fire:SetKeyValue("health", math.random(5, 15))
				fire:SetKeyValue("firesize", "8")
				fire:SetKeyValue("fireattack", "10")
				fire:SetKeyValue("damagescale", "1.0")
				fire:SetKeyValue("StartDisabled", "0")
				fire:SetKeyValue("firetype", "0")
				fire:SetKeyValue("spawnflags", "128")
				fire:Spawn()
				fire:Fire("StartFire", "", 0)
			end
		end
	end
end

function SWEP:ShootAnimation()

	local AllowDryFire = self:GetOwner():GetActiveWeapon():GetClass() == ("weapon_mad_deagle")
				   or self:GetOwner():GetActiveWeapon():GetClass() == ("weapon_mad_usp")
				   or self:GetOwner():GetActiveWeapon():GetClass() == ("weapon_mad_usp_match")

	if (self:Clip1() <= 0) then
		if (AllowDryFire) then
			if self:GetDTBool(3) and self.Type == 2 then
				self:SendWeaponAnim(ACT_VM_DRYFIRE_SILENCED)
			else
				self:SendWeaponAnim(ACT_VM_DRYFIRE)
			end
		elseif self:GetDTBool(3) and self.Type == 2 then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
		else
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		end
	else
		if self:GetDTBool(3) and self.Type == 2 then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
		else
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		end
	end
end

local TracerName = "Tracer"

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone)

	num_bullets 		= num_bullets or 1
	aimcone 			= aimcone or 0

	self:ShootEffects()

	if self.Tracer == 1 then
		TracerName = "Ar2Tracer"
	elseif self.Tracer == 2 then
		TracerName = "AirboatGunHeavyTracer"
	else
		TracerName = "Tracer"
	end

	local bullet = {}
		bullet.Num 		= num_bullets
		bullet.Src 		= self:GetOwner():GetShootPos()
		bullet.Dir 		= self:GetOwner():GetAimVector()
		bullet.Spread 	= Vector(aimcone, aimcone, 0)
		bullet.Tracer	= 1
		bullet.TracerName = TracerName
		bullet.Force	= damage * 0.5
        if self:GetOwner():GetTable().ShockWaved then
            bullet.Damage	= 0
            bullet.SDamage  = damage
        else
            bullet.Damage 	= damage
        end
		bullet.Callback	= function(attacker, tr, dmginfo)
						if not self:GetOwner():IsNPC() and self:GetOwner():GetNWInt("Fuel") > 0 then
							self:ShootFire(attacker, tr, dmginfo)
						end

                        if attacker:GetTable().ShockWaved then
                            local radius = bullet.SDamage*2
                            if radius<32 then radius=32 elseif radius>64 then radius = 64 end
                            util.BlastDamage(dmginfo:GetInflictor(),attacker,tr.HitPos, radius, bullet.SDamage*drugeffect_shockwavemultiplier)
                            if SERVER then
                                ShockWaveExplosion(tr.HitPos, self:GetOwner(), tr.HitNormal, radius)
                            end
                        end

                        if attacker:GetTable().MagicBulleted and IsValid(tr.Entity) and math.random(0,1)==1 then
                            if tr.Entity:IsPlayer() then
                                local ply = tr.Entity
                                local firedoneoff = false
                                for k, v in pairs(player.GetAll()) do
                                    if not firedoneoff and ply:GetPos():Distance(v:GetPos())<2048 and attacker:GetPos():Distance(v:GetPos())>ply:GetPos():Distance(v:GetPos()) and v~=attacker and v~=ply and v:Alive() then
                                        local traceshit = {}
											traceshit.start = ply:GetPos()+Vector(0,0,25)
											traceshit.endpos = v:GetPos()+Vector(0,0,25)
											traceshit.filter = { ply, v, attacker }
											traceshit.mask = COLLISION_GROUP_PLAYER
                                        traceshit = util.TraceLine(traceshit)
                                    if traceshit.Fraction==1 then
                                        local shotdir = (v:GetPos()+Vector(0,0,30))-(ply:GetPos()+Vector(0,0,30))
                                        firedoneoff = true
                                        local magshot = {}
                                            magshot.Num = 1
                                            magshot.Src = ply:GetShootPos()
                                            magshot.Dir = shotdir:GetNormal()
                                            magshot.Spread = Vector( 0,0,0 )
                                            magshot.Tracer = 1
                                            magshot.Force = 5
                                            magshot.Damage = 0
                                            magshot.attacker = attacker
                                        ply:FireBullets(magshot)
                                        v:TakeDamage(dmginfo:GetDamage()*.5, attacker, attacker)
                                    end
                                end
                            end
                        end
                    end

						return self:RicochetCallback_Redirect(attacker, tr, dmginfo)
					  end

	self:GetOwner():FireBullets(bullet)

	if (SERVER and (self.Sniper or self.Shotgun) and not self:GetOwner():GetActiveWeapon():GetClass() == ("weapon_mad_admin")) then
		self:GetOwner():SetVelocity(self:GetOwner():GetAimVector() * -(damage * num_bullets))
	end

	if (not self:GetOwner():IsNPC()) and ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
		local eyeangle 	= self:GetOwner():EyeAngles()
		eyeangle.pitch 	= eyeangle.pitch - recoil
		self:GetOwner():SetEyeAngles(eyeangle)
	end
end

function SWEP:BulletPenetrate(bouncenum, attacker, tr, dmginfo, isplayer)

	if (CLIENT) then return end

	local MaxPenetration

	if self.Primary.Ammo == "AirboatGun" then
		MaxPenetration = 18
	elseif self.Primary.Ammo == "Gravity" then
		MaxPenetration = 8
	elseif self.Primary.Ammo == "AlyxGun" then
		MaxPenetration = 12
	elseif self.Primary.Ammo == "Battery" then
		MaxPenetration = 14
	elseif self.Primary.Ammo == "StriderMinigun" then
		MaxPenetration = 20
	elseif self.Primary.Ammo == "SniperPenetratedRound" then
		MaxPenetration = 16
	elseif self.Primary.Ammo == "CombineCannon" then
		MaxPenetration = 20
	else
		MaxPenetration = 16
	end

	local DoDefaultEffect = true

	if ((tr.MatType == MAT_METAL and self.Ricochet) or (tr.MatType == MAT_SAND) or (tr.Entity:IsPlayer())) then return false end

	if (bouncenum > 3) then return false end

	local PenetrationDirection = tr.Normal * MaxPenetration

	if (tr.MatType == MAT_GLASS or tr.MatType == MAT_PLASTIC or tr.MatType == MAT_WOOD or tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH) then
		PenetrationDirection = tr.Normal * (MaxPenetration * 2)
	end

	local trace 	= {}
	trace.endpos 	= tr.HitPos
	trace.start 	= tr.HitPos + PenetrationDirection
	trace.mask 		= MASK_SHOT
	trace.filter 	= {self:GetOwner()}

	local trace 	= util.TraceLine(trace)

	if (trace.StartSolid or trace.Fraction >= 1.0 or tr.Fraction <= 0.0) then return false end

	local fDamageMulti = 0.5

	if (tr.MatType == MAT_CONCRETE) then
		fDamageMulti = 0.3
	elseif (tr.MatType == MAT_WOOD or tr.MatType == MAT_PLASTIC or tr.MatType == MAT_GLASS) then
		fDamageMulti = 0.8
	elseif (tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH) then
		fDamageMulti = 0.9
	end

	local bullet =
	{
		Num 		= 1,
		Src 		= trace.HitPos,
		Dir 		= tr.Normal,
		Spread 	= Vector(0, 0, 0),
		Tracer	= 1,
		TracerName 	= "effect_mad_penetration_trace",
		Force		= 5,
		Damage	= (dmginfo:GetDamage() * fDamageMulti),
		HullSize	= 2
	}

	bullet.Callback   = function(a, b, c) if (self.Ricochet) then return self:RicochetCallback(bouncenum + 1, a, b, c) end end

	timer.Simple(0.05, function()
		if not IsFirstTimePredicted() then return end
		attacker.FireBullets(attacker, bullet, true)
	end)

	return true
end

function SWEP:RicochetCallback(bouncenum, attacker, tr, dmginfo)

	if (CLIENT) then return end

	if (not self) then return end

	local DoDefaultEffect = true
	if (tr.HitSky) then return end

	if (self.Penetration) and (self:BulletPenetrate(bouncenum, attacker, tr, dmginfo)) then
		return {damage = true, effects = DoDefaultEffect}
	end

	if (tr.MatType ~= MAT_METAL) then
		if (SERVER) then
			util.ScreenShake(tr.HitPos, 5, 0.1, 0.5, 64)
			sound.Play("Bullets.DefaultNearmiss", tr.HitPos, 250, math.random(110, 180))
		end

		if self.Tracer == 1 or self.Tracer == 2 then
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetScale(20)
			util.Effect("AR2Impact", effectdata)
		elseif self.Tracer == 3 then
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				effectdata:SetNormal(tr.HitNormal)
				effectdata:SetScale(20)
			util.Effect("StunstickImpact", effectdata)
		end

		return
	end

	if (self.Ricochet == false) then return {damage = true, effects = DoDefaultEffect} end

	if (bouncenum > self.MaxRicochet) then return end

	local trace = {}
	trace.start = tr.HitPos
	trace.endpos = trace.start + (tr.HitNormal * 16384)

	local trace = util.TraceLine(trace)

 	local DotProduct = tr.HitNormal:Dot(tr.Normal * -1)

	local bullet =
	{
		Num 		= 1,
		Src 		= tr.HitPos + (tr.HitNormal * 5),
		Dir 		= ((2 * tr.HitNormal * DotProduct) + tr.Normal) + (VectorRand() * 0.05),
		Spread 	= Vector(0, 0, 0),
		Tracer	= 1,
		TracerName 	= "effect_mad_ricochet_trace",
		Force		= dmginfo:GetDamage() * 0.25,
		Damage	= dmginfo:GetDamage() * 0.5,
		HullSize	= 2
	}

	bullet.Callback  	= function(a, b, c) if (self.Ricochet) then return self:RicochetCallback(bouncenum + 1, a, b, c) end end

	timer.Simple(0.05, function()
		if not IsFirstTimePredicted() then return end
		attacker.FireBullets(attacker, bullet, true)
	end)

	return {damage = true, effects = DoDefaultEffect}
end

function SWEP:RicochetCallback_Redirect(a, b, c)

	return self:RicochetCallback(0, a, b, c)
end

function SWEP:CanPrimaryAttack()

	if (self:Clip1() <= 0) or (self:GetOwner():WaterLevel() > 2) then
		self:SetNextPrimaryFire(CurTime() + 0.5)

		return false
	end

	if not self:GetOwner():IsNPC() and (self:GetOwner():KeyDown(IN_SPEED) or self:GetDTBool(0) or self:GetOwner():WaterLevel() > 2) then
		self:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	return true
end

function SWEP:CanSecondaryAttack()

	if (self:Clip2() <= 0) then
		self:SetNextSecondaryFire(CurTime() + 0.5)

		return false
	end

	if not self:GetOwner():IsNPC() and (self:GetOwner():KeyDown(IN_SPEED) or self:GetDTBool(0) or self:GetOwner():WaterLevel() > 2) then
		self:SetNextSecondaryFire(CurTime() + 0.5)
		return false
	end

	return true
end
