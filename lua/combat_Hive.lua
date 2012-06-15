//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Hive.lua

if(not CombatHive) then
  CombatHive = {}
end

local HotReload = ClassHooker:Mixin("CombatHive")
    
function CombatHive:OnLoad()

    ClassHooker:SetClassCreatedIn("Hive", "lua/Hive.lua")
    self:ReplaceClassFunction("Hive", "GenerateEggSpawns", "GenerateEggSpawns_Hook")
    self:ReplaceClassFunction("Hive", "SpawnEgg", "SpawnEgg_Hook")
	
end

// No eggs will be spawned
function CombatHive:GenerateEggSpawns_Hook(self)
	// Do nothing
end

function CombatHive:SpawnEgg_Hook(self)
	// Do nothing
end
