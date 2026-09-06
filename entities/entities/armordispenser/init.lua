AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 42

	local ent = ents.Create( "armordispenser" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:Initialize()

	self:SetModel( "models/props_combine/suit_charger001.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetNWInt("upgrade", 0)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",250)
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxarmordispensers=ply:GetTable().maxarmordispensers + 1
	self:SetNWInt("power",0)
	self.scrap = false
end

function ENT:MakeScraps()

end

function ENT:Use(activator,caller)
	if self:GetNWBool("sparking") == true then return end
	self:SetNWBool("sparking",true)
	if (self:GetNWInt("upgrade")==2) then
        if activator:Armor()<100 then
            activator:SetArmor(activator:Armor()+35)
            if (activator:Armor()>100) then activator:SetArmor(100) end
        end
		timer.Create( tostring(self) .. "resup", 0.75, 1, function() if IsValid( self ) then self:resupply() end end )
	elseif (self:GetNWInt("upgrade")==1) then
        if activator:Armor()<100 then
            activator:SetArmor(activator:Armor()+25)
            if (activator:Armor()>100) then activator:SetArmor(100) end
        end
		timer.Create( tostring(self) .. "resup", 0.85, 1, function() if IsValid( self ) then self:resupply() end end )
	elseif (self:GetNWInt("upgrade")==0) then
        if activator:Armor()<100 then
            activator:SetArmor(activator:Armor()+15)
            if (activator:Armor()>100) then activator:SetArmor(100) end
        end
        timer.Create( tostring(self) .. "resup", 0.95, 1, function() if IsValid( self ) then self:resupply() end end )
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
		ply:GetTable().maxarmordispensers=ply:GetTable().maxarmordispensers - 1
	end
	timer.Destroy(tostring(self) .. "resup")
end
