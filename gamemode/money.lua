if ( not sql.TableExists( "bwmoney" ) ) then

	sql.Query( "CREATE TABLE IF NOT EXISTS bwmoney (Money TEXT, SteamID TEXT)" )
end

local sql		=	sql
local Format	=	Format
local SQLStr	=	SQLStr

local meta = FindMetaTable( "Player" )

local function FormatID( str )

	return str:lower():gsub( ":", "_" )
end

function UpdateMoney( self, value )

	net.Start( "MoneyChange" )

		net.WriteInt( 0, 16 )
		net.WriteInt( value, 32 )

	net.Send( self )
end

function SetMoney( self )
	local id

	id = self:SteamID()
	id = FormatID( id )

	if ( tonumber( self.Money ) ~= nil ) then
		local str = Format( "UPDATE bwmoney SET Money = %s WHERE SteamID = %s", self.Money, SQLStr( id ) )

		sql.Query( str )
	end
end

function GetMoney( pl )
	local id, money

	id = pl:SteamID()
	id = FormatID( id )

	money = sql.QueryValue( Format( "SELECT Money FROM bwmoney WHERE SteamID = %s", SQLStr( id ) ) )
	money = tonumber( money ) or sql.Query( Format( "INSERT INTO bwmoney (SteamID, Money) VALUES (%s, 5000)", SQLStr( id ) ) ) or 5000

	pl.Money = math.min( math.ceil( money ), 700000000 )

	UpdateMoney( pl, pl.Money )
	return pl.Money
end

setMoney = SetMoney
getMoney = GetMoney
