if SERVER then
	include('particletrace.lua')
end

local sndAttackLoop = Sound("fire_large")
local sndSprayLoop = Sound("ambient.steam01")
local sndAttackStop = Sound("ambient/_period.wav")
local sndIgnite = Sound("PropaneTank.Burst")

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

	SWEP.HoldType			= "rpg"

end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 64
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false

	SWEP.PrintName			= "Flamethrower"
	SWEP.Author			= "Teta_Bonita"
	SWEP.Slot			= 4
	SWEP.SlotPos			= 11
	SWEP.IconLetter 		= "a"
	surface.CreateFont( "HL2SelectIcons", { font = "HalfLife2", size = ScreenScale( 60 ), weight = 500, antialias = true, shadow = true } )
	killicon.AddFont("weapon_flamethrower","HL2MPTypeDeath","/",Color(200,125,0,255))
	killicon.AddFont("env_fire","HL2MPTypeDeath","C",Color(200,125,0,255))

end

SWEP.Author			= "Teta_Bonita"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Aim at enemy"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_smg1.mdl"
SWEP.WorldModel			= "models/weapons/w_smg1.mdl"

SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 4
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.05

SWEP.Primary.ClipSize		= 250
SWEP.Primary.DefaultClip	= 250
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "CombineCannon"

SWEP.Secondary.Recoil			= 0
SWEP.Secondary.Damage			= 3
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0.02
SWEP.Secondary.Delay			= 0.05

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Upgraded = 0

function SWEP:Initialize()

	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end

	self.EmittingSound = false

	util.PrecacheModel("models/player/charple01.mdl")

end

function SWEP:Reload()
	self:DefaultReload( ACT_VM_RELOAD )
	self:StopSounds()
end

function SWEP:Think()

	if self:GetOwner():KeyReleased(IN_ATTACK) or self:GetOwner():KeyReleased(IN_ATTACK2) then
		self:StopSounds()
	end

end

function SWEP:Upgrade(bool)
	self:SetNWBool("upgraded",bool)
    if self:GetNWBool("upgraded") then
        SWEP.Primary.Damage	= 8
    else
        SWEP.Primary.Damage	= 4
    end
end
function SWEP:PrimaryAttack()

	local curtime = CurTime()
	local InRange = false

	self:SetNextSecondaryFire( curtime + 1 )
	self:SetNextPrimaryFire( curtime + self.Primary.Delay )

	if not self:CanPrimaryAttack() or self:GetOwner():WaterLevel() > 1 then
	self:StopSounds()
	return end

	if not self.EmittingSound then
		self:EmitSound(sndAttackLoop)
		self.EmittingSound = true
	end

	self:TakePrimaryAmmo(1)

		local PlayerVel = self:GetOwner():GetVelocity()
		local PlayerPos = self:GetOwner():GetShootPos()
		local PlayerAng = self:GetOwner():GetAimVector()

		local trace = {}
		trace.start = PlayerPos
		trace.endpos = PlayerPos + (PlayerAng*1024)
		trace.filter = self:GetOwner()

		local traceRes = util.TraceLine(trace)
		local hitpos = traceRes.HitPos

		local vel = 0

		if IsValid(traceRes.Entity) then
			vel = traceRes.Entity:GetVelocity():Distance(Vector(0,0,0))
		end
		local jetlength = (hitpos - PlayerPos):Length()+vel
		if jetlength > 512 then jetlength = 512 end
		if jetlength < 6 then jetlength = 6 end
		if self:GetOwner():Alive() then
			local effectdata = EffectData()
			effectdata:SetOrigin( hitpos )
			effectdata:SetEntity( self )
			effectdata:SetStart( PlayerPos )
			effectdata:SetNormal( PlayerAng )
			effectdata:SetScale( jetlength )
			effectdata:SetAttachment( 1 )
			util.Effect( "flamepuffs", effectdata )
		end

		if self.DoShoot then

			local ptrace = {}
			ptrace.startpos = PlayerPos + PlayerAng:GetNormalized()*16
			local ang = (traceRes.HitPos - ptrace.startpos):GetNormalized()
			ptrace.func = burndamage
			ptrace.movetype = MOVETYPE_FLY
			ptrace.velocity = ang*728 + 0.5*PlayerVel
			ptrace.model = "none"
			ptrace.filter = {self:GetOwner()}
			ptrace.killtime = (jetlength + 16)/ptrace.velocity:Length()
			ptrace.runonkill = false
			ptrace.collisionsize = 16
			ptrace.worldcollide = true
			ptrace.owner = self:GetOwner()
			ptrace.name = "flameparticle"
			if SERVER then
				ParticleTrace(ptrace)
			end
			self.DoShoot = false
		else
			self.DoShoot = true
		end

end

function SWEP:SecondaryAttack()

end

HumanModels = {

"models/Humans/",
"models/player/",
"models/zombie",
"[Pp]olice.mdl",
"[Ss]oldier",
"[Aa]lyx.mdl",
"[Bb]arney.mdl",
"[Bb]reen.mdl",
"[Ee]li.mdl",
"[Mm]onk.mdl",
"[Kk]leiner.mdl",
"[Mm]ossman.mdl",
"[Oo]dessa.mdl",
"[Gg]man"

}

function IsHumanoid(ent)

	if ent:IsPlayer() then return true end

	local entmodel = ent:GetModel()

	for k,model in pairs(HumanModels) do
		if string.find(entmodel,model) ~= nil then
		return true end
	end

	return false

end

function explode(ent,pos)

	pos.z = pos.z - 64

	Immolate(ent,pos)

	local boom = ents.Create("env_explosion")
	boom:SetKeyValue("iMagnitude","60")
	boom:SetPos(pos)
	boom:SetOwner(ent)
	boom:Spawn()

	boom:Fire("Explode","","0")

	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "explosion_large", effectdata )

end

function Immolate(ent,pos)

	pos = pos or ent:GetPos()

	if SERVER then

		if ent:IsPlayer() then

			BurnPlayer(ent,20,ent,ent:GetWeapon("weapon_flamethrower"))
		else
			ent:SetModel("models/player/charple01.mdl")
			ent:Fire("sethealth","0","0")
		end
	end

	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "immolate", effectdata )

end

function burndamage(ptres)

	local hitent = ptres.activator
	if hitent:WaterLevel() > 0 then return end

	local ttime = ptres.time
	if ttime == 0 then ttime = 0.1 end

	local damage = 5
	local isnpc = hitent:IsNPC()
	if isnpc then damage = damage*2 end
	local radius = math.ceil(256*ttime)
	if radius < 16 then radius = 16 end

	local healthpercent = 3
	local enthealth = 1
	local enttable = hitent:GetTable()

	if isnpc or hitent:IsPlayer() then
		enthealth = hitent:Health()
		healthpercent = math.ceil(enthealth/5)
	end
	local fuel = enttable.FuelLevel
	if fuel and fuel > 0 then
		ptres.caller:EmitSound(sndIgnite)
		enttable.FuelLevel = 0
		local entpos = hitent:GetPos()
		local boompos = entpos
		boompos.z = boompos.z + hitent:BoundingRadius()/2
		local damagemult = 4*fuel
		local radiusmult = radius + fuel

		local effectdata = EffectData()
			effectdata:SetOrigin( entpos )
			effectdata:SetEntity( hitent )
			effectdata:SetStart( entpos )
			effectdata:SetNormal( Vector(0,0,1) )
			effectdata:SetScale( 10 )
		util.Effect( "HelicopterMegaBomb", effectdata )

		if damagemult < enthealth then
			if hitent:IsPlayer() then
				BurnPlayer(hitent,fuel,ptres.owner,ptres.owner:GetWeapon("weapon_flamethrower"))
			else
				hitent:Ignite(math.random(4,6),0)
			end
			hitent:TakeDamage(damagemult, ptres.owner, ptres.owner:GetWeapon("weapon_flamethrower"))
		elseif IsHumanoid(hitent) then
			Immolate(hitent,entpos)
		else

			hitent:TakeDamage(damagemult, ptres.owner, ptres.owner:GetWeapon("weapon_flamethrower"))

		end
	else
		local weapon = ptres.owner:GetWeapon("weapon_flamethrower")
		if hitent:IsPlayer() then
			hitent:TakeDamage(damage, ptres.owner, weapon)
			BurnPlayer(hitent,1,ptres.owner,weapon)
		else
			hitent:TakeDamage(damage*2, ptres.owner, weapon)
			if not hitent:GetTable().Structure and math.random(0,10)>8 then
				hitent:Ignite(math.random(4,6),0)
			end
		end
		for k,v in pairs(ents.FindInSphere(hitent:GetPos(),32)) do
			if v:GetClass()=="sent_firecontroller" then
				v:StartFire()
			end
		end
	end
end

function DeFlamitize(ply)
	ply:GetTable().FuelLevel = 0
	if ply:IsOnFire() then
		ply:Extinguish()
	end
end
hook.Add( "PlayerDeath", "deflame", DeFlamitize )

function SWEP:StopSounds()
	if self.EmittingSound then
		self:StopSound(sndAttackLoop)
		self:StopSound(sndSprayLoop)
		self:EmitSound(sndAttackStop)
		self.EmittingSound = false
	end
end

function SWEP:Holster()
	self:StopSounds()
	return true
end

function SWEP:OnRemove()
	self:StopSounds()
	return true
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	draw.SimpleText( "a", "HL2SelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )

	if (self:GetNWBool("upgraded")) then
		draw.SimpleText("K", "CSKillIcons", x + wide-20, y + tall-25, Color(200,200, 200, 255), TEXT_ALIGN_CENTER )
	end
end
