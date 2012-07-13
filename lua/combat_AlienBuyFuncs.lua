//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_AlienBuyFuncs.lua
      
// helper Functions for the List, text etc  



function CombatAlienBuy_GetAbilitiesFor(lifeFormTechId)

    local abilityIds = {}

    local player = Client.GetLocalPlayer()
    if player and player:isa("Alien") then
    
        local tierTwoTech = GetAlienTierTwoFor(lifeFormTechId)
        if tierTwoTech then
            table.insert(abilityIds, tierTwoTech)
        end
        
        local tierThreeTech = GetAlienTierThreeFor(lifeFormTechId)
        if tierThreeTech then
            table.insert(abilityIds, tierThreeTech)
        end
        
        
    
    end
    
    return abilityIds

end


local function GetUnpurchasedTechIds(techId)

    // get All ups for the aliens
    //TODO : delete purchased ups
    local allUps = GetAllUpgrades("Allien") 
    local techUps = GetUpgradesOfType(allUps, kCombatUpgradeTypes.Tech)
    local addOnUpgrades = {}   
    local player = Client.GetLocalPlayer()
    
    for i, upgrade in ipairs(techUps) do
        table.insert(addOnUpgrades, upgrade:GetTechId())
    end
        
    return addOnUpgrades
    
end

// iconx, icony, name, tooltip, research, cost. Need to change that to change the costs
function CombatAlienBuy_GetUnpurchasedUpgradeInfoArray(techIdTable)

    local t = {}
    
    local player = Client.GetLocalPlayer()
    
    if player then
    
        for index, techId in ipairs(techIdTable) do
        
            if not player:GetIsUpgradeForbidden(techId) then
        
                local iconX, iconY = GetMaterialXYOffset(techId, false)
                
                if iconX and iconY then

                    local techTree = GetTechTree(player:GetTeamNumber())
                    local upgradeName = GetDisplayNameForTechId(techId, string.format("<name not found - %s>", EnumToString(kTechId, techId)))
                    local upgrade = GetUpgradeFromTechId(techId)
                    
                    table.insert(t, iconX)
                    table.insert(t, iconY)                    
                    table.insert(t, upgradeName)                    
                    table.insert(t, GetTooltipInfoText(techId))                 
                    table.insert(t, GetTechTree():GetResearchProgressForNode(techId))
                    // cost
                    table.insert(t, upgrade:GetLevels()) 
                    table.insert(t, techId)
                    if techTree then
                        table.insert(t, techTree:GetIsTechAvailable(techId))
                    else
                        table.insert(t, false)
                    end
                end
            
            end
            
        end
    
    end
    
    return t
    
end


// return the unpurchased ups from the UpsList
function CombatAlienBuy_GetUnpurchasedUpgrades(idx)
    if idx == nil then
        Print("AlienBuy_GetUnpurchasedUpgrades(nil) called")
        return {}
    end
    
    return CombatAlienBuy_GetUnpurchasedUpgradeInfoArray(GetUnpurchasedTechIds(IndexToAlienTechId(idx)))   

end





