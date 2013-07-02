//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIBioMassDisplay.lua

local HotReload = CombatGUIBioMassDisplay
if(not HotReload) then
  CombatGUIBioMassDisplay = {}
  ClassHooker:Mixin("CombatGUIBioMassDisplay")
end
    
function CombatGUIBioMassDisplay:OnLoad()

    ClassHooker:SetClassCreatedIn("GUIBioMassDisplay", "lua/GUIBioMassDisplay.lua") 
	_addHookToTable(self:PostHookClassFunction("GUIBioMassDisplay", "Update", "Update_Hook"))
	
end

// Hide the biomass GUI
function CombatGUIBioMassDisplay:Update_Hook(self, deltaTime)

    self.backgroundColor.a = 0
    self.background:SetColor(self.backgroundColor)
    self.smokeyBackground:SetColor(self.backgroundColor)

end

if (not HotReload) then
	CombatGUIBioMassDisplay:OnLoad()
end