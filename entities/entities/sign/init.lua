AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 42

	local ent = ents.Create( "sign" )
	ent:SetPos( SpawnPos )
	ent:SetNWString("text","I am bored.")
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()
	self:SetModel( "models/props_junk/plasticbucket001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()

	end
	self.DidHit = false
	self.GoofyTiem = CurTime()
	self.Upgraded = false
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxsign=ply:GetTable().maxsign + 1
	self.Damage = 300
end

function ENT:Think()
	if (not IsValid((self.Owner or self:GetOwner()))) then
		self:Remove()
	end
end

function ENT:OnRemove()
	local ply = (self.Owner or self:GetOwner())
	if IsValid(ply) then
		ply:GetTable().maxsign=ply:GetTable().maxsign - 1
	end
end

function ENT:SetMode(t)
	self:SetNWInt("mode",t)
end

function ENT:OnTakeDamage(dmg)
	local damage = dmg:GetDamage()
	local attacker=dmg:GetAttacker()
	local inflictor=dmg:GetInflictor()
	if not dmg:IsExplosionDamage() and IsValid(attacker) and attacker:IsPlayer() and attacker:GetTable().ArmorPiercered then
		damage = damage*drugeffect_armorpiercermod
	end
	if self.Damage>0 then
		self.Damage = self.Damage - damage
		if(self.Damage <= 0) then
			self:Remove()
		end
	end
end
