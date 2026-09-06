AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

end

function ENT:Touch( ent )
	if ent:GetClass( ) == "prop_moneybag" then
		if not called then
				if ent:GetTable().Amount < self:GetTable().Amount then
					self:GetTable().Amount = self:GetTable().Amount + ent:GetTable( ).Amount
					ent:Remove( );
					called = true;
					timer.Simple( 1, function( )
						called = false;
					end );
				end
			end;
		end;
	end;
