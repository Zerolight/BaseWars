Extracrap = { }
Jackpot = 1000
Ticketsdrawn = 0

function Upgrade(ply, args)
	args = Purify(args)
	if( args ~= "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 150;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
	if (not IsValid(tr.Entity)) then
		return "";
	end
	local targent = tr.Entity
	if (targent:GetClass()~="auto_turret" and targent:GetClass()~="dispenser" and targent:GetClass()~="healthdispenser" and targent:GetClass()~="armordispenser" and targent:GetClass()~="supplytable" and targent:GetClass()~="drugfactory" and targent:GetClass()~="drug_lab" and targent:GetClass()~="still_average" and targent:GetClass()~="money_printer_washingmachine" and targent:GetClass()~="money_printer_bronze" and targent:GetClass()~="money_printer_silver" and targent:GetClass()~="money_printer_gold" and targent:GetClass()~="money_printer_platinum" and targent:GetClass()~="money_printer_diamond" and targent:GetClass()~="money_printer_bixbite" and targent:GetClass()~="money_printer_nuclear" and targent:GetClass()~="radartower" and targent:GetClass()~="gunfactory" and targent:GetClass()~="weedplant" and targent:GetClass()~="meth_lab" and targent:GetClass()~="meth_lab_stable") then
		Notify(ply,4,3,"This cannot be upgraded.")
		ply:ConCommand( "play buttons/button10.wav" )
		return "" ;
	end

	if not (targent.Owner) then
		Notify( ply, 4, 3, "You do not own this Structure!" );
			ply:ConCommand( "play buttons/button10.wav" )
		return "" ;
	end
	local lvl = targent:GetNWInt("upgrade") + 1
	if (lvl>2 and targent:GetClass()~="supplytable" and targent:GetClass()~="drug_lab") then
		Notify(ply, 4, 3, "This is already fully upgraded.")
		return "" ;
	end
	if (lvl>3 and targent:GetClass()=="supplytable") then
		Notify(ply, 4, 3, "This is already fully upgraded.")
		return "" ;
	end
	if (lvl>5 and targent:GetClass()=="drug_lab") then
		Notify(ply, 4, 3, "This is already fully upgraded.")
		return "" ;
	end

	local price = 0
	if targent:GetClass()== "auto_turret" then price = CfgVars["turretcost"]
	elseif targent:GetClass()== "dispenser" then price = CfgVars["dispensercost"]
    elseif targent:GetClass()== "healthdispenser" then price = CfgVars["healthdispensercost"]
    elseif targent:GetClass()== "armordispenser" then price = CfgVars["armordispensercost"]
	elseif targent:GetClass()== "drugfactory" then price = CfgVars["drugfactorycost"]
	elseif targent:GetClass()== "drug_lab" then price = CfgVars["druglabcost"]
	elseif targent:GetClass()== "still_average" then price = CfgVars["stillcost"]
	elseif targent:GetClass()== "money_printer_washingmachine" then price = CfgVars["washingmachineprintercost"]
	elseif targent:GetClass()== "money_printer_bronze" then price = CfgVars["bronzeprintercost"]
	elseif targent:GetClass()== "money_printer_silver" then price = CfgVars["silverprintercost"]
	elseif targent:GetClass()== "money_printer_gold" then price = CfgVars["goldprintercost"]
	elseif targent:GetClass()== "money_printer_platinum" then price = CfgVars["platinumprintercost"]
	elseif targent:GetClass()== "money_printer_nuclear" then price = CfgVars["nukeprintercost"]
	elseif targent:GetClass()== "money_printer_diamond" then price = CfgVars["diamondprintercost"]
	elseif targent:GetClass()== "money_printer_bixbite" then price = CfgVars["bixbiteprintercost"]
	elseif targent:GetClass()== "meth_lab" then price = CfgVars["methlabcost"]
	elseif targent:GetClass()== "meth_lab_stable" then price = CfgVars["metlabstable"]
	elseif targent:GetClass()== "radartower" then price = CfgVars["radartowercost"]
	elseif targent:GetClass()== "weedplant" then price = CfgVars["weedcost"]
	elseif targent:GetClass()== "gunfactory" then price = CfgVars["gunfactorycost"]
	elseif targent:GetClass()== "supplytable" then price = CfgVars["supplytablecost"]
	end
	price = price*CfgVars["upgradecost"]
	if (lvl==5) then price = price*16 end
	if (lvl==4) then price = price*8 end
	if (lvl==3) then price = price*4 end
	if (lvl==2) then price = price*2 end

	if (not ply:CanAfford(price)) then
		Notify(ply, 4, 3, "Cannot afford this. Cost is $" .. price)
			ply:ConCommand( "play buttons/button10.wav" )
		return "" ;
	end
	ply:AddMoney(price*-1)
	Notify( ply, 0, 3, "Applying level " .. lvl .. " upgrade.")
	targent:SetNWInt("upgrade", lvl)
		ply:ConCommand( "play buttons/button4.wav" )
	return "";
end
AddChatCommand( "/upgrade", Upgrade );

function BuyRefinery( ply )
    if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["drugfactorycost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxdrugfactory >= CfgVars["maxdrugfactory"])then
			Notify( ply, 4, 3, "Max Drug Refineries Reached!" );
			return "";
		end
		ply:AddMoney( CfgVars["drugfactorycost"] * -1 );
		Notify( ply, 0, 3, "You bought a Drug Refinery!" );
		local gunlab = ents.Create( "drugfactory" );

		gunlab.Owner = ply
		gunlab:SetPos( tr.HitPos+Vector(0,0,40));
		gunlab:Spawn();
		return "";
end
AddChatCommand( "/buyrefinery", BuyRefinery );
AddChatCommand( "/buydrugfactory", BuyRefinery );
AddChatCommand( "/buydrugrefinery", BuyRefinery );

function BuyMoneyVault( ply )
    if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["moneyvaultcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this Structure." );
			return "";
		end
		if(ply:GetTable().maxMoneyVault >= 1)then
			Notify( ply, 4, 3, "You already own a Money Vault!" );
			return "";
		end
		ply:AddMoney( CfgVars["moneyvaultcost"] * -1 );
		Notify( ply, 0, 3, "You bought a Money Vault!" );
		local gunlab = ents.Create( "moneyvault" );

		gunlab:SetPos( tr.HitPos+Vector(0,0,40));
		gunlab.Owner = ply
		gunlab:Spawn();
		return "";
end
AddChatCommand( "/buymoneyvault", BuyMoneyVault );

function BuyTurret( ply )
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 150;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if (not tr.HitWorld) then
			Notify( ply, 4, 3, "Please look at the ground to spawn sentry turret." );
			return "";
		end
		if( not ply:CanAfford( CfgVars["turretcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxturret >= CfgVars["turretmax"])then
			Notify( ply, 4, 3, "Max sentry turrets Reached!" );
			return "";
		end
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local SpawnAng = tr.HitNormal:Angle()
		for k, v in pairs( ents.FindInSphere(SpawnPos, 1250)) do
			if (v:GetClass() == "info_player_deathmatch" or v:GetClass() == "info_player_rebel" or v:GetClass() == "gmod_player_start" or v:GetClass() == "info_player_start" or v:GetClass() == "info_player_allies" or v:GetClass() == "info_player_axis" or v:GetClass() == "info_player_counterterrorist" or v:GetClass() == "info_player_terrorist") then
				Notify( ply, 4, 3, "Cannot create sentry turret near a spawn point!" );
				return "" ;
			end
		end
		ply:AddMoney( CfgVars["turretcost"] * -1 );
		Notify( ply, 0, 3, "You bought a Sentry turret" );

		local ent = ents.Create( "auto_turret" )
		ent:SetPos( SpawnPos + (tr.HitNormal*-3) )
		ent:SetAngles( SpawnAng + Angle(90, 0, 0) )

		ent.Owner = ply
		ent:SetNWString( "ally" , "")
		ent:SetNWString( "jobally", "")
		ent:SetNWString( "enemytarget", "")
		ent:SetNWBool( "hatetarget", false)

		ent:Spawn()
		ent:Activate()
		local head = ents.Create( "auto_turret_gun" )
		head:SetPos( SpawnPos + (tr.HitNormal*18) )
		head:SetAngles( SpawnAng + Angle(90, 0, 0) )
		head:Spawn()
		head:Activate()
		head:SetParent(ent)
		head.Body = ent
		ent.Head = head
		head:SetOwner(ply)
		return "";
end
AddChatCommand( "/buyturret", BuyTurret );

function BuyGunFactory( ply )
    if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

	if( not ply:CanAfford( CfgVars["gunfactorycost"] ) ) then
		Notify( ply, 4, 3, "Cannot afford this" );
		return "";
	end
	if(ply:GetTable().maxgunfactory >= CfgVars["maxgunfactory"])then
		Notify( ply, 4, 3, "Max Gun Factories Reached!" );
		return "";
	end
	ply:AddMoney( CfgVars["gunfactorycost"] * -1 );
	Notify( ply, 0, 3, "You bought a Gun Factory!" );
	local gunlab = ents.Create( "gunfactory" );

	gunlab.Owner = ply
	gunlab:SetPos( tr.HitPos+Vector(0,0,10));
	gunlab:Spawn();
	return "";
end
AddChatCommand( "/buygunfactory", BuyGunFactory );
AddChatCommand( "/buyfactory", BuyGunFactory );

function BuyTower( ply )
    if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
	if( not ply:CanAfford( CfgVars["radartowercost"] ) ) then
		Notify( ply, 4, 3, "Cannot afford this" );
		return "";
	end
	if(ply:GetTable().maxtower >= 1)then
		Notify( ply, 4, 3, "You already have a Radar Tower!" );
		return "";
	end
	ply:AddMoney( CfgVars["radartowercost"] * -1 );
	Notify( ply, 0, 3, "You bought a Radar Tower!" );
	local gunlab = ents.Create( "radartower" );

	gunlab.Owner = ply
	gunlab:SetPos( tr.HitPos+Vector(0,0,10));
	gunlab:Spawn();
	return "";
end
AddChatCommand( "/buytower", BuyTower );
AddChatCommand( "/buyradar", BuyTower );

function BuySupplyTable( ply )
    if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
	if( not ply:CanAfford( CfgVars["supplytablecost"] )) then
		Notify( ply, 4, 3, "Cannot afford this!" );
		return "";
	end
	if(ply:GetTable().maxsupplytable >= 1)then
		Notify( ply, 4, 3, "You already have a Supply Table!" );
		return "";
	end
	ply:AddMoney( CfgVars["supplytablecost"] * -1 );
	Notify( ply, 0, 3, "You bought a Supply Table!" );
	local gunlab = ents.Create( "supplytable" );

	gunlab:SetPos( tr.HitPos+Vector(0,0,10));
	gunlab.Owner = ply
	gunlab:Spawn();
	return "";
end
AddChatCommand( "/buysupplytable", BuySupplyTable );
AddChatCommand( "/buysupplycabinet", BuySupplyTable );

function BuyLamp( ply )
    if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["lampcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxlamp >= CfgVars["maxlamp"])then
			Notify( ply, 4, 3, "Max Lamps Reached!" );
			return "";
		end
			ply:AddMoney( CfgVars["lampcost"] * -1 );
			Notify( ply, 0, 3, "You bought a Lamp" );
			local lamp = ents.Create( "bw_lamp" );

			lamp:SetPos( tr.HitPos );
			lamp.Owner = ply
			lamp:Spawn();
			return "";
end
AddChatCommand( "/buylamp", BuyLamp );

function BuyGenerator( ply )
    if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["generatorcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxgenerator >= CfgVars["maxgenerator"])then
			Notify( ply, 4, 3, "Max Generators Reached!" );
			return "";
		end
		ply:AddMoney( CfgVars["generatorcost"] * -1 );
		Notify( ply, 0, 3, "You bought a Generator!" );
		local gunlab = ents.Create( "powerplant" );

		gunlab:SetPos( tr.HitPos+Vector(0,0,10));
		gunlab.Owner = ply
		gunlab:Spawn();
		return "";
end
AddChatCommand( "/buypowerplant", BuyGenerator );
AddChatCommand( "/buygenerator", BuyGenerator );

function BuySuperGenerator( ply )

    if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["supergeneratorcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxsupergenerator >= CfgVars["maxsupergenerator"])then
			Notify( ply, 4, 3, "Max Super Generators Reached!" );
			return "";
		end
		ply:AddMoney( CfgVars["supergeneratorcost"] * -1 );
		Notify( ply, 0, 3, "You bought a Super Generator!" );
		local gunlab = ents.Create( "superpowerplant" );

		gunlab:SetPos( tr.HitPos+Vector(0,0,10));
		gunlab.Owner = ply
		gunlab:Spawn();
		return "";
end
AddChatCommand( "/buysuperpowerplant", BuySuperGenerator );
AddChatCommand( "/buysupergenerator", BuySuperGenerator );

function BuyBomb( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
	if( not ply:CanAfford( CfgVars["bigbombcost"] ) ) then
		Notify( ply, 4, 3, "Cannot afford this!" );
		return "";
	end
		if(ply:GetTable().maxBigBombs >= CfgVars["bigbombmax"])then
			Notify( ply, 4, 3, "Max Big Bombs Reached!" );
			return "";
		end
	ply:AddMoney( CfgVars["bigbombcost"] * -1 );
	Notify( ply, 0, 3, "You bought the Big Bomb!" );
	local Bigbomb = ents.Create( "bigbomb" );
	Bigbomb:SetPos( tr.HitPos + tr.HitNormal*15);
	Bigbomb.Owner = ply
	Bigbomb:Spawn();
	Bigbomb:Activate();
	return "";
end
AddChatCommand( "/buybomb", BuyBomb );

function BuyKnife( ply )
		if( not ply:CanAfford( CfgVars["knifecost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["knifecost"] * -1 );
		Notify( ply, 0, 3, "You bought a Knife!" );

		ply:Give("weapon_knife2")
		return "";
end
AddChatCommand( "/buyknife", BuyKnife );

function BuyLockPick( ply )
		if( not ply:CanAfford( CfgVars["lockpickcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["lockpickcost"] * -1 );
		Notify( ply, 0, 3, "You bought a lockpick" );

		ply:Give("lockpick")
		return "";
end
AddChatCommand( "/buylockpick", BuyLockPick );

function BuyWelder( ply )
		if( not ply:CanAfford( CfgVars["weldercost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["weldercost"] * -1 );
		Notify( ply, 0, 3, "You bought a blowtorch/welder" );

		ply:Give("weapon_welder")
		return "";
end
AddChatCommand( "/buywelder", BuyWelder );
AddChatCommand( "/buyblowtorch", BuyWelder );

function BuyDispenser( ply )
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 150;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["dispensercost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxdispensers >= CfgVars["dispensermax"])then
			Notify( ply, 4, 3, "Max dispensers Reached!" );
			return "";
		end
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		ply:AddMoney( CfgVars["dispensercost"] * -1 );
		Notify( ply, 0, 3, "You bought an Ammo Dispenser!" );

		local ent = ents.Create( "dispenser" )
		ent:SetPos( SpawnPos + Vector(0,0,30) )

		ent.Owner = ply
		ent:Spawn()
		ent:Activate()
		return "";
end
AddChatCommand( "/buydispenser", BuyDispenser );

function BuyHealthDispenser( ply )
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 150;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["healthdispensercost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxhealthdispensers >= CfgVars["healthdispensersmax"])then
			Notify( ply, 4, 3, "Max Health Dispensers Reached!" );
			return "";
		end
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		ply:AddMoney( CfgVars["healthdispensercost"] * -1 );
		Notify( ply, 0, 3, "You bought a Health Dispenser!" );

		local ent = ents.Create( "healthdispenser" )
		ent:SetPos( SpawnPos + Vector(0,0,30) )

		ent.Owner = ply
		ent:Spawn()
		ent:Activate()
		return "";
end
AddChatCommand( "/buyhealthdispenser", BuyHealthDispenser );

function BuyArmorDispenser( ply )
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 150;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["armordispensercost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxarmordispensers >= CfgVars["armordispensersmax"])then
			Notify( ply, 4, 3, "Max Armor dispensers Reached!" );
			return "";
		end
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		ply:AddMoney( CfgVars["armordispensercost"] * -1 );
		Notify( ply, 0, 3, "You bought a Armor Dispenser!" );

		local ent = ents.Create( "armordispenser" )
		ent:SetPos( SpawnPos + Vector(0,0,30) )

		ent.Owner = ply
		ent:Spawn()
		ent:Activate()
		return "";
end
AddChatCommand( "/buyarmordispenser", BuyArmorDispenser );

function BuyMethlab( ply,args )
	args = Purify(args)
	local count = tonumber(args)
	if count==nil then count = 1 end
	if count>CfgVars["maxmethlab"] or count<1 then count = 1 end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 150;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["methlabcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxmethlab >= CfgVars["maxmethlab"])then
			Notify( ply, 4, 3, "Max methlabs Reached!" );
			return "";
		end
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		ply:AddMoney( CfgVars["methlabcost"] * -1 );
		Notify( ply, 0, 3, "You bought a meth lab. Good luck!" );

		local ent = ents.Create( "meth_lab" )
		ent:SetPos( SpawnPos + Vector(0,0,10) )

		ent.Owner = ply
		ent:Spawn()
		ent:SetColor(Color(255, 255, 255, 255))
		ent:Activate()
	return "";
end
AddChatCommand( "/buymethlab", BuyMethlab );

function BuyStableMethLab( ply )
	args = Purify(args)
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["methlabstablecost"] )) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxstablemethlab >= CfgVars["maxstablemethlab"])then
			Notify( ply, 4, 3, "Max Stable Meth Labs Reached!" );
			return "";
		end
		ply:AddMoney( CfgVars["methlabstablecost"] * -1 );
		Notify( ply, 0, 3, "You bought a Stable Meth Labs" );
		local druglab = ents.Create( "meth_lab_stable" );

		druglab.Owner = ply
		druglab:SetPos( tr.HitPos + tr.HitNormal*148);
		druglab:Spawn();

	return "";
end
AddChatCommand( "/buystablemethlab", BuyStableMethLab );

function BuyPlant( ply, args )
  	args = Purify(args)
  	local count = tonumber(args)
  	if count==nil then count = 1 end
  	if count>CfgVars["maxweed"] or count<1 then count = 1 end
  	local trace = { }

  	trace.start = ply:EyePos();
  	trace.endpos = trace.start + ply:GetAimVector() * 150;
  	trace.filter = ply;

  	local tr = util.TraceLine( trace );
  		if ( ply:GetTable().Arrested ) then
  			Notify( ply, 4, 3, "You can't buy a plant while arrested!" );
  			return "";
  		end
  	for i=1,count do
  		if( not ply:CanAfford( CfgVars["weedcost"] ) ) then
  			Notify( ply, 4, 3, "Cannot afford this" );
  			return "";
  		end
  		if(ply:GetTable().maxweed >= CfgVars["maxweed"])then
  			Notify( ply, 4, 3, "Max plants Reached!" );
  			return "";
  		end
  		local SpawnPos = tr.HitPos + tr.HitNormal * 20
  		ply:AddMoney( CfgVars["weedcost"] * -1 );
  		Notify( ply, 0, 3, "You bought a plant!" );

  		local ent = ents.Create( "weedplant" )
		ent.Owner = ply
  		ent:SetPos( SpawnPos + Vector(0,0,20) )
  		ent:Spawn()
  		ent:Activate()
  		if (math.Rand(0,1)>.75) then
  			ent:Worthless()
  			Notify( ply, 1, 3, "Unluckily for you, it's hemp. You might as well destroy it.")
  		end
  	end
  	return "";
end
AddChatCommand( "/buyplant", BuyPlant );
AddChatCommand( "/buyweed", BuyPlant );
AddChatCommand( "/buyweedplant", BuyPlant );

function BuySpawn( ply )

    if( args == "" ) then return ""; end
    	local trace = { }
    		trace.start = ply:GetPos()+Vector(0,0,1)
		trace.endpos = trace.start+Vector(0,0,90)
		trace.filter = ply
	trace = util.TraceLine(trace)
	if( trace.Fraction<1 ) then
            Notify( ply, 4, 3, "Need more room" );
            return "";
        end
        if( not ply:CanAfford( CfgVars["spawncost"] ) ) then
            Notify( ply, 4, 3, "Cannot afford this" );
            return "";
        end
	if(not ply:Alive())then
            Notify( ply, 4, 3, "Dead men buy no spawn points.");
            return "";
        end
	if IsValid(ply:GetTable().Spawnpoint) then
		ply:GetTable().Spawnpoint:Remove()
		Notify(ply,1,3, "Destroyed old spawnpoint to create this one.")
	end
        ply:AddMoney( CfgVars["spawncost"] * -1 );
        Notify( ply, 0, 3, "You bought a spawn point!" );
        local spawnpoint = ents.CreateEx( "spawnpoint" );
		spawnpoint.Owner = ply
        spawnpoint:SetPos( ply:GetPos());
		spawnpoint:SetColor(Color(255, 255, 255, 254))
	ply:SetPos(ply:GetPos()+Vector(0,0,3))

        spawnpoint:Spawn();
    return "";
end
AddChatCommand( "/buyspawnpoint", BuySpawn );

function AllyTurret(ply, args)
	Notify( ply, 1, 3, "Use the LmaoLlamaBaseWarsV2 Allies menu instead of this")
	return "";
end

function UnAllyTurret(ply, args)
	Notify( ply, 1, 3, "Use the LmaoLlamaBaseWarsV2 Allies menu instead of this")
	return""
end
AddChatCommand( "/clearally", UnAllyTurret );

function JobAllyTurret(ply, args)
	Notify( ply, 1, 3, "Use the LmaoLlamaBaseWarsV2 Allies menu instead of this")
	return""
end

function TargetTurret(ply, args)
	args = Purify(args)
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 150;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
	local targent = tr.Entity
	if (targent:GetClass()~="auto_turret") then
		return "" ;
	end
	if (targent.Owner) then
		Notify( ply, 4, 3, "This is not your turret!" );
		return "" ;
	end
	Notify( ply, 0, 3, "Set turret target string to " .. args)
	targent:SetNWString("enemytarget", args)
	return "" ;
end

function BuyArmor( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["armorcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["armorcost"] * -1 );
		Notify( ply, 0, 3, "You bought some Armor!" );
			local vehiclespawn = ents.CreateEx( "item_armor" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 25, 15));
			vehiclespawn:Spawn();
	return "";
end
AddChatCommand( "/buyarmor", BuyArmor );

function BuyHelmet( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["helmetcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( -CfgVars["helmetcost"] );
		Notify( ply, 0, 3, "You bought a Helmet!" );
			local vehiclespawn = ents.CreateEx( "item_helmet" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 25, 15));
			vehiclespawn:Spawn();
	return "";
end
AddChatCommand( "/buyhelmet", BuyHelmet );

function BuyToolKit( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["toolkitcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["toolkitcost"] * -1 );
		Notify( ply, 0, 3, "You bought a Toolkit!" );
			local vehiclespawn = ents.CreateEx( "item_toolkit" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 20, 10));
			vehiclespawn:Spawn();
	return "";
end
AddChatCommand( "/buytoolkit", BuyToolKit );

function BuyScanner( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["scannercost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["scannercost"] * -1 );
		Notify( ply, 0, 3, "You bought a Scan Blocker!" );
			local vehiclespawn = ents.CreateEx( "item_scanner" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 20, 10));
			vehiclespawn:Spawn();
	return "";
end
AddChatCommand( "/buyscanner", BuyScanner );

function BuyShield( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["shieldcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["shieldcost"] * -1 );
		Notify( ply, 0, 3, "You bought a Snipe Shield!" );
			local vehiclespawn = ents.CreateEx( "item_snipeshield" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 20, 10));
			vehiclespawn:Spawn();
	return "";
end
AddChatCommand( "/buyshield", BuyShield );

function BuyBatchSteroid( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["steroidcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["steroidcost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of Steroids!" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_steroid" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchsteroids", BuyBatchSteroid );

function BuyBatchDoubleJump( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["doublejumpcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["doublejumpcost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of double jump" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_doublejump" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchdoublejump", BuyBatchDoubleJump );

function BuyBatchAdrenaline( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["adrenalinecost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["adrenalinecost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of adrenaline" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_adrenaline" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchadrenaline", BuyBatchAdrenaline );

function BuyBatchKnockback( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["knockbackcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["knockbackcost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of knockback" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_knockback" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchknockback", BuyBatchKnockback );

function BuyBatchArmorpiercer( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["armorpiercercost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["armorpiercercost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of armorpiercer" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_armorpiercer" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchapiercer", BuyBatchArmorpiercer );
AddChatCommand( "/buybatchpiercer", BuyBatchArmorpiercer );
AddChatCommand( "/buybatcharmorpiercer", BuyBatchArmorpiercer );

function BuyBatchShockWave( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["shockwavecost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["shockwavecost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of shock wave" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_shockwave" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchshockwave", BuyBatchShockWave );

function BuyBatchLeech( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["leechcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["leechcost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of leech" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_leech" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchleech", BuyBatchLeech );

function BuyBatchDoubleTap( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["doubletapcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["doubletapcost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of double tap" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_doubletap" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchdoubletap", BuyBatchDoubleTap );

function BuyBatchReflect( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["reflectcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["reflectcost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of reflect" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_reflect" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchreflect", BuyBatchReflect );

function BuyBatchFocus( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["focuscost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["focuscost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of focus" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_focus" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchfocus", BuyBatchFocus );

function BuyBatchAntidote( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["antidotecost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["antidotecost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of antidote" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_antidote" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchantidote", BuyBatchAntidote );

function BuyBatchAmp( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["ampcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["ampcost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of amplifier" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_amp" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchamp", BuyBatchAmp );

function BuyBatchPainKiller( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["painkillercost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["painkillercost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of pain killers" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_painkiller" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchpainkiller", BuyBatchPainKiller );
AddChatCommand( "/buybatchpainkillers", BuyBatchPainKiller );

function BuyBatchMagicBullet( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["magicbulletcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["magicbulletcost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of magic bullet" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_magicbullet" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchmagicbullet", BuyBatchMagicBullet );
AddChatCommand( "/buybatchmb", BuyBatchMagicBullet );

function BuyBatchRegen( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( 4 * CfgVars["regencost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( 4 * CfgVars["regencost"] * -1 );
		Notify( ply, 0, 3, "You bought a batch of regeneration" );
		for i=-2, 2, 1 do
			local vehiclespawn = ents.CreateEx( "item_regen" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, i*12, 15));
			vehiclespawn:Spawn();
		end
	return "";
end
AddChatCommand( "/buybatchregen", BuyBatchRegen );

function BuySteroid( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["steroidcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["steroidcost"] * -1 );
		Notify( ply, 0, 3, "You bought steroids" );

			local vehiclespawn = ents.CreateEx( "item_steroid" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buysteroids", BuySteroid );

function BuyDoubleJump( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["doublejumpcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["doublejumpcost"] * -1 );
		Notify( ply, 0, 3, "You bought double jump" );

			local vehiclespawn = ents.CreateEx( "item_doublejump" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buydoublejump", BuyDoubleJump );

function BuyAdrenaline( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["adrenalinecost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["adrenalinecost"] * -1 );
		Notify( ply, 0, 3, "You bought adrenaline" );

			local vehiclespawn = ents.CreateEx( "item_adrenaline" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyadrenaline", BuyAdrenaline );

function BuyKnockback( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["knockbackcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["knockbackcost"] * -1 );
		Notify( ply, 0, 3, "You bought knockback" );

			local vehiclespawn = ents.CreateEx( "item_knockback" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyknockback", BuyKnockback );

function BuyArmorpiercer( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["armorpiercercost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["armorpiercercost"] * -1 );
		Notify( ply, 0, 3, "You bought armorpiercer" );

			local vehiclespawn = ents.CreateEx( "item_armorpiercer" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyapiercer", BuyArmorpiercer );
AddChatCommand( "/buypiercer", BuyArmorpiercer );
AddChatCommand( "/buyarmorpiercer", BuyArmorpiercer );

function BuyShockWave( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["shockwavecost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["shockwavecost"] * -1 );
		Notify( ply, 0, 3, "You bought shock wave" );

			local vehiclespawn = ents.CreateEx( "item_shockwave" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyshockwave", BuyShockWave );

function BuyLeech( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["leechcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["leechcost"] * -1 );
		Notify( ply, 0, 3, "You bought leech" );

			local vehiclespawn = ents.CreateEx( "item_leech" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyleech", BuyLeech );

function BuyDoubleTap( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["doubletapcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["doubletapcost"] * -1 );
		Notify( ply, 0, 3, "You bought double tap" );

			local vehiclespawn = ents.CreateEx( "item_doubletap" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buydoubletap", BuyDoubleTap );

function BuyReflect( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["reflectcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["reflectcost"] * -1 );
		Notify( ply, 0, 3, "You bought Reflect!" );

			local vehiclespawn = ents.CreateEx( "item_reflect" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyreflect", BuyReflect );

function BuyFocus( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["focuscost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["focuscost"] * -1 );
		Notify( ply, 0, 3, "You bought Focus!" );

			local vehiclespawn = ents.CreateEx( "item_focus" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyfocus", BuyFocus );

function BuyAntidote( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["antidotecost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["antidotecost"] * -1 );
		Notify( ply, 0, 3, "You bought Antidote!" );

			local vehiclespawn = ents.CreateEx( "item_antidote" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyantidote", BuyAntidote );

function BuyAmp( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["ampcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["ampcost"] * -1 );
		Notify( ply, 0, 3, "You bought Amplifier!" );

			local vehiclespawn = ents.CreateEx( "item_amp" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyamp", BuyAmp );

function BuyPainKiller( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["painkillercost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["painkillercost"] * -1 );
		Notify( ply, 0, 3, "You bought Pain Killers!" );

			local vehiclespawn = ents.CreateEx( "item_painkiller" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buypainkiller", BuyPainKiller );
AddChatCommand( "/buypainkillers", BuyPainKiller );

function BuyMagicBullet( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["magicbulletcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["magicbulletcost"] * -1 );
		Notify( ply, 0, 3, "You bought magic bullet" );

			local vehiclespawn = ents.CreateEx( "item_magicbullet" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buymagicbullet", BuyMagicBullet );
AddChatCommand( "/buymb", BuyMagicBullet );

function BuyRegen( ply )
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
		if( not ply:CanAfford( CfgVars["regencost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		ply:AddMoney( CfgVars["regencost"] * -1 );
		Notify( ply, 0, 3, "You bought Regeneration!" );

			local vehiclespawn = ents.CreateEx( "item_regen" );
			vehiclespawn:SetPos( tr.HitPos + Vector(0, 12, 15));
			vehiclespawn:Spawn();

	return "";
end
AddChatCommand( "/buyregen", BuyRegen );

function BuyBronzePrinter( ply )
	args = Purify(args)
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["bronzeprintercost"] )) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxBronzePrinter >= CfgVars["maxbronzeprinters"])then
			Notify( ply, 4, 3, "Max Bronze Printers Reached!" );
			return "";
		end
		ply:AddMoney( -CfgVars["bronzeprintercost"] );
		Notify( ply, 0, 3, "You bought a Bronze Printer" );
		local druglab = ents.Create( "money_printer_bronze" );

		druglab:SetMaterial( "models/shiny" )
		druglab:SetColor(Color(140, 120, 83, 255))
		druglab:SetPos( tr.HitPos + tr.HitNormal*30);
		druglab.Owner = ply
		druglab:Spawn();
	return "";
end
AddChatCommand( "/buybronzeprinter", BuyBronzePrinter );

function BuySilverPrinter( ply )
	args = Purify(args)
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["silverprintercost"] )) then
			Notify( ply, 4, 3, "Cannot afford this." );
			return "";
		end
		if(ply:GetTable().maxSilverPrinter >= CfgVars["maxsilverprinters"])then
			Notify( ply, 4, 3, "Max Silver Printers Reached!" );
			return "";
		end
		ply:AddMoney( -CfgVars["silverprintercost"] );
		Notify( ply, 0, 3, "You bought a Silver Printer" );
		local druglab = ents.Create( "money_printer_silver" );

		druglab:SetMaterial( "models/shiny" )
		druglab:SetColor(Color(230, 232, 250, 255))
		druglab:SetPos( tr.HitPos + tr.HitNormal*40);
		druglab.Owner = ply
		druglab:Spawn();
	return "";
end
AddChatCommand( "/buysilverprinter", BuySilverPrinter );

function BuyGoldPrinter( ply )
	args = Purify(args)
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["goldprintercost"] )) then
			Notify( ply, 4, 3, "Cannot afford this." );
			return "";
		end
		if(ply:GetTable().maxGoldPrinter >= CfgVars["maxgoldprinters"])then
			Notify( ply, 4, 3, "Max Gold Printers Reached!" );
			return "";
		end
		ply:AddMoney( -CfgVars["goldprintercost"] );
		Notify( ply, 0, 3, "You bought a Gold Printer." );
		local druglab = ents.Create( "money_printer_gold" );

		druglab:SetMaterial( "models/shiny" )
		druglab:SetColor(Color(255, 215, 0, 255))
		druglab:SetPos( tr.HitPos + tr.HitNormal*40);
		druglab.Owner = ply
		druglab:Spawn();
	return "";
end
AddChatCommand( "/buygoldprinter", BuyGoldPrinter );

function BuyPlatinumPrinter( ply )
	args = Purify(args)
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["platinumprintercost"] )) then
			Notify( ply, 4, 3, "Cannot afford this." );
			return "";
		end
		if(ply:GetTable().maxPlatinumPrinter >= CfgVars["maxplatinumprinters"])then
			Notify( ply, 4, 3, "Max Platinum Printers Reached!" );
			return "";
		end
		ply:AddMoney( -CfgVars["platinumprintercost"] );
		Notify( ply, 0, 3, "You bought a Platinum Printer." );
		local druglab = ents.Create( "money_printer_platinum" );

		druglab:SetMaterial( "models/shiny" )
		druglab:SetColor(Color(229, 228, 226, 255))
		druglab:SetPos( tr.HitPos + tr.HitNormal*50);
		druglab.Owner = ply
		druglab:Spawn();
	return "";
end
AddChatCommand( "/buyplatinumprinter", BuyPlatinumPrinter );

function BuyDiamondPrinter( ply )
	args = Purify(args)
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["diamondprintercost"] )) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxDiamondPrinter >= CfgVars["maxdiamondprinters"])then
			Notify( ply, 4, 3, "Max Diamond Printers Reached!" );
			return "";
		end
		ply:AddMoney( -CfgVars["diamondprintercost"] );
		Notify( ply, 0, 3, "You bought a Diamond Printer" );
		local druglab = ents.Create( "money_printer_diamond" );

		druglab:SetMaterial( "models/shiny" )
		druglab:SetColor(Color(229, 228, 226, 255))
		druglab:SetPos( tr.HitPos + tr.HitNormal*50);
		druglab.Owner = ply
		druglab:Spawn();
	return "";
end
AddChatCommand( "/buydiamondprinter", BuyDiamondPrinter );

function BuyBixbitePrinter( ply )
	args = Purify(args)
	if( args == "" ) then return ""; end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

		if( not ply:CanAfford( CfgVars["bixbiteprintercost"] )) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxBixbitePrinter >= CfgVars["maxbixbiteprinters"])then
			Notify( ply, 4, 3, "Max Bixbite Printers Reached!" );
			return "";
		end
		ply:AddMoney( -CfgVars["bixbiteprintercost"] );
		Notify( ply, 0, 3, "You bought a Bixbite Printer!" );
		local printer = ents.Create( "money_printer_bixbite" );

		printer:SetMaterial( "models/shiny" )
		printer:SetColor(Color(229, 228, 226, 255))
		printer:SetPos( tr.HitPos + tr.HitNormal*50);
		printer.Owner = ply
		printer:Spawn();
	return "";
end
AddChatCommand( "/buybixbiteprinter", BuyBixbitePrinter );

function BuyNuclearPrinter( ply )
	local nuclearmax = false

	for k,v in pairs( ents.FindByClass("money_printer_nuclear")) do
		if IsValid(v) then
			nuclearmax = true
		end
	end
	if nuclearmax==true then
		Notify( ply, 4, 3, "Someone has already spawned a Nuclear Money Printer!" );
		return
	end

	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

	if( not ply:CanAfford( CfgVars["nukeprintercost"] )) then
		Notify( ply, 4, 3, "Cannot afford this" );
		return "";
	end
	if(ply:GetTable().maxNuclearPrinter >= CfgVars["maxnuclearprinters"])then
		Notify( ply, 4, 3, "Max Nuclear Printers Reached!" );
		return "";
	end
	ply:AddMoney( -CfgVars["nukeprintercost"] );
	Notify( ply, 0, 3, "You bought a Nuclear Money Printer, Take Cover!" );
	local druglab = ents.Create( "money_printer_nuclear" );

	druglab:SetPos( tr.HitPos + tr.HitNormal*70);
	druglab:SetColor(Color(255, 255, 255, 255))
	druglab.Owner = ply
	druglab:Spawn();
	for k, v in pairs(player.GetAll()) do
		v:EmitSound( "basewars/nuclearprinter.mp3" )
	end
	return "";
end
AddChatCommand( "/buynuclearprinter", BuyNuclearPrinter );

function BuyWashingMachinePrinter( ply )

end
AddChatCommand( "/buybuywashingmachineprinter", BuyWashingMachinePrinter );

function BuyPrinter( ply )

end
AddChatCommand( "/buymoneyprinter", BuyPrinter );

function BuyStill( ply,args )
	args = Purify(args)
	local count = tonumber(args)
	if count==nil then count = 1 end
	if count>CfgVars["maxstills"] or count<1 then count = 1 end
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );
	for i=1,count do
		if( not ply:CanAfford( CfgVars["stillcost"] ) ) then
			Notify( ply, 4, 3, "Cannot afford this" );
			return "";
		end
		if(ply:GetTable().maxStill >= CfgVars["maxstills"])then
			Notify( ply, 4, 3, "Max Stills Reached!" );
			return "";
		end
		ply:AddMoney( CfgVars["stillcost"] * -1 );
		Notify( ply, 0, 3, "You bought a Moonshine Still" );
		local druglab = ents.Create( "still_average" );

		druglab.Owner = ply
		druglab:SetPos( tr.HitPos + tr.HitNormal*40);
		druglab:Spawn();
	end
	return "";
end
AddChatCommand( "/buystill", BuyStill );

function BuyNPC(ply,args)
	args = Purify(args)
	args = string.Explode(" ", args)
	local trace = { }

	trace.start = ply:EyePos();
	trace.endpos = trace.start + ply:GetAimVector() * 85;
	trace.filter = ply;

	local tr = util.TraceLine( trace );

	local npctype = "npc_manhack"

	npctype = "npc_metropolice"

	if( true ) then

		Notify( ply, 0, 3, "You bought an npc" );
		local npc = ents.Create( npctype );
		npc:SetNWEntity("owner", ply);
		table.insert(ply:GetTable().NPCs, npc)
		npc:SetPos( tr.HitPos );
		if npctype=="npc_vortigaunt" then
			npc:SetModel("models/vortigaunt_slave.mdl")
		end
		npc:Spawn()
		npc:Give("weapon_mac102")

		npc:AddRelationship("player D_FR 3")
		npc:AddRelationship("player D_HT 9")
		npc:AddRelationship("player D_LI 8")
		npc:AddRelationship("player D_NU 10")

		npc:AddEntityRelationship(ply,D_LI,99)
		npc:AddEntityRelationship(ply,D_HT,0)
		npc:AddEntityRelationship(ply,D_FR,5)
		npc:AddEntityRelationship(ply,D_NU,4)

		npc:SetNPCState(1)
		npc:SetLastPosition(ply:GetPos())
		npc:SetSchedule(71)
	else
		Notify( ply, 1, 3, "That's not an available NPC." );
	end
	return "";
end

function BuyAmmo( ply )
		local plyweapon = ply:GetActiveWeapon()
		if not IsValid( plyweapon ) then return "" end
		local class = plyweapon:GetClass()

		-- Explosives / thrown weapons cannot be refilled with ammo - they must be rebought from the shop.
		if class == "weapon_stickgrenade" or class == "cse_eq_hegrenade" or class == "weapon_gasgrenade" or class == "cse_eq_flashbang" or class == "weapon_mad_charge" or class == "weapon_mad_c4" or class == "weapon_pipebomb" then
			Notify( ply, 4, 3, "This cannot be refilled with ammo - rebuy it from the shop." );
			return ""
		end
		if class == "weapon_minigun" then
			ply:GiveAmmo(500, plyweapon:GetPrimaryAmmoType())
			ply:AddMoney( CfgVars["minigunammocost"] * -1 );
			Notify( ply, 0, 3, "You purchased one Minigun Ammo for " ..CfgVars["minigunammocost"].. " dollars." );
			ply:ConCommand("play basewars/chaching.mp3")
			return ""
		end
		if class == "weapon_welder" or class == "weapon_knife2" or class == "lockpick" or class == "weapon_worldslayer" or class == "keys" or class == "gmod_tool" or class == "weapon_physgun" or class == "gmod_camera" or class == "weapon_physcannon" then
			Notify( ply, 4, 3, "This weapon does not require ammo." );
			return ""
		end
			ply:GiveAmmo(CfgVars["ammoamount"], plyweapon:GetPrimaryAmmoType())
			ply:AddMoney( CfgVars["ammocost"] * -1 )
			Notify( ply, 0, 3, CfgVars["ammoamount"].. " Ammo Purchased for " ..CfgVars["ammocost"].. " dollars." );
			ply:ConCommand("play basewars/chaching.mp3")
			return ""
end
AddChatCommand( "/buyammo", BuyAmmo );
concommand.Add("buyammo", BuyAmmo)

-- Economy safeguard: only admins may spawn weapons, entities, NPCs and vehicles
-- from the sandbox spawn (Q) menu. Everyone else must buy from the shop.
-- Returning false blocks the spawn; returning nil for admins lets the sandbox
-- default (Spawnable / AdminSpawnable) decide, so admins keep their normal access.
-- Props are intentionally left alone (handled by GM:PlayerSpawnProp).
local function BW_BlockMenuSpawn( ply )
	if not IsValid( ply ) then return false end
	if ply:IsAdmin() or ply:IsSuperAdmin() then return end
	if Admins and Admins[ply:SteamID()] then return end
	Notify( ply, 4, 3, "Admin-Only! Buy items from the shop instead." )
	return false
end

hook.Add( "PlayerSpawnSWEP",    "BW_BlockMenuSpawn_SWEP",     BW_BlockMenuSpawn )
hook.Add( "PlayerGiveSWEP",     "BW_BlockMenuSpawn_GiveSWEP", BW_BlockMenuSpawn )
hook.Add( "PlayerSpawnSENT",    "BW_BlockMenuSpawn_SENT",     BW_BlockMenuSpawn )
hook.Add( "PlayerSpawnNPC",     "BW_BlockMenuSpawn_NPC",      BW_BlockMenuSpawn )
hook.Add( "PlayerSpawnVehicle", "BW_BlockMenuSpawn_Vehicle",  BW_BlockMenuSpawn )

function Purify ( strng )
	if (string.find(tostring(strng), [[%"]])) then
		strng = " "
	end
	if (string.find(tostring(strng), [[\n]])) then
		strng = " "
	end
	return strng
end

CreateConVar('sbox_maxmagnets', 50)

function Notify( ply, msgtype, len, msg )
	ply:PrintMessage( 2, msg );
	net.Start("RPDMNotify")
		net.WriteString(msg)
		net.WriteInt(msgtype, 16)
		net.WriteInt(len, 16)
	net.Send(ply)

end

function NotifyAll( msgtype, len, msg )

	for k, v in pairs( player.GetAll() ) do

		Notify( v, msgtype, len, msg );

	end

end

function PrintMessageAll( msgtype, msg )

	for k, v in pairs( player.GetAll() ) do

		v:PrintMessage( msgtype, msg );

	end

end

function TalkToRange( msg, pos, size )

	local ents = ents.FindInSphere( pos, size );

	for k, v in pairs( ents ) do

		if( v:IsPlayer() ) then

			v:ChatPrint( msg );
			v:PrintMessage( 2, msg );

		end

	end

end

function FindPlayer( info )

	for k, v in pairs( player.GetAll() ) do

		if( tonumber( info ) == v:EntIndex() ) then
			return v;
		end

		if( info == v:SteamID() ) then
			return v;
		end

		if( string.find( string.lower(v:Nick()), string.lower(info) ) ~= nil ) then
			return v;
		end

	end

	return nil;

end

function ShockWaveExplosion(pos, ply, hitnorm, rad)
	rad = math.Round(rad*.5)

	net.Start("shockwaveeffect")
		net.WriteVector(pos)
		net.WriteAngle(hitnorm)
		net.WriteInt(rad, 16)
	net.Send(ply)
	local efdt = EffectData()
		efdt:SetStart(pos)
		efdt:SetOrigin(pos)
		efdt:SetScale(1)
		efdt:SetRadius(rad)
		efdt:SetNormal(hitnorm)
	util.Effect("cball_bounce",efdt)
end

function SpyScan(ply,target,backscan)
	if target:GetNWBool("scannered") then
		Notify(ply,4,3,"Could not scan target information due to target having a scanner")
		if not backscan and target~=ply then
			Notify(target, 1, 3, "Using your scanner to scan them back.")
			SpyScan(target,ply,true)
		end
	else
		Notify(ply,2,3,"Printing information on scan target in your console")
		local weapon = "Nothing"
		if IsValid(target:GetActiveWeapon()) then
			weapon = target:GetActiveWeapon():GetClass()
		end
		ply:PrintMessage(2, "\n" ..target:GetName() .. "\n" .. target:Health() .. "/" .. target:GetMaxHealth() .. " Health and " .. target:Armor() .. "/100 Armor\nHolding weapon: " .. weapon .. "\nOther weapons: \n")
		for k,v in pairs(target:GetWeapons()) do
			if v~=target:GetActiveWeapon() then
				ply:PrintMessage(2, v:GetClass() .. "\n")
			end
		end
		local shield = ""
		local scanner = ""
		local helmet = ""
		if target:GetNWBool("shielded") then shield = "shield " end
		if target:GetNWBool("helmeted") then helmet = "helmet " end
		if target:GetNWBool("scannered") then scanner = "scanner " end
		if scanner=="" and helmet == "" and shield == "" then scanner = "Nothing" end
		ply:PrintMessage(2, "Equipped: " .. shield .. helmet .. scanner .. "\n\n")

	end
end

function ReconScan(ply, target)
	Notify(ply,2,3,"Printing a list of things found in scan to your console")
	local scanpos = target:GetPos()
	local stuff = 0
	ply:PrintMessage(2,"\n")
	for k, v in pairs(ents.FindInSphere(scanpos, 512)) do
		if IsValid(v) then
			if v:GetTable().Structure then
				stuff = stuff+1
				ply:PrintMessage(2, v:GetTable().PrintName .. " " .. v.Owner:GetName())
			end
		end
	end
	ply:PrintMessage(2,"\n")
	if stuff>0 then
		Notify(ply,3,3,"Scan has found " .. tostring(stuff) .. " structures near " .. target:GetName().."")
	else
		Notify(ply,4,3,"Scan has found nothing")
	end
end

local uberexists=false
function UberDrugExists()
	if not uberexists then
		NotifyAll(1,5,"Someone has created an UberDrug!")
		uberexists=true
	end
end

function ccBuyDrugs( ply, command, args )
	local drug = args[1]
	if ply:GetTable().LastBuy+1.5<CurTime() then
		ply:GetTable().LastBuy=CurTime()
		if( drug == "steroid" ) then
			BuySteroid(ply)
		elseif( drug == "doublejump" ) then
			BuyDoubleJump(ply)
		elseif( drug == "leech" ) then
			BuyLeech(ply)
		elseif( drug == "amp" or drug == "amplifier" ) then
			BuyAmp(ply)
		elseif( drug == "armorpiercer" ) then
			BuyArmorpiercer(ply)

		elseif( drug == "regen" ) then
			BuyRegen(ply)
		elseif( drug == "painkiller" ) then
			BuyPainKiller(ply)
		elseif( drug == "antidote" ) then
			BuyAntidote(ply)
		elseif( drug == "reflect" ) then
			BuyReflect(ply)
		elseif( drug == "adrenaline" ) then
			BuyAdrenaline(ply)

		elseif( drug == "magicbullet" ) then
			BuyMagicBullet(ply)
		elseif( drug == "shockwave" ) then
			BuyShockWave(ply)
		elseif( drug == "knockback" ) then
			BuyKnockback(ply)
		elseif( drug == "doubletap" ) then
			BuyDoubleTap(ply)
		elseif( drug == "focus" ) then
			BuyFocus(ply)

		elseif( drug == "health" ) then
			BuyHealth(ply)
		elseif( drug == "shield" ) then
			BuyShield(ply)
		elseif( drug == "helmet" ) then
			BuyHelmet(ply)
		elseif( drug == "scanner" ) then
			BuyScanner(ply)
		elseif( drug == "toolkit" ) then
			BuyToolKit(ply)
		elseif( drug == "armor" ) then
			BuyArmor(ply)
		end
	end
end
concommand.Add( "buydrug", ccBuyDrugs );

function ccBuyBatchDrugs( ply, command, args )
	local drug = args[1]
	if ply:GetTable().LastBuy+1.5<CurTime() then
		ply:GetTable().LastBuy=CurTime()
		if( drug == "steroid" ) then
			BuyBatchSteroid(ply)
		elseif( drug == "doublejump" ) then
			BuyBatchDoubleJump(ply)
		elseif( drug == "leech" ) then
			BuyBatchLeech(ply)
		elseif( drug == "amp" or drug == "amplifier" ) then
			BuyBatchAmp(ply)
		elseif( drug == "armorpiercer" ) then
			BuyBatchArmorpiercer(ply)

		elseif( drug == "regen" ) then
			BuyBatchRegen(ply)
		elseif( drug == "painkiller" ) then
			BuyBatchPainKiller(ply)
		elseif( drug == "antidote" ) then
			BuyBatchAntidote(ply)
		elseif( drug == "reflect" ) then
			BuyBatchReflect(ply)
		elseif( drug == "adrenaline" ) then
			BuyBatchAdrenaline(ply)

		elseif( drug == "magicbullet" ) then
			BuyBatchMagicBullet(ply)
		elseif( drug == "shockwave" ) then
			BuyBatchShockWave(ply)
		elseif( drug == "knockback" ) then
			BuyBatchKnockback(ply)
		elseif( drug == "doubletap" ) then
			BuyBatchDoubleTap(ply)
		elseif( drug == "focus" ) then
			BuyBatchFocus(ply)

		end
	end
end
concommand.Add( "buybatchdrug", ccBuyBatchDrugs );

function ccBuyStructure( ply, command, args )
	local building = args[1]
	if ply:GetTable().LastBuy+1.5<CurTime() then
		ply:GetTable().LastBuy=CurTime()
		if( building == "sentry" ) then
			BuyTurret(ply)
		elseif( building == "spawn" ) then
			BuySpawn(ply)
		elseif( building == "dispenser" ) then
			BuyDispenser(ply)
        elseif( building == "healthdispenser" ) then
			BuyHealthDispenser(ply)
        elseif( building == "armordispenser" ) then
			BuyArmorDispenser(ply)
		elseif( building == "microwave" ) then
			BuyMicrowave(ply)
		elseif( building == "lamp" ) then
			BuyLamp(ply)
		elseif( building == "radar" ) then
			BuyTower(ply)
		elseif( building == "refinery" ) then
			BuyRefinery(ply)
		elseif( building == "gunlab" ) then
			BuyGunlab(ply)
		elseif( building == "factory" ) then
			BuyGunFactory(ply)
		elseif( building == "plant" ) then
			BuyPlant(ply)
		elseif( building == "still" ) then
			BuyStill(ply)
		elseif( building == "druglab" ) then
			BuyDrug(ply)
		elseif( building == "methlab" ) then
			BuyMethlab(ply)
		elseif( building == "stablemethlab" ) then
			BuyStableMethLab(ply)
		elseif( building == "supplycabinet" ) then
			BuySupplyTable(ply)

		elseif( building == "bronzeprinter" ) then
			BuyBronzePrinter(ply)
		elseif( building == "printer" ) then
			BuyPrinter(ply)
		elseif( building == "silverprinter" ) then
			BuySilverPrinter(ply)
		elseif( building == "goldprinter" ) then
			BuyGoldPrinter(ply)
		elseif( building == "platinumprinter" ) then
			BuyPlatinumPrinter(ply)
		elseif( building == "washingmachineprinter" ) then
			BuyWashingMachinePrinter(ply)
		elseif( building == "diamondprinter" ) then
			BuyDiamondPrinter(ply)
		elseif( building == "bixbiteprinter" ) then
			BuyBixbitePrinter(ply)
		elseif( building == "nuclearprinter" ) then
			BuyNuclearPrinter(ply)

		elseif( building == "generator" ) then
			BuyGenerator(ply)
		elseif( building == "supergenerator" ) then
			BuySuperGenerator(ply)
		elseif( building == "moneyvault" ) then
			BuyMoneyVault(ply)
		end
	end
end
concommand.Add( "buystruct", ccBuyStructure );

function ccBuySpecial( ply, command, args )
	local building = args[1]
	if ply:GetTable().LastBuy+1.5<CurTime() then
		ply:GetTable().LastBuy=CurTime()
		if( building == "knife" ) then
			BuyKnife(ply)
		elseif( building == "pipebomb" ) then
			BuyPBomb(ply)
		elseif( building == "lockpick" ) then
			BuyLockPick(ply)
		elseif( building == "welder" ) then
			BuyWelder(ply)
		elseif( building == "bigbomb" ) then
			BuyBomb(ply)
		elseif( building == "airboat" ) then
			BuyAirboat(ply)
		elseif( building == "jeep" ) then
			BuyJeep(ply)
		elseif( building == "gunvault" ) then
			BuyGunvault(ply)
		elseif( building == "pillbox" ) then
			BuyPillBox(ply)
		elseif( building == "fueltank" ) then
			BuyIncedAmmo(ply)
		elseif( building == "bluefireworks" ) then
			BuyFireWorksBlue(ply)
		elseif( building == "greenfireworks" ) then
			BuyFireWorksGreen(ply)
		elseif( building == "redfireworks" ) then
			BuyFireWorksRed(ply)
		elseif( building == "purplefireworks" ) then
			BuyFireWorksPurple(ply)
		end
	end
end
concommand.Add( "buyspecial", ccBuySpecial );

local nograv = {
"shot_beanbag",
"shot_tankshell",
"shot_rocket",
"shot_tranq",
"auto_turret_gun",
"shot_glround",
"svehicle_part_nophysics",
"svehicle_part",
"shot_glround",
"worldslayer",
"shot_energy"
}

physgunables = {
"gmod_cameraprop",
"gmod_rtcameraprop",
"gmod_balloon",
"gmod_button",
"gmod_lamp",
"gmod_light",
"gmod_anchor",
"func_physbox",
"prop_physics",
"prop_physics_multiplayer",
"spawned_weapon",
"microwave",
"bw_lamp",
"drug_lab",
"gunlab",
"dispenser",
"healthdispenser",
"armordispenser",
"phys_magnet",
"m_crate",
"prop_ragdoll",
"gmod_thruster",
"gmod_wheel",
"item_drug",
"item_steroid",
"item_painkiller",
"item_magicbullet",
"item_antidote",
"item_amp",
"item_helmet",
"item_random",
"item_buyhealth",
"item_superdrug",
"item_booze",
"item_scanner",
"item_toolkit",
"item_regen",
"item_reflect",
"item_focus",
"item_snipeshield",
"item_armor",
"item_food",
"item_leech",
"item_shockwave",
"item_doubletap",
"item_uberdrug",
"item_knockback",
"item_doublejump",
"item_armorpiercer",
"item_superdrugoffense",
"item_superdrugdefense",
"item_superdrugweapmod",
"pillbox",
"drugfactory",
"powerplant",
"superpowerplant",
"weedplant",
"meth_lab",
"prop_effect",
"money_printer",
"still",
"gunvault",
"radartower",
"gunfactory",
"bigbomb",
"keypad",
"sign"
}

function ccWithdrawGun( ply, cmd, args )

	if (args[1]==nil or args[2] == nil) then
		return
	end
	gnum = tonumber(args[2])
	if (not ents.GetByIndex(args[1]):IsValid() or gnum>10 or gnum<1) then
		return
	end
	local vault = ents.GetByIndex(args[1])
	if (vault:GetClass()~="gunvault" or ply:GetPos():Distance(vault:GetPos())>200) then return end
	if (vault:IsLocked() and ply~=vault.Owner and not ply:IsAllied(vault.Owner)) then return end
	if (vault:CanDropGun(gnum)) then
		vault:DropGun(gnum, ply, 25, false)
	else
		Notify(ply,4,3, "This gun does not exist!")
		net.Start("killgunvaultgui");
			net.WriteInt( args[1] , 16)
		net.Send(ply)
	end
end
concommand.Add( "withdrawgun", ccWithdrawGun );

function ccWithdrawItem( ply, cmd, args )

	if (args[1]==nil or args[2] == nil) then
		return
	end
	gnum = tonumber(args[2])
	if (not ents.GetByIndex(args[1]):IsValid() or gnum>20 or gnum<1) then
		return
	end
	local vault = ents.GetByIndex(args[1])
	if (vault:GetClass()~="pillbox" or ply:GetPos():Distance(vault:GetPos())>200) then return end
	if (vault:IsLocked() and ply~=vault.Owner and not ply:IsAllied(vault.Owner)) then return end
	if (vault:CanDropGun(gnum)) then
		vault:DropGun(gnum, ply, 35, false)
	else
		Notify(ply,4,3, "This item does not exist!")
		net.Start("killpillboxgui");
			net.WriteInt( args[1] , 16)
		net.Send(ply)
	end
end
concommand.Add( "withdrawitem", ccWithdrawItem );

function ccSetWeapon( ply, cmd, args )
	if (args[1]==nil or args[2] == nil) then
		return
	end
	guntype = tostring(args[2])
	if not IsValid(ents.GetByIndex(args[1])) or (guntype~="laserbeam" and guntype~="laserrifle" and guntype~="grenadegun" and guntype~="plasma" and guntype~="worldslayer" and guntype~="minigun" and guntype~="resetbutton") then
		return
	end
	local vault = ents.GetByIndex(args[1])
	if (vault:GetClass()~="gunfactory" or ply:GetPos():Distance(vault:GetPos())>300) then return end
	if (vault:CanProduce(guntype, ply)) then
		vault:StartProduction(ply,guntype)
	else
		if guntype=="resetbutton" then
			Notify(ply,4,3, "Only Gun Factory owner can cancel weapon production.")
		else
			Notify(ply,4,3, "Cant make weapon.")
		end
		net.Start("killgunfactorygui");
			net.WriteInt( args[1] , 16)
		net.Send(ply)
	end
end
concommand.Add( "setgunfactoryweapon", ccSetWeapon );

function WeldControl(ent,ply)
	if (IsValid(ply)) then
		if IsValid(ent) then
			ent:SetNWInt("welddamage", 150)
		end
		ply:GetTable().spamweldcount=ply:GetTable().spamweldcount-1
		if (ply:GetTable().spamweldcount<=0) then
			ply:GetTable().spamweldcount=0
			ply:SetNWBool("spamwelding", false)
		end
	end
end

function ccSetRefineryMode( ply, cmd, args )
	if (args[1]==nil or args[2] == nil) then
		return
	end
	mode = tostring(args[2])
	if not IsValid(ents.GetByIndex(args[1])) or (mode~="money" and mode~="offense" and mode~="defense" and mode~="weapmod" and mode~="eject" and mode~="uber") then
		return
	end
	local vault = ents.GetByIndex(args[1])
	if (vault:GetClass()~="drugfactory" or ply:GetPos():Distance(vault:GetPos())>300) then return end

	local ref = vault:CanRefine(mode,ply)
	if (ref==true) then
		vault:SetMode(mode)
	else
		Notify(ply,4,3,ref)
	end
	net.Start("killdrugfactorygui");
		net.WriteInt( args[1] , 16)
	net.Send(ply)
end
concommand.Add( "setrefinerymode", ccSetRefineryMode );

local function GetEntOwner(ent)
	if not IsValid(ent) then return false end
	local owner = ent
	if ent:GetVar("PropProtection")==nil then return false end
	if IsValid(player.GetByUniqueID(ent:GetVar("PropProtection"))) then
		owner = player.GetByUniqueID(ent:GetVar("PropProtection"))
	end
	if owner~=ent then
		return owner
	else
		return false
	end
end

local function SetOwner(ent, ply)

	if (IsValid(ent) and IsValid(ply) and ply:IsPlayer()) then
		ent:SetVar("PropProtection", ply:UniqueID() )
		return true
	else
		return false
	end
end

local originalCleanup = cleanup.Add
function cleanup.Add(ply,type,ent)
	if (IsValid(ply) and ply:IsPlayer() and IsValid(ent)) then
		SetOwner(ent, ply)
	end
	originalCleanup(ply,type,ent)
end

function SpawnedProp(ply, model, ent)
	SetOwner(ent, ply)
end

hook.Add("PlayerSpawnedProp", "playerSpawnedProp", SpawnedProp)

local BW_MovableStructures = {
	-- money printers (every tier is its own class)
	money_printer_washingmachine = true,
	money_printer_bronze         = true,
	money_printer_silver         = true,
	money_printer_gold           = true,
	money_printer_platinum       = true,
	money_printer_diamond        = true,
	money_printer_bixbite        = true,
	money_printer_nuclear        = true,
	-- drug / production
	drugfactory     = true,
	drug_lab        = true,
	meth_lab        = true,
	meth_lab_stable = true,
	weedplant       = true,
	still_average   = true, -- moonshine still
	-- economy / storage
	moneyvault  = true,
	supplytable = true,
	gunvault    = true,
	pillbox     = true,
	-- factories / power / misc
	gunfactory     = true,
	radartower     = true,
	powerplant     = true,
	superpowerplant = true,
	dispenser      = true,
	healthdispenser = true,
	armordispenser = true,
	bw_lamp        = true,
	keypad         = true,
	sign           = true,
}

hook.Add("OnEntityCreated", "BW_AssignStructureOwner", function(ent)
	if not IsValid(ent) then return end
	if not BW_MovableStructures[ent:GetClass()] then return end
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		if ent.FPPOwner then return end -- already owned (e.g. spawn-menu props tracked by FPP)
		local owner = ent.Owner
		if IsValid(owner) and owner:IsPlayer() and ent.CPPISetOwner then
			ent:CPPISetOwner(owner)
		end
	end)
end)
