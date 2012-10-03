//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_ArmoryClient.lua

local HotReload = CombatArmoryClient
if(not HotReload) then
  CombatArmoryClient = {}
  ClassHooker:Mixin("CombatArmoryClient")
end
    
function CombatArmoryClient:OnLoad()
    
    ClassHooker:SetClassCreatedIn("Armory", "lua/Armory.lua") 
    _addHookToTable(self:ReplaceClassFunction("Armory", "OnUse", function() end)) 
	_addHookToTable(self:ReplaceClassFunction("Armory", "GetCanBeUsedConstructed", "GetCanBeUsedConstructed_Hook"))
    
end

function CombatArmoryClient:GetCanBeUsedConstructed_Hook()

    return false
	
end    

if (not HotReload) then
	CombatArmoryClient:OnLoad()
end
