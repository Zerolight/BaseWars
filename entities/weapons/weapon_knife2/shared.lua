SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFlip		= false
SWEP.ViewModel			= "models/weapons/v_knife_t.mdl"
SWEP.WorldModel			= "models/weapons/w_knife_t.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Recoil		= 5
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 0.5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "XBowBolt"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.ShellEffect			= "none"
SWEP.ShellDelay			= 0

SWEP.Pistol				= true
SWEP.Rifle				= false
SWEP.Shotgun			= false
SWEP.Sniper				= false

SWEP.RunArmOffset 		= Vector (0.3671, 0.1571, 5.7856)
SWEP.RunArmAngle	 		= Vector (-37.4833, 2.7476, 0)

SWEP.Sequence			= 0

function SWEP:Precache()

    	util.PrecacheSound("weapons/knife/knife_slash1.wav")
    	util.PrecacheSound("weapons/knife/knife_hitwall1.wav")
    	util.PrecacheSound("weapons/knife/knife_deploy1.wav")
    	util.PrecacheSound("weapons/knife/knife_hit1.wav")
    	util.PrecacheSound("weapons/knife/knife_hit2.wav")
    	util.PrecacheSound("weapons/knife/knife_hit3.wav")
    	util.PrecacheSound("weapons/knife/knife_hit4.wav")
    	util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
end

function SWEP:Deploy()

	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + 1)

	self:EmitSound("weapons/knife/knife_deploy1.wav", 50, 100)

	self:IdleAnimation(1)

	return true
end

function SWEP:EntsInSphereBack(pos, range)

	local ents = ents.FindInSphere(pos, range)

	for k, v in pairs(ents) do
		if v ~= self and v ~= self:GetOwner() and (v:IsNPC() or v:IsPlayer()) and IsValid(v) and self:EntityFaceBack(v) then
			return true
		end
	end

	return false
end

function SWEP:EntityFaceBack(ent)

	local angle = self:GetOwner():GetAngles().y - ent:GetAngles().y

	if angle < -180 then angle = 360 + angle end
	if angle <= 90 and angle >= -90 then return true end

	return false
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

	if self:GetNWBool("Holsted") or self:GetOwner():KeyDown(IN_SPEED) then return end

	local tr = {}
	tr.start = self:GetOwner():GetShootPos()
	tr.endpos = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * 50)
	tr.filter = self:GetOwner()
	tr.mask = MASK_SHOT
	local trace = util.TraceLine(tr)

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)

	if (trace.Hit) then
		if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			if self:EntsInSphereBack(tr.endpos, 12) then
				self:SendWeaponAnim(ACT_VM_IDLE)
				local Animation = self:GetOwner():GetViewModel()
				Animation:SetSequence(Animation:LookupSequence("stab"))

				bullet = {}
				bullet.Num    = 1
				bullet.Src    = self:GetOwner():GetShootPos()
				bullet.Dir    = self:GetOwner():GetAimVector()
				bullet.Spread = Vector(0, 0, 0)
				bullet.Tracer = 0
				bullet.Force  = 1
				bullet.Damage = 100
				self:GetOwner():FireBullets(bullet)

				self:EmitSound("Weapon_Knife.Stab")
				self:SetNextPrimaryFire(CurTime() + 1.5)
				self:SetNextSecondaryFire(CurTime() + 1.5)

				return
			end

			self:SendWeaponAnim(ACT_VM_IDLE)
			local Animation = self:GetOwner():GetViewModel()
			Animation:SetSequence(Animation:LookupSequence("midslash" .. math.random(1, 2)))

			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self:GetOwner():GetShootPos()
			bullet.Dir    = self:GetOwner():GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = 20
			self:GetOwner():FireBullets(bullet)

			self:EmitSound("Weapon_Knife.Hit")
		else
			self:SendWeaponAnim(ACT_VM_IDLE)
			local Animation = self:GetOwner():GetViewModel()
			Animation:SetSequence(Animation:LookupSequence("midslash" .. math.random(1, 2)))

			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self:GetOwner():GetShootPos()
			bullet.Dir    = self:GetOwner():GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = 50
			self:GetOwner():FireBullets(bullet)

			self:EmitSound("Weapon_Knife.HitWall")

			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
		end
	else
		self:SendWeaponAnim(ACT_VM_IDLE)
		local Animation = self:GetOwner():GetViewModel()
		Animation:SetSequence(Animation:LookupSequence("midslash" .. math.random(1, 2)))

		self:EmitSound("Weapon_Knife.Slash")
	end

	if ((game.SinglePlayer() and SERVER) or CLIENT) then
		self:SetNWFloat("LastShootTime", CurTime())
	end

	self:IdleAnimation(1)
end

function SWEP:SecondaryAttack()

end
