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

    ClassHooker:SetClassCreatedIn("Hive", "lua/Hive_Server.lua")
	
end

// No eggs will be spawned


//function CombatHive:SpawnEgg_Hook(self)
	// Do nothing
//end
