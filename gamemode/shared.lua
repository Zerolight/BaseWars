team.SetUp( 1, "Citizen", Color( 125, 125, 125, 255 ) );

GMS = {}

GM.Name = "BaseWars"
GM.Author 	= "By Llamalords"
GM.Email 	= "jupiterjrb@msn.com"
GM.Website 	= "www.LmaoLlama.net"

drugtable = {}
drugtable["regen"] = {}
drugtable["regen"].color = Color(50, 150, 50, 255)
drugtable["regen"].string = "regened"
drugtable["regen"].symbol = "F"
drugtable["regen"].font = "DrugFont"
drugtable["regen"].type = 0
drugtable["antidote"] = {}
drugtable["antidote"].color = Color(50, 150, 150, 255)
drugtable["antidote"].string = "antidoted"
drugtable["antidote"].symbol = "F"
drugtable["antidote"].font = "DrugFont"
drugtable["antidote"].type = 0
drugtable["painkiller"] = {}
drugtable["painkiller"].color = Color(50, 50, 150, 255)
drugtable["painkiller"].string = "painkillered"
drugtable["painkiller"].symbol = "L"
drugtable["painkiller"].font = "DrugFont"
drugtable["painkiller"].type = 0
drugtable["reflect"] = {}
drugtable["reflect"].color = Color(100,125,0,255)
drugtable["reflect"].string = "mirrored"
drugtable["reflect"].symbol = "E"
drugtable["reflect"].font = "DrugFont"
drugtable["reflect"].type = 0
drugtable["adrenaline"] = {}
drugtable["adrenaline"].color = Color(100,125,150,255)
drugtable["adrenaline"].string = "adrenalined"
drugtable["adrenaline"].symbol = "M"
drugtable["adrenaline"].font = "DrugFont2"
drugtable["adrenaline"].type = 0

drugtable["steroid"] = {}
drugtable["steroid"].color = Color(150, 50, 50, 255)
drugtable["steroid"].string = "roided"
drugtable["steroid"].symbol = "D"
drugtable["steroid"].font = "DrugFont2"
drugtable["steroid"].type = 1
drugtable["amplifier"] = {}
drugtable["amplifier"].color = Color(100,50,125,255)
drugtable["amplifier"].string = "amped"
drugtable["amplifier"].symbol = "K"
drugtable["amplifier"].font = "DrugFont"
drugtable["amplifier"].type = 1
drugtable["leech"] = {}
drugtable["leech"].color = Color(50,0,0,255)
drugtable["leech"].string = "leeched"
drugtable["leech"].symbol = "z"
drugtable["leech"].font = "DrugFont2"
drugtable["leech"].type = 1
drugtable["doublejump"] = {}
drugtable["doublejump"].color = Color(100, 100, 100, 255)
drugtable["doublejump"].string = "doublejumped"
drugtable["doublejump"].symbol = "N"
drugtable["doublejump"].font = "DrugFont2"
drugtable["doublejump"].type = 1
drugtable["armorpiercer"] = {}
drugtable["armorpiercer"].color = Color(125, 125, 100, 255)
drugtable["armorpiercer"].string = "armorpiercered"
drugtable["armorpiercer"].symbol = "X"
drugtable["armorpiercer"].font = "DrugFont2"
drugtable["armorpiercer"].type = 1

drugtable["magicbullet"] = {}
drugtable["magicbullet"].color = Color(100,75,0,255)
drugtable["magicbullet"].string = "magicbulleted"
drugtable["magicbullet"].symbol = "W"
drugtable["magicbullet"].font = "DrugFont2"
drugtable["magicbullet"].type = 2
drugtable["focus"] = {}
drugtable["focus"].color = Color(200, 125, 50, 255)
drugtable["focus"].string = "focused"
drugtable["focus"].symbol = "D"
drugtable["focus"].font = "DrugFont"
drugtable["focus"].type = 2
drugtable["shockwave"] = {}
drugtable["shockwave"].color = Color(150, 125, 75, 255)
drugtable["shockwave"].string = "shockwaved"
drugtable["shockwave"].symbol = "I"
drugtable["shockwave"].font = "DrugFont"
drugtable["shockwave"].type = 2
drugtable["doubletap"] = {}
drugtable["doubletap"].color = Color(150,150,0,255)
drugtable["doubletap"].string = "doubletapped"
drugtable["doubletap"].symbol = "G"
drugtable["doubletap"].font = "DrugFont"
drugtable["doubletap"].type = 2
drugtable["knockback"] = {}
drugtable["knockback"].color = Color(200,200,150,255)
drugtable["knockback"].string = "knockbacked"
drugtable["knockback"].symbol = "*"
drugtable["knockback"].font = "DrugFont2"
drugtable["knockback"].type = 2

local DRUG_ICONS = {
	regen        = "icon16/heart_add.png",
	painkiller   = "icon16/pill.png",
	antidote     = "icon16/accept.png",
	reflect      = "icon16/shield.png",
	adrenaline   = "icon16/lightning.png",
	steroid      = "icon16/star.png",
	doublejump   = "icon16/arrow_up.png",
	leech        = "icon16/heart.png",
	amplifier    = "icon16/chart_bar.png",
	armorpiercer = "icon16/bullet_go.png",
	magicbullet  = "icon16/wand.png",
	shockwave    = "icon16/asterisk_orange.png",
	knockback    = "icon16/arrow_out.png",
	doubletap    = "icon16/control_fastforward.png",
	focus        = "icon16/eye.png"
}

for name, icon in pairs( DRUG_ICONS ) do
	if ( drugtable[ name ] ) then drugtable[ name ].icon = icon end
end

cleanup.Register( "magnets" )
