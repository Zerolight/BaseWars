ENT.Type = "anim"

ENT.PrintName		= "scrap"
ENT.Author			= "HLTV Proxy"
ENT.Contact			= ""
ENT.Purpose			= nil
ENT.Instructions	= nil

function ENT:OnRemove()
end

function ENT:Explode()
        local pos = self:GetPos()
        local radius = self.BlastRadius
        local damage = self.BlastDamage
        self.exploded = true

        util.BlastDamage( self, (self.Owner or self:GetOwner()), pos, radius, damage )
        local effect = EffectData()
        effect:SetStart(pos)
        effect:SetOrigin(pos)
        effect:SetScale(radius)
        effect:SetRadius(radius)
        effect:SetMagnitude(damage)
        util.Effect("Explosion", effect, true, true)

        if SERVER then self:Remove() end
end
