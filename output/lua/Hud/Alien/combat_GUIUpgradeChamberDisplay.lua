//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIUpgradeChamberDisplay.lua

local HotReload = CombatGUIUpgradeChamberDisplay
if(not HotReload) then
  CombatGUIUpgradeChamberDisplay = {}
  ClassHooker:Mixin("CombatGUIUpgradeChamberDisplay")
end
    
function CombatGUIUpgradeChamberDisplay:OnLoad()

    ClassHooker:SetClassCreatedIn("GUIUpgradeChamberDisplay", "lua/GUIUpgradeChamberDisplay.lua") 
	_addHookToTable(self:PostHookClassFunction("GUIUpgradeChamberDisplay", "Initialize", "Initialize_Hook"))
	
end

// Hide the chamber GUI
function CombatGUIUpgradeChamberDisplay:Initialize_Hook(self)

    self.background:SetIsVisible(false)

end

if (not HotReload) then
	CombatGUIUpgradeChamberDisplay:OnLoad()
end