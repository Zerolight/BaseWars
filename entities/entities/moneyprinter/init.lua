AddCSLuaFile "cl_init.lua";
AddCSLuaFile "shared.lua";
include "shared.lua";

function ENT:UpdateMoney( )
	if (self.Owner or self:GetOwner()) and self:IsValid( ) then
		local owner = self.Owner or self:GetOwner()
		if IsValid( owner ) then owner:SetNWInt( "vaultamount", self.Money ) end
	end;
end;

local machineloop;
function ENT:Initialize( )
	self:SetModel( "models/props/chest/chest.mdl" );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:SetSolid( SOLID_VPHYSICS );
	self:EmitSound( "ambient/machines/thumper_startup1.wav" );

	local phys = self:GetPhysicsObject( );
	if( phys:IsValid( ) ) then
		phys:Wake( );
	end;

	local machineloop = CreateSound( self, Sound( "ambient/machines/wall_loop1.wav" ) );
	machineloop:Play( );

	self.Money = 0;
end;

function ENT:Use( activator, caller )
	net.Start("MoneyVaultMenu");
	net.Send(activator);
end;

function ENT:EjectMoney( )
	trace.start = self:GetPos( )+self:GetAngles( ):Up( ) * 15;
	trace.endpos = trace.start + self:GetAngles( ):Forward( ) + self:GetAngles( ):Right( );
	trace.filter = self;

	local moneybag = ents.Create( "prop_moneybag" );
		moneybag:SetModel( "models/notes.mdl" );
		moneybag:SetPos( tr.HitPos );
		moneybag:SetAngles( self:GetAngles( ) );
		moneybag:SetColor(Color(200, 255, 200, 255));
		moneybag:Spawn( );
		moneybag:GetTable( ).MoneyBag = true;
		moneybag:SetMoveType( MOVETYPE_VPHYSICS )
		moneybag:GetTable( ).Amount = self.Money;
		moneybag:SetVelocity( Vector( 0, 0, 10 ) * 10 );
		self:UpdateMoney( );

	self.Money = 0;
end;

function ENT:OnRemove( )
	self:EjectMoney( );
	self:EmitSound "ambient/machines/thumper_shutdown.wav";
	machineloop:Stop( );
end;

concommand.Add( "ll_printer_deposit", function( ply, cmd, argv )
	local amt = tonumber( argv[ 1 ] );
	if not amt then
		ply:ChatPrint "Invalid Money Printer deposit type!";
		return;
	end;
	if not ply:CanAfford( amt ) then
		ply:ChatPrint "You can't afford that!";
		return;
	end;

	local trace = { };
		trace.start = ply:GetShootPos( );
		trace.endpos = ply:GetShootPos( ) + ( ply:GetAimVector( ) * 200 );
		trace.filter = ply;
		local traceline = util.TraceLine( trace );
		if traceline.HitNonWorld and traceline.Entity:IsValid( ) then
			local ent = traceline.Entity;
			ply:AddMoney( -amt );
			ent.Money = ( ent.Money or 0 ) + amt;
			ent:UpdateMoney( );
		end;
end );
