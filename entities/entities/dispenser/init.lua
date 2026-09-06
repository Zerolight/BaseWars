AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 42

	local ent = ents.Create( "dispenser" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()

	self:SetModel( "models/props_lab/reciever_cart.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetNWInt("upgrade", 0)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",500)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxdispensers=ply:GetTable().maxdispensers + 1
	self:SetNWInt("power",0)
	self.scrap = false
end

function ENT:MakeScraps()

end

function ENT:Use(activator,caller)
	if self:GetNWBool("sparking") == true then return end
	plgun = activator:GetActiveWeapon()
	if activator:Health()<activator:GetMaxHealth() then
		activator:SetHealth(activator:Health()+15)
		if (activator:Health()>activator:GetMaxHealth()) then activator:SetHealth(activator:GetMaxHealth()) end
	end

	self:SetNWBool("sparking",true)
	if (self:GetNWInt("upgrade")>0) then
		timer.Create( tostring(self) .. "resup", 0.75, 1, function() if IsValid( self ) then self:resupply() end end )
	else
		timer.Create( tostring(self) .. "resup", 1, 1, function() if IsValid( self ) then self:resupply() end end )
	end
	if (activator:GetAmmoCount("rpg_round")<=0 and activator:HasWeapon("weapon_rocketlauncher")) then
		activator:GiveAmmo(2, "rpg_round")
		return "" ;
	end
	if (activator:GetAmmoCount("xbowbolt")<=0 and activator:HasWeapon("weapon_tranqgun")) then
		activator:GiveAmmo(5, "xbowbolt")
		return "" ;
	end
	if (plgun:GetClass() == "weapon_rpg") then
		activator:GiveAmmo(2, plgun:GetPrimaryAmmoType())
	elseif (plgun:Clip1()>0) then
		activator:GiveAmmo(plgun:Clip1()*2, plgun:GetPrimaryAmmoType())
	end
end

function ENT:resupply()
	self:SetNWBool("sparking",false)
end

function ENT:Think()
	if (IsValid((self.Owner or self:GetOwner()))~=true) then
		self:Remove()
	end
end

function ENT:OnRemove( )
	timer.Destroy(tostring(self))
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxdispensers=ply:GetTable().maxdispensers - 1
	end
	timer.Destroy(tostring(self) .. "resup")
end
