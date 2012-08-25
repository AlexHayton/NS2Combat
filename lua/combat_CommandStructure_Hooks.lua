//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_CommandStructure_Hooks.lua

local HotReload = CombatCommandStructure
if(not HotReload) then
  CombatCommandStructure = {}
  ClassHooker:Mixin("CombatCommandStructure")
end
    
function CombatCommandStructure:OnLoad()

    ClassHooker:SetClassCreatedIn("CommandStructure", "lua/CommandStructure.lua") 
    self:ReplaceClassFunction("CommandStructure", "UpdateCommanderLogin", "UpdateCommanderLogin_Hook")
	
end

function CombatCommandStructure:UpdateCommanderLogin_Hook(self, force)

	self.occupied = true
    self.commanderId = Entity.invalidId
            
end

if (not HotReload) then
	CombatCommandStructure:OnLoad()
end