AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:OnTakeDamage(dmg)
	local damage = dmg:GetDamage()
	local attacker=dmg:GetAttacker()
	local inflictor=dmg:GetInflictor()
	if not dmg:IsExplosionDamage() and IsValid(attacker) and attacker:IsPlayer() and attacker:GetTable().ArmorPiercered then
		damage = damage*drugeffect_armorpiercermod
	end
	if self:GetNWInt("damage")>0 then
		self:SetNWInt("damage",self:GetNWInt("damage") - damage)
		if(self:GetNWInt("damage") <= 0) then
			self:Explode()
			if self.Payout~=nil and attacker:IsPlayer() then

				local owner = self.Owner or self:GetOwner()
				local welding = IsValid( owner ) and owner:GetNWBool("spamwelding") and attacker == owner
				local pay=self.Payout[1]*.75
				if welding then
					pay=self.Payout[1] * -2
				end
				pay=math.ceil(pay)
				attacker:AddMoney(pay)
				if welding then
					Notify(attacker,2,3,"Lost "..tostring(pay * -1).." for destroying a "..self.Payout[2].." during a raid")
				else
					Notify(attacker,2,3,"Paid "..tostring(pay).." for destroying a "..self.Payout[2])
				end
			end
			if inflictor:GetClass()~="bigbomb" and inflictor:GetClass()~="env_physexplosion" and self.MakeScraps~=nil then
				self:MakeScraps()
			end
			self:Remove()

		end
	end
end

function ENT:Explode()

	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart( vPoint )
	effectdata:SetOrigin( vPoint )
	effectdata:SetScale( 1 )
	util.Effect( "Explosion", effectdata )
end
