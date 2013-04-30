//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Armory.lua

local HotReload = CombatArmory
if(not HotReload) then
  CombatArmory = {}
  ClassHooker:Mixin("CombatArmory")
end
    
function CombatArmory:OnLoad()
    
    ClassHooker:SetClassCreatedIn("Armory", "lua/Armory.lua") 
    self:ReplaceClassFunction("Armory", "GetRequiresPower", "GetRequiresPower_Hook") 
	self:ReplaceClassFunction("Armory", "GetCanBeUsedConstructed", "GetCanBeUsedConstructed_Hook")
    
end

// Give some XP to the damaging entity.
function CombatArmory:GetRequiresPower_Hook(self)

   return false
    
end

function CombatArmory:GetCanBeUsedConstructed_Hook()

    return false
	
end    

if (not HotReload) then
	CombatArmory:OnLoad()
end
