//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_TechTreeHooks.lua

if(not CombatTechTree) then
  CombatTechTree = {}
end

local HotReload = ClassHooker:Mixin("CombatTechTree")

function CombatTechTree:OnLoad()

    ClassHooker:SetClassCreatedIn("TechTree", "lua/TechTree.lua") 
	self:ReplaceFunction("GetHasTech", "GetHasTech_Hook")
	
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


if(HotReload) then
    CombatTechTree:OnLoad()
end