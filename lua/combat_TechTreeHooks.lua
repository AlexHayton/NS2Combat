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
	self:ReplaceClassFunction("TechTree", "GetIsTechAvailable", "GetIsTechAvailable_Hook")
	
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

// when techIds from our combat, just say true
function CombatTechTree:GetIsTechAvailable_Hook(self, techId)

    local isCombatUp = false

    if UpsList then
        for index, upgrade in pairs(UpsList) do
            if techId == upgrade:GetTechId() then
                isCombatUp = true
            end
        end
	end
	
    if isCombatUp then        
        return true
    else    
        local techNode = self:GetTechNode(techId)
        if techNode then
            return techNode:GetAvailable()
        end 
        
        return false        
    end 

end


if(HotReload) then
    CombatTechTree:OnLoad()
end