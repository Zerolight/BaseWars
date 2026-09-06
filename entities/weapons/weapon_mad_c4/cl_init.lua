include('shared.lua')

SWEP.PrintName			= "EXPLOSIVE C4"
SWEP.Slot				= 4
SWEP.SlotPos			= 1

SWEP.Ghost 				= NULL

if (file.Exists( "materials/weapons/weapon_mad_c4.vmt", "GAME" )) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_c4")
end

function SWEP:Think()

	if self:GetOwner() ~= LocalPlayer() then return end

	if not IsValid(self.Ghost) then

		self.Ghost = ents.CreateClientProp("models/weapons/w_c4_planted.mdl")
		if not IsValid(self.Ghost) then return end
		self.Ghost:SetModel("models/weapons/w_c4_planted.mdl")
		self.Ghost:SetOwner(self:GetOwner())
	end

	if not IsValid(self.Ghost) then return end

	local tr = {}
	tr.start = self:GetOwner():GetShootPos()
	tr.endpos = self:GetOwner():GetShootPos() + 100 * self:GetOwner():GetAimVector()
	tr.filter = {self.Ghost, self:GetOwner()}
	local trace = util.TraceLine(tr)

	if trace.Hit then
		self.Ghost:SetPos(trace.HitPos + trace.HitNormal)
		trace.HitNormal.z = -trace.HitNormal.z
		self.Ghost:SetAngles(trace.HitNormal:Angle() - Angle(90, 180, 0))

		self.Ghost:SetColor(Color(255, 255, 255, 100))
	else
		self.Ghost:SetColor(Color(255, 255, 255, 0))
	end
end
