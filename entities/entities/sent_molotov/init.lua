AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_junk/garbage_glassbottle003a.mdl")

	util.PrecacheSound( "explode_3" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	local zfire = ents.Create( "env_fire_trail" )
		zfire:SetPos( self:GetPos() )
		zfire:SetParent( self )
		zfire:Spawn()
		zfire:Activate()

end

function ENT:Think()
end

function ENT:Explosion()
 	util.BlastDamage( self, (self.Owner or self:GetOwner()), self:GetPos(), 200, 500 )
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
    util.Effect( "Molotov_Explosion", effectdata )

	local shake = ents.Create( "env_shake" )
		shake:SetOwner( (self.Owner or self:GetOwner()) )
		shake:SetPos( self:GetPos() )
		shake:SetKeyValue( "amplitude", "1000" )
		shake:SetKeyValue( "radius", "1000" )
		shake:SetKeyValue( "duration", "3" )
		shake:SetKeyValue( "frequency", "255" )
		shake:SetKeyValue( "spawnflags", "4" )
		shake:Spawn()
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )

	local physExplo = ents.Create( "env_physexplosion" )
	    physExplo:SetOwner( (self.Owner or self:GetOwner()) )
        physExplo:SetPos( self:GetPos() )
        physExplo:SetKeyValue( "Magnitude", "500" )
        physExplo:SetKeyValue( "radius", "450" )
        physExplo:SetKeyValue( "spawnflags", "19" )
        physExplo:Spawn()
        physExplo:Fire( "Explode", "", 0.02 )

	local ar2Explo = ents.Create( "env_ar2explosion" )
		ar2Explo:SetOwner( (self.Owner or self:GetOwner()) )
		ar2Explo:SetPos( self:GetPos() )
		ar2Explo:SetKeyValue( "material", "effects/muzzleflash"..math.random( 1, 4 ) )
		ar2Explo:Spawn()
		ar2Explo:Activate()
		ar2Explo:Fire( "Explode", "", 0 )

	for i=1, 25 do
		local fire = ents.Create( "env_fire" )
			fire:SetPos( self:GetPos() + Vector( math.random( -300, 300 ), math.random( -300, 300 ), 0 ) )
			fire:SetKeyValue( "health", math.random( 10, 15 ) )
			fire:SetKeyValue( "firesize", "128" )
			fire:SetKeyValue( "fireattack", "4" )
			fire:SetKeyValue( "damagescale", "2.0" )
			fire:SetKeyValue( "StartDisabled", "0" )
			fire:SetKeyValue( "firetype", "0" )
			fire:SetKeyValue( "spawnflags", "132" )
			fire:Spawn()
			fire:Fire( "StartFire", "", 1.5 )
	end

	for i=1, 16 do
		local sparks = ents.Create( "env_spark" )
			sparks:SetPos( self:GetPos() + Vector( math.random( -150, 150 ), math.random( -150, 150 ), math.random( -150, 200 ) ) )
			sparks:SetKeyValue( "MaxDelay", "0" )
			sparks:SetKeyValue( "Magnitude", "2" )
			sparks:SetKeyValue( "TrailLength", "3" )
			sparks:SetKeyValue( "spawnflags", "0" )
			sparks:Spawn()
			sparks:Fire( "SparkOnce", "", 0 )
	end

	for k, v in pairs ( ents.FindInSphere( self:GetPos(), 350 ) ) do
		if v:IsValid() and v:IsPlayer() then return end
		v:Ignite( 10, 0 )
	end

end

function ENT:PhysicsCollide( data, physobj )
	util.Decal("Scorch", data.HitPos + data.HitNormal , data.HitPos - data.HitNormal)
	self:EmitSound( "explode_3" )
	self:Explosion()
	self:Remove()
end
