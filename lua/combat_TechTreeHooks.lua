//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_TechTreeHooks.lua

local HotReload = CombatTechTree
if(not HotReload) then
  CombatTechTree = {}
end

ClassHooker:Mixin("CombatTechTree")

function CombatTechTree:OnLoad()

    ClassHooker:SetClassCreatedIn("TechTree", "lua/TechTree.lua") 
	self:ReplaceFunction("GetHasTech", "GetHasTech_Hook")
    self:PostHookFunction("GetIsTechAvailable", function() return true end)
	self:ReplaceClassFunction("TechTree", "GetIsTechAvailable", function() return true end)
	
end

// Utility functions
function CombatTechTree:GetHasTech_Hook(callingEntity, techId, silenceError)

	if callingEntity ~= nil then
       
		// In combat mode, the tech tree resides on the player not the team
        local techTree = callingEntity:GetTechTree()
            
        if techTree ~= nil then
          return techTree:GetHasTech(techId, silenceError)
        end
        
    end
    
    return false
    
end

CombatTechTree:OnLoad()
