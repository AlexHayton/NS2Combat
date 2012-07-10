//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Armory.lua


if(not CombatArmory) then
    CombatArmory = {}
end


local HotReload = ClassHooker:Mixin("CombatArmory")
    
function CombatArmory:OnLoad()
    
    ClassHooker:SetClassCreatedIn("Armory", "lua/Armory.lua") 
    self:ReplaceClassFunction("Armory", "GetRequiresPower", "GetRequiresPower_Hook") 
    
end

// Give some XP to the damaging entity.
function CombatArmory:GetRequiresPower_Hook(self)

   return false
    
end

if(HotReload) then
    CombatArmory:OnLoad()
end