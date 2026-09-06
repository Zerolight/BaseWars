AddCSLuaFile "cl_init.lua";
AddCSLuaFile "shared.lua";
include "shared.lua";

function ENT:UpdateMoney( )
	if self:IsValid( ) then

		local owner = (self.Owner or self:GetOwner())
		owner:SetNWInt( "vaultamount", self.Money );
	end;
end;

local machineloop;
local called = false;
function ENT:Initialize( )
	self:SetModel( "models/props_lab/powerbox01a.mdl" );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:SetSolid( SOLID_VPHYSICS );
	self:EmitSound( "ambient/machines/thumper_startup1.wav" );

	local phys = self:GetPhysicsObject( );
	if( phys:IsValid( ) ) then
		phys:Wake( );
	end;

	self:SetNWInt("damage",1000)
	self:SetNWInt("upgrade", 0)
	machineloop = CreateSound( self, Sound( "ambient/machines/wall_loop1.wav" ) );
	machineloop:Play( );

			timer.Create( "giveInterest_" .. self:EntIndex(), 5, 0, function() if IsValid( self ) then self:giveInterest() end end )

	self.Money = 0;
	self.KeyPress = CurTime( );
	local ply = (self.Owner or self:GetOwner())
	ply:GetTable().maxMoneyVault=ply:GetTable().maxMoneyVault + 1
end;

function ENT:Use( activator, caller )
	if CurTime( ) >= self.KeyPress then
		if (self.Owner or self:GetOwner()) == activator then
			net.Start("MoneyVaultMenu") net.Send(activator);
			self.KeyPress = CurTime( ) + 1;
		else
			Notify(activator,4,3,"This Money Vault is locked!");
			self.KeyPress = CurTime( ) + 1;
		end;
	end;
end;

function ENT:giveInterest()
	local owner = (self.Owner or self:GetOwner())
		if (self:GetNWInt("upgrade")==0) then
			self.Money = self.Money * 1.1
			if IsValid(owner) then Notify( owner, 4, 3, "You have been given 10% Intrest in Your Money Bank." ) end
		end
		if (self:GetNWInt("upgrade")==1) then
			if IsValid(owner) then Notify( owner, 4, 3, "You have been given 20% Intrest in Your Money Bank." ) end
			self.Money = self.Money * 1.2
		end
		if (self:GetNWInt("upgrade")==2) then
			self.Money = self.Money * 1.3
		if IsValid(owner) then Notify( owner, 4, 3, "You have been given 30% Intrest in Your Money Bank." ) end
		end

end

function ENT:EjectMoney( )
	if self.Money > 0 then
		local moneybag = ents.Create( "prop_moneybag" );
			moneybag:SetModel( "models/props/cs_assault/Money.mdl" );
			moneybag:SetPos( self:GetPos( ) + Vector( 0, 0, 20 ) );
			moneybag:SetAngles( self:GetAngles( ) );
			moneybag:SetColor(Color(200, 255, 200, 255));
			moneybag:Spawn( );
			moneybag:GetTable( ).MoneyBag = true;
			moneybag:GetTable( ).Amount = self.Money;
			moneybag:SetVelocity( Vector( 0, 0, 10 ) * 10 );
			moneybag.Ejected = true;

			self.Money = 0;
			self:UpdateMoney( );
	else
		Notify((self.Owner or self:GetOwner()), 4, 3, "This Money Vault is empty!")
		end;
end;

function ENT:OnRemove( )
	self:EjectMoney( );
	self:EmitSound( "ambient/machines/thumper_shutdown1.wav" );
	machineloop:Stop( );
	timer.Remove("giveInterest_" .. self:EntIndex())
	local owner = (self.Owner or self:GetOwner())
	owner:GetTable().maxMoneyVault = owner:GetTable().maxMoneyVault - 1
end;

function ENT:Touch( ent )
	if ent:GetClass( ) == "prop_moneybag" then
		if not ent.Ejected and not called then
			self.Money = self.Money + ent:GetTable( ).Amount;
			ent:Remove( );
			self:UpdateMoney( );
			called = true;
			timer.Simple( 1, function( )
				called = false;
			end );
		end;
	end;
end;

concommand.Add( "ll_vault_deposit", function( ply, cmd, argv )
	local amt = tonumber( argv[ 1 ] );
	if not amt then
		ply:ChatPrint "Invalid Money Vault deposit type!";
		return;
	end;
	if not ply:CanAfford( amt ) then
		ply:ChatPrint "You can't afford that!";
		return;
	end;

	ply:AddMoney( -amt );
	local trace = { };
		trace.start = ply:GetShootPos( );
		trace.endpos = ply:GetShootPos( ) + ( ply:GetAimVector( ) * 200 );
		trace.filter = ply;
		local traceline = util.TraceLine( trace );
		if traceline.HitNonWorld and traceline.Entity:IsValid( ) then
			local ent = traceline.Entity;
			ent.Money = ent.Money + amt;
			ent:EmitSound( "ambient/levels/labs/coinslot1.wav" );
			ent:UpdateMoney( );
		end;
end );

concommand.Add( "ll_vault_eject", function( ply, cmd, argv )
	local trace = { };
		trace.start = ply:GetShootPos( );
		trace.endpos = ply:GetShootPos( ) + ( ply:GetAimVector( ) * 200 );
		trace.filter = ply;
		local traceline = util.TraceLine( trace );
		if traceline.HitNonWorld and traceline.Entity:IsValid( ) then
			traceline.Entity:EjectMoney( );
			traceline.Entity:EmitSound( "ambient/alarms/klaxon1.wav" );
		end;
end );
