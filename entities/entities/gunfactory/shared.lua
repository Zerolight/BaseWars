ENT.Type = "anim"
ENT.Base = "base_structure"
ENT.PrintName = "Gun Factory"
ENT.Author = "HLTV Proxy"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.HealthRing={200,60,2}

ENT.Power		= 3
ENT.SparkPos = Vector(-30,-30,60)

function ENT:CanProduce(guntype, ply)
	if guntype=="resetbutton" and ply==(self.Owner or self:GetOwner()) then
		return true
	elseif not self:IsPowered() or not self.Ready then
		return false
	elseif guntype=="laserbeam" then
		return true
	elseif guntype=="laserrifle" then
		return true
	elseif guntype=="grenadegun" and self:GetNWInt("upgrade")>=1 then
		return true
	elseif guntype=="plasma" and self:GetNWInt("upgrade")>=1 then
		return true
	elseif guntype=="worldslayer" and self:GetNWInt("upgrade")>=2 then
		return true
	elseif guntype=="minigun" and self:GetNWInt("upgrade")>=2 then
		return true
	else
		return false
	end
end
