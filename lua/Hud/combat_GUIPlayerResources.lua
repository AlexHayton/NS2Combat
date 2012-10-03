//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIPlayerResources.lua


local HotReload = CombatGUIPlayerResources
if(not HotReload) then
  CombatGUIPlayerResources = {}
  ClassHooker:Mixin("CombatGUIPlayerResources")
end
    
function CombatGUIPlayerResources:OnLoad()

	
	ClassHooker:SetClassCreatedIn("GUIPlayerResource", "lua/Hud/GUIPlayerResource.lua") 
    _addHookToTable(self:PostHookClassFunction("GUIPlayerResource", "Update", "UpdateResource_Hook"))
    _addHookToTable(self:PostHookClassFunction("GUIPlayerResource", "Initialize", "Initialize_Hook"))

end


// Hide the TEAM RES
function CombatGUIPlayerResources:UpdateResource_Hook(self, deltaTime, parameters)

	self.teamText:SetText("")

end


// Upgrade Points instead of RESOURCES
function CombatGUIPlayerResources:Initialize_Hook(self, style) 

	self.pResDescription:SetText("Upgrade Points")

end

if (not HotReload) then
	CombatGUIPlayerResources:OnLoad()
end