if not SERVER then return end

-- Workshop delivery: clients auto-download the "BaseWars Content" pack through
-- Steam. This is the reliable method; the resource.AddFile walk below is the
-- FastDL fallback.

-- resource.AddWorkshop( "ID HERE" )

local CONTENT = "gamemodes/basewars/content"

-- Virtual-path prefixes to skip, mirroring content/addon.json's "ignore" so the
-- FastDL registration and the Workshop pack stay in sync. materials/gui holds
-- the stock silk-icon VTFs -- unused by the port (code uses the built-in
-- icon16/*.png), so there is no reason to make clients download them.
local IGNORE = {
	"materials/gui/",
}

local function ignored( virtualPath )
	for _, prefix in ipairs( IGNORE ) do
		if virtualPath:sub( 1, #prefix ) == prefix then return true end
	end
	return false
end

local function AddContentDir( realDir, virtualPrefix )
	if ignored( virtualPrefix ) then return end

	local files, dirs = file.Find( realDir .. "/*", "GAME" )

	for _, f in ipairs( files or {} ) do
		resource.AddFile( virtualPrefix .. f )
	end

	for _, d in ipairs( dirs or {} ) do
		AddContentDir( realDir .. "/" .. d, virtualPrefix .. d .. "/" )
	end
end

-- content/<top>/...  maps to the client-visible path  <top>/...
for _, top in ipairs( { "materials", "models", "sound", "particles" } ) do
	AddContentDir( CONTENT .. "/" .. top, top .. "/" )
end
