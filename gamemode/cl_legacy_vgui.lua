local function ParseControlString( str )

	local kv = {}

	for key, value in string.gmatch( str or "", '"([%w_]+)"%s*"([^"]*)"' ) do
		kv[ string.lower( key ) ] = value
	end

	return kv

end

surface.CreateFont( "DefaultSmallDropShadow", {
	font		= "Tahoma",
	size		= 13,
	weight		= 500,
	antialias	= false,
	shadow		= true
} )

surface.CreateFont( "HUDNumber", {
	font		= "Trebuchet MS",
	size		= 32,
	weight		= 800,
	antialias	= true
} )

surface.CreateFont( "HUDNumber2", {
	font		= "Trebuchet MS",
	size		= 24,
	weight		= 800,
	antialias	= true
} )

surface.CreateFont( "HUDNumber5", {
	font		= "Trebuchet MS",
	size		= 40,
	weight		= 800,
	antialias	= true
} )

surface.CreateFont( "Trebuchet20", {
	font		= "Trebuchet MS",
	size		= 20,
	weight		= 900,
	antialias	= true
} )

surface.CreateFont( "TitleFont", {
	font		= "HalfLife2",
	size		= 64,
	weight		= 500,
	antialias	= true,
	additive	= true
} )

local PANEL = {}

function PANEL:Init()

	self:SetSize( 160, 200 )
	self:SetTitle( "" )
	self:SetDeleteOnClose( false )
	self:MakePopup()

end

function PANEL:LoadControlsFromString( str )

	local kv = ParseControlString( str )

	self:SetSize( tonumber( kv.wide ) or self:GetWide(), tonumber( kv.tall ) or self:GetTall() )
	self:SetSizable( kv.sizable == "1" )

	if ( kv.title ) then self:SetTitle( kv.title ) end

end

vgui.Register( "BWFrame", PANEL, "DFrame" )

local PANEL = {}

function PANEL:Init()

	self:SetText( "" )

end

function PANEL:SetActionFunction( func )

	self.m_ActionFunction = func

end

function PANEL:DoClick()

	if ( self.m_ActionFunction ) then self.m_ActionFunction( self ) end

end

function PANEL:SetCommand()
end

vgui.Register( "BWButton", PANEL, "DButton" )

local PANEL = {}

function PANEL:Init()

	self:SetTextColor( Color( 255, 255, 255, 255 ) )
	self:SetContentAlignment( 4 )

end

function PANEL:SetText( text )

	self.BaseClass.SetText( self, text )

	if ( isstring( text ) and string.find( text, "\n", 1, true ) ) then
		self:SetWrap( true )
		self:SetContentAlignment( 7 )
	end

end

vgui.Register( "BWLabel", PANEL, "DLabel" )

local PANEL = {}

function PANEL:Init()

	self:SetSize( 180, 2 )

end

function PANEL:Paint( w, h )

	surface.SetDrawColor( 160, 160, 160, 255 )
	surface.DrawRect( 0, 0, w, h )

end

vgui.Register( "BWDivider", PANEL, "DPanel" )
