DeriveGamemode( "sandbox" );

drugeffect_doubletapmod = 0.675

GUIToggled = false;
HelpToggled = false;

HelpLabels = { }
HelpCategories = { }

Tribes = {}

AdminTellAlpha = -1;
AdminTellStartTime = 0;
AdminTellMsg = "";

MoneyAlpha = -1
MoneyY = 0
MoneyAmount = 0

MyMoney = "If you can see this, you should reconnect."

afkbigness = 255
afkdir = true
local Extracrap = { }

if( HelpVGUI ) then
	HelpVGUI:Remove();
end

HelpVGUI = nil;

StunStickFlashAlpha = -1;

local viewpl = nil
local viewpltime = 0

local viewstructure = nil
local viewstructuretime = 0

local bHitActive = false
local flFrameTime = 0
local x
local y

surface.CreateFont( "AFKFont", { font = "ChatFont", size = 72, weight = 700, antialias = true, shadow = false } );

local tsize = 12
if ScrW()>1000 then
	tsize=16
end
surface.CreateFont( "MessageFont", { font = "Default", size = tsize, weight = 500, antialias = true, shadow = false } )

function GM:Initialize()

	self.BaseClass:Initialize();

end

include( "cl_legacy_vgui.lua" );
include( "cl_deaths.lua" );
include( "shared.lua" );
include( "copypasta.lua" );
include( "cl_vgui.lua" );
include( "cl_helpvgui.lua" );
include( "cl_scoreboard.lua" );
include( "cl_msg.lua" );
include( "cl_menu.lua" );
include("swep_fix.lua");
include("vars.lua");

-- Prop protection (and CPPI) now come from the standalone Falco's Prop

surface.CreateFont( "AckBarWriting", { font = "akbar", size = 20, weight = 500, antialias = true, shadow = false } );
surface.CreateFont( "HL2Symbols", { font = "HalfLife2", size = 74, weight = 500, antialias = true, shadow = false } );

function GetTextHeight( font, str )

	surface.SetFont( font );
	local w, h = surface.GetTextSize( str );

	return h;

end

function GetTextWidth( font, str )

	surface.SetFont( font );
	local w, h = surface.GetTextSize( str );

	return w;

end

local function DrawBox(startx, starty, sizex, sizey, color1,color2 )
	draw.RoundedBox( 0, startx, starty, sizex, sizey, color2 )
	draw.RoundedBox( 0, startx+1, starty+1, sizex-2, sizey-2, color1 )
end

function DrawPlayerInfo( ply, scn )

	if( not ply:Alive() ) then return; end

	local pos = ply:EyePos();

	pos.z = pos.z + 14;
	pos = pos:ToScreen();
	local mudkips = 0
	if scn then
		local weapn = ply:GetActiveWeapon()
		local wepclass = "Nothing"
		local wepammo = 0
		if IsValid(weapn) then
			wepclass = weapn:GetClass()
			wepammo = weapn:Clip1()
		end
		draw.DrawText( "H: " .. tostring(ply:Health()) .. " A: " .. tostring(ply:Armor()) .. "\n" .. wepclass .. " " .. wepammo, "TargetID", pos.x + 1, pos.y + 41+mudkips, Color( 0, 0, 0, 255 ), 1 );
		draw.DrawText( "H: " .. tostring(ply:Health()) .. " A: " .. tostring(ply:Armor()) .. "\n" .. wepclass .. " " .. wepammo, "TargetID", pos.x, pos.y+40+mudkips, Color(120,120,120,255), 1 );
	end
end

local Scans = {}

function ScannerSweep()
	local ply = net.ReadEntity()
	local pos = net.ReadVector()
	local num = net.ReadInt(16)
	Scans[num] = {}
	Scans[num].Time = CurTime()+10
	Scans[num].Pos = pos
	Scans[num].Ply = ply
end
net.Receive("RadarScan", ScannerSweep)

function clearscan(index)

	Scans[index] = nil
end

function DrawScans()
	for k, v in pairs(Scans) do
		if v~=nil then
			local ply = v.Ply
			if IsValid(ply) then
				local pos = v.Pos + Vector(0,0,100)

				pos = pos:ToScreen();
				draw.DrawText( ply:Nick(), "TargetID", pos.x + 1, pos.y + 1, Color( 0, 0, 0, 255 ), 1 );
				draw.DrawText( ply:Nick(), "TargetID", pos.x, pos.y, team.GetColor( ply:Team() ), 1 );
				draw.DrawText( "SCAN", "TargetID", pos.x + 1, pos.y-16 + 1, Color( 0, 0, 0, 255 ), 1 );
				draw.DrawText( "SCAN", "TargetID", pos.x, pos.y-16, Color(255,0,0,255 ), 1 );
			end
			if v.Time<CurTime() then
				clearscan(k)
			end
		end
	end
end

function DrawBombInfo( ent )
	if LocalPlayer():GetPos():Distance(ent:GetPos())<2048 and ent:GetNWBool("armed") then
		local pos = ent:GetPos()+ent:GetAngles():Up()*30;

		pos.z = pos.z + 14;
		pos = pos:ToScreen();
		local time = math.ceil(ent:GetNWFloat("goofytiem")-CurTime())
		if time<=2 then
			time = CfgVars["bigbomblastmessage"]
		end
		draw.DrawText( "BOMB\n" .. tostring(time), "TargetID", pos.x + 1, pos.y + 1, Color( 0, 0, 0, 255 ), 1 );
		draw.DrawText( "BOMB\n" .. tostring(time), "TargetID", pos.x, pos.y, Color(255,0,0,255), 1 );
	end
end

function DrawNuclearInfo( ent )
		local pos = ent:GetPos()+ent:GetAngles():Up()*40;

		pos.z = pos.z + 14;
		pos = pos:ToScreen();
		draw.DrawText( "Nuclear Money Printer\n", "TargetID", pos.x + 1, pos.y + 1, Color( 0, 0, 0, 255 ), 1 );
		draw.DrawText( "Nuclear Money Printer\n", "TargetID", pos.x, pos.y, Color(255,0,0,255), 1 );
end

function DrawTurretInfo( ent )
	if LocalPlayer():GetPos():Distance(ent:GetPos())<258 and ent:GetNWBool("NotBuilt") then
		local pos = ent:GetPos()+ent:GetAngles():Up()*25;

		pos.z = pos.z + 14;
		pos = pos:ToScreen();

		draw.DrawText( "Hold 'E' to Activate your Turret", "TargetID", pos.x, pos.y, Color(255,255,255,255), 1 );
	end
end

function DrawStructureInfo3d2d( ent, alpha )
	local pos = ent:GetPos();

	pos.z = pos.z + 14;
	pos = pos:ToScreen();
			if ent:GetClass()=="superpowerplant" then
					DrawBox(pos.x-100, pos.y-50, 350, 100, Color(0,0,0,alpha), Color(50,50,50,alpha*1.5),1)
				else
					DrawBox(pos.x-100, pos.y-50, 200, 100, Color(0,0,0,alpha), Color(50,50,50,alpha*1.5),1)
		end
	local power = ent.Power
	local upgradestring = ""
	local upgrade = ent:GetNWInt("upgrade")
	if upgrade==1 then
		upgradestring= "I"
	elseif upgrade==2 then
		upgradestring = "II"
	elseif upgrade==3 then
		upgradestring = "III"
	elseif upgrade==4 then
		upgradestring = "IV"
	elseif upgrade==5 then
		upgradestring = "V"
	elseif upgrade==6 then
		upgradestring = "VI"
	elseif upgrade==7 then
		upgradestring = "VII"
	elseif upgrade==8 then
		upgradestring = "VIII"
	elseif upgrade==9 then
		upgradestring = "IX"
	elseif upgrade==10 then
		upgradestring = "X"
	end
	if ent:GetClass()=="superpowerplant" then
		draw.DrawText(ent.PrintName, "TargetID", pos.x+49,pos.y-49, Color(0,0,0,alpha*2.55),1)
		draw.DrawText(ent.PrintName, "TargetID", pos.x+50,pos.y-50, Color(100,150,200,alpha*2.55),1)
		draw.RoundedBox(0,pos.x-100,pos.y-28, 350, 1, Color(50,50,50,alpha*1.5))
		draw.RoundedBox(0,pos.x-100,pos.y+27, 350, 1, Color(50,50,50,alpha*1.5))
	else
		draw.DrawText(ent.PrintName, "TargetID", pos.x-9,pos.y-49, Color(0,0,0,alpha*2.55),1)
		draw.DrawText(ent.PrintName, "TargetID", pos.x-10,pos.y-50, Color(100,150,200,alpha*2.55),1)
		draw.RoundedBox(0,pos.x-100,pos.y-28, 200, 1, Color(50,50,50,alpha*1.5))
		draw.RoundedBox(0,pos.x-100,pos.y+27, 200, 1, Color(50,50,50,alpha*1.5))
	end
	if upgrade>0 then
		draw.DrawText(upgradestring, "Default", pos.x+91,pos.y-45, Color(0,0,0,alpha*2.55),1)
		draw.DrawText(upgradestring, "Default", pos.x+90,pos.y-46, Color(200,200,0,alpha*2.55),1)
	end
	local pwr = false
	for i=1,power,1 do
		draw.DrawText( "Z", "HL2Symbols", pos.x-89+(i*30), pos.y-74, Color(0,0,0,alpha*1.55), 1 );
		if ent:GetNWInt("power")>=i then
			draw.DrawText( "Z", "HL2Symbols", pos.x-90+(i*30), pos.y-75, Color(0,255,0,alpha*1.55), 1 );
		else
			pwr = true
			draw.DrawText( "Z", "HL2Symbols", pos.x-90+(i*30), pos.y-75, Color(90,90,90,alpha*1.55), 1 );
		end
	end
	if pwr then
		draw.DrawText("Low power.", "TargetID", pos.x-9,pos.y-1, Color(0,0,0,alpha*2.55),1)
		draw.DrawText("Low power.", "TargetID", pos.x-10,pos.y, Color(150,0,0,alpha*2.55),1)
	end
	if ent:GetTable().TimeToFinish~=nil and ent:GetClass()=="gunfactory" and ent:GetTable().TimeToFinish>CurTime() then
		draw.DrawText(tostring(math.ceil(ent:GetTable().TimeToFinish-CurTime())), "TargetID", pos.x+79,pos.y-1, Color(0,0,0,alpha*2.55),1)
		draw.DrawText(tostring(math.ceil(ent:GetTable().TimeToFinish-CurTime())), "TargetID", pos.x+80,pos.y, Color(150,150,150,alpha*2.55),1)
	end
end

function DrawStructureInfo( ent, alpha )
	local pos = ent:GetPos();

	pos.z = pos.z + 14;
	pos = pos:ToScreen();
			if ent:GetClass()=="superpowerplant" then
					DrawBox(pos.x-100, pos.y-50, 350, 100, Color(0,0,0,alpha), Color(50,50,50,alpha*1.5),1)
				else
					DrawBox(pos.x-100, pos.y-50, 200, 100, Color(0,0,0,alpha), Color(50,50,50,alpha*1.5),1)
		end
	local power = ent.Power
	local upgradestring = ""
	local upgrade = ent:GetNWInt("upgrade")
	if upgrade==1 then
		upgradestring= "I"
	elseif upgrade==2 then
		upgradestring = "II"
	elseif upgrade==3 then
		upgradestring = "III"
	elseif upgrade==4 then
		upgradestring = "IV"
	elseif upgrade==5 then
		upgradestring = "V"
	elseif upgrade==6 then
		upgradestring = "VI"
	elseif upgrade==7 then
		upgradestring = "VII"
	elseif upgrade==8 then
		upgradestring = "VIII"
	elseif upgrade==9 then
		upgradestring = "IX"
	elseif upgrade==10 then
		upgradestring = "X"
	end
	if ent:GetClass()=="superpowerplant" then
		draw.DrawText(ent.PrintName, "TargetID", pos.x+49,pos.y-49, Color(0,0,0,alpha*2.55),1)
		draw.DrawText(ent.PrintName, "TargetID", pos.x+50,pos.y-50, Color(100,150,200,alpha*2.55),1)
		draw.RoundedBox(0,pos.x-100,pos.y-28, 350, 1, Color(50,50,50,alpha*1.5))
		draw.RoundedBox(0,pos.x-100,pos.y+27, 350, 1, Color(50,50,50,alpha*1.5))
	else
		draw.DrawText(ent.PrintName, "TargetID", pos.x-9,pos.y-49, Color(0,0,0,alpha*2.55),1)
		draw.DrawText(ent.PrintName, "TargetID", pos.x-10,pos.y-50, Color(100,150,200,alpha*2.55),1)
		draw.RoundedBox(0,pos.x-100,pos.y-28, 200, 1, Color(50,50,50,alpha*1.5))
		draw.RoundedBox(0,pos.x-100,pos.y+27, 200, 1, Color(50,50,50,alpha*1.5))
	end
	if upgrade>0 then
		draw.DrawText(upgradestring, "Default", pos.x+91,pos.y-45, Color(0,0,0,alpha*2.55),1)
		draw.DrawText(upgradestring, "Default", pos.x+90,pos.y-46, Color(200,200,0,alpha*2.55),1)
	end
	local pwr = false
    local xOff = GetTextWidth( "HL2Symbols" , "*" )
	for i=1,power,1 do
		local xOff = xOff + i*5.3
		draw.DrawText( "*", "HL2Symbols", pos.x-138+(i*30)+xOff, pos.y-51, Color(0,0,0,alpha*1.55), 1 );
		if ent:GetNWInt("power")>=i then
			draw.DrawText( "*", "HL2Symbols", pos.x-139+(i*30)+xOff, pos.y-52, Color(0,255,0,alpha*1.55), 1 );
		else
			pwr = true
			draw.DrawText( "*", "HL2Symbols", pos.x-139+(i*30)+xOff, pos.y-52, Color(90,90,90,alpha*1.55), 1 );
		end
	end
	if pwr then
		draw.DrawText("Low power.", "TargetID", pos.x-9,pos.y-1, Color(0,0,0,alpha*2.55),1)
		draw.DrawText("Low power.", "TargetID", pos.x-10,pos.y, Color(150,0,0,alpha*2.55),1)
	end
	if ent:GetTable().TimeToFinish~=nil and ent:GetClass()=="gunfactory" and ent:GetTable().TimeToFinish>CurTime() then
		draw.DrawText(tostring(math.ceil(ent:GetTable().TimeToFinish-CurTime())), "TargetID", pos.x+79,pos.y-1, Color(0,0,0,alpha*2.55),1)
		draw.DrawText(tostring(math.ceil(ent:GetTable().TimeToFinish-CurTime())), "TargetID", pos.x+80,pos.y, Color(150,150,150,alpha*2.55),1)
	end
	if ent:GetClass()=="powerplant" then
		for i=1,5,1 do
		local xOff = xOff + i*5.3
			draw.DrawText( "*", "HL2Symbols", pos.x-138+(i*30)+xOff, pos.y-51, Color(0,0,0,alpha*1.55), 1 );
			if IsValid(ent:GetNWEntity("socket"..tostring(i))) or ent:GetNWEntity("socket"..tostring(i))==ent then
				render.SetMaterial(Material('cable/redlaser'))
				render.DrawBeam( ent:GetPos(), ent:GetNWEntity("socket"..tostring(i)):GetPos(), 2, 0, 0, Color(255,255,255,255) )
				draw.DrawText( "*", "HL2Symbols", pos.x-139+(i*30)+xOff, pos.y-52, Color(255,0,0,alpha*1.55), 1 );
			else
				draw.DrawText( "*", "HL2Symbols", pos.x-139+(i*30)+xOff, pos.y-52, Color(0,255,0,alpha*1.55), 1 );
			end
		end
	end

		if ent:GetClass()=="superpowerplant" then
		for i=1,10,1 do
        local xOff = xOff + i*3.8
			draw.DrawText( "*", "HL2Symbols", pos.x-142+(i*30)+xOff, pos.y-51, Color(0,0,0,alpha*3.55), 1 );
			if IsValid(ent:GetNWEntity("socket"..tostring(i))) or ent:GetNWEntity("socket"..tostring(i))==ent then
				render.SetMaterial(Material('cable/redlaser'))
				render.DrawBeam( ent:GetPos(), ent:GetNWEntity("socket"..tostring(i)):GetPos(), 2, 0, 0, Color(255,255,255,255) )
				draw.DrawText( "*", "HL2Symbols", pos.x-143+(i*30)+xOff, pos.y-52, Color(255,0,0,alpha*1.55), 1 );
			else
				draw.DrawText( "*", "HL2Symbols", pos.x-143+(i*30)+xOff, pos.y-52, Color(0,255,0,alpha*1.55), 1 );
			end
		end
	end
end

function DrawDisplay()
	local tr = LocalPlayer():GetEyeTrace();
	for k, v in pairs( ents.FindByClass("bigbomb") ) do

		DrawBombInfo( v );

	end
	for k, v in pairs( ents.FindByClass("money_printer_nuclear") ) do

		DrawNuclearInfo( v );

	end
	for k, v in pairs( ents.FindByClass("auto_turret") ) do

		DrawTurretInfo( v );

	end
	DrawScans()

	if not IsValid(tr.Entity) and IsValid(viewpl) and viewpltime>CurTime() and LocalPlayer():GetNWBool("scannered") then
		DrawPlayerInfo(viewpl,LocalPlayer():GetNWBool("scannered"))
	end
	if( tr.Entity~=nil and tr.Entity:IsValid() and tr.Entity:GetPos():Distance( LocalPlayer():GetPos() ) <= 768 ) then

		if( tr.Entity:IsPlayer() ) then
			viewpl = tr.Entity
			viewpltime = CurTime()+.5
			local scanner = LocalPlayer():GetNWBool("scannered")
			if(tr.Entity:GetPos():Distance(LocalPlayer():GetPos())<512 or scanner) then
				DrawPlayerInfo( tr.Entity,scanner );
			end

		elseif (tr.Entity:GetTable().Structure) then
			viewpltime = 0

			if viewstructure==tr.Entity then
				viewstructuretime = viewstructuretime+30*FrameTime()
			else
				viewstructure = tr.Entity
				viewstructuretime = 0
			end
			if viewstructuretime>=30 then
				local scanner = LocalPlayer():GetNWBool("scannered")
				if(tr.Entity:GetPos():Distance(LocalPlayer():GetPos())<256) then
					DrawStructureInfo( tr.Entity, math.Clamp((viewstructuretime-30)*5, 0, 100) );
				end
			end
		else
			if IsValid(viewpl) and viewpltime>CurTime() and LocalPlayer():GetNWBool("scannered") then
				DrawPlayerInfo(viewpl,LocalPlayer():GetNWBool("scannered"))
			end
			viewstructure = nil
			viewstructuretime = 0
		end
	end
end

-- The HUD scales with vertical resolution (1080p baseline) so it stays legible
-- and comparable in size to the default weapon/ammo HUD on any screen.
BW_HUD_SCALE = math.Clamp( ScrH() / 1080, 0.85, 2.5 )
local function BW_S( n ) return math.Round( n * BW_HUD_SCALE ) end

surface.CreateFont( "BWHudMoney", { font = "Roboto", size = BW_S( 32 ), weight = 800, antialias = true } )
surface.CreateFont( "BWHudStat",  { font = "Roboto", size = BW_S( 18 ), weight = 700, antialias = true } )
surface.CreateFont( "BWHudLabel", { font = "Roboto", size = BW_S( 13 ), weight = 600, antialias = true } )

-- Shared bottom-left stack anchors ------------------------------------------
-- The money/health panel is pinned to the bottom-left corner. The status-effect
-- icons and the chatbox stack ABOVE it so nothing overlaps. These helpers are
-- global so cl_chatbox.lua can line the chatbox up with the panel.

-- Height reserved above the panel for the status-effect icon strip. The icons
-- scale with the HUD, so the reserve scales too.
BW_HUD_ICON_STRIP = BW_S( 118 )

-- Y of the top edge of the panel, computed from the tallest (armour-present)
-- layout so elements stacked above it don't shift when armour comes and goes.
function BW_HUDReserveTop()
	local pad    = BW_S( 15 )
	local barH   = BW_S( 20 )
	local rowGap = BW_S( 10 )
	local labelH = draw.GetFontHeight( "BWHudLabel" )
	local moneyH = labelH + draw.GetFontHeight( "BWHudMoney" )
	local barsH  = barH * 2 + rowGap
	local panH   = pad * 2 + moneyH + BW_S( 12 ) + barsH
	return ScrH() - panH - BW_S( 22 )
end

-- Y of the top of the whole bottom-left stack (icon strip + panel); the chatbox
-- sits above this.
function BW_HUDStackTop()
	return BW_HUDReserveTop() - BW_HUD_ICON_STRIP
end

local BW_COL_MUTED  = Color( 142, 152, 168 )
local BW_COL_TEXT   = Color( 240, 243, 248 )
local BW_COL_ACCENT = Color( 90, 175, 255 )
local BW_COL_MONEY  = Color( 92, 226, 142 )
local BW_COL_PANEL  = Color( 20, 22, 28, 230 )

function BW_CommaNumber( n )
	local out = tostring( tonumber( n ) or n or 0 )
	local sign = ""
	if ( string.sub( out, 1, 1 ) == "-" ) then sign, out = "-", string.sub( out, 2 ) end
	local k
	repeat out, k = string.gsub( out, "^(%d+)(%d%d%d)", "%1,%2" ) until k == 0
	return sign .. out
end

-- Rounded track + gradient-ish fill with a glossy top highlight.
local function BW_DrawBar( x, y, w, h, frac, col )
	frac = math.Clamp( frac or 0, 0, 1 )
	local r = math.Round( h * 0.4 )
	draw.RoundedBox( r, x, y, w, h, Color( 0, 0, 0, 150 ) )
	if ( frac > 0 ) then
		local fw = math.max( w * frac, h )
		draw.RoundedBox( r, x, y, fw, h, col )
		surface.SetDrawColor( 255, 255, 255, 34 )
		surface.DrawRect( x + r, y + 1, math.max( fw - r * 2, 1 ), math.floor( h * 0.42 ) )
	end
end

-- One "LABEL  [====== value ======]" stat row.
local function BW_DrawStatRow( x, y, labW, barW, h, label, frac, col, value )
	draw.SimpleText( label, "BWHudLabel", x, y + h * 0.5, BW_COL_MUTED, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	local bx = x + labW
	BW_DrawBar( bx, y, barW, h, frac, col )
	draw.SimpleText( value, "BWHudStat", bx + barW * 0.5 + 1, y + h * 0.5 + 1, Color( 0, 0, 0, 170 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( value, "BWHudStat", bx + barW * 0.5,     y + h * 0.5,     BW_COL_TEXT,           TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function GM:HUDPaint()

	DrawDrugs()

	self.BaseClass:HUDPaint();
	self:PaintMessages()

	local client = LocalPlayer()

	local health = math.max( client:Health(), 0 )
	local armor  = math.max( client:Armor(), 0 )

	local ft = FrameTime() * 8
	BW_HudHealth = Lerp( ft, BW_HudHealth or health, health )
	BW_HudArmor  = Lerp( ft, BW_HudArmor  or armor,  armor  )

	local pad     = BW_S( 15 )
	local labW    = BW_S( 46 )
	local barW    = BW_S( 210 )
	local barH    = BW_S( 20 )
	local rowGap  = BW_S( 10 )
	local bars    = ( armor > 0 ) and 2 or 1
	local accentW = BW_S( 4 )

	local labelH  = draw.GetFontHeight( "BWHudLabel" )
	local moneyFH = draw.GetFontHeight( "BWHudMoney" )
	local moneyH  = labelH + moneyFH
	local barsH   = barH * bars + rowGap * ( bars - 1 )

	local moneyText = "$" .. BW_CommaNumber( MyMoney )
	surface.SetFont( "BWHudMoney" )
	local moneyW   = select( 1, surface.GetTextSize( moneyText ) )
	local contentW = math.max( labW + barW, moneyW )

	local panW = accentW + pad + contentW + pad
	local panH = pad * 2 + moneyH + BW_S( 12 ) + barsH
	local r    = BW_S( 10 )
	local panX = BW_S( 22 )
	local panY = ScrH() - panH - BW_S( 22 )

	draw.RoundedBox( r, panX + BW_S( 2 ), panY + BW_S( 3 ), panW, panH, Color( 0, 0, 0, 80 ) )   -- shadow
	draw.RoundedBox( r, panX, panY, panW, panH, BW_COL_PANEL )                                   -- panel
	draw.RoundedBoxEx( r, panX, panY, accentW, panH, BW_COL_ACCENT, true, false, true, false )   -- accent

	local cx = panX + accentW + pad
	local cy = panY + pad

	draw.SimpleText( "CASH", "BWHudLabel", cx, cy, BW_COL_MUTED, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( moneyText, "BWHudMoney", cx, cy + labelH, BW_COL_MONEY, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	cy = cy + moneyH + BW_S( 8 )

	surface.SetDrawColor( 255, 255, 255, 20 )
	surface.DrawRect( cx, cy, contentW, 1 )
	cy = cy + BW_S( 4 )

	BW_DrawStatRow( cx, cy, labW, barW, barH, "HP", BW_HudHealth / 100, Color( 232, 66, 66 ), math.Round( health ) )
	cy = cy + barH + rowGap

	if ( armor > 0 ) then
		BW_DrawStatRow( cx, cy, labW, barW, barH, "ARMOR", BW_HudArmor / 100, Color( 70, 140, 240 ), math.Round( armor ) )
	end

	if( MoneyAlpha >= 0 ) then
		mul=-0.1
		if MoneyAmount<0 then
			draw.DrawText( tostring(MoneyAmount), "TargetID", 11, MoneyY + 1, Color( 0, 0, 0, MoneyAlpha ), 0 );
			draw.DrawText( tostring(MoneyAmount), "TargetID", 10, MoneyY, Color( 150, 20, 20, MoneyAlpha ), 0 );
		else
			draw.DrawText( "+" .. tostring(MoneyAmount), "TargetID", 11, MoneyY + 1, Color( 0, 0, 0, MoneyAlpha ), 0 );
			draw.DrawText( "+" .. tostring(MoneyAmount), "TargetID", 10, MoneyY, Color( 20, 150, 20, MoneyAlpha ), 0 );
		end
		MoneyAlpha = math.Clamp( MoneyAlpha - (255 * FrameTime()), -1, 255 );
		MoneyY = MoneyY - (50*FrameTime())

	end

	if( LetterAlpha > -1 ) then

		if( LetterY > ScrH() * .25 ) then

			LetterY = math.Clamp( LetterY - 300 * FrameTime(), ScrH() * .25, ScrH() / 2 );

		end

		if( LetterAlpha < 255 ) then

			LetterAlpha = math.Clamp( LetterAlpha + 400 * FrameTime(), 0, 255 );

		end

		local font = "";

		if( LetterType == 1 ) then
			font = "AckBarWriting";
		else
			font = "Default";
		end

		draw.RoundedBox( 2, ScrW() * .2, LetterY, ScrW() * .8 - ( ScrW() * .2 ), ScrH(), Color( 255, 255, 255, math.Clamp( LetterAlpha, 0, 200 ) ) );
		draw.DrawText( LetterMsg, font, ScrW() * .25 + 20, LetterY + 80, Color( 0, 0, 0, LetterAlpha ), 0 );
	end

	DrawDisplay();
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

	if (trace.Entity:IsPlayer()) then
		text = trace.Entity:Nick()
	else

		return
	end

	surface.SetFont( font )
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

	local text = "Health:" .. trace.Entity:Health() .. "%"
	local font = "TargetIDSmall"

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x =  MouseX  - w / 2

	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

	y = y + h + 5

	local text = "Armor:" .. trace.Entity:Armor() .. "%"
	local font = "TargetIDSmall"

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x =  MouseX  - w / 2

	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

end

function GM:HUDShouldDraw( name )

	if( name == "CHudHealth" or name == "CHudBattery" or name == "CHudSuitPower" ) then return false; end
	if( name == "CHudChat" ) then return false; end        -- replaced by the custom BaseWars chatbox

	return true;

end

surface.CreateFont( "ArmorFont", { font = "ChatFont", size = 22, weight = 400, antialias = true, shadow = false } );
surface.CreateFont( "DrugFont", { font = "csd", size = 32, weight = 400, antialias = true, shadow = false } );
surface.CreateFont( "CSDFont", { font = "Counter-Strike", size = 32, weight = 400, antialias = true, shadow = false } );
surface.CreateFont( "DrugFont2", { font = "HalfLife2", size = 50, weight = 400, antialias = true, shadow = false } );

-- HUD-scaled copies of the status-icon fonts, so the status cluster grows with
-- the redesigned panel instead of staying tiny on high-resolution displays.
surface.CreateFont( "BWDrugFontS",  { font = "csd",            size = BW_S( 32 ), weight = 400, antialias = true } );
surface.CreateFont( "BWCSDFontS",   { font = "Counter-Strike", size = BW_S( 32 ), weight = 400, antialias = true } );
surface.CreateFont( "BWDrugFont2S", { font = "HalfLife2",      size = BW_S( 50 ), weight = 400, antialias = true } );
local BW_DRUGFONT_S = { DrugFont = "BWDrugFontS", CSDFont = "BWCSDFontS", DrugFont2 = "BWDrugFont2S" }

function DrawDrugs()
	local effects = 0
	local S = BW_S
	local x = S( 7 )
	-- The status-icon cluster is scaled with the HUD and parked in the reserved
	-- strip just above the money/health panel, so it clears the panel and stays
	-- legible at high resolutions. All offsets below are the original layout
	-- constants run through S() so the arrangement grows in proportion.
	local y = BW_HUDReserveTop() + S( 50 )

	local function Icon( sym, font, ox, oy, col )
		font = BW_DRUGFONT_S[ font ] or font
		draw.DrawText( sym, font, x + S( ox ) + 1, y - S( oy ) + 1, Color( 0, 0, 0, 200 ), 0 )
		draw.DrawText( sym, font, x + S( ox ),     y - S( oy ),     col, 0 )
	end

	if ( LocalPlayer():GetNWBool( "shielded" )      == true ) then Icon( "p", "DrugFont", 128, 110, Color( 255, 255, 255 ) ) end
	if ( LocalPlayer():GetNWBool( "helmeted" )      == true ) then Icon( "E", "DrugFont", 148, 110, Color( 255, 255, 255 ) ) end
	if ( LocalPlayer():GetNWBool( "poisoned" )      == true ) then Icon( "C", "DrugFont",  92,  95, Color(  50, 250,   0 ) ) end
	if ( LocalPlayer():GetNWBool( "scannered" )     == true ) then Icon( "H", "DrugFont", 131,  90, Color( 255, 255, 255 ) ) end
	if ( LocalPlayer():GetNWBool( "tooled" )        == true ) then Icon( "f", "CSDFont",  154,  96, Color( 255, 255, 255 ) ) end
	if ( LocalPlayer():GetNWBool( "nightvisioned" ) == true ) then Icon( "s", "CSDFont",  168,  94, Color( 255, 255, 255 ) ) end

	local effectslots = {}
	effectslots[0] = 0
	effectslots[1] = 0
	effectslots[2] = 0

	for k,v in pairs(drugtable) do
		if LocalPlayer():GetNWBool(drugtable[k].string)==true then
			local off, soff, soff2 = 0, 0, 0
			if ( k == "leech" ) then soff, soff2 = -2, 5 end
			if ( k == "focus" ) then soff = -4 end
			if ( drugtable[k].font == "DrugFont2" ) then off = -25 end

			local d    = drugtable[k]
			local font = BW_DRUGFONT_S[ d.font ] or d.font
			local dx   = x + S( soff + ( effectslots[d.type] * 20 ) - 3 )
			local dy   = y - S( 133 - soff2 - ( d.type * 20 ) - off )
			draw.DrawText( d.symbol, font, dx + 1, dy + 1, Color( 0, 0, 0, 200 ), 0 )
			draw.DrawText( d.symbol, font, dx,     dy,     d.color, 0 )
			effectslots[d.type] = effectslots[d.type] + 1
		end
	end
	DrugTrails()

end

function DrawDrugTrail(color, ent, effect)
	local type = effect or "drug_trail"
	if type==none then return end
	local r = color.r
	local g = color.g
	local b = color.b
	if type=="drug_bolt" then
		local gun = ent:GetActiveWeapon()
		if IsValid(gun) then
			local attachpos = gun:GetAttachment(1)
			if attachpos~=nil then
				local effectdata = EffectData()
					effectdata:SetOrigin( attachpos.Pos )
					effectdata:SetStart( Vector( r, g, b ) )
					effectdata:SetEntity( ent )
					effectdata:SetNormal(ent:GetAimVector())
				util.Effect( effect, effectdata )
			end
		end
	else
		local effectdata = EffectData()
			effectdata:SetOrigin( ent:GetPos() )
			effectdata:SetStart( Vector( r, g, b ) )
			effectdata:SetRadius(64)
			effectdata:SetEntity( ent )
		util.Effect( effect, effectdata )
	end
end

local drawstuff = false
function DrugTrails()
	if drawstuff then
		for i, q in pairs(player.GetAll()) do
			if q~=LocalPlayer() then
				for k,v in pairs(drugtable) do
					if q:GetNWBool(drugtable[k].string)==true and math.random(1,5)>4 then
						local type="drug_trail"
						if drugtable[k].type == 1 then type="drug_glow" end
						if drugtable[k].type == 2 then type="drug_bolt" end
						DrawDrugTrail(drugtable[k].color,q,type)
					end
				end
			end
		end
	end
	drawstuff = not drawstuff
end

function EndStunStickFlash()

	StunStickFlashAlpha = -1;

end

function AdminTell()

	AdminTellStartTime = CurTime();
	AdminTellAlpha = 0;
	AdminTellMsg = net.ReadString();

end
net.Receive( "AdminTell", AdminTell );

LetterY = 0;
LetterAlpha = -1;
LetterMsg = "";
LetterType = 0;
LetterStartTime = 0;
LetterPos = Vector( 0, 0, 0 );

function ShowLetter()

	LetterType = net.ReadInt(16);
	LetterPos = net.ReadVector();
	LetterMsg = net.ReadString();
	LetterY = ScrH() / 2;
	LetterAlpha = 0;
	LetterStartTime = CurTime();

end
net.Receive( "ShowLetter", ShowLetter );

function GM:Think()

	if( LetterAlpha > -1 and LocalPlayer():GetPos():Distance( LetterPos ) > 125 ) then

		LetterAlpha = -1;

	end

end

function KillLetter()

	LetterAlpha = -1;

end
net.Receive( "KillLetter", KillLetter );

function UpdateHelp()

	function tDelayHelp()

		if( HelpVGUI ) then

			HelpVGUI:Remove();

			if( HelpToggled ) then
				HelpVGUI = vgui.Create( "HelpVGUI" );
			end

		end

	end

	timer.Simple( .5, tDelayHelp );

end
net.Receive( "UpdateHelp", UpdateHelp );


function MoneyChange()

	MoneyAmount = net.ReadInt(16)
	MyMoney = net.ReadInt(32)
	MoneyAlpha = 255;
	MoneyY = ScrH() - 75;

end
net.Receive( "MoneyChange", MoneyChange );

GVGUI = { }
PanelNumg = 0;

function MsgGunVault()
	local gunlist = string.Explode(",", net.ReadString() )
	local vault = net.ReadInt(16)
	local upgradelist = string.Explode(",", net.ReadString() )
	local inputenabled = false;
	if( HelpToggled or GUIToggled ) then
		inputenabled = true;
	end
	local panel = vgui.Create( "BWFrame" );
	panel:SetPos( ScrW()/2-200 , ScrH() / 2 - 50 );
	panel:SetName( "Panel" );
	panel:LoadControlsFromString( [[

		"GVPanel"
		{

			"Panel"
			{

				"ControlName" "Panel"
				"fieldName" "Vote"
				"wide" "160"
				"tall" "200"
				"sizable" "0"
				"enabled" "1"
				"title" "Select gun."

			}

		}

	]] );
	panel:SetKeyboardInputEnabled( false );
	panel:SetMouseInputEnabled( true );
	panel:SetVisible( true );
	local divider = vgui.Create( "BWDivider" );
	divider:SetParent( panel );
	divider:SetPos( 2, 30 );
	divider:SetSize( 180, 2 );
	divider:SetVisible( true );
	local ybutton = {}
	local upgradelabel = {}
	if gunlist[1]~="" then
		for i=1, table.Count(gunlist), 1 do
			_G["PickFunc" .. i] = function( msg )
				LocalPlayer():ConCommand( "withdrawgun " .. vault .. " " .. i .. "\n" );
			end

			ybutton[i] = vgui.Create( "BWButton" );
			ybutton[i]:SetParent( panel );
			ybutton[i]:SetPos( 15, 20+(i*15) );
			ybutton[i]:SetSize( 130, 14 );
			ybutton[i]:SetCommand( "!" );
			local gunname = gunlist[i]
			ybutton[i]:SetText( gunname );
			ybutton[i]:SetActionFunction( _G["PickFunc" .. i] );
			ybutton[i]:SetVisible( true );

			table.insert( GVGUI, ybutton[i] );

			if (util.tobool(upgradelist[i])) then
				upgradelabel[i] = vgui.Create("BWLabel")
				upgradelabel[i]:SetParent(panel)
				upgradelabel[i]:SetPos(146, 18+(i*15))
				upgradelabel[i]:SetSize(12,12)
				upgradelabel[i]:SetText("+")
				upgradelabel[i]:SetVisible(true)

				table.insert(GVGUI, upgradelabel[i])
			end

		end
	else

		local label = vgui.Create( "BWLabel" );
		label:SetParent( panel );
		label:SetPos( 15, 45 );
		label:SetSize( 130, 40 );
		label:SetText( "This Gun Vault is empty. \nDrop guns into it before \ntrying to take guns out." );
		label:SetVisible( true );
		table.insert( GVGUI, label )
	end
	PanelNumg = PanelNumg + 1;
	GVGUI[vault] = panel;
end
net.Receive( "gunvaultgui", MsgGunVault );

function MsgDrugFactory()
	local upgrade = net.ReadInt(16)
	local vault = net.ReadInt(16)
	local booze = net.ReadInt(16)
	local drugs = net.ReadInt(16)
	local rands = net.ReadInt(16)
	local sdefense = net.ReadInt(16)
	local soffense = net.ReadInt(16)
	local sweapmod = net.ReadInt(16)
	local mode = net.ReadInt(16)

	local inputenabled = false;
	if( HelpToggled or GUIToggled ) then
		inputenabled = true;
	end
	local panel = vgui.Create( "BWFrame" );
	panel:SetPos( ScrW()/2-200 , ScrH() / 2 - 50 );
	panel:SetName( "Panel" );
	panel:LoadControlsFromString( [[

		"GVPanel"
		{

			"Panel"
			{

				"ControlName" "Panel"
				"fieldName" "Vote"
				"wide" "160"
				"tall" "210"
				"sizable" "0"
				"enabled" "1"
				"title" "Drug Refinery"

			}

		}

	]] );
	panel:SetKeyboardInputEnabled( false );
	panel:SetMouseInputEnabled( true );
	panel:SetVisible( true );
	local divider = vgui.Create( "BWDivider" );
	divider:SetParent( panel );
	divider:SetPos( 2, 30 );
	divider:SetSize( 180, 2 );
	divider:SetVisible( true );
	local ybutton = {}
	local ylabel = {}

	local maxbooze = 25
	local maxdrug = 25
	if upgrade==1 then
		maxdrug=25
		maxbooze=25
	elseif upgrade==2 then
		maxdrug=15
		maxbooze=15
	end

	ylabel[1] = vgui.Create( "BWLabel" );
	ylabel[1]:SetParent( panel );
	ylabel[1]:SetPos( 15, 35 );
	ylabel[1]:SetSize( 130, 14 );
	ylabel[1]:SetText( "Booze: "..tostring(booze).."/"..tostring(maxbooze) );
	ylabel[1]:SetVisible(true)
	table.insert( GVGUI, ylabel[1] );

	ylabel[2] = vgui.Create( "BWLabel" );
	ylabel[2]:SetParent( panel );
	ylabel[2]:SetPos( 15, 50 );
	ylabel[2]:SetSize( 130, 14 );
	ylabel[2]:SetText( "Drugs: "..tostring(drugs).."/"..tostring(maxdrug) );
	ylabel[2]:SetVisible( true );
	table.insert( GVGUI, ylabel[2] );

	ylabel[3] = vgui.Create( "BWLabel" );
	ylabel[3]:SetParent( panel );
	ylabel[3]:SetPos( 15, 65 );
	ylabel[3]:SetSize( 130, 14 );
	ylabel[3]:SetText( "RandomDrugs: "..tostring(rands).."/10" );
	ylabel[3]:SetVisible( true );
	table.insert( GVGUI, ylabel[3] );

	ylabel[4] = vgui.Create( "BWLabel" );
	ylabel[4]:SetParent( panel );
	ylabel[4]:SetPos( 15, 80 );
	ylabel[4]:SetSize( 130, 14 );
	ylabel[4]:SetText( "Superdrugs: "..tostring(soffense).."/3, "..tostring(sdefense).."/3, "..tostring(sweapmod).."/3" );
	ylabel[4]:SetVisible( true );
	table.insert( GVGUI, ylabel[4] );

	local rmode = "$10,000"
	if mode==1 then rmode="S. Offense"
	elseif mode==2 then rmode="S. Defense"
	elseif mode==3 then rmode="S. Weapon Mod"
	end

	ylabel[5] = vgui.Create( "BWLabel" );
	ylabel[5]:SetParent( panel );
	ylabel[5]:SetPos( 15, 95 );
	ylabel[5]:SetSize( 130, 14 );
	ylabel[5]:SetText( "Refining to "..rmode );
	ylabel[5]:SetVisible( true );
	table.insert( GVGUI, ylabel[5] );

	_G["PickFunc1"] = function( msg )
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " money\n" );
	end
	_G["PickFunc2"] = function( msg )
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " offense\n" );
	end
	_G["PickFunc3"] = function( msg )
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " defense\n" );
	end
	_G["PickFunc4"] = function( msg )
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " weapmod\n" );
	end
	_G["PickFunc5"] = function (msg)
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " eject\n" );
	end
	_G["PickFunc6"] = function(msg)
		LocalPlayer():ConCommand("setrefinerymode "..vault.." uber\n")
	end
	ybutton[1] = vgui.Create( "BWButton" );
	ybutton[1]:SetParent( panel );
	ybutton[1]:SetPos( 15, 110 );
	ybutton[1]:SetSize( 130, 14 );
	ybutton[1]:SetCommand( "!" );
	ybutton[1]:SetText( "Eject Money" );
	ybutton[1]:SetActionFunction( _G["PickFunc5"] );
	ybutton[1]:SetVisible( true );
	table.insert( GVGUI, ybutton[1] );

	ybutton[5] = vgui.Create( "BWButton" );
	ybutton[5]:SetParent( panel );
	ybutton[5]:SetPos( 15, 125 );
	ybutton[5]:SetSize( 130, 14 );
	ybutton[5]:SetCommand( "!" );
	ybutton[5]:SetText( "Refine to Money" );
	ybutton[5]:SetActionFunction( _G["PickFunc1"] );
	ybutton[5]:SetVisible( true );
	table.insert( GVGUI, ybutton[5] );
	local ymod=0
	table.insert( GVGUI, ybutton[1] );
	PanelNumg = PanelNumg + 1;
	GVGUI[vault] = panel;
end
net.Receive( "drugfactorygui", MsgDrugFactory );


function TestDrawHud()

local struc = {}
struc.pos = {}
struc.pos[1] = ScrW()*.5
struc.pos[2] = ScrH()*.005
struc.color = Color(0,0,0,255)
struc.text = "LmaoLlama BaseWars - 1.8"
struc.font = "DefaultFixed"
struc.xalign = TEXT_ALIGN_CENTER
struc.yalign = TEXT_ALIGN_CENTER
draw.Text( struc )

end
hook.Add("HUDPaint", "HUD_TEST", TestDrawHud)

function MsgPillBox()
	local gunlist = string.Explode(",", net.ReadString() )
	local vault = net.ReadInt(16)

	local inputenabled = false;
	if( HelpToggled or GUIToggled ) then
		inputenabled = true;
	end
	local panel = vgui.Create( "BWFrame" );
	panel:SetPos( ScrW()/2-200 , ScrH() / 2 - 50 );
	panel:SetName( "Panel" );
	panel:LoadControlsFromString( [[

		"GVPanel"
		{

			"Panel"
			{

				"ControlName" "Panel"
				"fieldName" "Vote"
				"wide" "320"
				"tall" "200"
				"sizable" "0"
				"enabled" "1"
				"title" "Select item."

			}

		}

	]] );
	panel:SetKeyboardInputEnabled( false );
	panel:SetMouseInputEnabled( true );
	panel:SetVisible( true );
	local divider = vgui.Create( "BWDivider" );
	divider:SetParent( panel );
	divider:SetPos( 2, 30 );
	divider:SetSize( 360, 2 );
	divider:SetVisible( true );
	local ybutton = {}
	local upgradelabel = {}
	if gunlist[1]~="" then
		for i=1, table.Count(gunlist), 1 do
			_G["PickFunc" .. i] = function( msg )
				LocalPlayer():ConCommand( "withdrawitem " .. vault .. " " .. i .. "\n" );
			end

			ybutton[i] = vgui.Create( "BWButton" );
			ybutton[i]:SetParent( panel );
			if (i>10) then
				ybutton[i]:SetPos( 15+135, 20+((i-10)*15) )
			else
				ybutton[i]:SetPos( 15, 20+(i*15) );
			end
			ybutton[i]:SetSize( 130, 14 );
			ybutton[i]:SetCommand( "!" );
			local gunname = gunlist[i]
			ybutton[i]:SetText( gunname );
			ybutton[i]:SetActionFunction( _G["PickFunc" .. i] );
			ybutton[i]:SetVisible( true );

			table.insert( GVGUI, ybutton[i] );

		end
	else

		local label = vgui.Create( "BWLabel" );
		label:SetParent( panel );
		label:SetPos( 15, 45 );
		label:SetSize( 130, 40 );
		label:SetText( "This Pill Box is empty. \nDrop items into it before \ntrying to take items out." );
		label:SetVisible( true );
		table.insert( GVGUI, label )
	end
	PanelNumg = PanelNumg + 1;
	GVGUI[vault] = panel;
end
net.Receive( "pillboxgui", MsgPillBox );


function MsgGunFactory()
	local upgrade = net.ReadInt(16)
	local vault = net.ReadInt(16)
	local inputenabled = false;
	local cancelmode = net.ReadBool()
	if( HelpToggled or GUIToggled ) then
		inputenabled = true;
	end
	local panel = vgui.Create( "BWFrame" );
	panel:SetPos( ScrW()/2-200 , ScrH() / 2 - 50 );
	panel:SetName( "Panel" );
	local ttl = "Select weapon."
	if cancelmode then
		ttl = "Cancel weapon"
	end
	panel:LoadControlsFromString( [[

		"GVPanel"
		{

			"Panel"
			{

				"ControlName" "Panel"
				"fieldName" "Vote"
				"wide" "160"
				"tall" "140"
				"sizable" "0"
				"enabled" "1"
				"title" "]]..ttl..[["

			}

		}

	]] );
	panel:SetKeyboardInputEnabled( false );
	panel:SetMouseInputEnabled( true );
	panel:SetVisible( true );
	local divider = vgui.Create( "BWDivider" );
	divider:SetParent( panel );
	divider:SetPos( 2, 30 );
	divider:SetSize( 180, 2 );
	divider:SetVisible( true );
	local ybutton = {}
	_G["PickFunc1"] = function( msg )
		LocalPlayer():ConCommand( "setgunfactoryweapon " .. vault .. " laserbeam\n" );
	end
	_G["PickFunc2"] = function( msg )
		LocalPlayer():ConCommand( "setgunfactoryweapon " .. vault .. " laserrifle\n" );
	end
	_G["PickFunc3"] = function( msg )
		LocalPlayer():ConCommand( "setgunfactoryweapon " .. vault .. " grenadegun\n" );
	end
	_G["PickFunc4"] = function( msg )
		LocalPlayer():ConCommand( "setgunfactoryweapon " .. vault .. " worldslayer\n" );
	end
	_G["PickFunc5"] = function (msg)
		LocalPlayer():ConCommand( "setgunfactoryweapon " .. vault .. " resetbutton\n" );
	end
	_G["PickFunc6"] = function (msg)
		LocalPlayer():ConCommand( "setgunfactoryweapon " .. vault .. " plasma\n" );
	end
	_G["PickFunc7"] = function (msg)
		LocalPlayer():ConCommand( "setgunfactoryweapon " .. vault .. " minigun\n" );
	end
	if not cancelmode then
	ybutton[1] = vgui.Create( "BWButton" );
	ybutton[1]:SetParent( panel );
	ybutton[1]:SetPos( 15, 35 );
	ybutton[1]:SetSize( 130, 14 );
	ybutton[1]:SetCommand( "!" );
	ybutton[1]:SetText( "Laser" );
	ybutton[1]:SetActionFunction( _G["PickFunc1"] );
	ybutton[1]:SetVisible( true );
	table.insert( GVGUI, ybutton[1] );

	ybutton[2] = vgui.Create( "BWButton" );
	ybutton[2]:SetParent( panel );
	ybutton[2]:SetPos( 15, 50 );
	ybutton[2]:SetSize( 130, 14 );
	ybutton[2]:SetCommand( "!" );
	ybutton[2]:SetText( "Laser Rifle" );
	ybutton[2]:SetActionFunction( _G["PickFunc2"] );
	ybutton[2]:SetVisible( true );
	table.insert( GVGUI, ybutton[2] );

	if upgrade>=1 then
		ybutton[3] = vgui.Create( "BWButton" );
		ybutton[3]:SetParent( panel );
		ybutton[3]:SetPos( 15, 65 );
		ybutton[3]:SetSize( 130, 14 );
		ybutton[3]:SetCommand( "!" );
		ybutton[3]:SetText( "Grenade Launcher" );
		ybutton[3]:SetActionFunction( _G["PickFunc3"] );
		ybutton[3]:SetVisible( true );
		table.insert( GVGUI, ybutton[3] );

		ybutton[4] = vgui.Create( "BWButton" );
		ybutton[4]:SetParent( panel );
		ybutton[4]:SetPos( 15, 80 );
		ybutton[4]:SetSize( 130, 14 );
		ybutton[4]:SetCommand( "!" );
		ybutton[4]:SetText( "AR2 Pulse Rifle" );
		ybutton[4]:SetActionFunction( _G["PickFunc6"] );
		ybutton[4]:SetVisible( true );
		table.insert( GVGUI, ybutton[4] );
	end

	if upgrade>=2 then
		ybutton[5] = vgui.Create( "BWButton" );
		ybutton[5]:SetParent( panel );
		ybutton[5]:SetPos( 15, 95 );
		ybutton[5]:SetSize( 130, 14 );
		ybutton[5]:SetCommand( "!" );
		ybutton[5]:SetText( "Worldslayer" );
		ybutton[5]:SetActionFunction( _G["PickFunc4"] );
		ybutton[5]:SetVisible( true );
		table.insert( GVGUI, ybutton[5] );

		ybutton[6] = vgui.Create( "BWButton" );
		ybutton[6]:SetParent( panel );
		ybutton[6]:SetPos( 15, 110 );
		ybutton[6]:SetSize( 130, 14 );
		ybutton[6]:SetCommand( "!" );
		ybutton[6]:SetText( "Minigun" );
		ybutton[6]:SetActionFunction( _G["PickFunc7"] );
		ybutton[6]:SetVisible( true );
		table.insert( GVGUI, ybutton[6] );

	end
	else
	ybutton[1] = vgui.Create( "BWButton" );
	ybutton[1]:SetParent( panel );
	ybutton[1]:SetPos( 15, 35 );
	ybutton[1]:SetSize( 130, 14 );
	ybutton[1]:SetCommand( "!" );
	ybutton[1]:SetText( "Cancel" );
	ybutton[1]:SetActionFunction( _G["PickFunc5"] );
	ybutton[1]:SetVisible( true );
	table.insert( GVGUI, ybutton[1] );
	end
	PanelNumg = PanelNumg + 1;
	GVGUI[vault] = panel;
end
net.Receive( "gunfactorygui", MsgGunFactory );

function MsgGunFactoryGet()
	local time = net.ReadFloat()
	local ent = net.ReadEntity()
	if IsValid(ent) then
		ent:GetTable().TimeToFinish = time
	end
end
net.Receive( "gunfactoryget", MsgGunFactoryGet );

function KillGunVaultGUI()

	local vault = net.ReadInt(16);

	if( GVGUI[vault] ) then

		for k, v in pairs( GVGUI ) do

			if( v:GetParent() == GVGUI[vault] ) then

				v:Remove();
				GVGUI[k] = nil;

			end

		end

		GVGUI[vault]:Remove();

		GVGUI[vault] = nil;

		PanelNumg = PanelNumg - 1;

	end

end
net.Receive( "killgunvaultgui", KillGunVaultGUI );

function KillPillBoxGUI()

	local vault = net.ReadInt(16);

	if( GVGUI[vault] ) then

		for k, v in pairs( GVGUI ) do

			if( v:GetParent() == GVGUI[vault] ) then

				v:Remove();
				GVGUI[k] = nil;

			end

		end

		GVGUI[vault]:Remove();

		GVGUI[vault] = nil;

		PanelNumg = PanelNumg - 1;

	end

end
net.Receive( "killpillboxgui", KillPillBoxGUI );


function KillGunFactoryGUI()

	local vault = net.ReadInt(16);

	if( GVGUI[vault] ) then

		for k, v in pairs( GVGUI ) do

			if( v:GetParent() == GVGUI[vault] ) then

				v:Remove();
				GVGUI[k] = nil;

			end

		end

		GVGUI[vault]:Remove();

		GVGUI[vault] = nil;

		PanelNumg = PanelNumg - 1;

	end

end
net.Receive( "killgunfactorygui", KillGunFactoryGUI );


function msgShockWaveEffect()
	local start = net.ReadVector()
	local norm = net.ReadAngle()
	local radius = net.ReadInt(16)
	local efdt = EffectData()
		efdt:SetStart(start)
		efdt:SetOrigin(start)
		efdt:SetScale(1)
		efdt:SetRadius(radius)
		efdt:SetNormal(norm)
	util.Effect("cball_bounce",efdt)
end
net.Receive("shockwaveeffect", msgShockWaveEffect)

function MsgDrugFactory()
	local upgrade = net.ReadInt(16)
	local vault = net.ReadInt(16)
	local booze = net.ReadInt(16)
	local drugs = net.ReadInt(16)
	local rands = net.ReadInt(16)
	local sdefense = net.ReadInt(16)
	local soffense = net.ReadInt(16)
	local sweapmod = net.ReadInt(16)
	local mode = net.ReadInt(16)

	local inputenabled = false;
	if( HelpToggled or GUIToggled ) then
		inputenabled = true;
	end
	local panel = vgui.Create( "BWFrame" );
	panel:SetPos( ScrW()/2-200 , ScrH() / 2 - 50 );
	panel:SetName( "Panel" );
	panel:LoadControlsFromString( [[

		"GVPanel"
		{

			"Panel"
			{

				"ControlName" "Panel"
				"fieldName" "Vote"
				"wide" "160"
				"tall" "210"
				"sizable" "0"
				"enabled" "1"
				"title" "Drug Refinery"

			}

		}

	]] );
	panel:SetKeyboardInputEnabled( false );
	panel:SetMouseInputEnabled( true );
	panel:SetVisible( true );
	local divider = vgui.Create( "BWDivider" );
	divider:SetParent( panel );
	divider:SetPos( 2, 30 );
	divider:SetSize( 180, 2 );
	divider:SetVisible( true );
	local ybutton = {}
	local ylabel = {}

	local maxbooze = 50
	local maxdrug = 100
	if upgrade==1 then
		maxdrug=70
		maxbooze=40
	elseif upgrade==2 then
		maxdrug=50
		maxbooze=30
	end

	ylabel[1] = vgui.Create( "BWLabel" );
	ylabel[1]:SetParent( panel );
	ylabel[1]:SetPos( 15, 35 );
	ylabel[1]:SetSize( 130, 14 );
	ylabel[1]:SetText( "Booze: "..tostring(booze).."/"..tostring(maxbooze) );
	ylabel[1]:SetVisible(true)
	table.insert( GVGUI, ylabel[1] );

	ylabel[2] = vgui.Create( "BWLabel" );
	ylabel[2]:SetParent( panel );
	ylabel[2]:SetPos( 15, 50 );
	ylabel[2]:SetSize( 130, 14 );
	ylabel[2]:SetText( "Drugs: "..tostring(drugs).."/"..tostring(maxdrug) );
	ylabel[2]:SetVisible( true );
	table.insert( GVGUI, ylabel[2] );

	ylabel[3] = vgui.Create( "BWLabel" );
	ylabel[3]:SetParent( panel );
	ylabel[3]:SetPos( 15, 65 );
	ylabel[3]:SetSize( 130, 14 );
	ylabel[3]:SetText( "RandomDrugs: "..tostring(rands).."/10" );
	ylabel[3]:SetVisible( true );
	table.insert( GVGUI, ylabel[3] );

	ylabel[4] = vgui.Create( "BWLabel" );
	ylabel[4]:SetParent( panel );
	ylabel[4]:SetPos( 15, 80 );
	ylabel[4]:SetSize( 130, 14 );
	ylabel[4]:SetText( "Superdrugs: "..tostring(soffense).."/3, "..tostring(sdefense).."/3, "..tostring(sweapmod).."/3" );
	ylabel[4]:SetVisible( true );
	table.insert( GVGUI, ylabel[4] );

	local rmode = "Money"
	if mode==1 then rmode="S. Offense"
	elseif mode==2 then rmode="S. Defense"
	elseif mode==3 then rmode="S. Weapon Mod"
	end

	ylabel[5] = vgui.Create( "BWLabel" );
	ylabel[5]:SetParent( panel );
	ylabel[5]:SetPos( 15, 95 );
	ylabel[5]:SetSize( 130, 14 );
	ylabel[5]:SetText( "Refining to "..rmode );
	ylabel[5]:SetVisible( true );
	table.insert( GVGUI, ylabel[5] );

	_G["PickFunc1"] = function( msg )
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " money\n" );
	end
	_G["PickFunc2"] = function( msg )
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " offense\n" );
	end
	_G["PickFunc3"] = function( msg )
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " defense\n" );
	end
	_G["PickFunc4"] = function( msg )
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " weapmod\n" );
	end
	_G["PickFunc5"] = function (msg)
		LocalPlayer():ConCommand( "setrefinerymode " .. vault .. " eject\n" );
	end
	_G["PickFunc6"] = function(msg)
		LocalPlayer():ConCommand("setrefinerymode "..vault.." uber\n")
	end
	ybutton[1] = vgui.Create( "BWButton" );
	ybutton[1]:SetParent( panel );
	ybutton[1]:SetPos( 15, 110 );
	ybutton[1]:SetSize( 130, 14 );
	ybutton[1]:SetCommand( "!" );
	ybutton[1]:SetText( "Eject SuperDrugs" );
	ybutton[1]:SetActionFunction( _G["PickFunc5"] );
	ybutton[1]:SetVisible( true );
	table.insert( GVGUI, ybutton[1] );

	ybutton[5] = vgui.Create( "BWButton" );
	ybutton[5]:SetParent( panel );
	ybutton[5]:SetPos( 15, 125 );
	ybutton[5]:SetSize( 130, 14 );
	ybutton[5]:SetCommand( "!" );
	ybutton[5]:SetText( "Refine to Money" );
	ybutton[5]:SetActionFunction( _G["PickFunc1"] );
	ybutton[5]:SetVisible( true );
	table.insert( GVGUI, ybutton[5] );
	local ymod=0
	if upgrade>=1 then
		ybutton[2] = vgui.Create( "BWButton" );
		ybutton[2]:SetParent( panel );
		ybutton[2]:SetPos( 15, 140 );
		ybutton[2]:SetSize( 130, 14 );
		ybutton[2]:SetCommand( "!" );
		ybutton[2]:SetText( "Refine to Offense" );
		ybutton[2]:SetActionFunction( _G["PickFunc2"] );
		ybutton[2]:SetVisible( true );
		table.insert( GVGUI, ybutton[2] );

		ybutton[3] = vgui.Create( "BWButton" );
		ybutton[3]:SetParent( panel );
		ybutton[3]:SetPos( 15, 155 );
		ybutton[3]:SetSize( 130, 14 );
		ybutton[3]:SetCommand( "!" );
		ybutton[3]:SetText( "Refine to Defense" );
		ybutton[3]:SetActionFunction( _G["PickFunc3"] );
		ybutton[3]:SetVisible( true );
		table.insert( GVGUI, ybutton[3] );

		ybutton[4] = vgui.Create( "BWButton" );
		ybutton[4]:SetParent( panel );
		ybutton[4]:SetPos( 15, 170 );
		ybutton[4]:SetSize( 130, 14 );
		ybutton[4]:SetCommand( "!" );
		ybutton[4]:SetText( "Refine to Weapon Mod" );
		ybutton[4]:SetActionFunction( _G["PickFunc4"] );
		ybutton[4]:SetVisible( true );
		table.insert( GVGUI, ybutton[4] );
		ymod = 45
	end
	if upgrade>=2 and soffense>=3 and sdefense>=3 and sweapmod>=3 then
		ybutton[6] = vgui.Create( "BWButton" );
		ybutton[6]:SetParent( panel );
		ybutton[6]:SetPos( 15, 140+ymod );
		ybutton[6]:SetSize( 130, 14 );
		ybutton[6]:SetCommand( "!" );
		ybutton[6]:SetText( "Create UberDrug" );
		ybutton[6]:SetActionFunction( _G["PickFunc6"] );
		ybutton[6]:SetVisible( true );
		table.insert( GVGUI, ybutton[6] );
	end
	table.insert( GVGUI, ybutton[1] );
	PanelNumg = PanelNumg + 1;
	GVGUI[vault] = panel;
end
net.Receive( "drugfactorygui", MsgDrugFactory );

function KillDrugFactoryGUI()

	local vault = net.ReadInt(16);

	if( GVGUI[vault] ) then

		for k, v in pairs( GVGUI ) do

			if( v:GetParent() == GVGUI[vault] ) then

				v:Remove();
				GVGUI[k] = nil;

			end

		end

		GVGUI[vault]:Remove();

		GVGUI[vault] = nil;

		PanelNumg = PanelNumg - 1;

	end

end
net.Receive( "killdrugfactorygui", KillDrugFactoryGUI );

function Curtime()
	return CurTime()
end

language.Add("CombineCannon_ammo", "Flamethrower Fuel")
language.Add("SniperRound_ammo", "Sniper Rounds")
language.Add("SMG_ammo", "Rifle Rounds")
language.Add("Pistol_ammo", "Pistol Ammo")
language.Add("SLAM_ammo", "Grenades")
language.Add("XBowBolt_ammo", "Dart Gun Bolts")
language.Add("env_fire", "Fire")
language.Add("env_physexplosion", "The Game")
language.Add("entityflame", "Flames")
language.Add("env_explosion", "Explosion")
language.Add("SBoxLimit_magnets", "You have hit the Magnet limit!")

function GM.OpenTribeMenu()
         local GM = GAMEMODE

         if not IsValid(GM.TribeMenu) then
             GM.TribeMenu = vgui.Create("GMS_TribeMenu")
             GM.TribeMenu:MakePopup()
             return
         end

         local show = not GM.TribeMenu:IsVisible()
         GM.TribeMenu:SetVisible(show)
         if show then GM.TribeMenu:MakePopup() end
end

concommand.Add("bw_factionmenu",GM.OpenTribeMenu)

function GM.getTribes()
	team.SetUp(net.ReadInt(16),net.ReadString(),Color(net.ReadInt(16),net.ReadInt(16),net.ReadInt(16),255))
end
net.Receive("recvTribes",GM.getTribes)

function GM.ReceiveTribe()
	local name = net.ReadString()
	local id = net.ReadInt(16)
	local red = net.ReadInt(16)
	local green = net.ReadInt(16)
	local blue = net.ReadInt(16)
	team.SetUp(id,name,Color(red,green,blue,255))
end
net.Receive("newTribe",GM.ReceiveTribe)

hook.Add( "PlayerTraceAttack", "PlayerHitMarker", function( ply, dmginfo, dir, trace )
  if ( dmginfo:GetAttacker() == LocalPlayer() ) then
    bHitActive = true
	flFrameTime = CurTime() + FrameTime() * 15
  end
end )

hook.Add( "HUDPaint", "CHitMarker", function()

  local player	= LocalPlayer()
  if ( not player:Alive() ) then return end

  if ( not gamemode.Call( "HUDShouldDraw", "CHitMarker" ) ) then return end

  if ( bHitActive and flFrameTime > CurTime() ) then
	x = ScrW() / 2
	y = ScrH() / 2
	surface.SetDrawColor( 255, 255, 255, 200 )
	surface.DrawLine( x+7, y-7, x+15, y-15 )
	surface.DrawLine( x-7, y+7, x-15, y+15 )
	surface.DrawLine( x+7, y+7, x+15, y+15 )
	surface.DrawLine( x-7, y-7, x-15, y-15 )
  else
    bHitActive = false
  end

end )

local DoorType = {"func_door","prop_door_rotating","func_door_rotating"}

hook.Add("HUDPaint", "DoorTrace", function()
	local pos = LocalPlayer():GetShootPos()
	local ang = LocalPlayer():GetAimVector()
	local trd = {}
	trd.start = pos
	trd.endpos = pos+(ang*300)
	trd.filter = LocalPlayer()
	local tr = util.TraceLine(trd)
		if tr.HitNonWorld then
			local tar = tr.Entity

			if tar:GetPos():Distance(LocalPlayer():GetPos()) < 300 then
				if table.HasValue(DoorType, tar:GetClass()) then
					if tar:GetNWInt("State") == 0 then
						draw.DrawText("Unowned Door", "HUDNumber2", ScrW()/2, ScrH()/2, Color(0, 0, 0),TEXT_ALIGN_CENTER)
						draw.DrawText("Unowned Door", "HUDNumber2", ScrW()/2-1, ScrH()/2-1, Color(0, 143, 52),TEXT_ALIGN_CENTER)
						local prop = tar:GetNWString("Property", "None")
						draw.DrawText("Property: "..prop, "Trebuchet20", ScrW()/2, ScrH()/2+40, Color(255, 255, 255),TEXT_ALIGN_CENTER)
						draw.DrawText("Price: "..tar:GetNWInt("Price", 75), "Trebuchet20", ScrW()/2, ScrH()/2+60, Color(255, 255, 255),TEXT_ALIGN_CENTER)
					elseif tar:GetNWInt("State") == 1 then
						local own = tar:GetNWEntity("DOwner")
						local w, h = surface.GetTextSize("Owned By: "..own:Nick())
						draw.DrawText("Owned By: "..own:Nick(), "HUDNumber2", ScrW()/2, ScrH()/2, Color(0, 0, 0),TEXT_ALIGN_CENTER)
						draw.DrawText("Owned By: "..own:Nick(), "HUDNumber2", ScrW()/2-1, ScrH()/2-1, Color(255, 143, 4),TEXT_ALIGN_CENTER)
						local prop = tar:GetNWString("Property", "None")
						draw.DrawText("Property: "..prop, "Trebuchet20", ScrW()/2, ScrH()/2+40, Color(255, 255, 255),TEXT_ALIGN_CENTER)
					end
				end
			end
		end
end)

include( "cl_chatbox.lua" )
