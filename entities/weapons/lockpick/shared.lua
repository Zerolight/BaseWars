if( SERVER ) then

	AddCSLuaFile( "shared.lua" );
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if( CLIENT ) then

	SWEP.DrawAmmo = false;
	if (file.Exists( "materials/weapons/weapon_mad_medic.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_medic")
end

	SWEP.PrintName = "Lock Pick";
	SWEP.Slot = 5;
	SWEP.SlotPos = 4;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = false;

end

SWEP.Author			= "Rickster"
SWEP.Instructions	= "Left click to pick a lock or gun vault"
SWEP.Contact		= ""
SWEP.Purpose		= ""

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel = Model( "models/weapons/v_crowbar.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_crowbar.mdl" )

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.Sound = Sound( "physics/wood/wood_box_impact_hard3.wav" );

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= ""

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= ""

function SWEP:Initialize()

	if( SERVER ) then

		self:SetWeaponHoldType( "melee" );

	end
util.PrecacheSound("physics/flesh/flesh_impact_bullet" .. math.random( 3, 5 ) .. ".wav")
util.PrecacheSound("weapons/iceaxe/iceaxe_swing1.wav")
end

function SWEP:Precache()
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 1)

	local trace = self:GetOwner():GetEyeTrace()
	local bullet = {}
		bullet.Num    = 1
		bullet.Src    = self:GetOwner():GetShootPos()
		bullet.Dir    = self:GetOwner():GetAimVector()
		bullet.Spread = Vector(0, 0, 0)
		bullet.Tracer = 0
		bullet.Force  = 1
		bullet.Damage = 0
	local ent = trace.Entity

	if ent:IsValid() and table.HasValue({"func_door","prop_door_rotating","func_door_rotating"}, ent:GetClass()) then
		local cha = math.random(1,6)
		self:SendWeaponAnim(ACT_VM_HITCENTER)
		self:GetOwner():FireBullets(bullet)
		print(cha)
		if cha ~= 1 then
			self:EmitSound("physics/flesh/flesh_impact_bullet"..math.random(3,5)..".wav")
		else
			self:EmitSound("play items/ammocrate_open.wav")
			self:GetOwner():PrintMessage(HUD_PRINTTALK, "You Successfully Broke The Lock And Latch On The Door")
			ent:Fire("Unlock","",0.1)
			ent.NextLock = CurTime()+10
			ent:SetNWBool("Locked", false)
		end
	end

	if (IsValid(trace.Entity)) then
		if (trace.HitPos:Distance(self:GetOwner():GetShootPos()) <= 75 and not trace.Entity:GetClass()~="gunvault" and trace.Entity:GetClass()~="pillbox" and trace.Entity:GetClass()~="gunvault" and trace.Entity:GetClass()~="sent_keypad") then
			self:SendWeaponAnim(ACT_VM_HITCENTER)
			self:GetOwner():FireBullets(bullet)
			self:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random( 3, 5 ) .. ".wav")

		elseif (trace.HitPos:Distance(self:GetOwner():GetShootPos()) <= 75 and (trace.Entity:GetClass()=="gunvault" or trace.Entity:GetClass()=="pillbox" or trace.Entity:GetClass()=="moneyvault") and IsValid(trace.Entity)) then
			self:SendWeaponAnim(ACT_VM_HITCENTER)
			self:GetOwner():FireBullets(bullet)
			self:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random( 3, 5 ) .. ".wav")

			if(trace.Entity:GetNWInt("unlockAmount") == nil) then
				trace.Entity:SetNWInt("unlockAmount", 0)
			elseif(trace.Entity:GetNWInt("unlockAmount") < 9) then
				if self:GetOwner():GetTable().Tooled then
					trace.Entity:SetNWInt("unlockAmount", trace.Entity:GetNWInt("unlockAmount")+2)
				else
					trace.Entity:SetNWInt("unlockAmount", trace.Entity:GetNWInt("unlockAmount")+1)
				end
			else
				trace.Entity:SetNWInt("unlockAmount", 0)
				if SERVER then
					Notify(self:GetOwner(), 4, 3, "The Monevault/Pillbox/Gunvault has been unlocked.")
					trace.Entity:SetUnLocked()
				end
			end
		elseif (self:GetOwner():GetTable().Tooled and trace.HitPos:Distance(self:GetOwner():GetShootPos()) <= 75 and (trace.Entity:GetClass()=="sent_keypad") and IsValid(trace.Entity)) then
			self:SendWeaponAnim(ACT_VM_HITCENTER)
			self:GetOwner():FireBullets(bullet)
			self:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random( 3, 5 ) .. ".wav")

			if(trace.Entity:GetNWInt("unlockAmount") == nil) then
				trace.Entity:SetNWInt("unlockAmount", 0)
			elseif(trace.Entity:GetNWInt("unlockAmount") < 20) then
				if self:GetOwner():GetTable().Tooled then
					trace.Entity:SetNWInt("unlockAmount", trace.Entity:GetNWInt("unlockAmount")+2)
				else
					trace.Entity:SetNWInt("unlockAmount", trace.Entity:GetNWInt("unlockAmount")+1)
				end
			else
				trace.Entity:SetNWInt("unlockAmount", 0)
				if SERVER then
					local Pass=0
					for k,v in pairs(Keypad.Passwords) do
						if (trace.Entity:EntIndex() == v.Ent) then
							Pass=v.Pass
						end
					end
					Notify(self:GetOwner(), 4, 3, "The code is "..tostring(Pass))
				end
			end
		elseif CLIENT and (trace.Entity:GetClass()=="sent_keypad") then
				self:EmitSound("physics/flesh/flesh_impact_bullet" .. math.random( 3, 5 ) .. ".wav")
		end
	else
		self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav")
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
	end

end

function SWEP:ShouldDropOnDie()
	return true
end
