ENT.Type 		= "anim"
ENT.Base 		= "base_gmodentity"

ENT.PrintName	= "Base Structure"
ENT.Author		= "HLTV Proxy"
ENT.Contact		= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.Power		= 0
ENT.Structure		= true

function ENT:Initialize()

	self:SetNWInt("power", 0)
end

function ENT:IsPowered()
	if self:GetNWInt("power")>=self.Power then return true else return false end
end
