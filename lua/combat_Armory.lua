//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Armory.lua

local HotReload = CombatArmory
if(not HotReload) then
  CombatArmory = {}
end

ClassHooker:Mixin("CombatArmory")
    
function CombatArmory:OnLoad()
    
    ClassHooker:SetClassCreatedIn("Armory", "lua/Armory.lua") 
    self:ReplaceClassFunction("Armory", "GetRequiresPower", "GetRequiresPower_Hook") 
    
end

// Give some XP to the damaging entity.
function CombatArmory:GetRequiresPower_Hook(self)

   return false
    
end

CombatArmory:OnLoad()