//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIMarineHud.lua

local HotReload = CombatGUIMarineHud
if(not HotReload) then
  CombatGUIMarineHud = {}
  ClassHooker:Mixin("CombatGUIMarineHud")
end
    
function CombatGUIMarineHud:OnLoad()

    ClassHooker:SetClassCreatedIn("GUIMarineHUD", "lua/Hud/Marine/GUIMarineHud.lua") 
    _addHookToTable(self:PostHookClassFunction("GUIMarineHUD", "Update", "Update_Hook"))


end

// Display a COMBAT MODE instead of commander name...
function CombatGUIMarineHud:Update_Hook(self, deltaTime)

	self.commanderName:DestroyAnimation("COMM_TEXT_WRITE")
	self.commanderName:SetText("COMBAT MODE")
	self.commanderName:SetColor(GUIMarineHUD.kActiveCommanderColor)

end

if (not HotReload) then
	CombatGUIMarineHud:OnLoad()
end