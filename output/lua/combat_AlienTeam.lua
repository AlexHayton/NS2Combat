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
	self:ReplaceClassFunction("AlienTeam", "GetBioMassLevel","GetBioMassLevel_Hook")
	self:ReplaceClassFunction("AlienTeam", "GetMaxBioMassLevel","GetMaxBioMassLevel_Hook")
	
end


// No cysts
function CombatAlienTeam:SpawnInitialStructures_Hook(self, techPoint)

    local tower, hive = PlayingTeam.SpawnInitialStructures(self, techPoint)
    
    hive:SetFirstLogin()
    hive:SetInfestationFullyGrown()    
   
    return tower, hive
    
end


function CombatAlienTeam:GetNumHives_Hook(self)

    return 6
    
end

function CombatAlienTeam:GetBioMassLevel_Hook(self)

	return 12
	
end

function CombatAlienTeam:GetMaxBioMassLevel_Hook(self)

	return 12
	
end

if (not HotReload) then
	CombatAlienTeam:OnLoad()
end