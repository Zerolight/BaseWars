--[[
	BaseWars - modern custom chatbox (client)

	Replaces the default GMod chat HUD with a rounded, translucent, resolution
	aware box: team-coloured names, word-wrapped colour segments, smooth fade
	when idle, scroll wheel history and a styled input bar.
]]--

local SCALE = math.Clamp( ScrH() / 1080, 0.85, 2.2 )
local function S( n ) return math.Round( n * SCALE ) end

surface.CreateFont( "BWChatText", { font = "Roboto",       size = S( 19 ), weight = 500, antialias = true } )
surface.CreateFont( "BWChatName", { font = "Roboto",       size = S( 19 ), weight = 800, antialias = true } )
surface.CreateFont( "BWChatType", { font = "Roboto Medium", size = S( 17 ), weight = 600, antialias = true } )

BW_Chat = BW_Chat or {}
BW_Chat.Messages = BW_Chat.Messages or {}   -- { lines = { { {col,str}, ... }, ... }, time = CurTime() }
BW_Chat.Open     = false
BW_Chat.Team     = false
BW_Chat.Scroll   = 0

local MAX_MESSAGES = 120
local FADE_HOLD    = 12      -- seconds fully visible after arriving
local FADE_TIME    = 1.5     -- seconds to fade out
local COL_SYSTEM   = Color( 176, 185, 198 )
local COL_TEXT     = Color( 236, 239, 244 )
local COL_BG_OPEN  = Color( 18, 20, 26, 242 )
local COL_HEADER   = Color( 26, 29, 37, 255 )
local COL_INPUT_BG = Color( 28, 32, 40, 255 )
local COL_ACCENT   = Color( 90, 175, 255 )
local COL_HINT     = Color( 120, 128, 140, 220 )

-- Box geometry ---------------------------------------------------------------

local function ChatDims()
	local w = math.Clamp( ScrW() * 0.30, S( 380 ), S( 640 ) )
	local h = math.Clamp( ScrH() * 0.30, S( 200 ), S( 430 ) )
	local x = S( 30 )
	-- Stack the box above the money/health panel and its status-icon strip so
	-- its input bar is never covered. Fall back to a bottom margin if the HUD
	-- anchor isn't available yet.
	local top = BW_HUDStackTop and BW_HUDStackTop() or ( ScrH() - S( 90 ) )
	local y   = top - S( 10 ) - h
	return x, y, w, h
end

local PAD    = S( 12 )
local HEADER = S( 28 )
local INPUTH = S( 36 )
local function LineH() return draw.GetFontHeight( "BWChatText" ) + S( 3 ) end

-- Let other addons that call chat.GetChatBoxPos/Size line up with our box.
function chat.GetChatBoxPos()  local x, y = ChatDims() return x, y end
function chat.GetChatBoxSize() local _, _, w, h = ChatDims() return w, h end

-- Word-wrap a list of {colour,string} segments to a pixel width ---------------

local function WrapSegments( segs, maxw )
	local lines = { {} }
	local lineW = 0

	local function newLine() lines[ #lines + 1 ] = {}; lineW = 0 end

	for _, seg in ipairs( segs ) do
		local col  = seg[ 1 ] or COL_TEXT
		local str  = tostring( seg[ 2 ] or "" )
		local font = seg[ 3 ] or "BWChatText"

		surface.SetFont( font )
		local spaceW = select( 1, surface.GetTextSize( " " ) )

		for pi, part in ipairs( string.Split( str, "\n" ) ) do
			if ( pi > 1 ) then newLine() end

			for word in string.gmatch( part, "%S+" ) do
				local ww   = select( 1, surface.GetTextSize( word ) )
				local addW = ( lineW > 0 ) and ( spaceW + ww ) or ww

				if ( lineW > 0 and lineW + addW > maxw ) then
					newLine()
					addW = ww
				end

				table.insert( lines[ #lines ], { col, ( lineW > 0 and " " or "" ) .. word, font } )
				lineW = lineW + addW
			end
		end
	end

	return lines
end

-- Add a message from chat.AddText style varargs ------------------------------

local function AddMessage( ... )
	local segs, col = {}, COL_TEXT
	for _, v in ipairs( { ... } ) do
		if ( IsColor( v ) ) then
			col = v
		elseif ( isentity( v ) ) then
			if ( IsValid( v ) and v:IsPlayer() ) then
				segs[ #segs + 1 ] = { team.GetColor( v:Team() ), v:Nick(), "BWChatName" }
			else
				segs[ #segs + 1 ] = { col, tostring( v ) }
			end
		else
			segs[ #segs + 1 ] = { col, tostring( v ) }
		end
	end

	local _, _, w = ChatDims()
	local msg = { lines = WrapSegments( segs, w - PAD * 2 ), time = CurTime() }
	table.insert( BW_Chat.Messages, msg )

	while ( #BW_Chat.Messages > MAX_MESSAGES ) do table.remove( BW_Chat.Messages, 1 ) end

	if ( BW_Chat.Open ) then BW_Chat.Scroll = 0 end
	chat.PlaySound()
	return msg
end

-- Reroute other addons' chat.AddText into our box.
local oldAddText = chat.AddText
function chat.AddText( ... ) AddMessage( ... ) end

-- Drawing --------------------------------------------------------------------

local function DrawChat( open )
	local x, y, w, h = ChatDims()
	local lineH = LineH()

	local topInset = open and HEADER or 0
	local botInset = open and INPUTH or 0
	local maxRows  = math.max( math.floor( ( h - topInset - botInset - PAD ) / lineH ), 1 )

	-- Flatten messages into rows, keeping per-message alpha (fade only when idle).
	local rows = {}
	for _, msg in ipairs( BW_Chat.Messages ) do
		local a = 255
		if ( not open ) then
			local age = CurTime() - msg.time
			if ( age > FADE_HOLD + FADE_TIME ) then a = 0
			elseif ( age > FADE_HOLD ) then a = math.Clamp( 255 * ( 1 - ( age - FADE_HOLD ) / FADE_TIME ), 0, 255 ) end
		end
		if ( a > 0 ) then
			for _, line in ipairs( msg.lines ) do rows[ #rows + 1 ] = { line = line, a = a } end
		end
	end

	if ( not open and #rows == 0 ) then return end

	local total  = #rows
	local scroll = open and math.Clamp( BW_Chat.Scroll, 0, math.max( total - maxRows, 0 ) ) or 0
	BW_Chat.Scroll = scroll
	local last  = total - scroll
	local first = math.max( last - maxRows + 1, 1 )

	if ( open ) then
		local r = S( 10 )
		draw.RoundedBox( r, x + S( 2 ), y + S( 3 ), w, h, Color( 0, 0, 0, 90 ) )        -- shadow
		draw.RoundedBox( r, x, y, w, h, COL_BG_OPEN )                                    -- panel

		-- header bar
		draw.RoundedBoxEx( r, x, y, w, HEADER, COL_HEADER, true, true, false, false )
		surface.SetDrawColor( COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b, 255 )
		surface.DrawRect( x, y, S( 3 ), HEADER )
		local mcol = BW_Chat.Team and team.GetColor( LocalPlayer():Team() ) or COL_ACCENT
		draw.SimpleText( BW_Chat.Team and "TEAM CHAT" or "CHAT", "BWChatType", x + PAD, y + HEADER * 0.5,
			mcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( "ENTER send    ESC cancel", "BWChatType", x + w - PAD, y + HEADER * 0.5,
			COL_HINT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

		-- input bar
		draw.RoundedBoxEx( r, x, y + h - INPUTH, w, INPUTH, COL_INPUT_BG, false, false, true, true )
		surface.SetDrawColor( 255, 255, 255, 12 )
		surface.DrawRect( x + S( 8 ), y + h - INPUTH, w - S( 16 ), 1 )
	end

	-- Draw rows bottom-up within the message area.
	local ty       = y + h - botInset - PAD - lineH
	local topLimit = y + topInset + math.floor( PAD * 0.5 )
	for i = last, first, -1 do
		local row = rows[ i ]
		if ( not row or ty < topLimit ) then break end
		local tx = x + PAD
		for _, part in ipairs( row.line ) do
			local col, str, font = part[ 1 ], part[ 2 ], part[ 3 ] or "BWChatText"
			surface.SetFont( font )
			if ( not open ) then                                  -- shadow for readability over the world
				surface.SetTextColor( 0, 0, 0, math.floor( row.a * 0.65 ) )
				surface.SetTextPos( tx + 1, ty + 1 )
				surface.DrawText( str )
			end
			surface.SetTextColor( col.r, col.g, col.b, row.a )
			surface.SetTextPos( tx, ty )
			surface.DrawText( str )
			tx = tx + select( 1, surface.GetTextSize( str ) )
		end
		ty = ty - lineH
	end

	if ( open and scroll > 0 ) then
		draw.SimpleText( scroll .. " more", "BWChatType", x + w - PAD, y + h - INPUTH - S( 3 ),
			COL_HINT, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
	end
end

-- Both the idle history and the open box are drawn here, in screen space. The
-- open box must NOT be drawn from the DFrame's Paint: inside a VGUI Paint the
-- draw origin is the panel's top-left, so DrawChat's absolute coordinates would
-- render the panel offset off-screen. The DFrame is only an input overlay.
hook.Add( "HUDPaint", "BW_ChatHUD", function()
	if ( HelpToggled ) then return end                  -- hide while the F1 menu is up
	DrawChat( BW_Chat.Open )
end )

-- Input ----------------------------------------------------------------------

local function CloseChat()
	BW_Chat.Open   = false
	BW_Chat.Scroll = 0
	if ( IsValid( BW_Chat.Frame ) ) then BW_Chat.Frame:Remove() end
	BW_Chat.Frame = nil
	BW_Chat.Entry = nil
	hook.Run( "ChatTextChanged", "" )
	hook.Run( "FinishChat" )
end
BW_Chat.Close = CloseChat

local function OpenChat( teamChat )
	if ( IsValid( BW_Chat.Frame ) ) then BW_Chat.Frame:Remove() end

	BW_Chat.Open   = true
	BW_Chat.Team   = teamChat or false
	BW_Chat.Scroll = 0

	local x, y, w, h = ChatDims()

	local frame = vgui.Create( "DFrame" )
	frame:SetPos( x, y )
	frame:SetSize( w, h )
	frame:SetTitle( "" )
	frame:ShowCloseButton( false )
	frame:SetDraggable( false )
	frame:SetKeyboardInputEnabled( true )
	frame:SetMouseInputEnabled( true )
	frame.Paint = function() end            -- transparent; the box is drawn in HUDPaint (screen space)

	-- Keep our state in sync no matter how the frame goes away (ESC, Remove, etc.)
	frame.OnRemove = function()
		BW_Chat.Open = false
		if ( BW_Chat.Frame == frame ) then BW_Chat.Frame = nil; BW_Chat.Entry = nil end
	end

	local label = vgui.Create( "DLabel", frame )
	label:SetFont( "BWChatName" )
	label:SetTextColor( COL_ACCENT )
	label:SetText( ">" )
	label:SizeToContents()
	label:SetPos( PAD, h - INPUTH + ( INPUTH - label:GetTall() ) * 0.5 )

	local entry = vgui.Create( "DTextEntry", frame )
	entry:SetFont( "BWChatText" )
	entry:SetPos( PAD + label:GetWide() + S( 8 ), h - INPUTH + S( 4 ) )
	entry:SetSize( w - PAD * 2 - label:GetWide() - S( 8 ), INPUTH - S( 8 ) )
	entry:SetPaintBackground( false )
	entry:SetTextColor( COL_TEXT )
	entry:SetUpdateOnType( true )

	entry.Paint = function( self, pw, ph )
		self:DrawTextEntryText( COL_TEXT, COL_ACCENT, COL_TEXT )
		return true
	end

	local function send()
		local txt = string.Trim( entry:GetText() or "" )
		if ( txt ~= "" ) then
			RunConsoleCommand( teamChat and "say_team" or "say", txt )
		end
		CloseChat()
	end

	entry.OnEnter       = send
	entry.OnValueChange = function( self, val ) hook.Run( "ChatTextChanged", val ) end

	entry.OnKeyCodeTyped = function( self, code )
		if ( code == KEY_ENTER or code == KEY_PAD_ENTER ) then send(); return true end
		if ( code == KEY_ESCAPE ) then CloseChat(); return true end
		if ( code == KEY_TAB ) then
			local val = hook.Run( "OnChatTab", self:GetText() )
			if ( isstring( val ) ) then self:SetText( val ); self:SetCaretPos( #val ) end
			return true
		end
		return false
	end

	frame.OnMouseWheeled = function( self, delta ) BW_Chat.Scroll = math.max( BW_Chat.Scroll + delta, 0 ); return true end
	entry.OnMouseWheeled = frame.OnMouseWheeled

	frame:MakePopup()
	entry:RequestFocus()
	timer.Simple( 0, function() if ( IsValid( entry ) ) then entry:RequestFocus() end end )

	BW_Chat.Frame = frame
	BW_Chat.Entry = entry
end

-- Guaranteed escape hatch: close the box on ESC even if the entry lost focus.
hook.Add( "Think", "BW_ChatEscape", function()
	if ( BW_Chat.Open and input.IsKeyDown( KEY_ESCAPE ) ) then CloseChat() end
end )

-- Bound as hooks (not GM: methods) so they take effect regardless of whether
-- `GM` is the live gamemode table at include time.
hook.Add( "StartChat", "BW_StartChat", function( teamChat )
	OpenChat( teamChat )
	return true
end )

-- Feed engine / player messages into our box ---------------------------------

hook.Add( "OnPlayerChat", "BW_OnPlayerChat", function( ply, text, teamChat, isDead )
	local segs = {}

	if ( isDead ) then   segs[ #segs + 1 ] = Color( 210, 70, 70 ); segs[ #segs + 1 ] = "*DEAD* " end
	if ( teamChat ) then segs[ #segs + 1 ] = Color( 120, 190, 120 ); segs[ #segs + 1 ] = "(TEAM) " end

	if ( IsValid( ply ) ) then
		segs[ #segs + 1 ] = ply
	else
		segs[ #segs + 1 ] = Color( 150, 150, 150 )
		segs[ #segs + 1 ] = "???"
	end

	segs[ #segs + 1 ] = COL_TEXT
	segs[ #segs + 1 ] = ": " .. tostring( text )

	AddMessage( unpack( segs ) )
	return true
end )

hook.Add( "ChatText", "BW_ChatText", function( index, name, text, typ )
	if ( typ == "chat" ) then return end        -- handled by OnPlayerChat
	AddMessage( COL_SYSTEM, tostring( text ) )
	return true
end )

AddMessage( COL_ACCENT, "BaseWars ", COL_SYSTEM, "chat ready. Press ", COL_TEXT, "Y", COL_SYSTEM, " to talk, ", COL_TEXT, "U", COL_SYSTEM, " for team." )
