//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIAlienSpectatorHUD.lua

local HotReload = CombatGUIAlienSpectatorHUD
if(not HotReload) then
  CombatGUIAlienSpectatorHUD = {}
  ClassHooker:Mixin("CombatGUIAlienSpectatorHUD")
end
    
function CombatGUIAlienSpectatorHUD:OnLoad()

    ClassHooker:SetClassCreatedIn("GUIAlienSpectatorHUD", "lua/GUIAlienSpectatorHUD.lua") 
	_addHookToTable(self:PostHookClassFunction("GUIAlienSpectatorHUD", "Update", "Update_Hook"))
	
end

function CombatGUIAlienSpectatorHUD:Update_Hook(self)

	self.eggIcon:SetIsVisible(false)

end

if (not HotReload) then
	CombatGUIAlienSpectatorHUD:OnLoad()
end