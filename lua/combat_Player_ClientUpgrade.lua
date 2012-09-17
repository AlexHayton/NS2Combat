//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Player_SharedUpgrade.lua

// helper functions for the buy Menu

function Player:GotRequirements(upgrade)
    
    if upgrade then
        local requirements = upgrade:GetRequirements()

        // does this up needs other ups??
        if requirements then
            requiredUpgrade = GetUpgradeFromId(requirements)    
            if (self.combatUpgrades and table.maxn(self.combatUpgrades) > 0) then
                for i, id in ipairs(self.combatUpgrades) do
                    if (tonumber(id) == requiredUpgrade:GetId()) then
                        return true
                    end  
                end  
            else
            
                return false
                
            end 
        else
            return true
        end
    end
    return false
end

function Player:GotItemAlready(upgrade)

    if upgrade then 
        if (self.combatUpgrades and table.maxn(self.combatUpgrades) > 0) then
            for i, id in ipairs(self.combatUpgrades) do
                if (tonumber(id) == upgrade:GetId()) then
                    return true
                end  
            end  
        else        
            return false            
        end 
    end
    return false
    
end

function Player:GetUpgrades()

    local upgrades = {}
    local deleteIDs = {}
    
    if (self.combatUpgrades and table.maxn(self.combatUpgrades) > 0) then    
        for i, id in ipairs(self.combatUpgrades) do
            local upgrade = GetUpgradeFromId(tonumber(id))
            local techId = upgrade:GetTechId()
            table.insert(upgrades,  techId)  

            if techId == kTechId.Weapons2 then
                table.insert(deleteIDs, kTechId.Weapons1)
            elseif techId == kTechId.Weapons3 then
                table.insert(deleteIDs, kTechId.Weapons2)
            elseif techId == kTechId.Armor2 then
                table.insert(deleteIDs, kTechId.Armor1)                
            elseif techId == kTechId.Armor3 then                
                table.insert(deleteIDs, kTechId.Armor2)
            end   
            
        end   
 
        if (table.maxn(deleteIDs) > 0) and (table.maxn(upgrades) > 0) then
            // sort upgrades, if we got wpn2, delete wpn1 again etc..
            for i, deleteId in ipairs(deleteIDs) do
                for j, techId in ipairs(upgrades) do
                    if techId == deleteId then
                        table.remove(upgrades, j)
                        break
                    end
                end
            end
            
        end 
     
    end
    
    return upgrades

end


// sends the buy command to the console
function Player:Combat_PurchaseItemAndUpgrades(textCodes)

    local buyString = ""
    
    if type(textCodes) == "table" then    
        for i, textCode in ipairs(textCodes) do
            buyString = (buyString  .. textCode .. " ")
        end        
    else
        buyString = textCodes
    end
    

    Shared.ConsoleCommand("/buy " .. buyString)

end



