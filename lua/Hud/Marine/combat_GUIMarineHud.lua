//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIMarineHud.lua


if(not CombatGUIMarineHud) then
  CombatGUIMarineHud = {}
end

local HotReload = ClassHooker:Mixin("CombatGUIMarineHud")
    
function CombatGUIMarineHud:OnLoad()

    ClassHooker:SetClassCreatedIn("GUIMarineHUD", "lua/Hud/Marine/GUIMarineHud.lua") 
    self:PostHookClassFunction("GUIMarineHUD", "Update", "Update_Hook")


end

// Display a COMBAT MODE instead of commander name...
function CombatGUIMarineHud:Update_Hook(self, deltaTime)

	self.commanderName:DestroyAnimation("COMM_TEXT_WRITE")
	self.commanderName:SetText("COMBAT MODE")
	self.commanderName:SetColor(GUIMarineHUD.kActiveCommanderColor)

end


if(hotreload) then
    CombatGUIMarineHud:OnLoad()
end