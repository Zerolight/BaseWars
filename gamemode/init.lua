DeriveGamemode( "sandbox" );

for _, name in ipairs( {
	"MoneyChange", "MoneyVaultMenu",
	"PlrKilled", "PlrKilledPlr", "PlrKilledSelf",
	"RPDMNotify", "shockwaveeffect",
	"killgunvaultgui", "killpillboxgui", "killgunfactorygui", "killdrugfactorygui",
	"gunvaultgui", "pillboxgui", "gunfactorygui", "gunfactoryget", "drugfactorygui",
	"AdminTell", "UpdateHelp", "RadarScan", "ShowLetter", "KillLetter",
	"recvTribes", "newTribe", "DRReady",
} ) do
	util.AddNetworkString( name )
end

AddCSLuaFile( "cl_deaths.lua" );
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "cl_chatbox.lua" );
AddCSLuaFile( "cl_legacy_vgui.lua" );
AddCSLuaFile( "cl_msg.lua" )
AddCSLuaFile( "shared.lua" );
AddCSLuaFile( "cl_vgui.lua" );
AddCSLuaFile( "shared/props.lua" );
AddCSLuaFile( "cl_scoreboard.lua" );
AddCSLuaFile( "cl_helpvgui.lua" );
AddCSLuaFile( "cl_menu.lua" );
AddCSLuaFile( "copypasta.lua" );
AddCSLuaFile("Extracrap.lua")
AddCSLuaFile("drugs.lua")
AddCSLuaFile("vars.lua")


include("resources.lua") -- registers content/ files for client download (FastDL/Workshop)
include("properties.lua")
include("shared/props.lua")

GM.Tribes = {}
GM.NumTribes = 1

include("decay.lua")

include( "player.lua" );
include( "money.lua" );
include( "shared.lua" );
include( "chat.lua" );
include( "rplol.lua" );
include( "drugs.lua" );
include( "admins.lua" );
include( "admincc.lua" );
include( "bannedprops.lua" );
include( "commands.lua" );
include( "hints.lua" );
include( "vars.lua" );
include( "rating.lua" );
include("swep_fix.lua");
include( "Extracrap.lua" );
CSFiles = { }

LRP = { }

SetGlobalInt( "nametag", 1 );
SetGlobalInt( "jobtag", 1 );
SetGlobalInt("globalshow", 0) ;
SetGlobalString( "cmdprefix", "/" );

function GM:Initialize()
	self.BaseClass:Initialize();

end

for k, v in pairs( player.GetAll() ) do

	v:NewData();
	v:SetNWBool("helpMenu",false)
	getMoney(v);

end

function ShowSpare1( ply )

	ply:ConCommand( "gm_showspare1\n" );

end
concommand.Add( "gm_spare1", ShowSpare1 );

function serverHelp( player )

    if(player:GetNWBool("helpMenu") == false) then
        player:SetNWBool("helpMenu",true)
    else
        player:SetNWBool("helpMenu",false)
    end
end
concommand.Add( "serverHelp", serverHelp )

function GM:ShowTeam( ply )
	ply:DoorControl()
end

function ShowSpare2( ply )
	ply:ConCommand( "gm_showspare2\n" );
end
concommand.Add( "gm_spare2", ShowSpare2 );

function GM:ShowHelp( ply )

	ply:ConCommand( "helpmenu" );

end

GM.Name = "BaseWars"
GM.Author = "By Llamalords";

function GM.SendTribes(ply)
for i,v in pairs(GAMEMODE.Tribes) do
	net.Start("recvTribes")
	net.WriteInt(v.id, 16)
	net.WriteString(i)
	net.WriteInt(v.red, 16)
	net.WriteInt(v.green, 16)
	net.WriteInt(v.blue, 16)
	net.Send(ply)
	end
end
hook.Add("PlayerInitialSpawn","getTribes",GM.SendTribes)

function CreateTribe( ply, name, red, green, blue, password )

	local Password = false

	if password and password ~= "" then
		Password = password
	end

	GAMEMODE.NumTribes = GAMEMODE.NumTribes + 1
	GAMEMODE.Tribes[name] = {
	id = GAMEMODE.NumTribes,
	red = red,
	green = green,
	blue = blue,
	Password = Password
	}
	local rp = RecipientFilter()
	rp:AddAllPlayers()
	net.Start("newTribe")
		net.WriteString(name)
		net.WriteInt(GAMEMODE.NumTribes, 16)
		net.WriteInt(red, 16)
		net.WriteInt(green, 16)
		net.WriteInt(blue, 16)
	net.Send(rp)

	team.SetUp(GAMEMODE.NumTribes,tostring(name),Color(red,green,blue,255))
	ply:SetTeam(GAMEMODE.NumTribes)
	ply:ChatPrint("Successfully Created A Faction",5,Color(255,255,255,255))
	ply:SetNWBool("FactionLeader", true)
end

function CreateTribeCmd( ply, cmd, args, argv )
	if not args[4] or args[4] == "" then
		ply:ChatPrint("Syntax is: bw_createfaction \"factionname\" red green blue [password(optional)]") return
	end
	if args[5] and args[5] ~= "" then
		CreateTribe( ply, args[1], args[2], args[3], args[4], args[5] )
	else
		CreateTribe( ply, args[1], args[2], args[3], args[4], "" )
	end
end
concommand.Add( "bw_createfaction", CreateTribeCmd )

function joinTribe( ply, cmd, args )
	local pw = ""
	if not args[1] or args[1] == "" then
		ply:ChatPrint("Syntax is: bw_join \"faction\" [password(if needed)]") return
	end
	if args[2] and args[2] ~= "" then
		pw = args[2]
	end
	for i,v in pairs(GAMEMODE.Tribes) do
		if string.lower(i) == string.lower(args[1]) then
			if v.Password and v.Password ~= pw then ply:PrintMessage(3,"Incorrect Faction Password") return end
			ply:SetTeam(v.id)
			ply:SetNWBool("FactionLeader", false)
			ply:SendMessage("Successfully Joined A Faction",5,Color(255,255,255,255))
		end
	end
end
concommand.Add( "bw_join", joinTribe )

function leaveTribe( ply, cmd, args )
	ply:SetTeam(1)
	ply:SendMessage("Successfully Left A Faction",5,Color(255,255,255,255))
	ply:SetNWBool("FactionLeader", false)
end
concommand.Add( "bw_leave", leaveTribe )

function Init_TriggerLogic()
	for k,v in pairs(ents.FindByClass("bigbomb")) do
		v:SetKeyValue( "health", 0 )
		v:SetKeyValue( "minhealthdmg", 100000000000000000000 )
	end
end
hook.Add( "InitPostEntity", "GlassUnbreakable", Init_TriggerLogic )
