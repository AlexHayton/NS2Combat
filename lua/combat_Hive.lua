//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Hive.lua

if(not CombatHive) then
  CombatHive = {}
end

ClassHooker:Mixin("CombatHive")
    
function CombatHive:OnLoad()

    self:PostHookClassFunction("Hive", "OnCreate", "OnCreate_Hook")
	
end

// Hives should begin as mature.
function CombatHive:OnCreate_Hook(self)

	self:SetMature()
            
end