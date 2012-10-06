//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_FileOverrides.lua

// Use this to remove files entirely from the loading process.

// Case doesn't matter here!
kCombatFileRemovals = {
	"lua/CommAbilities/Alien/Bonewall.lua",
	"lua/CommAbilities/Alien/CragBabblers.lua",
	"lua/CommAbilities/Alien/NutrientMist.lua",
	"lua/CommAbilities/Alien/Rupture.lua"
}

// Case matters here!
kCombatEntityStubs = {
	"BoneWall",
	"CragBabblers",
	"NutrientMist",
	"Rupture"
}

if #kCombatFileRemovals > 0 then
	Shared.Message ("Registering file removals...")
end

for index, override in ipairs(kCombatFileRemovals) do
	Shared.Message ("Removing source file " .. override)
	
	// Hook into the load tracker code to remove the file when we come across it.
	// The normalized string is always lower case.
	override = string.lower(override)
	LoadTracker:SetFileOverride(override, "")
end

for index, stub in ipairs(kCombatEntityStubs) do
	Shared.Message ("Stubbing the entity " .. stub)
	
	local result, error 
	result, error = loadstring(stub .. " = {}")
	pcall(result)
	
	result, error = loadstring(stub .. ".kModelName = \"\"")
	pcall(result)
	
	result, error = loadstring(stub .. ".kMapName = \"\"")
	pcall(result)
end 