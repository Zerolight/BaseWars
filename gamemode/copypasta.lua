include( "vars.lua" )

surface.CreateFont( "BWShopItem", { font = "Roboto", size = 13, weight = 600, antialias = true } )

local buytable = {}
buytable["Weapons - HandGuns"] = {}
buytable["Weapons - HandGuns"].Names = {"P228","Deagle","Glock","FiveSeven","USP","Elites","Mac-10","TMP",".357"}
buytable["Weapons - HandGuns"].Cost = {CfgVars["p228cost"],CfgVars["deaglecost"],CfgVars["glockcost"],CfgVars["fivesevencost"],CfgVars["uspcost"],CfgVars["elitescost"],CfgVars["mac10pistcost"],CfgVars["tmppistcost"],CfgVars[".357pistcost"]}
buytable["Weapons - HandGuns"].Data = {"p228","deagle","glock","fiveseven","usp","elites","mac10","tmp","357"}
buytable["Weapons - HandGuns"].Cmd = "buypistol"
buytable["Weapons - HandGuns"].Model = {"models/weapons/w_pist_p228.mdl", "models/weapons/w_pist_deagle.mdl", "models/weapons/w_pist_glock18.mdl", "models/weapons/w_pist_fiveseven.mdl", "models/weapons/w_pist_usp.mdl", "models/weapons/w_pist_elite_dropped.mdl", "models/weapons/w_smg_mac10.mdl", "models/weapons/w_smg_tmp.mdl", "models/weapons/w_357.mdl"}

buytable["Weapons - General"] = {}
buytable["Weapons - General"].Names = {"UMP45","M4A1","Shotgun","MP5","Galil","P90","AUG","AK-47","Flamethrower","Sniper","Auto-Shotgun","Auto-Sniper"}
buytable["Weapons - General"].Cost = {CfgVars["umpcost"],CfgVars["m16cost"],CfgVars["shotguncost"],CfgVars["mp5cost"],CfgVars["galilcost"],CfgVars["p90cost"],CfgVars["augcost"],CfgVars["ak47cost"],CfgVars["flamethrowercost"],CfgVars["snipercost"],CfgVars["autoshotguncost"],CfgVars["autosnipecost"]}
buytable["Weapons - General"].Data = {"ump","m4","shotgun","mp5","galil","p90","aug","ak47","flamethrower","sniper","autoshotgun","g3"}
buytable["Weapons - General"].Cmd = "buyshipment"
buytable["Weapons - General"].CmdTwo = "buyweapon"
buytable["Weapons - General"].Model = {"models/weapons/w_smg_ump45.mdl", "models/weapons/w_rif_m4a1.mdl", "models/weapons/w_shot_m3super90.mdl", "models/weapons/w_smg_mp5.mdl", "models/weapons/w_rif_galil.mdl","models/weapons/w_smg_p90.mdl" ,"models/weapons/w_rif_aug.mdl", "models/weapons/w_rif_ak47.mdl", "models/Weapons/w_smg1.mdl", "models/weapons/w_snip_awp.mdl", "models/weapons/w_shot_xm1014.mdl", "models/weapons/w_snip_g3sg1.mdl"}

buytable["Weapons - Grenades"] = {}
buytable["Weapons - Grenades"].Names = {"Grenade","Pipe Bomb","Stun Grenade","Gas Grenade","Sticky Grenades","Door Charges","C4 Explosive"}
buytable["Weapons - Grenades"].Cost = {CfgVars["grenadecost"],CfgVars["pipebombcost"],CfgVars["flashbangcost"],CfgVars["gasgrenadecost"],CfgVars["stickycost"],CfgVars["doorchargecost"],CfgVars["c4cost"]}
buytable["Weapons - Grenades"].Data = {"grenade","pipebomb","stun","gas","sticky","doorcharge","c4"}
buytable["Weapons - Grenades"].Cmd = "buyweapon"
buytable["Weapons - Grenades"].Model = {"models/weapons/w_eq_fraggrenade_thrown.mdl", "models/props_lab/pipesystem03b.mdl", "models/weapons/w_eq_smokegrenade_thrown.mdl", "models/weapons/w_eq_smokegrenade.mdl","models/magnusson_device.mdl","models/weapons/w_slam.mdl","models/weapons/w_c4_planted.mdl"}

buytable["Ammo"] = {}
buytable["Ammo"].Names = {"Buy Ammo"}
buytable["Ammo"].Cost = {CfgVars["ammocost"]}
buytable["Ammo"].Data = {"currentammo"}
buytable["Ammo"].Cmd = "buyammo"
buytable["Ammo"].Model = {"models/Items/357ammobox.mdl", "models/Items/BoxSRounds.mdl", "models/Items/BoxBuckshot.mdl","models/weapons/w_snip_awp.mdl","models/Weapons/W_missile_closed.mdl", "models/Items/CrossbowRounds.mdl", "models/props_junk/gascan001a.mdl"}

buytable["Drugs"] = {}
buytable["Drugs"].Names = {"Regeneration","Pain Killers","Antidote","Reflect","Adrenaline","Steroids","Double Jump","Leech","Amplifier","Armor Piercer","Magicbullet","Shockwave","Knockback","Doubletap","Focus"}
buytable["Drugs"].Cost = {CfgVars["regencost"],CfgVars["painkillercost"],CfgVars["antidotecost"],CfgVars["reflectcost"],400,600,400,400,600,400,300,600,400,750,300}
buytable["Drugs"].Data = {"regen","painkiller","antidote","reflect","adrenaline","steroid","doublejump","leech","amplifier","armorpiercer","magicbullet","shockwave","knockback","doubletap","focus"}
buytable["Drugs"].Cmd = "buydrug"
buytable["Drugs"].CmdTwo = "buybatchdrug"
buytable["Drugs"].Model = {""}

buytable["Equipment"] = {}
buytable["Equipment"].Names = {"Medkit","Snipe Shield","Helmet","Scan Blocker","Tool Kit","Armor"}
buytable["Equipment"].Cost = {CfgVars["healthcost"],CfgVars["shieldcost"],CfgVars["helmetcost"],CfgVars["scannercost"],CfgVars["toolkitcost"],CfgVars["armorcost"]}
buytable["Equipment"].Data = {"health","shield","helmet","scanner","toolkit","armor"}
buytable["Equipment"].Cmd = "buydrug"
buytable["Equipment"].Model = {"models/items/healthkit.mdl", "models/items/car_battery01.mdl", "models/props/de_tides/vending_hat.mdl",  "models/props_lab/monitor01b.mdl", "models/props_c17/tools_pliers01a.mdl", "models/props_c17/utilityconducter001.mdl"}

buytable["Structures - Base"] = {}
buytable["Structures - Base"].Names = {"Sentry Gun", "Spawn Point","Ammo Dispenser","Health Dispenser","Armor Dispenser","Microwave","Lamp","Radar Tower","Drug Refinery","Gun Lab","Gun Factory","Generator","Super Generator","Money Vault","Supply Table"}
buytable["Structures - Base"].Cost = {CfgVars["turretcost"],CfgVars["spawncost"],CfgVars["dispensercost"],CfgVars["healthdispensercost"],CfgVars["armordispensercost"],CfgVars["microwavecost"],CfgVars["lampcost"],CfgVars["radartowercost"],CfgVars["drugfactorycost"],CfgVars["gunlabcost"],CfgVars["gunfactorycost"],CfgVars["generatorcost"],CfgVars["supergeneratorcost"],CfgVars["moneyvaultcost"],CfgVars["supplytablecost"]}
buytable["Structures - Base"].Data = {"sentry","spawn","dispenser","healthdispenser","armordispenser","microwave","lamp","radar","refinery","gunlab","factory","generator","supergenerator","moneyvault","supplycabinet"}
buytable["Structures - Base"].Cmd = "buystruct"
buytable["Structures - Base"].Model = {"models/props_c17/TrapPropeller_Engine.mdl", "models/props_trainstation/trainstation_clock001.mdl", "models/props_lab/reciever_cart.mdl", "models/props_combine/health_charger001.mdl", "models/props_combine/suit_charger001.mdl", "models/props/cs_office/microwave.mdl", "models/props_wasteland/prison_lamp001c.mdl", "models/props_rooftop/roof_dish001.mdl", "models/props_c17/furniturestove001a.mdl","models/props_c17/furnitureboiler001a.mdl", "models/props/de_prodigy/transformer.mdl", "models/props_vehicles/generatortrailer01.mdl","models/props_mining/diesel_generator.mdl","models/props_lab/powerbox01a.mdl","models/props/CS_militia/table_shed.mdl"}

buytable["Structures - Profitable"] = {}
buytable["Structures - Profitable"].Names = {"Still","Plant","Drug Lab","Meth Lab","Stable Meth Lab","Bronze Money Printer","Silver Money Printer","Gold Money Printer","Platinum Money Printer","Diamond Money Printer","Bixbite Money Printer","Nuclear Money Printer"}
buytable["Structures - Profitable"].Cost = {CfgVars["stillcost"],CfgVars["weedcost"],CfgVars["druglabcost"],CfgVars["methlabcost"],CfgVars["methlabstablecost"],CfgVars["bronzeprintercost"],CfgVars["silverprintercost"],CfgVars["goldprintercost"],CfgVars["platinumprintercost"],CfgVars["diamondprintercost"],CfgVars["bixbiteprintercost"],CfgVars["nukeprintercost"]}
buytable["Structures - Profitable"].Data = {"still","plant","druglab","methlab","stablemethlab","bronzeprinter","silverprinter","goldprinter","platinumprinter","diamondprinter","bixbiteprinter","nuclearprinter"}
buytable["Structures - Profitable"].Cmd = "buystruct"
buytable["Structures - Profitable"].Model = {"models/props/de_inferno/wine_barrel.mdl", "models/props/cs_office/plant01.mdl", "models/props_combine/combine_mine01.mdl", "models/props/de_train/processor_nobase.mdl", "models/props_silo/processor.mdl", "models/props_lab/reciever01b.mdl", "models/props_c17/consolebox03a.mdl","models/props_lab/reciever01a.mdl", "models/props_c17/consolebox01a.mdl","models/props_lab/citizenradio.mdl","models/props_lab/citizenradio.mdl","models/props/de_train/Barrel.mdl"}

buytable["Other Stuff"] = {}
buytable["Other Stuff"].Names = {"Knife","Lockpick","Blowtorch","BIG BOMB","Gun Vault","Pill Box","Fuel Tank"}
buytable["Other Stuff"].Cost = {CfgVars["knifecost"],CfgVars["lockpickcost"],CfgVars["weldercost"],CfgVars["bigbombcost"],CfgVars["gunvaultcost"],CfgVars["pillboxcost"],CfgVars["insenammocost"]}
buytable["Other Stuff"].Data = {"knife","lockpick","welder","bigbomb","gunvault","pillbox","fueltank"}
buytable["Other Stuff"].Cmd = "buyspecial"
buytable["Other Stuff"].Model = {"models/weapons/w_knife_t.mdl", "models/weapons/w_crowbar.mdl", "models/weapons/w_IRifle.mdl", "models/props_c17/oildrum001_explosive.mdl", "models/props/CS_militia/footlocker01_closed.mdl" ,"models/props_c17/furniturefridge001a.mdl","models/props_junk/gascan001a.mdl"}

local PANEL = {}

function PANEL:Init()
	self:SetSize( 83, 83 )
	self.Label = vgui.Create ( "DLabel", self )
	self:SetKeepAspect( true )
	self:SetDrawBorder( true )
	self.m_Image:SetPaintedManually( true )
end

local PANEL = {}

function PANEL:Init()
	self.PanelList = vgui.Create( "DPanelList", self )
		self.PanelList:SetPadding( 4 )
		self.PanelList:SetSpacing( 2 )
		self.PanelList:EnableVerticalScrollbar( true )
	self:BuildList()
end

	local function AddComma(n)
		local sn = tostring(n)
		sn = string.ToTable(sn)

		local tab = {}
		for i=0,#sn-1 do

			if i%3 == #sn%3 and not (i==0) then
				table.insert(tab, ",")
			end
			table.insert(tab, sn[i+1])

		end

		return string.Implode("",tab)
	end

function PANEL:BuildList()
	self.PanelList:Clear()

	local Categorised = {}

	for k, v in pairs( buytable ) do
		v.Category = k
		Categorised[ v.Category ] = Categorised[ v.Category ] or {}
		table.insert( Categorised[ v.Category ], v )

	end

	for CategoryName, v in SortedPairs( Categorised ) do

		local Category = vgui.Create( "DCollapsibleCategory", self )
		self.PanelList:AddItem( Category )
		Category:SetExpanded(false)
		Category:SetLabel( CategoryName )
		Category:SetCookieName( "EntitySpawn."..CategoryName )

		local Content = vgui.Create( "DPanelList" )
		Category:SetContents( Content )
		Content:EnableHorizontal( true )
		Content:SetDrawBackground( false )
		Content:SetSpacing( 2 )
		Content:SetPadding( 2 )
		Content:SetAutoSize( true )

		number=1

		for k,v in pairs( buytable[ CategoryName ].Data ) do
				if(CategoryName ~= "Drugs") then
					local cmd = buytable[ CategoryName ].Cmd
					local cmdtwo = buytable[ CategoryName ].CmdTwo
					local data = buytable[ CategoryName ].Data[ number ]
					local name = buytable[ CategoryName ].Names[ number ]
					local Icon = vgui.Create( "SpawnIcon", self)

					if(buytable[ CategoryName ].Model[ number ] ~=nil) then
						Icon:SetModel( buytable[ CategoryName ].Model[ number ] )
					else
						Icon:SetModel( "models/error.mdl" )
					end

						if(CategoryName == "Weapons - General") then
					Icon:SetToolTip( " Item: " .. buytable[ CategoryName ].Names[ number ] .. "\n  Single Weapon Cost: $" .. AddComma(buytable[ CategoryName ].Cost[ number ]*.5) .. "\n Weapon Shipment Cost: $" .. AddComma(buytable[ CategoryName ].Cost[ number ]*1.5) )
						else
					Icon:SetToolTip( " Item: " .. buytable[ CategoryName ].Names[ number ] .. "\n Cost: $" .. AddComma(buytable[ CategoryName ].Cost[ number ] ))
						end

					Icon.DoClick = function()
						if(CategoryName == "Weapons - General") then
								local menu1 = DermaMenu()
								menu1:AddOption("Buy Single Weapon", function() RunConsoleCommand( cmdtwo, data ) surface.PlaySound( "basewars/chaching.mp3" ) end)
								menu1:AddOption("Buy Shipment", function() RunConsoleCommand( cmd, data ) surface.PlaySound( "basewars/chaching.mp3" ) end)
								menu1:Open()

						else
							-- Ammo purchases can be refused server-side (explosives, no-ammo weapons),
							-- so the "cha-ching" is played by the server only on a successful buy.
							if(CategoryName ~= "Ammo") then
								surface.PlaySound( "basewars/chaching.mp3" )
							end
							RunConsoleCommand( cmd, data )
						end
					end

					local lable  = vgui.Create("DLabel", Icon)
					lable:SetFont( "DefaultSmallDropShadow" )
					lable:SetTextColor( color_white )
					lable:SetText(name)
					lable:SetContentAlignment( 5 )
					lable:SetWide( self:GetWide() )
					lable:AlignBottom( -42 )

					Content:AddItem( Icon )

				else

					local cmd = buytable[ CategoryName ].Cmd
					local cmdtwo = buytable[ CategoryName ].CmdTwo
					local data = buytable[ CategoryName ].Data[ number ]
					local name = buytable[ CategoryName ].Names[ number ]
					local info = drugtable[ data ] or {}
					local col  = info.color or Color( 200, 200, 200 )
					local mat  = Material( info.icon or "icon16/pill.png" )

					local Icon = vgui.Create( "DButton", self )
					Icon:SetSize( 74, 74 )
					Icon:SetText( "" )
					Icon:SetToolTip( " Item: " .. name ..
						"\n Normal Cost: $" .. AddComma( buytable[ CategoryName ].Cost[ number ] ) ..
						"\n Batch Cost: $" .. AddComma( buytable[ CategoryName ].Cost[ number ] * 4 ) )

					Icon.Paint = function( pnl, w, h )
						draw.RoundedBox( 4, 0, 0, w, h,
							Color( col.r * 0.26, col.g * 0.26, col.b * 0.26, 240 ) )
						draw.RoundedBox( 4, 0, 0, w, 3, col )
						if ( pnl:IsHovered() ) then
							draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 255, 255, 20 ) )
						end
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.SetMaterial( mat )
						surface.DrawTexturedRect( w * 0.5 - 12, 14, 24, 24 )
						draw.SimpleText( name, "BWShopItem", w * 0.5, h - 16, col,
							TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end

					Icon.DoClick = function()
						local menu1 = DermaMenu()
						menu1:AddOption("Buy Single Drug", function() RunConsoleCommand( cmd, data ) surface.PlaySound( "basewars/chaching.mp3" ) end)
						menu1:AddOption("Buy Batch of Drugs", function() RunConsoleCommand( cmdtwo, data ) surface.PlaySound( "basewars/chaching.mp3" ) end)
						menu1:Open()
					end

					Content:AddItem( Icon )
				end
				number = number+1
		end
	end
	self.PanelList:InvalidateLayout()
end

function PANEL:PerformLayout()
	self.PanelList:StretchToParent( 0, 0, 0, 0 )
end

local CreationSheet = vgui.RegisterTable( PANEL, "Panel" )

local function CreateContentPanel()
	local ctrl = vgui.CreateFromTable( CreationSheet )
	return ctrl
end

local function BunkMenu()

	return vgui.Create( "DPanel" )
end

	spawnmenu.AddCreationTab( "Base War Buy Menu", CreateContentPanel, "icon16/brick_add.png", 50 )
