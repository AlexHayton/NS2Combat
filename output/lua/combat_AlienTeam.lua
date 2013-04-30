//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_AlienTeam.lua

local HotReload = CombatAlienTeam
if(not HotReload) then
  CombatAlienTeam = {}
  ClassHooker:Mixin("CombatAlienTeam")
end

function CombatAlienTeam:OnLoad()

    ClassHooker:SetClassCreatedIn("AlienTeam", "lua/AlienTeam.lua") 
	self:ReplaceClassFunction("AlienTeam", "SpawnInitialStructures", "SpawnInitialStructures_Hook")
	self:ReplaceClassFunction("AlienTeam", "GetNumHives","GetNumHives_Hook")
	
end


// No cysts
function CombatAlienTeam:SpawnInitialStructures_Hook(self, techPoint)

    local tower, hive = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    hive:SetFirstLogin()
    hive:SetInfestationFullyGrown()    
   
    return tower, hive
    
end


function CombatAlienTeam:GetNumHives_Hook()

    return 6
    
end

if (not HotReload) then
	CombatAlienTeam:OnLoad()
end