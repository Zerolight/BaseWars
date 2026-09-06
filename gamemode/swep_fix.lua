local COMPENSATION = 7;
if SERVER then AddCSLuaFile("swep_fix.lua") return end;
local meta = FindMetaTable("Weapon");
if not meta then return end;

if not (meta.__SetNextPrimaryFire) then meta.__SetNextPrimaryFire = meta.SetNextPrimaryFire end;
if not (meta.__SetNextSecondaryFire) then meta.__SetNextSecondaryFire = meta.SetNextSecondaryFire end;

local function PrimaryAttack(self,...)
	if(self.__PrimaryAttack and (self.__NextPrimaryAttack or 0) < CurTime()) then
		return self:__PrimaryAttack(...)
	end;
end
local function SecondaryAttack(self,...)
	if(self.__SecondaryAttack and (self.__NextSecondaryAttack or 0) < CurTime()) then return self:__SecondaryAttack(...) end;
end

function meta:SetNextPrimaryFire(delay)
	self:__SetNextPrimaryFire(delay);
	if(IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then
		local time = CurTime();

		local delay = (delay or time) - time;

		if((self:GetOwner():Ping() + COMPENSATION)/1000 > delay) then delay = delay + COMPENSATION/1000 end;
		self.__NextPrimaryAttack = delay + time;
		if(self.PrimaryAttack and not self.__PrimaryAttack) then
			self.__PrimaryAttack = self.PrimaryAttack;
			self.PrimaryAttack = PrimaryAttack;
		end
	end
end

function meta:SetNextSecondaryFire(delay)
	self:__SetNextSecondaryFire(delay);
	if(IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then
		local time = CurTime();

		local delay = (delay or time) - time;

		if((self:GetOwner():Ping() + COMPENSATION)/1000 > delay) then delay = delay + COMPENSATION/1000 end;
		self.__NextSecondaryAttack = delay + time;
		if(self.SecondaryAttack and not self.__SecondaryAttack) then
			self.__SecondaryAttack = self.SecondaryAttack;
			self.SecondaryAttack = SecondaryAttack;
		end
	end
end
