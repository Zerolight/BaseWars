ENT.Type 		= "anim"
ENT.PrintName	= "Land Mine"
ENT.Author		= "Worshipper"
ENT.Contact		= "Josephcadieux@hotmail.com"
ENT.Purpose		= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:DTVar("Boal", 0, "Activated")
	self:DTVar("Entity", 0, "Owner")
end
