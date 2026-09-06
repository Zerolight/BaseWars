SWEP.Base 				= "weapon_mad_base"

SWEP.ViewModelFOV			= 80
SWEP.ViewModel			= "models/items/v_medkit2.mdl"
SWEP.WorldModel			= "models/items/w_medkit.mdl"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound 		= Sound("HealthVial.Touch")
SWEP.Secondary.Sound 		= Sound("WeaponFrag.Throw")
SWEP.Primary.Recoil		= 0
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 2

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

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

SWEP.Power				= 0

function SWEP:Precache()

    	util.PrecacheSound("items/smallmedkit1.wav")
    	util.PrecacheSound("weapons/slam/throw.wav")
end

cleanup.Register("Medic Kit")

function SWEP:PrimaryAttack()

	if (not self:GetOwner():IsNPC() and self:GetOwner():KeyDown(IN_USE)) then
		bHolsted = not self:GetNWBool("Holsted", false)
		self:SetHolsted(bHolsted)

		self:SetNextPrimaryFire(CurTime() + 0.3)
		self:SetNextSecondaryFire(CurTime() + 0.3)

		self:SetIronsights(false)

		return
	end

	if not IsFirstTimePredicted() then return end
	if self.ActionDelay > CurTime() then return end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	self.ActionDelay = (CurTime() + self.Primary.Delay)

	self:SendWeaponAnim(ACT_VM_HOLSTER)

	timer.Simple(1, function()
		if (not self:GetOwner():Alive() or self:GetOwner():GetActiveWeapon():GetClass() ~= "weapon_mad_medic" or not IsFirstTimePredicted()) then return end
		self:SendWeaponAnim(ACT_VM_DRAW)
	end)

	timer.Simple(0.75, function()
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)

		if (SERVER) then
			self:EmitSound(self.Secondary.Sound)
		end

		if (CLIENT) then return end

		local health = ents.Create("ent_mad_medic")

		health.Owner = self:GetOwner()

		local pos = self:GetOwner():GetShootPos() + self:GetOwner():GetUp() * -12.5
		health:SetPos(pos)

		health:SetAngles(self:GetOwner():GetAngles())
		health:Spawn()

		undo.Create("Medic Kit")
			undo.AddEntity(health)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()

		self:GetOwner():AddCleanup("Medic Kit", health)

		local phys = health:GetPhysicsObject()
		phys:SetVelocity(self:GetOwner():GetAimVector() * 200)
	end)
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()

	self:SendWeaponAnim(ACT_VM_DRAW)

	self:SetNextPrimaryFire(CurTime() + self.DeployDelay)
	self:SetNextSecondaryFire(CurTime() + self.DeployDelay)
	self.ActionDelay = (CurTime() + self.DeployDelay)

	return true
end

function SWEP:Reload()
end
