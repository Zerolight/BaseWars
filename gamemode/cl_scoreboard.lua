local build = "1.9"

function GM:ScoreboardShow()
	GAMEMODE.ShowScoreboard = true
end

function GM:ScoreboardHide()
	GAMEMODE.ShowScoreboard = false
end

surface.CreateFont( "BWScoreTitle", { font = "Roboto", size = 22, weight = 700, antialias = true } )
surface.CreateFont( "BWScoreTeam",  { font = "Roboto", size = 17, weight = 700, antialias = true } )
surface.CreateFont( "BWScoreRow",   { font = "Roboto", size = 16, weight = 500, antialias = true } )
surface.CreateFont( "BWScoreSmall", { font = "Roboto", size = 13, weight = 500, antialias = true } )

surface.CreateFont( "arial20", { font = "arial", size = 16, weight = 500, antialias = true, shadow = false } )
surface.CreateFont( "arialbold", { font = "arial", size = 16, weight = 600, antialias = true, shadow = false } )

surface.CreateFont( "arialout", { font = "arial", size = 16, weight = 600, antialias = true, outline = true } )

function GM:GetTeamScoreInfo()

	local TeamInfo = {}

		for id,pl in pairs( player.GetAll() ) do

		local _team = pl:Team()
		local _frags = pl:Frags()
		local _deaths =pl:Deaths(	)
		local _ping = pl:Ping()

		if (not TeamInfo[_team]) then
			TeamInfo[_team] = {}
			TeamInfo[_team].TeamName = team.GetName( _team )
			TeamInfo[_team].Color = team.GetColor( _team )
			TeamInfo[_team].Players = {}
		end

		local PlayerInfo = {}

		PlayerInfo.Frags = _frags
		PlayerInfo.Deaths = _deaths
		PlayerInfo.Score = _frags - _deaths
		PlayerInfo.Ping = _ping
		PlayerInfo.Name = pl:Nick()
		PlayerInfo.SteamID = pl:SteamID()
		PlayerInfo.PlayerObj = pl

		local insertPos = #TeamInfo[_team].Players + 1
		for idx,info in pairs(TeamInfo[_team].Players) do
			if (PlayerInfo.Frags > info.Frags) then
				insertPos = idx
				break
			elseif (PlayerInfo.Frags == info.Frags) then
				if (PlayerInfo.Deaths < info.Deaths) then
					insertPos = idx
					break
				elseif (PlayerInfo.Deaths == info.Deaths) then
					if (PlayerInfo.Name < info.Name) then
						insertPos = idx
						break
					end
				end
			end
		end

		table.insert(TeamInfo[_team].Players, insertPos, PlayerInfo)
	end

	return TeamInfo
end

local ROW_H     = 22
local HEADER_H  = 58
local COLS_H    = 24
local TEAM_H    = 26
local PAD       = 8

local COL_BG       = Color(  18,  20,  24, 230 )
local COL_HEADER   = Color(  28,  32,  38, 245 )
local COL_COLS     = Color(  38,  43,  50, 245 )
local COL_ROW      = Color( 255, 255, 255,   8 )
local COL_ROW_ME   = Color( 120, 180, 255,  28 )
local COL_TEXT     = Color( 225, 228, 232, 255 )
local COL_DIM      = Color( 150, 155, 162, 255 )
local COL_LINE     = Color(   0,   0,   0, 180 )

local function PingColour( ping )
	if ( ping <= 0 )   then return COL_DIM end
	if ( ping < 80 )   then return Color(  90, 220, 120 ) end
	if ( ping < 150 )  then return Color( 240, 205,  90 ) end
	return Color( 235, 100, 100 )
end

function GM:HUDDrawScoreBoard()

	if ( not GAMEMODE.ShowScoreboard ) then return end

	local info = self:GetTeamScoreInfo()

	local order = {}
	for id, t in pairs( info ) do table.insert( order, id ) end
	table.sort( order )

	local rows = 0
	for _, id in ipairs( order ) do rows = rows + #info[ id ].Players end
	local bodyH = ( #order * ( TEAM_H + 2 ) ) + ( rows * ROW_H ) + PAD

	local w = math.Clamp( ScrW() * 0.55, 640, 1100 )
	local maxH = ScrH() - 120
	local h = math.min( HEADER_H + COLS_H + bodyH, maxH )
	local x = ( ScrW() - w ) / 2
	local y = math.max( 60, ( ScrH() - h ) / 2 - ScrH() * 0.08 )

	local cPing   = x + w - 60
	local cDeaths = x + w - 130
	local cKills  = x + w - 200

	draw.RoundedBox( 6, x, y, w, h, COL_BG )
	draw.RoundedBoxEx( 6, x, y, w, HEADER_H, COL_HEADER, true, true, false, false )

	draw.SimpleText( GetHostName(), "BWScoreTitle", x + PAD * 2, y + 12, COL_TEXT )
	draw.SimpleText( GAMEMODE.Name .. "  -  " .. GAMEMODE.Author,
		"BWScoreSmall", x + PAD * 2, y + 36, COL_DIM )

	local count = player.GetCount() .. " / " .. game.MaxPlayers() .. " players"
	draw.SimpleText( count, "BWScoreSmall", x + w - PAD * 2, y + 36, COL_DIM, TEXT_ALIGN_RIGHT )

	surface.SetDrawColor( COL_COLS )
	surface.DrawRect( x, y + HEADER_H, w, COLS_H )

	local ch = y + HEADER_H + COLS_H * 0.5
	draw.SimpleText( "Player",  "BWScoreSmall", x + PAD * 2, ch, COL_DIM, TEXT_ALIGN_LEFT,   TEXT_ALIGN_CENTER )
	draw.SimpleText( "Kills",   "BWScoreSmall", cKills,      ch, COL_DIM, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( "Deaths",  "BWScoreSmall", cDeaths,     ch, COL_DIM, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( "Ping",    "BWScoreSmall", cPing,       ch, COL_DIM, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	local me  = LocalPlayer()
	local cy  = y + HEADER_H + COLS_H
	local bot = y + h - 2

	for _, id in ipairs( order ) do

		local t = info[ id ]
		if ( cy + TEAM_H > bot ) then break end

		local tc = t.Color or Color( 120, 120, 120 )
		surface.SetDrawColor( tc.r * 0.35, tc.g * 0.35, tc.b * 0.35, 230 )
		surface.DrawRect( x, cy, w, TEAM_H )
		surface.SetDrawColor( tc.r, tc.g, tc.b, 255 )
		surface.DrawRect( x, cy, 4, TEAM_H )

		local name = string.upper( string.Left( string.Trim( t.TeamName or "?" ), 32 ) )
		draw.SimpleText( name, "BWScoreTeam", x + PAD * 2, cy + TEAM_H * 0.5,
			COL_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( #t.Players .. ( #t.Players == 1 and " player" or " players" ),
			"BWScoreSmall", x + w - PAD * 2, cy + TEAM_H * 0.5,
			COL_DIM, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

		cy = cy + TEAM_H + 2

		for _, pl in ipairs( t.Players ) do

			if ( cy + ROW_H > bot ) then break end

			local ent = pl.PlayerObj
			local mine = IsValid( ent ) and ent == me

			surface.SetDrawColor( mine and COL_ROW_ME or COL_ROW )
			surface.DrawRect( x + 4, cy, w - 8, ROW_H - 2 )

			local ty  = cy + ( ROW_H - 2 ) * 0.5
			local afk = IsValid( ent ) and ent:GetNWBool( "AFK", false )
			local nm  = pl.Name .. ( afk and "  (AFK)" or "" )

			draw.SimpleText( nm, "BWScoreRow", x + PAD * 2, ty,
				afk and COL_DIM or COL_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.SimpleText( pl.Frags,  "BWScoreRow", cKills,  ty, COL_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( pl.Deaths, "BWScoreRow", cDeaths, ty, COL_TEXT, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( pl.Ping,   "BWScoreRow", cPing,   ty, PingColour( pl.Ping ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			cy = cy + ROW_H
		end
	end

	surface.SetDrawColor( COL_LINE )
	surface.DrawOutlinedRect( x, y, w, h )

end

function GM:HUDDrawTargetID()

	local aim = vgui.CursorVisible() and gui.ScreenToVector( input.GetCursorPos() )
	                                 or LocalPlayer():GetAimVector()
	local tr = util.GetPlayerTrace( LocalPlayer(), aim )
	local trace = util.TraceLine( tr )
	if (not trace.Hit) then return end
	if (not trace.HitNonWorld) then return end

	local text = "ERROR"
	local font = "TargetID"

	if (trace.Entity:IsPlayer() and (LocalPlayer():GetObserverTarget()== nil or trace.Entity~=LocalPlayer():GetObserverTarget())) then
		text = trace.Entity:Nick()
	else
		return

	end

	local w, h = surface.GetTextSize( text )

	local MouseX, MouseY = gui.MousePos()

	if ( MouseX == 0 and MouseY == 0 ) then

		MouseX = ScrW() / 2
		MouseY = ScrH() / 2

	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

	y = y + h + 5

	local text = trace.Entity:Health() .. "%"
	local font = "TargetIDSmall"

	local w, h = surface.GetTextSize( text )
	local x =  MouseX  - w / 2

	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

end
