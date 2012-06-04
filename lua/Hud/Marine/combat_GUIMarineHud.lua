//________________________________
//
//   	Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//	Version 0.1
//	
//________________________________

// combat_GUIMarineHud.lua


if(not CombatGUIMarineHud) then
  CombatGUIMarineHud = {}
end

local HotReload = ClassHooker:Mixin("CombatGUIMarineHud")
    
function CombatGUIMarineHud:OnLoad()

    ClassHooker:SetClassCreatedIn("GUIMarineHUD", "lua/GUIMarineHud.lua") 
    self:ReplaceClassFunction("GUIMarineHUD", "Update", "Update_Hook")

end

// Display a COMBAT MODE instead of commander name...
function CombatGUIMarineHud:Update_Hook(deltaTime)

        self.commanderName:DestroyAnimation("COMM_TEXT_WRITE")
        self.commanderName:SetText("")
        self.commanderName:SetText("COMBAT MODE", 0.5, "COMM_TEXT_WRITE")
    
        if self.commanderNameIsAnimating then
        
            self.commanderNameIsAnimating = false
            self.commanderName:DestroyAnimations()
            self.commanderName:SetColor(GUIMarineHUD.kActiveCommanderColor)
            
        end
end

if(hotreload) then
    CombatGUIMarineHud:OnLoad()
end