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
	//"lua/CommAbilities/Alien/Bonewall.lua"
}
// We also need to somehow remove the corresponding entries in TechData.lua...

if #kCombatFileRemovals > 0 then
	Print ("Registering file removals...")
end

for index, override in ipairs(kCombatFileRemovals) do
	Print ("Removing source file " .. override)
	
	// Hook into the load tracker code to remove the file when we come across it.
	// The normalized string is always lower case.
	override = string.lower(override)
	LoadTracker:SetFileOverride(override, "")
end