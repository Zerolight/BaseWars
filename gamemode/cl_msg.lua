local HUDNote_c = 0
local HUDNote_i = 1
HUDNotesm = {}

local NoticeMaterial = {
	[ 0 ] = Material( "icon16/report_key.png" ),
	[ 1 ] = Material( "icon16/exclamation.png" ),
	[ 2 ] = Material( "icon16/money_add.png" ),
	[ 3 ] = Material( "icon16/information.png" ),
	[ 4 ] = Material( "icon16/error.png" ),
	[ 5 ] = Material( "icon16/money_delete.png" )
}

function GM:AddMessage( str, type, length )

	local tab = {}
	tab.text 	= str
	tab.recv 	= SysTime()
	tab.len 	= length
	tab.velx	= 0
	tab.vely	= 0
	tab.x		= 20
	tab.y		= 0
	tab.a		= 255
	tab.type	= type

	table.insert( HUDNotesm, tab )

	HUDNote_c = HUDNote_c + 1
	HUDNote_i = HUDNote_i + 1

end

local function DrawMessagem( self, k, v, i )

	local H = ScrH() / 1024
	local x = v.x
	local y = v.y

	if ( not v.w ) then

		surface.SetFont( "MessageFont" )
		v.w, v.h = surface.GetTextSize( v.text )

	end

	local w = v.w
	local h = v.h

	w = w + 16
	h = h+((i-1)*v.h)
	y=y+h

	local textcolor = Color(0,250,0,255)
	if v.type== 1 then
		textcolor = Color(250,0,0,255)
	elseif v.type== 2 then
		textcolor = Color(0,100,0,255)
	elseif v.type== 3 then
		textcolor = Color(150,150,0,255)
	elseif v.type== 4 then
		textcolor = Color(150,0,0,255)
	elseif v.type== 5 then
		textcolor = Color(100,0,0,255)
	end
	if LocalPlayer():GetInfoNum("bw_showmessages", 1)==1 then
		draw.SimpleText( v.text, "MessageFont", x+1, y+1, Color(0,0,0,150), TEXT_ALIGN_LEFT )
		draw.SimpleText( v.text, "MessageFont", x, y, textcolor, TEXT_ALIGN_LEFT )
		surface.SetMaterial( NoticeMaterial[ v.type ] or NoticeMaterial[ 3 ] )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( x-19, y, 16, 16)
	end
end

function GM:PaintMessages()
	if LocalPlayer():GetInfoNum("bw_showmessages", 1)==1 then
		if ScrW()>1000 then
			draw.RoundedBox( 10, 10, 10, 570, 170, Color( 30, 30, 30, 100 ) )
		else
			draw.RoundedBox( 10, 10, 10, 450, 130, Color( 30, 30, 30, 100 ) )
		end
	end
	if ( not HUDNotesm ) then return end

	while #HUDNotesm>10 do
		table.remove(HUDNotesm, 1)
	end
	local i = 0
	for k, v in pairs( HUDNotesm ) do

		if ( k ~= 0 ) then

			i = i + 1
			DrawMessagem( self, k, v, i)

		end

	end
end

function MsgManageMessages()
	local text = net.ReadString()
	local type = net.ReadInt(16)
	local time = net.ReadInt(16)
	if GetConVar("bw_showmessages") == nil then
		CreateClientConVar("bw_showmessages", 1, true, false)
	end
	if GetConVar("bw_shownotify") == nil then
		CreateClientConVar("bw_shownotify", 0, true, false)
	end
	if GetConVar("bw_messages_warningnotify") == nil then
		CreateClientConVar("bw_messages_warningnotify", 1, true, false)
	end
	if GetConVar("bw_messages_dontshowincome") == nil then
		CreateClientConVar("bw_messages_dontshowincome", 0, true, false)
	end
	local mode = LocalPlayer():GetInfoNum("bw_showmessages", 1)
	local both = LocalPlayer():GetInfoNum("bw_shownotify", 0)
	local warn = LocalPlayer():GetInfoNum("bw_messages_warningnotify", 1)
	local inc = LocalPlayer():GetInfoNum("bw_messages_dontshowincome", 0)

	if mode==0 then
		GAMEMODE:AddNotify(text,type,time)
	elseif mode==1 then
		if inc==0 or type~=2 then
			GAMEMODE:AddMessage(text,type,time)
		end
	end
	if both==1 and mode==1 then
		GAMEMODE:AddNotify(text,type,time)
	end

	if warn==1 and mode==1 and both==0 and type==1 then
		GAMEMODE:AddNotify(text,type,time)
	end
end
net.Receive("RPDMNotify", MsgManageMessages)
