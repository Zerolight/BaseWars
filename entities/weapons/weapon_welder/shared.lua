if(SERVER) then
	AddCSLuaFile( "cl_init.lua" )
	AddCSLuaFile( "shared.lua" )
end

if( CLIENT ) then

	SWEP.PrintName = "Blowtorch";
	SWEP.Slot = 5;
	SWEP.SlotPos = 8;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = false;

end

SWEP.Author			= "HLTV Proxy"
SWEP.Instructions	= "Blowtorch: Hold left click on a prop to eventually remove it."
SWEP.Contact		= ""
SWEP.Purpose		= ""

SWEP.ViewModelFOV	= 73
SWEP.ViewModelFlip	= false
SWEP.ViewModel = Model( "models/weapons/v_IRifle.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_IRifle.mdl" )

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.Sound = Sound( "physics/wood/wood_box_impact_hard3.wav" );

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= ""

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= ""

function SWEP:Initialize()

	if( SERVER ) then

		self:SetWeaponHoldType( "pistol" );

	end
	util.PrecacheSound("physics/metal/metal_box_impact_soft2.wav")
	util.PrecacheSound("ambient/energy/spark1.wav")
	util.PrecacheSound("ambient/energy/spark2.wav")
	util.PrecacheSound("ambient/energy/spark3.wav")
	util.PrecacheSound("ambient/energy/spark4.wav")
end

function SWEP:Precache()
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + .075)

	local trace = self:GetOwner():GetEyeTrace()
	local snd = math.random(1,4)

	if (trace.HitPos:Distance(self:GetOwner():GetShootPos()) <= 128 and (trace.Entity:GetClass()=="prop_ragdoll" or trace.Entity:GetClass()=="prop_physics_multiplayer" or trace.Entity:GetClass()=="prop_physics_respawnable" or trace.Entity:GetClass()=="prop_physics" or trace.Entity:GetClass()=="phys_magnet" or trace.Entity:GetClass()=="gmod_spawner" or trace.Entity:GetClass()=="gmod_wheel" or trace.Entity:GetClass()=="gmod_thruster" or trace.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trace.Entity:IsValid()) then
		local effectdata = EffectData()
			effectdata:SetOrigin(trace.HitPos)
			effectdata:SetMagnitude( 1 )
			effectdata:SetScale( 2 )
			effectdata:SetRadius( 2 )
		util.Effect( "Sparks", effectdata )

		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
		self:EmitSound("ambient/energy/spark" .. snd .. ".wav")

		if SERVER then
			timer.Destroy(tostring(trace.Entity) .. "unweldamage")

			timer.Create( tostring(trace.Entity) .. "unweldamage", 10, 1, function() WeldControl( trace.Entity, player.GetByUniqueID(trace.Entity:GetVar("PropProtection")) ) end )

		end

		if(trace.Entity:GetNWInt("welddamage") == nil or trace.Entity:GetNWInt("welddamage") <= 0 or trace.Entity:GetNWInt("welddamage") == 255) then
			trace.Entity:SetNWInt("welddamage", 254)
			if SERVER then
				if (player.GetByUniqueID(trace.Entity:GetVar("PropProtection"))~=false) then
					local entowner = player.GetByUniqueID(trace.Entity:GetVar("PropProtection"))
					entowner:GetTable().spamweldcount=entowner:GetTable().spamweldcount+1
					entowner:SetNWBool("spamwelding", true)
					Notify(entowner, 1, 3, "someone is destroying one of your props with a blowtorch!!!")
					entowner:PrintMessage(HUD_PRINTTALK, "someone is destroying one of your props with a blowtorch!")
				end
			end
		elseif(trace.Entity:GetNWInt("welddamage") > 1) then
			trace.Entity:SetNWInt("welddamage", trace.Entity:GetNWInt("welddamage") - 1)
			if SERVER then
				if (trace.Entity:GetNWInt("welddamage")==130) then
					if SERVER then

						local entowner = trace.Entity:CPPIGetOwner()
						if IsValid(entowner) and entowner:IsPlayer() then
							Notify(entowner, 1, 3, "someone has nearly finished destroying one of your props using blowtorch!!!")
							entowner:PrintMessage(HUD_PRINTTALK, "someone has nearly finished destroying one of your props with a blowtorch!")
						end
					end
				end
			end
		else
			if SERVER then
				if (player.GetByUniqueID(trace.Entity:GetVar("PropProtection"))~=false) then
						local entowner = player.GetByUniqueID(trace.Entity:GetVar("PropProtection"))
						Notify(entowner, 1, 3, "someone has destroyed one of your props using a blowtorch!!!")
						entowner:PrintMessage(HUD_PRINTTALK, "someone has destroyed one of your props with a blowtorch!")
				end
			end
			local effectdata = EffectData()
				effectdata:SetStart( trace.Entity:GetPos() )
				effectdata:SetOrigin( trace.Entity:GetPos() )
				effectdata:SetScale( 1 )
			util.Effect( "Explosion", effectdata )
			if SERVER then
				timer.Destroy(tostring(trace.Entity) .. "unweldamage")

				local weldEnt = trace.Entity
				local weldOwner = player.GetByUniqueID(weldEnt:GetVar("PropProtection") or "")
				timer.Create( tostring(weldEnt) .. "unweldamage", 30, 1, function() WeldControl( weldEnt, weldOwner ) end )

				timer.Destroy(tostring(trace.Entity) .. "undamagecolor")
				trace.Entity:Remove()
			end
		end
	else
		self:EmitSound("ambient/energy/spark" .. snd.. ".wav")
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	end

	local tr = {}
		tr.start = trace.HitPos
		tr.endpos = trace.HitPos + (self:GetOwner():GetAimVector() * 128)
		tr.filter = { self:GetOwner(), trace.Entity }
	local trtwo = util.TraceLine( tr )

	if (not trtwo.Hit) then return end

	if (trtwo.HitPos:Distance(self:GetOwner():GetShootPos()) <= 256 and (trtwo.Entity:GetClass()=="prop_ragdoll" or trtwo.Entity:GetClass()=="prop_physics_multiplayer" or trtwo.Entity:GetClass()=="prop_physics_respawnable" or trtwo.Entity:GetClass()=="prop_physics" or trtwo.Entity:GetClass()=="phys_magnet" or trtwo.Entity:GetClass()=="gmod_spawner" or trtwo.Entity:GetClass()=="gmod_wheel" or trtwo.Entity:GetClass()=="gmod_thruster" or trtwo.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trtwo.Entity:IsValid()) then

		if SERVER then
			timer.Destroy(tostring(trtwo.Entity) .. "unweldamage")

			timer.Create( tostring(trtwo.Entity) .. "unweldamage", 30, 1, function() if IsValid(trtwo.Entity) then WeldControl( trtwo.Entity, player.GetByUniqueID(trtwo.Entity:GetVar("PropProtection")), true ) end end )

		end

		if(trtwo.Entity:GetNWInt("welddamage") == nil or trtwo.Entity:GetNWInt("welddamage") <= 0 or trtwo.Entity:GetNWInt("welddamage") == 255) then
			trtwo.Entity:SetNWInt("welddamage", 254)
			if SERVER then
				if (player.GetByUniqueID(trtwo.Entity:GetVar("PropProtection"))~=false) then
					local entowner = player.GetByUniqueID(trtwo.Entity:GetVar("PropProtection"))
					entowner:GetTable().spamweldcount=entowner:GetTable().spamweldcount+1
					entowner:SetNWBool("spamwelding", true)
					Notify(entowner, 1, 3, "someone is destroying one of your props with a blowtorch!!!")
					entowner:PrintMessage(HUD_PRINTTALK, "someone is destroying one of your props with a blowtorch!")
				end
			end
		elseif(trtwo.Entity:GetNWInt("welddamage") > 1) then
			trtwo.Entity:SetNWInt("welddamage", trtwo.Entity:GetNWInt("welddamage") - 1)
			if SERVER then
				if (trtwo.Entity:GetNWInt("welddamage")==130) then
					if SERVER then
						if (player.GetByUniqueID(trtwo.Entity:GetVar("PropProtection"))~=false) then
							local entowner = player.GetByUniqueID(trtwo.Entity:GetVar("PropProtection"))
							Notify(entowner, 1, 3, "someone has nearly finished destroying one of your props using blowtorch!!!")
							entowner:PrintMessage(HUD_PRINTTALK, "someone has nearly finished destroying one of your props with a blowtorch!")
						end
					end
				end
			end
		else
			if SERVER then
				if (player.GetByUniqueID(trtwo.Entity:GetVar("PropProtection"))~=false) then
						local entowner = player.GetByUniqueID(trtwo.Entity:GetVar("PropProtection"))
						Notify(entowner, 1, 3, "someone has destroyed one of your props using a blowtorch!!!")
						entowner:PrintMessage(HUD_PRINTTALK, "someone has destroyed one of your props with a blowtorch!")
				end
			end
			local effectdata = EffectData()
				effectdata:SetStart( trtwo.Entity:GetPos() )
				effectdata:SetOrigin( trtwo.Entity:GetPos() )
				effectdata:SetScale( 1 )
			util.Effect( "Explosion", effectdata )
			if SERVER then
				timer.Destroy(tostring(trtwo.Entity) .. "unweldamage")

				timer.Create( tostring(trtwo.Entity) .. "unweldamage", 30, 1, function() WeldControl( trtwo.Entity, player.GetByUniqueID(trtwo.Entity:GetVar("PropProtection")) ) end )

				timer.Destroy(tostring(trtwo.Entity) .. "undamagecolor")
				trtwo.Entity:Remove()
			end
		end
	end

	local trx = {}
		trx.start = trtwo.HitPos
		trx.endpos = trtwo.HitPos + (self:GetOwner():GetAimVector() * 128.0)
		trx.filter = { self:GetOwner(), trace.Entity, trtwo.Entity }
	local trthree = util.TraceLine( trx )

	if (not trthree.Hit) then return end

	if (trthree.HitPos:Distance(self:GetOwner():GetShootPos()) <= 384 and (trthree.Entity:GetClass()=="prop_ragdoll" or trthree.Entity:GetClass()=="prop_physics_multiplayer" or trthree.Entity:GetClass()=="prop_physics_respawnable" or trthree.Entity:GetClass()=="prop_physics" or trthree.Entity:GetClass()=="phys_magnet" or trthree.Entity:GetClass()=="gmod_spawner" or trthree.Entity:GetClass()=="gmod_wheel" or trthree.Entity:GetClass()=="gmod_thruster" or trthree.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trthree.Entity:IsValid()) then

		if SERVER then
			timer.Destroy(tostring(trthree.Entity) .. "unweldamage")

			timer.Create( tostring(trthree.Entity) .. "unweldamage", 10, 1, function() WeldControl( trthree.Entity, player.GetByUniqueID(trthree.Entity:GetVar("PropProtection")), true ) end )

		end

		if(trthree.Entity:GetNWInt("welddamage") == nil or trthree.Entity:GetNWInt("welddamage") <= 0 or trthree.Entity:GetNWInt("welddamage") == 255) then
			trthree.Entity:SetNWInt("welddamage", 254)
			if SERVER then
				if (player.GetByUniqueID(trthree.Entity:GetVar("PropProtection"))~=false) then
					local entowner = player.GetByUniqueID(trthree.Entity:GetVar("PropProtection"))
					entowner:GetTable().spamweldcount=entowner:GetTable().spamweldcount+1
					entowner:SetNWBool("spamwelding", true)
					Notify(entowner, 1, 3, "someone is destroying one of your props with a blowtorch!!!")
					entowner:PrintMessage(HUD_PRINTTALK, "someone is destroying one of your props with a blowtorch!")
				end
			end
		elseif(trthree.Entity:GetNWInt("welddamage") > 1) then
			trthree.Entity:SetNWInt("welddamage", trthree.Entity:GetNWInt("welddamage") - 1)
			if SERVER then
				if (trthree.Entity:GetNWInt("welddamage")==130) then
					if SERVER then
						if (player.GetByUniqueID(trthree.Entity:GetVar("PropProtection"))~=false) then
							local entowner = player.GetByUniqueID(trthree.Entity:GetVar("PropProtection"))
							Notify(entowner, 1, 3, "someone has nearly finished destroying one of your props using blowtorch!!!")
							entowner:PrintMessage(HUD_PRINTTALK, "someone has nearly finished destroying one of your props with a blowtorch!")
						end
					end
				end
			end
		else
			if SERVER then
				if (player.GetByUniqueID(trthree.Entity:GetVar("PropProtection"))~=false) then
						local entowner = player.GetByUniqueID(trthree.Entity:GetVar("PropProtection"))
						Notify(entowner, 1, 3, "someone has destroyed one of your props using a blowtorch!!!")
						entowner:PrintMessage(HUD_PRINTTALK, "someone has destroyed one of your props with a blowtorch!")
				end
			end
			local effectdata = EffectData()
				effectdata:SetStart( trthree.Entity:GetPos() )
				effectdata:SetOrigin( trthree.Entity:GetPos() )
				effectdata:SetScale( 1 )
			util.Effect( "Explosion", effectdata )
			if SERVER then
				timer.Destroy(tostring(trthree.Entity) .. "unweldamage")

				timer.Create( tostring(trthree.Entity) .. "unweldamage", 30, 1, function() WeldControl( trthree.Entity, player.GetByUniqueID(trthree.Entity:GetVar("PropProtection")) ) end )

				timer.Destroy(tostring(trthree.Entity) .. "undamagecolor")
				trthree.Entity:Remove()
			end
		end
	end

	local try = {}
		try.start = trthree.HitPos
		try.endpos = trthree.HitPos + (self:GetOwner():GetAimVector() * 128.0)
		try.filter = { self:GetOwner(), trace.Entity, trtwo.Entity, trthree.Entity }
	local trfour = util.TraceLine( try )

	if (not trfour.Hit) then return end

	if (trfour.HitPos:Distance(self:GetOwner():GetShootPos()) <= 512 and (trfour.Entity:GetClass()=="prop_ragdoll" or trfour.Entity:GetClass()=="prop_physics_multiplayer" or trfour.Entity:GetClass()=="prop_physics_respawnable" or trfour.Entity:GetClass()=="prop_physics" or trfour.Entity:GetClass()=="phys_magnet" or trfour.Entity:GetClass()=="gmod_spawner" or trfour.Entity:GetClass()=="gmod_wheel" or trfour.Entity:GetClass()=="gmod_thruster" or trfour.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trfour.Entity:IsValid()) then

		if SERVER then
			timer.Destroy(tostring(trfour.Entity) .. "unweldamage")

			timer.Create( tostring(trfour.Entity) .. "unweldamage", 30, 1, function() WeldControl( trfour.Entity, player.GetByUniqueID(trfour.Entity:GetVar("PropProtection")), true ) end )

		end

		if(trfour.Entity:GetNWInt("welddamage") == nil or trfour.Entity:GetNWInt("welddamage") <= 0 or trfour.Entity:GetNWInt("welddamage") == 255) then
			trfour.Entity:SetNWInt("welddamage", 254)
			if SERVER then
				if (player.GetByUniqueID(trfour.Entity:GetVar("PropProtection"))~=false) then
					local entowner = player.GetByUniqueID(trfour.Entity:GetVar("PropProtection"))
					entowner:GetTable().spamweldcount=entowner:GetTable().spamweldcount+1
					entowner:SetNWBool("spamwelding", true)
					Notify(entowner, 1, 3, "someone is destroying one of your props with a blowtorch!!!")
					entowner:PrintMessage(HUD_PRINTTALK, "someone is destroying one of your props with a blowtorch!")
				end
			end
		elseif(trfour.Entity:GetNWInt("welddamage") > 1) then
			trfour.Entity:SetNWInt("welddamage", trfour.Entity:GetNWInt("welddamage") - 1)
			if SERVER then
				if (trfour.Entity:GetNWInt("welddamage")==130) then
					if SERVER then
						if (player.GetByUniqueID(trfour.Entity:GetVar("PropProtection"))~=false) then
							local entowner = player.GetByUniqueID(trfour.Entity:GetVar("PropProtection"))
							Notify(entowner, 1, 3, "someone has nearly finished destroying one of your props using blowtorch!!!")
							entowner:PrintMessage(HUD_PRINTTALK, "someone has nearly finished destroying one of your props with a blowtorch!")
						end
					end
				end
			end
		else
			if SERVER then
				if (player.GetByUniqueID(trfour.Entity:GetVar("PropProtection"))~=false) then
						local entowner = player.GetByUniqueID(trfour.Entity:GetVar("PropProtection"))
						Notify(entowner, 1, 3, "someone has destroyed one of your props using a blowtorch!!!")
						entowner:PrintMessage(HUD_PRINTTALK, "someone has destroyed one of your props with a blowtorch!")
				end
			end
			local effectdata = EffectData()
				effectdata:SetStart( trfour.Entity:GetPos() )
				effectdata:SetOrigin( trfour.Entity:GetPos() )
				effectdata:SetScale( 1 )
			util.Effect( "Explosion", effectdata )
			if SERVER then
				timer.Destroy(tostring(trfour.Entity) .. "unweldamage")

				timer.Create( tostring(trfour.Entity) .. "unweldamage", 30, 1, function() WeldControl( trfour.Entity, player.GetByUniqueID(trfour.Entity:GetVar("PropProtection")) ) end )

				timer.Destroy(tostring(trfour.Entity) .. "undamagecolor")
				trfour.Entity:Remove()
			end
		end
	end

	local trz = {}
		trz.start = trfour.HitPos
		trz.endpos = trfour.HitPos + (self:GetOwner():GetAimVector() * 128.0)
		trz.filter = { self:GetOwner(), trace.Entity, trtwo.Entity, trthree.Entity, trfour.Entity }
	local trfive = util.TraceLine( trz )

	if (not trfive.Hit) then return end

	if (trfive.HitPos:Distance(self:GetOwner():GetShootPos()) <= 768 and (trfive.Entity:GetClass()=="prop_ragdoll" or trfive.Entity:GetClass()=="prop_physics_multiplayer" or trfive.Entity:GetClass()=="prop_physics_respawnable" or trfive.Entity:GetClass()=="prop_physics" or trfive.Entity:GetClass()=="phys_magnet" or trfive.Entity:GetClass()=="gmod_spawner" or trfive.Entity:GetClass()=="gmod_wheel" or trfive.Entity:GetClass()=="gmod_thruster" or trfive.Entity:GetClass()=="gmod_button" or trace.Entity:GetClass()=="sent_keypad")and trfive.Entity:IsValid()) then

		if SERVER then
			timer.Destroy(tostring(trfive.Entity) .. "unweldamage")

			timer.Create( tostring(trfive.Entity) .. "unweldamage", 30, 1, function() WeldControl( trfive.Entity, player.GetByUniqueID(trfive.Entity:GetVar("PropProtection")), true ) end )

		end

		if(trfive.Entity:GetNWInt("welddamage") == nil or trfive.Entity:GetNWInt("welddamage") <= 0 or trfive.Entity:GetNWInt("welddamage") == 255) then
			trfive.Entity:SetNWInt("welddamage", 254)
			if SERVER then
				if (player.GetByUniqueID(trfive.Entity:GetVar("PropProtection"))~=false) then
					local entowner = player.GetByUniqueID(trfive.Entity:GetVar("PropProtection"))
					entowner:GetTable().spamweldcount=entowner:GetTable().spamweldcount+1
					entowner:SetNWBool("spamwelding", true)
					Notify(entowner, 1, 3, "someone is destroying one of your props with a blowtorch!!!")
					entowner:PrintMessage(HUD_PRINTTALK, "someone is destroying one of your props with a blowtorch!")
				end
			end
		elseif(trfive.Entity:GetNWInt("welddamage") > 1) then
			trfive.Entity:SetNWInt("welddamage", trfive.Entity:GetNWInt("welddamage") - 1)
			if SERVER then
				if (trfive.Entity:GetNWInt("welddamage")==130) then
					if SERVER then
						if (player.GetByUniqueID(trfive.Entity:GetVar("PropProtection"))~=false) then
							local entowner = player.GetByUniqueID(trfive.Entity:GetVar("PropProtection"))
							Notify(entowner, 1, 3, "someone has nearly finished destroying one of your props using blowtorch!!!")
							entowner:PrintMessage(HUD_PRINTTALK, "someone has nearly finished destroying one of your props with a blowtorch!")
						end
					end
				end
			end
		else
			if SERVER then
				if (player.GetByUniqueID(trfive.Entity:GetVar("PropProtection"))~=false) then
						local entowner = player.GetByUniqueID(trfive.Entity:GetVar("PropProtection"))
						Notify(entowner, 1, 3, "someone has destroyed one of your props using a blowtorch!!!")
						entowner:PrintMessage(HUD_PRINTTALK, "someone has destroyed one of your props with a blowtorch!")
				end
			end
			local effectdata = EffectData()
				effectdata:SetStart( trfive.Entity:GetPos() )
				effectdata:SetOrigin( trfive.Entity:GetPos() )
				effectdata:SetScale( 1 )
			util.Effect( "Explosion", effectdata )
			if SERVER then
				timer.Destroy(tostring(trfive.Entity) .. "unweldamage")

				timer.Create( tostring(trfive.Entity) .. "unweldamage", 45, 1, function() WeldControl( trfive.Entity, player.GetByUniqueID(trfive.Entity:GetVar("PropProtection")) ) end )

				timer.Destroy(tostring(trfive.Entity) .. "undamagecolor")
				trfive.Entity:Remove()
			end
		end
	end

end

function SWEP:SecondaryAttack()

end

function SWEP:Equip()
	if SERVER then
		if (self.WasEquipped==1) then self:Remove() end
		self.WasEquipped=1
	end
end

function SWEP:ShouldDropOnDie()
	return false
end
