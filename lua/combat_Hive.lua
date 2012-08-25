//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Hive.lua

local HotReload = CombatHive
if(not HotReload) then
  CombatHive = {}
  ClassHooker:Mixin("CombatHive")
end
    
function CombatHive:OnLoad()

    self:PostHookClassFunction("Hive", "OnCreate", "OnCreate_Hook")
	
end

// Hives should begin as mature.
function CombatHive:OnCreate_Hook(self)

	self:SetMature()
            
end

if (not HotReload) then
	CombatHive:OnLoad()
end