//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIPlayerResources.lua


if(not CombatGUIPlayerResources) then
  CombatGUIPlayerResources = {}
end

ClassHooker:Mixin("CombatGUIPlayerResources")
    
function CombatGUIPlayerResources:OnLoad()

	
	ClassHooker:SetClassCreatedIn("GUIPlayerResource", "lua/Hud/GUIPlayerResource.lua") 
    self:PostHookClassFunction("GUIPlayerResource", "Update", "UpdateResource_Hook")
    self:PostHookClassFunction("GUIPlayerResource", "Initialize", "Initialize_Hook")

end


// Hide the TEAM RES
function CombatGUIPlayerResources:UpdateResource_Hook(self, deltaTime, parameters)

	self.teamText:SetText("")

end


// Upgrade Points instead of RESOURCES
function CombatGUIPlayerResources:Initialize_Hook(self, style) 

	self.pResDescription:SetText("Upgrade Points")

end

CombatGUIPlayerResources:OnLoad()